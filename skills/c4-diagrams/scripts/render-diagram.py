#!/usr/bin/env python3
"""
PlantUML Diagram Renderer

Generates PNG diagrams from PlantUML (.puml) files by calling the public PlantUML server.
Uses only Python standard library for maximum compatibility and minimal setup requirements.

Usage:
    python3 render-diagram.py <path-to-diagram.puml>
    python3 render-diagram.py doc/diagrams/context/system.puml

Exit Codes:
    0 - Success
    1 - File error (not found, permission denied, etc.)
    2 - Network error (connection issues, timeout)
    3 - Server error (PlantUML server issues, invalid syntax)

Example:
    $ python3 render-diagram.py doc/diagrams/context/my-system.puml
    Successfully generated diagram: doc/diagrams/context/my-system.png
"""

import sys
import os
import time
import zlib
import base64
import argparse
from urllib import request, error
from typing import Tuple, Dict, Optional

# Retry up to 3 times - balances reliability with speed for typical server response times
MAX_RETRIES = 3

# Wait 1s, then 2s, then 4s - exponential backoff prevents overwhelming server
RETRY_DELAYS = [1, 2, 4]

# 15 second timeout per request - prevents hanging on slow/unresponsive servers
REQUEST_TIMEOUT = 15


def encode_plantuml(puml_text: str) -> str:
    """
    Encodes PlantUML text using the PlantUML server's encoding format.

    PlantUML requires: DEFLATE compression → Base64 encoding → Alphabet translation

    The PlantUML server uses a modified base64 alphabet:
    Standard: ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/
    PlantUML: 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_

    Args:
        puml_text: Raw PlantUML diagram text

    Returns:
        Encoded string suitable for PlantUML server URLs

    Example:
        >>> encode_plantuml("@startuml\\nBob->Alice : hello\\n@enduml")
        'SyfFKj2rKt3CoKnELR1Io4ZDoSa70000'
    """
    # Step 1: Compress using DEFLATE (same as zlib without header/trailer)
    compressed = zlib.compress(puml_text.encode('utf-8'))[2:-4]

    # Step 2: Encode to standard base64
    encoded = base64.b64encode(compressed).decode('ascii')

    # Step 3: Translate to PlantUML's modified alphabet
    # Standard base64 uses: A-Za-z0-9+/
    # PlantUML uses: 0-9A-Za-z-_
    translation_table = str.maketrans(
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/',
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_'
    )
    plantuml_encoded = encoded.translate(translation_table)

    return plantuml_encoded


def get_png_path(puml_path: str) -> str:
    """
    Derives PNG file path from PUML file path.

    Replaces .puml extension with .png, preserving the directory.

    Args:
        puml_path: Path to .puml file

    Returns:
        Path to .png file in same directory

    Example:
        >>> get_png_path("doc/diagrams/context/system.puml")
        'doc/diagrams/context/system.png'
    """
    if puml_path.endswith('.puml'):
        return puml_path[:-5] + '.png'
    else:
        # Handle edge case: no .puml extension
        return puml_path + '.png'


def fetch_diagram_png(encoded: str, timeout: int = REQUEST_TIMEOUT,
                      max_retries: int = MAX_RETRIES, verbose: bool = False) -> bytes:
    """
    Fetches PNG diagram from PlantUML server with retry logic.

    Implements exponential backoff retry strategy for transient failures.

    Args:
        encoded: PlantUML-encoded diagram string
        timeout: Request timeout in seconds
        max_retries: Maximum number of retry attempts
        verbose: Enable verbose logging

    Returns:
        Raw PNG image bytes

    Raises:
        Exception: On permanent failures or after exhausting retries
    """
    url = f"https://www.plantuml.com/plantuml/png/{encoded}"
    last_error = None

    for attempt in range(max_retries + 1):
        try:
            # Log retry attempts
            if attempt > 0:
                if verbose:
                    print(f"Retry attempt {attempt}/{max_retries}...", file=sys.stderr)

            # Make HTTP GET request
            if verbose:
                print(f"Requesting diagram from PlantUML server...", file=sys.stderr)

            with request.urlopen(url, timeout=timeout) as response:
                png_data = response.read()

                if verbose:
                    print(f"Received {len(png_data)} bytes from server", file=sys.stderr)

                return png_data

        except error.HTTPError as e:
            last_error = e
            status = e.code

            # Don't retry on permanent client errors
            if status in (401, 403):
                raise Exception(f"HTTP {status}: Access denied (permanent error)")

            # Handle specific error codes
            if status == 400:
                error_msg = f"HTTP 400: Invalid PlantUML syntax (check your diagram)"
            elif status == 429:
                error_msg = f"HTTP 429: Rate limited by server"
            elif status >= 500:
                error_msg = f"HTTP {status}: PlantUML server error"
            else:
                error_msg = f"HTTP {status}: Server error"

            # If last attempt, raise the error
            if attempt >= max_retries:
                raise Exception(f"{error_msg} (after {max_retries + 1} attempts)")

            # Otherwise, log and retry
            print(error_msg, file=sys.stderr)

        except error.URLError as e:
            last_error = e
            error_msg = f"Network error: {str(e.reason)}"

            if attempt >= max_retries:
                raise Exception(f"{error_msg} (after {max_retries + 1} attempts)")

            print(error_msg, file=sys.stderr)

        except TimeoutError:
            last_error = TimeoutError(f"Request timed out after {timeout} seconds")

            if attempt >= max_retries:
                raise Exception(f"Request timeout (after {max_retries + 1} attempts)")

            print(f"Request timed out after {timeout}s", file=sys.stderr)

        # Calculate exponential backoff delay
        if attempt < max_retries:
            delay = RETRY_DELAYS[attempt] if attempt < len(RETRY_DELAYS) else RETRY_DELAYS[-1]
            if verbose:
                print(f"Waiting {delay}s before retry...", file=sys.stderr)
            time.sleep(delay)

    # Should never reach here, but handle it anyway
    raise last_error or Exception("Failed to fetch diagram after retries")


