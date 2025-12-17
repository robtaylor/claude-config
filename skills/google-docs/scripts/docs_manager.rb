#!/usr/bin/env ruby
# frozen_string_literal: true

require 'google/apis/docs_v1'
require 'google/apis/drive_v3'
require 'google/apis/sheets_v4'
require 'google/apis/calendar_v3'
require 'google/apis/people_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'json'

# Google Docs Manager - Google CLI Integration for Document Operations
# Version: 1.0.0
# Scopes: Docs, Drive, Calendar, Contacts, Gmail
class DocsManager
  # OAuth scopes - ALL Google skills share these
  DOCS_SCOPE = Google::Apis::DocsV1::AUTH_DOCUMENTS
  DRIVE_SCOPE = Google::Apis::DriveV3::AUTH_DRIVE
  SHEETS_SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS
  CALENDAR_SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR
  CONTACTS_SCOPE = Google::Apis::PeopleV1::AUTH_CONTACTS
  GMAIL_SCOPE = 'https://www.googleapis.com/auth/gmail.modify'

  CREDENTIALS_PATH = File.join(Dir.home, '.claude', '.google', 'client_secret.json')
  TOKEN_PATH = File.join(Dir.home, '.claude', '.google', 'token.json')

  # Exit codes
  EXIT_SUCCESS = 0
  EXIT_OPERATION_FAILED = 1
  EXIT_AUTH_ERROR = 2
  EXIT_API_ERROR = 3
  EXIT_INVALID_ARGS = 4

  def initialize
    @docs_service = Google::Apis::DocsV1::DocsService.new
    @docs_service.client_options.application_name = 'Claude Docs Skill'
    @docs_service.authorization = authorize

    @drive_service = Google::Apis::DriveV3::DriveService.new
    @drive_service.client_options.application_name = 'Claude Docs Skill'
    @drive_service.authorization = authorize
  end

  # Authorize using shared OAuth token with all scopes
  def authorize
    client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)

    # Include ALL scopes for shared token
    authorizer = Google::Auth::UserAuthorizer.new(
      client_id,
      [DRIVE_SCOPE, SHEETS_SCOPE, DOCS_SCOPE, CALENDAR_SCOPE, CONTACTS_SCOPE, GMAIL_SCOPE],
      token_store
    )

    user_id = 'default'
    credentials = authorizer.get_credentials(user_id)

    if credentials.nil?
      url = authorizer.get_authorization_url(base_url: 'urn:ietf:wg:oauth:2.0:oob')
      output_json({
        status: 'error',
        error_code: 'AUTH_REQUIRED',
        message: 'Authorization required. Please visit the URL and enter the code.',
        auth_url: url,
        instructions: [
          '1. Visit the authorization URL',
          '2. Grant access to Google Docs, Drive, Sheets, Calendar, Contacts, and Gmail',
          '3. Copy the authorization code',
          "4. Run: ruby #{__FILE__} auth <code>"
        ]
      })
      exit EXIT_AUTH_ERROR
    end

    # Auto-refresh expired tokens
    credentials.refresh! if credentials.expired?
    credentials
  end

  # Complete OAuth authorization with code
  def complete_auth(code)
    client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)

    authorizer = Google::Auth::UserAuthorizer.new(
      client_id,
      [DRIVE_SCOPE, SHEETS_SCOPE, DOCS_SCOPE, CALENDAR_SCOPE, CONTACTS_SCOPE, GMAIL_SCOPE],
      token_store
    )

    user_id = 'default'
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id,
      code: code,
      base_url: 'urn:ietf:wg:oauth:2.0:oob'
    )

    output_json({
      status: 'success',
      message: 'Authorization complete. Token stored successfully.',
      token_path: TOKEN_PATH,
      scopes: [DOCS_SCOPE, DRIVE_SCOPE, SHEETS_SCOPE, CALENDAR_SCOPE, CONTACTS_SCOPE, GMAIL_SCOPE]
    })
  rescue StandardError => e
    output_json({
      status: 'error',
      error_code: 'AUTH_FAILED',
      message: "Authorization failed: #{e.message}"
    })
    exit EXIT_AUTH_ERROR
  end

  # Read document content
  def read_document(document_id:)
    document = @docs_service.get_document(document_id)

    # Extract text content
    content = extract_text_content(document.body.content)

    output_json({
      status: 'success',
      operation: 'read',
      document_id: document.document_id,
      title: document.title,
      content: content,
      revision_id: document.revision_id
    })
  rescue Google::Apis::Error => e
    output_json({
      status: 'error',
      error_code: 'API_ERROR',
      operation: 'read',
      message: "Google Docs API error: #{e.message}",
      details: e.body
    })
    exit EXIT_API_ERROR
  rescue StandardError => e
    output_json({
      status: 'error',
      error_code: 'READ_FAILED',
      operation: 'read',
      message: "Failed to read document: #{e.message}"
    })
    exit EXIT_OPERATION_FAILED
  end

  # Get document structure (headings, sections)
  def get_structure(document_id:)
    document = @docs_service.get_document(document_id)

    structure = []
    document.body.content.each do |element|
      next unless element.paragraph

      paragraph = element.paragraph
      next unless paragraph.paragraph_style && paragraph.paragraph_style.named_style_type

      style = paragraph.paragraph_style.named_style_type
      if style.start_with?('HEADING_')
        level = style.split('_').last.to_i
        text = extract_paragraph_text(paragraph)
        structure << {
          level: level,
          text: text,
          start_index: element.start_index,
          end_index: element.end_index
        }
      end
    end

    output_json({
      status: 'success',
      operation: 'structure',
      document_id: document.document_id,
      title: document.title,
      structure: structure
    })
  rescue Google::Apis::Error => e
    output_json({
      status: 'error',
      error_code: 'API_ERROR',
      operation: 'structure',
      message: "Google Docs API error: #{e.message}"
    })
    exit EXIT_API_ERROR
  rescue StandardError => e
    output_json({
      status: 'error',
      error_code: 'STRUCTURE_FAILED',
      operation: 'structure',
      message: "Failed to get document structure: #{e.message}"
    })
    exit EXIT_OPERATION_FAILED
  end

  # Insert text at specific index
  def insert_text(document_id:, text:, index: 1)
    requests = [
      {
        insert_text: {
          location: { index: index },
          text: text
        }
      }
    ]

    result = @docs_service.batch_update_document(
      document_id,
      Google::Apis::DocsV1::BatchUpdateDocumentRequest.new(requests: requests)
    )

    output_json({
      status: 'success',
      operation: 'insert',
      document_id: document_id,
      inserted_at: index,
      text_length: text.length,
      revision_id: result.document_id
    })
  rescue Google::Apis::Error => e
    output_json({
      status: 'error',
      error_code: 'API_ERROR',
      operation: 'insert',
      message: "Google Docs API error: #{e.message}"
    })
    exit EXIT_API_ERROR
  rescue StandardError => e
    output_json({
      status: 'error',
      error_code: 'INSERT_FAILED',
      operation: 'insert',
      message: "Failed to insert text: #{e.message}"
    })
    exit EXIT_OPERATION_FAILED
  end

  # Append text to end of document
  def append_text(document_id:, text:)
    document = @docs_service.get_document(document_id)
    end_index = document.body.content.last.end_index - 1

    requests = [
      {
        insert_text: {
          location: { index: end_index },
          text: text
        }
      }
    ]

    result = @docs_service.batch_update_document(
      document_id,
      Google::Apis::DocsV1::BatchUpdateDocumentRequest.new(requests: requests)
    )

    output_json({
      status: 'success',
      operation: 'append',
      document_id: document_id,
      appended_at: end_index,
      text_length: text.length,
      revision_id: result.document_id
    })
  rescue Google::Apis::Error => e
    output_json({
      status: 'error',
      error_code: 'API_ERROR',
      operation: 'append',
      message: "Google Docs API error: #{e.message}"
    })
    exit EXIT_API_ERROR
  rescue StandardError => e
    output_json({
      status: 'error',
      error_code: 'APPEND_FAILED',
      operation: 'append',
      message: "Failed to append text: #{e.message}"
    })
    exit EXIT_OPERATION_FAILED
  end

  # Replace text (find and replace)
  def replace_text(document_id:, find:, replace:, match_case: false)
    requests = [
      {
        replace_all_text: {
          contains_text: {
            text: find,
            match_case: match_case
          },
          replace_text: replace
        }
      }
    ]

    result = @docs_service.batch_update_document(
      document_id,
      Google::Apis::DocsV1::BatchUpdateDocumentRequest.new(requests: requests)
    )

    replacements = result.replies.first.replace_all_text.occurrences_changed || 0

    output_json({
      status: 'success',
      operation: 'replace',
      document_id: document_id,
      find: find,
      replace: replace,
      occurrences: replacements
    })
  rescue Google::Apis::Error => e
    output_json({
      status: 'error',
      error_code: 'API_ERROR',
      operation: 'replace',
      message: "Google Docs API error: #{e.message}"
    })
    exit EXIT_API_ERROR
  rescue StandardError => e
    output_json({
      status: 'error',
      error_code: 'REPLACE_FAILED',
      operation: 'replace',
      message: "Failed to replace text: #{e.message}"
    })
    exit EXIT_OPERATION_FAILED
  end

  # Format text (bold, italic, underline)
  def format_text(document_id:, start_index:, end_index:, bold: nil, italic: nil, underline: nil)
    text_style = {}
    text_style[:bold] = bold unless bold.nil?
    text_style[:italic] = italic unless italic.nil?
    text_style[:underline] = underline unless underline.nil?

    requests = [
      {
        update_text_style: {
          range: {
            start_index: start_index,
            end_index: end_index
          },
          text_style: text_style,
          fields: text_style.keys.join(',')
        }
      }
    ]

    result = @docs_service.batch_update_document(
      document_id,
      Google::Apis::DocsV1::BatchUpdateDocumentRequest.new(requests: requests)
    )

    output_json({
      status: 'success',
      operation: 'format',
      document_id: document_id,
      range: { start: start_index, end: end_index },
      formatting: text_style
    })
  rescue Google::Apis::Error => e
    output_json({
      status: 'error',
      error_code: 'API_ERROR',
      operation: 'format',
      message: "Google Docs API error: #{e.message}"
    })
    exit EXIT_API_ERROR
  rescue StandardError => e
    output_json({
      status: 'error',
      error_code: 'FORMAT_FAILED',
      operation: 'format',
      message: "Failed to format text: #{e.message}"
    })
    exit EXIT_OPERATION_FAILED
  end

  # Insert page break
  def insert_page_break(document_id:, index:)
    requests = [
      {
        insert_page_break: {
          location: { index: index }
        }
      }
    ]

    result = @docs_service.batch_update_document(
      document_id,
      Google::Apis::DocsV1::BatchUpdateDocumentRequest.new(requests: requests)
    )

    output_json({
      status: 'success',
      operation: 'page_break',
      document_id: document_id,
      inserted_at: index
    })
  rescue Google::Apis::Error => e
    output_json({
      status: 'error',
      error_code: 'API_ERROR',
      operation: 'page_break',
      message: "Google Docs API error: #{e.message}"
    })
    exit EXIT_API_ERROR
  rescue StandardError => e
    output_json({
      status: 'error',
      error_code: 'PAGE_BREAK_FAILED',
      operation: 'page_break',
      message: "Failed to insert page break: #{e.message}"
    })
    exit EXIT_OPERATION_FAILED
  end

  # Create new document
  def create_document(title:, content: nil)
    document = Google::Apis::DocsV1::Document.new(title: title)
    result = @docs_service.create_document(document)

    # Add initial content if provided
    if content
      requests = [
        {
          insert_text: {
            location: { index: 1 },
            text: content
          }
        }
      ]
      @docs_service.batch_update_document(
        result.document_id,
        Google::Apis::DocsV1::BatchUpdateDocumentRequest.new(requests: requests)
      )
    end

    output_json({
      status: 'success',
      operation: 'create',
      document_id: result.document_id,
      title: result.title,
      revision_id: result.revision_id
    })
  rescue Google::Apis::Error => e
    output_json({
      status: 'error',
      error_code: 'API_ERROR',
      operation: 'create',
      message: "Google Docs API error: #{e.message}"
    })
    exit EXIT_API_ERROR
  rescue StandardError => e
    output_json({
      status: 'error',
      error_code: 'CREATE_FAILED',
      operation: 'create',
      message: "Failed to create document: #{e.message}"
    })
    exit EXIT_OPERATION_FAILED
  end

  # Delete content from document (clear range)
  def delete_content(document_id:, start_index:, end_index:)
    requests = [
      {
        delete_content_range: {
          range: {
            start_index: start_index,
            end_index: end_index
          }
        }
      }
    ]

    result = @docs_service.batch_update_document(
      document_id,
      Google::Apis::DocsV1::BatchUpdateDocumentRequest.new(requests: requests)
    )

    output_json({
      status: 'success',
      operation: 'delete',
      document_id: document_id,
      deleted_range: { start: start_index, end: end_index }
    })
  rescue Google::Apis::Error => e
    output_json({
      status: 'error',
      error_code: 'API_ERROR',
      operation: 'delete',
      message: "Google Docs API error: #{e.message}"
    })
    exit EXIT_API_ERROR
  rescue StandardError => e
    output_json({
      status: 'error',
      error_code: 'DELETE_FAILED',
      operation: 'delete',
      message: "Failed to delete content: #{e.message}"
    })
    exit EXIT_OPERATION_FAILED
  end

  private

  # Extract text content from document body
  def extract_text_content(content_elements)
    text = []
    content_elements.each do |element|
      if element.paragraph
        text << extract_paragraph_text(element.paragraph)
      elsif element.table
        text << extract_table_text(element.table)
      end
    end
    text.join("\n")
  end

  # Extract text from paragraph
  def extract_paragraph_text(paragraph)
    return '' unless paragraph.elements

    paragraph.elements.map do |element|
      element.text_run&.content || ''
    end.join
  end

  # Extract text from table
  def extract_table_text(table)
    rows = []
    table.table_rows.each do |row|
      cells = row.table_cells.map do |cell|
        extract_text_content(cell.content)
      end
      rows << cells.join(' | ')
    end
    rows.join("\n")
  end

  # Output JSON to stdout
  def output_json(data)
    puts JSON.pretty_generate(data)
  end
