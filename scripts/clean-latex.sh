#!/bin/bash

# Clean LaTeX temporary files script for HSE AMI Cheatsheets
# This script removes all LaTeX temporary files from the project

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

echo "🧹 HSE AMI Cheatsheets LaTeX Cleaner"
echo "===================================="

# Count files before cleaning
aux_count=$(find . -name "*.aux" | wc -l)
log_count=$(find . -name "*.log" | wc -l)
fls_count=$(find . -name "*.fls" | wc -l)
out_count=$(find . -name "*.out" | wc -l)
toc_count=$(find . -name "*.toc" | wc -l)
fdb_count=$(find . -name "*.fdb_latexmk" | wc -l)
synctex_count=$(find . -name "*.synctex.gz" | wc -l)

total_files=$((aux_count + log_count + fls_count + out_count + toc_count + fdb_count + synctex_count))

if [ $total_files -eq 0 ]; then
    print_status "INFO" "No LaTeX temporary files found. Project is already clean!"
    exit 0
fi

print_status "INFO" "Found $total_files temporary files:"
echo "  - .aux files: $aux_count"
echo "  - .log files: $log_count"
echo "  - .fls files: $fls_count"
echo "  - .out files: $out_count"
echo "  - .toc files: $toc_count"
echo "  - .fdb_latexmk files: $fdb_count"
echo "  - .synctex.gz files: $synctex_count"

# Ask for confirmation
read -p "Do you want to remove all these files? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_status "INFO" "Operation cancelled."
    exit 0
fi

# Remove files
print_status "INFO" "Removing temporary files..."

# Remove common LaTeX temporary files
find . -name "*.aux" -delete
find . -name "*.log" -delete
find . -name "*.fls" -delete
find . -name "*.out" -delete
find . -name "*.toc" -delete
find . -name "*.fdb_latexmk" -delete
find . -name "*.synctex.gz" -delete

# Remove other common temporary files
find . -name "*.bbl" -delete
find . -name "*.bcf" -delete
find . -name "*.blg" -delete
find . -name "*.run.xml" -delete
find . -name "*.nav" -delete
find . -name "*.snm" -delete
find . -name "*.vrb" -delete
find . -name "*.idx" -delete
find . -name "*.ilg" -delete
find . -name "*.ind" -delete
find . -name "*.lof" -delete
find . -name "*.lot" -delete
find . -name "*.maf" -delete
find . -name "*.mtc" -delete
find . -name "*.mtc0" -delete
find . -name "*.slf" -delete
find . -name "*.slt" -delete
find . -name "*.stc" -delete
find . -name "*.thm" -delete
find . -name "*.xdy" -delete

print_status "SUCCESS" "All LaTeX temporary files have been removed!"
print_status "INFO" "Project is now clean and ready for development."

# Show remaining files (should be only source files and PDFs)
remaining_tex=$(find . -name "*.tex" | wc -l)
remaining_pdf=$(find . -name "*.pdf" | wc -l)

echo ""
echo "📊 Project status:"
echo "  - .tex files: $remaining_tex"
echo "  - .pdf files: $remaining_pdf"
echo "  - Temporary files: 0"