def generate_diagram(puml_path: str, verbose: bool = False,
                     max_retries: int = MAX_RETRIES,
                     timeout: int = REQUEST_TIMEOUT) -> Dict[str, any]:
    """
    Generates PNG diagram from PUML file.

    Main function that orchestrates the entire diagram generation process:
    1. Read PUML file
    2. Encode content
    3. Fetch PNG from server
    4. Save PNG to file

    Args:
        puml_path: Path to .puml file
        verbose: Enable verbose logging
        max_retries: Maximum number of retry attempts
        timeout: Request timeout in seconds

    Returns:
        Dictionary with success status, message, and png_path

    Raises:
        FileNotFoundError: If PUML file doesn't exist
        PermissionError: If cannot read PUML or write PNG
        Exception: On encoding or server errors
    """
    # Validate file exists
    if not os.path.exists(puml_path):
        raise FileNotFoundError(f"PUML file not found: {puml_path}")

    if not os.path.isfile(puml_path):
        raise FileNotFoundError(f"Path is not a file: {puml_path}")

    # Read PUML content
    if verbose:
        print(f"Reading PUML file: {puml_path}", file=sys.stderr)

    try:
        with open(puml_path, 'r', encoding='utf-8') as f:
            puml_content = f.read()
    except PermissionError:
        raise PermissionError(f"Cannot read file (permission denied): {puml_path}")

    # Check for empty file
    if not puml_content.strip():
        raise Exception(f"PUML file is empty: {puml_path}")

    if verbose:
        print(f"Read {len(puml_content)} bytes from PUML file", file=sys.stderr)

    # Encode PlantUML content
    if verbose:
        print("Encoding diagram...", file=sys.stderr)

    encoded = encode_plantuml(puml_content)

    if verbose:
        print(f"Encoded to {len(encoded)} characters", file=sys.stderr)

    # Fetch PNG from server
    png_data = fetch_diagram_png(encoded, timeout=timeout,
                                  max_retries=max_retries, verbose=verbose)

    # Determine output path
    png_path = get_png_path(puml_path)

    # Save PNG file
    if verbose:
        print(f"Saving PNG to: {png_path}", file=sys.stderr)

    try:
        with open(png_path, 'wb') as f:
            f.write(png_data)
    except PermissionError:
        raise PermissionError(f"Cannot write PNG file (permission denied): {png_path}")
    except Exception as e:
        raise Exception(f"Failed to write PNG file: {str(e)}")

    return {
        'success': True,
        'message': f'Successfully generated diagram: {png_path}',
        'png_path': png_path
    }


def main():
    """
    Main entry point for the script.

    Parses command-line arguments and orchestrates diagram generation.
    """
    parser = argparse.ArgumentParser(
        description='Generate PNG diagrams from PlantUML files using the public PlantUML server.',
        epilog='Example: python3 render-diagram.py doc/diagrams/context/system.puml'
    )

    parser.add_argument(
        'puml_file',
        help='Path to the .puml file to render'
    )

    parser.add_argument(
        '--max-retries',
        type=int,
        default=MAX_RETRIES,
        help=f'Maximum number of retry attempts (default: {MAX_RETRIES})'
    )

    parser.add_argument(
        '--timeout',
        type=int,
        default=REQUEST_TIMEOUT,
        help=f'Request timeout in seconds (default: {REQUEST_TIMEOUT})'
    )

    parser.add_argument(
        '-v', '--verbose',
        action='store_true',
        help='Enable verbose output'
    )

    args = parser.parse_args()

    try:
        result = generate_diagram(args.puml_file, verbose=args.verbose,
                                  max_retries=args.max_retries,
                                  timeout=args.timeout)
        print(result['message'])
        sys.exit(0)

    except FileNotFoundError as e:
        print(f"Error: {str(e)}", file=sys.stderr)
        sys.exit(1)

    except PermissionError as e:
        print(f"Error: {str(e)}", file=sys.stderr)
        sys.exit(1)

    except Exception as e:
        error_msg = str(e)

        # Categorize error for appropriate exit code
        if 'network' in error_msg.lower() or 'timeout' in error_msg.lower():
            print(f"Network Error: {error_msg}", file=sys.stderr)
            sys.exit(2)
        else:
            print(f"Error: {error_msg}", file=sys.stderr)
            sys.exit(3)


if __name__ == '__main__':
    main()
