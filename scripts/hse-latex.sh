#!/bin/bash

# hse-latex.sh — Unified LaTeX management script for HSE AMI Cheatsheets
# Project: HSE AMI Cheatsheets
# Author: werserk
# Version: 2.0
#
# This script provides a unified interface for all LaTeX operations:
# - Building documents
# - Cleaning temporary files
# - Style checking
# - Watching for changes
# - Project management

set -euo pipefail

# =============================================================================
# CONFIGURATION
# =============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/build"
STYLES_DIR="$PROJECT_ROOT/assets/styles"
CONFIG_FILE="$PROJECT_ROOT/project.yaml"

# LaTeX settings
LATEX_ENGINE="pdflatex"
LATEX_OPTIONS="-interaction=nonstopmode -halt-on-error -file-line-error"

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Print colored output
print_status() {
    local level=$1
    local message=$2
    case $level in
        "INFO")
            echo -e "${BLUE}ℹ️  INFO:${NC} $message"
            ;;
        "SUCCESS")
            echo -e "${GREEN}✅ SUCCESS:${NC} $message"
            ;;
        "WARNING")
            echo -e "${YELLOW}⚠️  WARNING:${NC} $message"
            ;;
        "ERROR")
            echo -e "${RED}❌ ERROR:${NC} $message"
            ;;
    esac
}

# Check if file exists
check_file() {
    local file=$1
    if [[ ! -f "$file" ]]; then
        print_status "ERROR" "File $file does not exist"
        exit 1
    fi
}

# Check if command exists
check_command() {
    local cmd=$1
    if ! command -v "$cmd" >/dev/null 2>&1; then
        print_status "ERROR" "Command $cmd not found. Please install it."
        exit 1
    fi
}

# Create build directory if it doesn't exist
ensure_build_dir() {
    mkdir -p "$BUILD_DIR"
}

# =============================================================================
# BUILD FUNCTIONS
# =============================================================================

# Build a single LaTeX file
build_file() {
    local file=$1
    local file_dir=$(dirname "$file")
    local file_name=$(basename "$file" .tex)
    local original_dir=$(pwd)

    print_status "INFO" "Building $file..."

    # Change to file directory
    if [[ "$file_dir" != "." ]]; then
        if [[ -d "$file_dir" ]]; then
            cd "$file_dir" || return 1
        else
            print_status "WARNING" "Directory $file_dir does not exist, skipping $file"
            return 1
        fi
    fi

    # Create a temporary build directory for this file
    local temp_build_dir="$BUILD_DIR/$(basename "$file_dir")_$file_name"
    mkdir -p "$temp_build_dir"

    # Build with latexmk (output to temp build directory)
    if latexmk -pdf -output-directory="$temp_build_dir" $LATEX_OPTIONS "$file_name.tex"; then
        # Copy PDF back to original location
        if [[ -f "$temp_build_dir/$file_name.pdf" ]]; then
            cp "$temp_build_dir/$file_name.pdf" "$file_name.pdf"
            print_status "SUCCESS" "Successfully built $file_name.pdf"
        else
            print_status "ERROR" "PDF file not found after build"
            # Return to original directory
            cd "$original_dir" || true
            return 1
        fi

        # Clean up temporary build directory
        rm -rf "$temp_build_dir"

        # Return to original directory
        cd "$original_dir" || true
        return 0
    else
        print_status "ERROR" "Failed to build $file_name.tex"
        # Clean up temporary build directory on failure
        rm -rf "$temp_build_dir"
        # Return to original directory
        cd "$original_dir" || true
        return 1
    fi
}

# Build all LaTeX files in project
build_all() {
    print_status "INFO" "Building all LaTeX documents..."

    local files_found=0
    local build_success=0
    local build_failed=0

    # Find all .tex files (excluding templates and topic files)
    while IFS= read -r -d '' file; do
        files_found=$((files_found + 1))
        # Remove ./ prefix if present
        file="${file#./}"
        if build_file "$file"; then
            build_success=$((build_success + 1))
        else
            build_failed=$((build_failed + 1))
        fi
    done < <(find . -name "*.tex" -not -path "./templates/*" -not -path "*/preparation/topics/*" -print0)

    print_status "INFO" "Build summary: $build_success successful, $build_failed failed out of $files_found files"

    if [[ $build_failed -gt 0 ]]; then
        exit 1
    fi
}

# =============================================================================
# CLEAN FUNCTIONS
# =============================================================================

# Clean temporary files
clean_files() {
    print_status "INFO" "Cleaning temporary files..."

    local cleaned=0

    # Clean common LaTeX temporary files (but keep PDF files)
    for pattern in "*.aux" "*.log" "*.fls" "*.out" "*.toc" "*.fdb_latexmk" "*.synctex.gz" "*.bbl" "*.blg" "*.idx" "*.ind" "*.ilg" "*.nav" "*.snm" "*.vrb" "*.run.xml" "*.bcf" "*.maf" "*.mtc" "*.mtc0" "*.slf" "*.slt" "*.stc" "*.thm" "*.xdy"; do
        while IFS= read -r -d '' file; do
            rm -f "$file"
            cleaned=$((cleaned + 1))
        done < <(find . -name "$pattern" -not -path "./build/*" -print0)
    done

    # Also clean any remaining temporary files in build directory
    if [[ -d "$BUILD_DIR" ]]; then
        find "$BUILD_DIR" -type f -name "*.aux" -o -name "*.log" -o -name "*.fls" -o -name "*.out" -o -name "*.toc" -o -name "*.fdb_latexmk" -o -name "*.synctex.gz" -o -name "*.bbl" -o -name "*.blg" -o -name "*.idx" -o -name "*.ind" -o -name "*.ilg" -o -name "*.nav" -o -name "*.snm" -o -name "*.vrb" -o -name "*.run.xml" -o -name "*.bcf" -o -name "*.maf" -o -name "*.mtc" -o -name "*.mtc0" -o -name "*.slf" -o -name "*.slt" -o -name "*.stc" -o -name "*.thm" -o -name "*.xdy" | while read -r file; do
            rm -f "$file"
            cleaned=$((cleaned + 1))
        done
    fi

    print_status "SUCCESS" "Cleaned $cleaned temporary files"
}

