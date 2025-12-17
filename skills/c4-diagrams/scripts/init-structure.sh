#!/usr/bin/env bash

################################################################################
# init-structure.sh - Initialize C4 Diagram Directory Structure
#
# Purpose:
#   Creates the doc/diagrams/ directory structure needed for organizing C4
#   architecture diagrams by type (context, container, component, sequence).
#
# Usage:
#   bash init-structure.sh
#
# Behavior:
#   - Creates doc/diagrams/ at project root if it doesn't exist
#   - Creates subdirectories for each diagram type
#   - Idempotent: safe to run multiple times
#   - Reports what was created or verified
#
# Exit Codes:
#   0 - Success (structure exists or was created)
#   1 - General error
#   2 - Permission error
#   3 - Directory creation failure
#
# Requirements:
#   - Bash 3.2+ (widely available on Linux, macOS, WSL)
#   - Write permissions in current working directory
#
# Language Choice Rationale:
#   Bash was chosen for minimal dependencies - all commands used (mkdir, test,
#   echo) are standard on Unix-like systems without requiring additional
#   installation.
################################################################################

# Enable strict error handling
# -e: Exit on error
# -u: Exit on undefined variable
# -o pipefail: Exit on pipe failure
set -euo pipefail

# Define target directories
BASE_DIR="doc/diagrams"
SUBDIRS=("context" "container" "component" "sequence")

# Color codes for output (optional, degrades gracefully)
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

################################################################################
# Function: check_permissions
# Checks if we have write permissions in the current directory
################################################################################
check_permissions() {
    if [ ! -w "." ]; then
        echo -e "${RED}ERROR: No write permission in current directory${NC}" >&2
        echo "Please navigate to a directory where you have write permissions" >&2
        exit 2
    fi
}

################################################################################
# Function: create_directory_structure
# Creates the base directory and all subdirectories
################################################################################
create_directory_structure() {
    local created=false
    local errors=()

    # Create base directory if it doesn't exist
    if [ ! -d "$BASE_DIR" ]; then
        if mkdir -p "$BASE_DIR" 2>/dev/null; then
            echo -e "${GREEN}✓${NC} Created base directory: $BASE_DIR/"
            created=true
        else
            errors+=("Failed to create base directory: $BASE_DIR/")
        fi
    fi

    # Create subdirectories
    for subdir in "${SUBDIRS[@]}"; do
        local full_path="$BASE_DIR/$subdir"
        if [ ! -d "$full_path" ]; then
            if mkdir -p "$full_path" 2>/dev/null; then
                echo -e "${GREEN}✓${NC} Created subdirectory: $full_path/"
                created=true
            else
                errors+=("Failed to create subdirectory: $full_path/")
            fi
        fi
    done

    # Report any errors
    if [ ${#errors[@]} -gt 0 ]; then
        echo -e "${RED}ERROR: Some directories could not be created:${NC}" >&2
        for error in "${errors[@]}"; do
            echo "  - $error" >&2
        done
        exit 3
    fi

    # Report success
    if [ "$created" = true ]; then
        echo -e "${GREEN}✓ Successfully created diagram directory structure${NC}"
    fi
}

################################################################################
# Function: verify_structure
# Verifies that all required directories exist
################################################################################
verify_structure() {
    local all_exist=true

    # Check base directory
    if [ ! -d "$BASE_DIR" ]; then
        echo -e "${RED}ERROR: Base directory does not exist: $BASE_DIR/${NC}" >&2
        all_exist=false
    fi

    # Check subdirectories
    for subdir in "${SUBDIRS[@]}"; do
        local full_path="$BASE_DIR/$subdir"
        if [ ! -d "$full_path" ]; then
            echo -e "${RED}ERROR: Subdirectory does not exist: $full_path/${NC}" >&2
            all_exist=false
        fi
    done

    if [ "$all_exist" = false ]; then
        exit 3
    fi
}

################################################################################
# Function: report_existing_structure
# Reports that the directory structure already exists
################################################################################
report_existing_structure() {
    echo -e "${GREEN}✓ Directory structure already exists at $BASE_DIR/${NC}"
    echo "  Structure verified:"
    for subdir in "${SUBDIRS[@]}"; do
        echo "    - $BASE_DIR/$subdir/"
    done
}

################################################################################
# Main execution
################################################################################
main() {
    # Check permissions before attempting any operations
    check_permissions

    # Check if structure already exists
    local structure_exists=true
    if [ ! -d "$BASE_DIR" ]; then
        structure_exists=false
    else
        for subdir in "${SUBDIRS[@]}"; do
            if [ ! -d "$BASE_DIR/$subdir" ]; then
                structure_exists=false
                break
            fi
        done
    fi

    # Create or report existing structure
    if [ "$structure_exists" = true ]; then
        report_existing_structure
    else
        create_directory_structure
        verify_structure
    fi

    exit 0
}

# Run main function
main