end

# CLI Interface
def usage
  puts <<~USAGE
    Google Docs Manager - Document Operations CLI
    Version: 1.0.0

    Usage:
      #{File.basename($PROGRAM_NAME)} <command> [options]

    Commands:
      auth <code>              Complete OAuth authorization with code
      read <document_id>       Read document content
      structure <document_id>  Get document structure (headings)
      insert                   Insert text at specific index (JSON via stdin)
      append                   Append text to end of document (JSON via stdin)
      replace                  Find and replace text (JSON via stdin)
      format                   Format text (bold, italic, underline) (JSON via stdin)
      page-break               Insert page break (JSON via stdin)
      create                   Create new document (JSON via stdin)
      delete                   Delete content range (JSON via stdin)

    JSON Input Formats:

      Insert:
        {
          "document_id": "abc123",
          "text": "Text to insert",
          "index": 1                    # Optional, default 1
        }

      Append:
        {
          "document_id": "abc123",
          "text": "Text to append"
        }

      Replace:
        {
          "document_id": "abc123",
          "find": "old text",
          "replace": "new text",
          "match_case": false           # Optional, default false
        }

      Format:
        {
          "document_id": "abc123",
          "start_index": 1,
          "end_index": 10,
          "bold": true,                 # Optional
          "italic": true,               # Optional
          "underline": true             # Optional
        }

      Page Break:
        {
          "document_id": "abc123",
          "index": 100
        }

      Create:
        {
          "title": "New Document",
          "content": "Initial content" # Optional
        }

      Delete:
        {
          "document_id": "abc123",
          "start_index": 1,
          "end_index": 10
        }

    Examples:
      # Complete OAuth authorization
      #{File.basename($PROGRAM_NAME)} auth YOUR_AUTH_CODE

      # Read document
      #{File.basename($PROGRAM_NAME)} read 1abc-xyz-123

      # Get document structure
      #{File.basename($PROGRAM_NAME)} structure 1abc-xyz-123

      # Insert text
      echo '{"document_id":"abc123","text":"Hello World","index":1}' | #{File.basename($PROGRAM_NAME)} insert

      # Append text
      echo '{"document_id":"abc123","text":"\\n\\nAppended text"}' | #{File.basename($PROGRAM_NAME)} append

      # Replace text
      echo '{"document_id":"abc123","find":"old","replace":"new"}' | #{File.basename($PROGRAM_NAME)} replace

      # Format text
      echo '{"document_id":"abc123","start_index":1,"end_index":10,"bold":true}' | #{File.basename($PROGRAM_NAME)} format

      # Create new document
      echo '{"title":"My Document","content":"Hello World"}' | #{File.basename($PROGRAM_NAME)} create

    Exit Codes:
      0 - Success
      1 - Operation failed
      2 - Authentication error
      3 - API error
      4 - Invalid arguments
  USAGE
