# Makefile for HSE AMI Cheatsheets v2.0
# This Makefile provides convenient commands using the unified hse-latex.sh script

.PHONY: help clean build check all status watch install

# Default target
help:
	@echo "HSE AMI Cheatsheets v2.0 - Available Commands:"
	@echo "==============================================="
	@echo "  make build    - Compile all LaTeX documents"
	@echo "  make clean    - Remove all temporary files"
	@echo "  make check    - Run style checks on all files"
	@echo "  make all      - Clean, build, and check everything"
	@echo "  make status   - Show project statistics"
	@echo "  make watch    - Watch for changes and rebuild"
	@echo "  make install  - Install dependencies and setup"
	@echo "  make help     - Show this help message"
	@echo ""
	@echo "For more options, use: ./scripts/hse-latex.sh help"

# Build all LaTeX documents
build:
	@./scripts/hse-latex.sh build

# Clean all temporary files
clean:
	@./scripts/hse-latex.sh clean

# Run style checks
check:
	@./scripts/hse-latex.sh check

# Clean, build, and check everything
all: clean build check
	@echo "🎉 All tasks completed successfully!"

# Show project status
status:
	@./scripts/hse-latex.sh status

# Watch for changes (requires file argument)
watch:
	@echo "Usage: make watch FILE=path/to/file.tex"
	@if [ -z "$(FILE)" ]; then \
		echo "Please specify a file: make watch FILE=cheatsheets/math/differential-equations/main.tex"; \
		exit 1; \
	fi
	@./scripts/hse-latex.sh watch "$(FILE)"

# Install dependencies and setup
install:
	@echo "🔧 Installing dependencies and setting up project..."
	@./scripts/install_deps.sh
	@./scripts/install_vscode_exts.sh
	@./scripts/setup-hooks.sh
	@echo "✅ Installation completed!"
