#!/bin/bash

# check-style.sh — Скрипт для проверки соответствия стилю
# Project: HSE AMI Cheatsheets
# Usage: ./scripts/check-style.sh [file.tex]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "ERROR")
            echo -e "${RED}❌ ERROR: $message${NC}"
            ;;
        "WARNING")
            echo -e "${YELLOW}⚠️  WARNING: $message${NC}"
            ;;
        "SUCCESS")
            echo -e "${GREEN}✅ $message${NC}"
            ;;
        "INFO")
            echo -e "${YELLOW}ℹ️  INFO: $message${NC}"
            ;;
    esac
}

# Function to check if file exists
check_file() {
    local file=$1
    if [[ ! -f "$file" ]]; then
        print_status "ERROR" "File $file does not exist"
        exit 1
    fi
}

# Function to check LaTeX compilation
check_compilation() {
    local file=$1
    print_status "INFO" "Checking LaTeX compilation for $file"

    # Get directory of the file
    local file_dir=$(dirname "$file")
    local file_name=$(basename "$file")

    # Change to file directory for compilation
    if [[ "$file_dir" != "." ]]; then
        cd "$file_dir" || return 1
    fi

    # Use latexmk with output directory to keep temp files organized
    # Create build directory if it doesn't exist
    mkdir -p ../../../build
    if latexmk -pdf -interaction=nonstopmode -halt-on-error -output-directory=../../../build "$file_name" > /dev/null 2>&1; then
        print_status "SUCCESS" "LaTeX compilation successful"
        # Return to original directory
        if [[ "$file_dir" != "." ]]; then
            cd - > /dev/null 2>&1
        fi
        return 0
    else
        print_status "ERROR" "LaTeX compilation failed"
        # Return to original directory
        if [[ "$file_dir" != "." ]]; then
            cd - > /dev/null 2>&1
        fi
        return 1
    fi
}

# Function to check for forbidden variables
check_forbidden_variables() {
    local file=$1
    print_status "INFO" "Checking for forbidden variables in $file"

    # Check for 'n' in time indices
    if grep -q "y_{n\|x_{n\|z_{n\|a_{n\|b_{n\|c_{n" "$file" 2>/dev/null; then
        print_status "ERROR" "Found forbidden variable 'n' in time indices"
        echo "Use 't' or 'T' instead of 'n' for time indices"
        return 1
    fi

    print_status "SUCCESS" "No forbidden variables found"
    return 0
}

# Function to check label consistency
check_labels() {
    local file=$1
    print_status "INFO" "Checking label consistency in $file"

    # Extract all labels and references
    labels=$(grep -o '\\label{[^}]*}' "$file" | sed 's/\\label{//;s/}//' | sort -u)
    refs=$(grep -o '\\ref{[^}]*}' "$file" | sed 's/\\ref{//;s/}//' | sort -u)

    local errors=0

    # Check if all refs have corresponding labels
    for ref in $refs; do
        if ! echo "$labels" | grep -q "^$ref$"; then
            print_status "ERROR" "Reference '$ref' has no corresponding label"
            errors=$((errors + 1))
        fi
    done

    if [[ $errors -eq 0 ]]; then
        print_status "SUCCESS" "All references have corresponding labels"
        return 0
    else
        print_status "ERROR" "Found $errors label inconsistencies"
        return 1
    fi
}

# Function to check notation standards
check_notation() {
    local file=$1
    print_status "INFO" "Checking notation standards in $file"

    # Check for non-standard mathbb usage
    if grep -q '\\mathbb{[^RNCZQ]}' "$file" 2>/dev/null; then
        print_status "WARNING" "Found non-standard \\mathbb usage"
        echo "Use \\reals, \\naturals, \\complex instead of \\mathbb{R}, \\mathbb{N}, \\mathbb{C}"
        return 1
    fi

    print_status "SUCCESS" "Notation standards check passed"
    return 0
}

# Function to check Russian terminology
check_terminology() {
    local file=$1
    print_status "INFO" "Checking Russian terminology in $file"

    local errors=0

    # Check for informal language
    if grep -qi "надо\|нужно\|доказ" "$file"; then
        print_status "WARNING" "Found informal language"
        echo "Use 'требуется' instead of 'надо'"
        echo "Use 'должно быть' instead of 'нужно'"
        echo "Use 'доказательство' instead of 'доказ'"
        errors=$((errors + 1))
    fi

    if [[ $errors -eq 0 ]]; then
        print_status "SUCCESS" "Russian terminology check passed"
        return 0
    else
        return 1
    fi
}

# Function to check LaTeX style
check_latex_style() {
    local file=$1
    print_status "INFO" "Checking LaTeX style for $file"

    if command -v chktex >/dev/null 2>&1; then
        if chktex "$file" 2>/dev/null; then
            print_status "SUCCESS" "LaTeX style check passed"
            return 0
        else
            print_status "WARNING" "LaTeX style issues found (run chktex for details)"
            return 1
        fi
    else
        print_status "WARNING" "chktex not installed, skipping style check"
        return 0
    fi
}

# Main function
main() {
    local file=$1
    local total_errors=0
    local total_warnings=0

    echo "🔍 HSE AMI Cheatsheets Style Checker"
    echo "====================================="
    echo

    if [[ -z "$file" ]]; then
        print_status "INFO" "Checking all .tex files in project"
        find . -name "*.tex" -not -path "./templates/*" | while read -r tex_file; do
            echo "Checking $tex_file..."
            ./scripts/check-style.sh "$tex_file"
            echo
        done
        return 0
    fi

    check_file "$file"

    # Run all checks
    check_compilation "$file" || total_errors=$((total_errors + 1))
    check_forbidden_variables "$file" || total_errors=$((total_errors + 1))
    check_labels "$file" || total_errors=$((total_errors + 1))
    check_notation "$file" || total_warnings=$((total_warnings + 1))
    check_terminology "$file" || total_warnings=$((total_warnings + 1))
    check_latex_style "$file" || total_warnings=$((total_warnings + 1))

    echo
    echo "📊 Summary for $file:"
    echo "====================="

    if [[ $total_errors -eq 0 && $total_warnings -eq 0 ]]; then
        print_status "SUCCESS" "All checks passed! 🎉"
        exit 0
    elif [[ $total_errors -eq 0 ]]; then
        print_status "WARNING" "Found $total_warnings warnings, but no errors"
        exit 0
    else
        print_status "ERROR" "Found $total_errors errors and $total_warnings warnings"
        exit 1
    fi
}

# Run main function with all arguments
main "$@"