end

# Main execution
if __FILE__ == $PROGRAM_NAME
  if ARGV.empty?
    usage
    exit DocsManager::EXIT_INVALID_ARGS
  end

  command = ARGV[0]

  # Handle auth command separately (doesn't require initialized service)
  if command == 'auth'
    if ARGV.length < 2
      puts JSON.pretty_generate({
        status: 'error',
        error_code: 'MISSING_CODE',
        message: 'Authorization code required',
        usage: "#{File.basename($PROGRAM_NAME)} auth <code>"
      })
      exit DocsManager::EXIT_INVALID_ARGS
    end

    # Create temporary manager just for auth completion
    temp_manager = DocsManager.allocate
    temp_manager.complete_auth(ARGV[1])
    exit DocsManager::EXIT_SUCCESS
  end

  # For all other commands, create manager (which requires authorization)
  manager = DocsManager.new

  case command

  when 'read'
    if ARGV.length < 2
      puts JSON.pretty_generate({
        status: 'error',
        error_code: 'MISSING_DOCUMENT_ID',
        message: 'Document ID required'
      })
      exit DocsManager::EXIT_INVALID_ARGS
    end

    manager.read_document(document_id: ARGV[1])

  when 'structure'
    if ARGV.length < 2
      puts JSON.pretty_generate({
        status: 'error',
        error_code: 'MISSING_DOCUMENT_ID',
        message: 'Document ID required'
      })
      exit DocsManager::EXIT_INVALID_ARGS
    end

    manager.get_structure(document_id: ARGV[1])

  when 'insert'
    input = JSON.parse(STDIN.read, symbolize_names: true)

    unless input[:document_id] && input[:text]
      puts JSON.pretty_generate({
        status: 'error',
        error_code: 'MISSING_REQUIRED_FIELDS',
        message: 'Required fields: document_id, text'
      })
      exit DocsManager::EXIT_INVALID_ARGS
    end

    manager.insert_text(
      document_id: input[:document_id],
      text: input[:text],
      index: input[:index] || 1
    )

  when 'append'
    input = JSON.parse(STDIN.read, symbolize_names: true)

    unless input[:document_id] && input[:text]
      puts JSON.pretty_generate({
        status: 'error',
        error_code: 'MISSING_REQUIRED_FIELDS',
        message: 'Required fields: document_id, text'
      })
      exit DocsManager::EXIT_INVALID_ARGS
    end

    manager.append_text(
      document_id: input[:document_id],
      text: input[:text]
    )

  when 'replace'
    input = JSON.parse(STDIN.read, symbolize_names: true)

    unless input[:document_id] && input[:find] && input[:replace]
      puts JSON.pretty_generate({
        status: 'error',
        error_code: 'MISSING_REQUIRED_FIELDS',
        message: 'Required fields: document_id, find, replace'
      })
      exit DocsManager::EXIT_INVALID_ARGS
    end

    manager.replace_text(
      document_id: input[:document_id],
      find: input[:find],
      replace: input[:replace],
      match_case: input[:match_case] || false
    )

  when 'format'
    input = JSON.parse(STDIN.read, symbolize_names: true)

    unless input[:document_id] && input[:start_index] && input[:end_index]
      puts JSON.pretty_generate({
        status: 'error',
        error_code: 'MISSING_REQUIRED_FIELDS',
        message: 'Required fields: document_id, start_index, end_index'
      })
      exit DocsManager::EXIT_INVALID_ARGS
    end

    manager.format_text(
      document_id: input[:document_id],
      start_index: input[:start_index],
      end_index: input[:end_index],
      bold: input[:bold],
      italic: input[:italic],
      underline: input[:underline]
    )

  when 'page-break'
    input = JSON.parse(STDIN.read, symbolize_names: true)

    unless input[:document_id] && input[:index]
      puts JSON.pretty_generate({
        status: 'error',
        error_code: 'MISSING_REQUIRED_FIELDS',
        message: 'Required fields: document_id, index'
      })
      exit DocsManager::EXIT_INVALID_ARGS
    end

    manager.insert_page_break(
      document_id: input[:document_id],
      index: input[:index]
    )

  when 'create'
    input = JSON.parse(STDIN.read, symbolize_names: true)

    unless input[:title]
      puts JSON.pretty_generate({
        status: 'error',
        error_code: 'MISSING_REQUIRED_FIELDS',
        message: 'Required field: title'
      })
      exit DocsManager::EXIT_INVALID_ARGS
    end

    manager.create_document(
      title: input[:title],
      content: input[:content]
    )

  when 'delete'
    input = JSON.parse(STDIN.read, symbolize_names: true)

    unless input[:document_id] && input[:start_index] && input[:end_index]
      puts JSON.pretty_generate({
        status: 'error',
        error_code: 'MISSING_REQUIRED_FIELDS',
        message: 'Required fields: document_id, start_index, end_index'
      })
      exit DocsManager::EXIT_INVALID_ARGS
    end

    manager.delete_content(
      document_id: input[:document_id],
      start_index: input[:start_index],
      end_index: input[:end_index]
    )

  else
    puts JSON.pretty_generate({
      status: 'error',
      error_code: 'INVALID_COMMAND',
      message: "Unknown command: #{command}",
      valid_commands: ['auth', 'read', 'structure', 'insert', 'append', 'replace', 'format', 'page-break', 'create', 'delete']
    })
    usage
    exit DocsManager::EXIT_INVALID_ARGS
  end

  exit DocsManager::EXIT_SUCCESS
end
