# Makefile for HSE AMI Cheatsheets
# This Makefile provides convenient commands for LaTeX compilation and cleanup

.PHONY: help clean build check all status

# Default target
help:
	@echo "HSE AMI Cheatsheets - Available Commands:"
	@echo "=========================================="
	@echo "  make build    - Compile all LaTeX documents"
	@echo "  make clean    - Remove all temporary files"
	@echo "  make check    - Run style checks on all files"
	@echo "  make all      - Clean, build, and check everything"
	@echo "  make status   - Show project statistics"
	@echo "  make help     - Show this help message"

# Build all LaTeX documents
build:
	@echo "🔨 Building all LaTeX documents..."
	@mkdir -p build
	@cd cheatsheets/math/differential-equations && \
		latexmk -pdf -interaction=nonstopmode -output-directory=../../../build main.tex
	@echo "✅ Build completed! PDFs are in the build/ directory."

# Clean all temporary files
clean:
	@echo "🧹 Cleaning temporary files..."
	@find . -name "*.aux" -delete
	@find . -name "*.log" -delete
	@find . -name "*.fls" -delete
	@find . -name "*.out" -delete
	@find . -name "*.toc" -delete
	@find . -name "*.fdb_latexmk" -delete
	@find . -name "*.synctex.gz" -delete
	@find . -name "*.bbl" -delete
	@find . -name "*.bcf" -delete
	@find . -name "*.blg" -delete
	@find . -name "*.run.xml" -delete
	@find . -name "*.nav" -delete
	@find . -name "*.snm" -delete
	@find . -name "*.vrb" -delete
	@find . -name "*.idx" -delete
	@find . -name "*.ilg" -delete
	@find . -name "*.ind" -delete
	@find . -name "*.lof" -delete
	@find . -name "*.lot" -delete
	@find . -name "*.maf" -delete
	@find . -name "*.mtc" -delete
	@find . -name "*.mtc0" -delete
	@find . -name "*.slf" -delete
	@find . -name "*.slt" -delete
	@find . -name "*.stc" -delete
	@find . -name "*.thm" -delete
	@find . -name "*.xdy" -delete
	@echo "✅ Cleanup completed!"

# Run style checks
check:
	@echo "🔍 Running style checks..."
	@./scripts/check-style.sh cheatsheets/math/differential-equations/main.tex
	@echo "✅ Style checks completed!"

# Clean, build, and check everything
all: clean build check
	@echo "🎉 All tasks completed successfully!"


# Show project status
status:
	@echo "📊 Project Status:"
	@echo "=================="
	@echo "LaTeX files: $$(find . -name "*.tex" | wc -l)"
	@echo "PDF files: $$(find . -name "*.pdf" | wc -l)"
	@echo "Temporary files: $$(find . -name "*.aux" -o -name "*.log" -o -name "*.fls" -o -name "*.out" -o -name "*.toc" | wc -l)"
	@echo "Build directory: $$(find build/ -type f 2>/dev/null | wc -l) files"