# Clean build directory
clean_build() {
    print_status "INFO" "Cleaning build directory..."

    if [[ -d "$BUILD_DIR" ]]; then
        rm -rf "$BUILD_DIR"/*
        print_status "SUCCESS" "Build directory cleaned"
    else
        print_status "INFO" "Build directory does not exist"
    fi
}

# =============================================================================
# CHECK FUNCTIONS
# =============================================================================

# Check LaTeX style
check_style() {
    local file=$1

    print_status "INFO" "Checking style for $file..."

    # Check for forbidden variables
    if grep -q "y_{n\|x_{n\|z_{n\|a_{n\|b_{n\|c_{n" "$file" 2>/dev/null; then
        print_status "ERROR" "Found forbidden variable 'n' in time indices"
        return 1
    fi

    # Check for informal language
    if grep -qi "надо\|нужно\|доказ" "$file"; then
        print_status "WARNING" "Found informal language in $file"
        echo "Use 'требуется' instead of 'надо'"
        echo "Use 'должно быть' instead of 'нужно'"
        echo "Use 'доказательство' instead of 'доказ'"
    fi

    # Check label consistency
    local labels=$(grep -o '\\label{[^}]*}' "$file" | sed 's/\\label{//;s/}//' | sort -u)
    local refs=$(grep -o '\\ref{[^}]*}' "$file" | sed 's/\\ref{//;s/}//' | sort -u)

    local errors=0
    for ref in $refs; do
        if ! echo "$labels" | grep -q "^$ref$"; then
            print_status "ERROR" "Reference '$ref' has no corresponding label"
            errors=$((errors + 1))
        fi
    done

    if [[ $errors -eq 0 ]]; then
        print_status "SUCCESS" "Style check passed for $file"
        return 0
    else
        print_status "ERROR" "Found $errors style issues in $file"
        return 1
    fi
}

# Check all files
check_all() {
    print_status "INFO" "Checking all LaTeX files..."

    local files_checked=0
    local files_passed=0
    local files_failed=0

    while IFS= read -r -d '' file; do
        files_checked=$((files_checked + 1))
        if check_style "$file"; then
            files_passed=$((files_passed + 1))
        else
            files_failed=$((files_failed + 1))
        fi
    done < <(find . -name "*.tex" -not -path "./templates/*" -not -path "*/preparation/topics/*" -print0)

    print_status "INFO" "Style check summary: $files_passed passed, $files_failed failed out of $files_checked files"

    if [[ $files_failed -gt 0 ]]; then
        exit 1
    fi
}

# =============================================================================
# WATCH FUNCTIONS
# =============================================================================

# Watch a single file for changes
watch_file() {
    local file=$1

    if [[ ! -f "$file" ]]; then
        print_status "ERROR" "File $file does not exist"
        exit 1
    fi

    print_status "INFO" "Watching $file for changes..."
    print_status "INFO" "Press Ctrl+C to stop"

    # Initial build
    build_file "$file"

    # Watch for changes
    while inotifywait -e modify "$file" >/dev/null 2>&1; do
        print_status "INFO" "File changed, rebuilding..."
        build_file "$file"
    done
}

# =============================================================================
# PROJECT MANAGEMENT
# =============================================================================

# Show project status
show_status() {
    print_status "INFO" "Project Status:"
    echo "=================="

    local tex_files=$(find . -name "*.tex" | wc -l)
    local pdf_files=$(find . -name "*.pdf" | wc -l)
    local temp_files=$(find . -name "*.aux" -o -name "*.log" -o -name "*.fls" -o -name "*.out" -o -name "*.toc" | wc -l)
    local build_files=$(find "$BUILD_DIR" -type f 2>/dev/null | wc -l)

    echo "LaTeX files: $tex_files"
    echo "PDF files: $pdf_files"
    echo "Temporary files: $temp_files"
    echo "Build directory: $build_files files"
}

# Show help
show_help() {
    echo "HSE AMI Cheatsheets LaTeX Manager"
    echo "=================================="
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  build [file]     Build LaTeX document(s)"
    echo "  clean            Clean temporary files"
    echo "  check [file]     Check style and quality"
    echo "  watch <file>     Watch file for changes and rebuild"
    echo "  status           Show project status"
    echo "  help             Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 build                                    # Build all files"
    echo "  $0 build cheatsheets/math/de/main.tex      # Build specific file"
    echo "  $0 clean                                    # Clean temporary files"
    echo "  $0 check                                    # Check all files"
    echo "  $0 watch cheatsheets/math/de/main.tex      # Watch specific file"
    echo "  $0 status                                   # Show project status"
}

# =============================================================================
# MAIN FUNCTION
# =============================================================================

main() {
    local command=${1:-help}

    case $command in
        "build")
            ensure_build_dir
            if [[ $# -eq 2 ]]; then
                build_file "$2"
            else
                build_all
            fi
            ;;
        "clean")
            clean_files
            clean_build
            ;;
        "check")
            if [[ $# -eq 2 ]]; then
                check_style "$2"
            else
                check_all
            fi
            ;;
        "watch")
            if [[ $# -eq 2 ]]; then
                watch_file "$2"
            else
                print_status "ERROR" "Please specify a file to watch"
                exit 1
            fi
            ;;
        "status")
            show_status
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# Run main function with all arguments
main "$@"
