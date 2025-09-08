# Makefile для HSE AMI LaTeX cheatsheet проекта
# Автор: werserk
# Дата: $(shell date +%Y-%m-%d)

# Переменные
LATEX = pdflatex
BIBTEX = bibtex
BUILD_DIR = build
TEMPLATES_DIR = templates
CHEATSHEETS_DIR = cheatsheets
STYLES_DIR = assets/styles

# Найти все .tex файлы в директории cheatsheets
# Исключаем файлы внутри каталогов topics/ (части тем), собираем только верхнеуровневые .tex
TEX_FILES = $(shell find $(CHEATSHEETS_DIR) -name "*.tex" -not -path "*/topics/*")

# Найти все файлы topics/ для отслеживания зависимостей
TOPICS_FILES = $(shell find $(CHEATSHEETS_DIR) -path "*/topics/*.tex")

# Найти все .tex файлы в директории templates
# Исключаем файлы внутри каталогов topics/ (части тем)
TEMPLATE_FILES = $(shell find $(TEMPLATES_DIR) -name "*.tex" -not -path "*/topics/*")
TEMPLATE_PDFS = $(TEMPLATE_FILES:.tex=.pdf)
PDF_FILES = $(TEX_FILES:.tex=.pdf)

# Основные цели
.PHONY: all clean templates cheatsheets help clean-pdf FORCE

# Собрать все документы
all: templates cheatsheets
	@echo "🎉 Все документы собраны!"

# Собрать только cheatsheet'ы
cheatsheets: $(PDF_FILES)
	@echo "📚 Cheatsheet'ы готовы!"

# Собрать только шаблоны
templates: $(TEMPLATE_PDFS)
	@echo "📋 Шаблоны готовы!"

# Правило для сборки PDF из LaTeX (пишем PDF рядом с .tex)
%.pdf: %.tex $(TOPICS_FILES) FORCE
	@if [ -f "$@" ]; then \
		PDF_MTIME=$$(stat -c %Y "$@" 2>/dev/null || echo "0"); \
		TEX_MTIME=$$(stat -c %Y "$<" 2>/dev/null || echo "0"); \
		NEED_COMPILE=0; \
		if [ "$$TEX_MTIME" -gt "$$PDF_MTIME" ]; then \
			echo "Обновление: $@ (изменен основной .tex)"; \
			NEED_COMPILE=1; \
		else \
			TOPICS_MTIME=$$(find $(CHEATSHEETS_DIR) -path "*/topics/*.tex" -exec stat -c %Y {} \; 2>/dev/null | sort -n | tail -1 || echo "0"); \
			if [ "$$TOPICS_MTIME" -gt "$$PDF_MTIME" ]; then \
				echo "Обновление: $@ (изменены файлы topics/)"; \
				NEED_COMPILE=1; \
			else \
				echo "Без изменений: $@"; \
			fi; \
		fi; \
	else \
		echo "Создание: $@"; \
		NEED_COMPILE=1; \
	fi; \
	if [ "$$NEED_COMPILE" = "1" ]; then \
		cd $(@D) && env TEXINPUTS=$(abspath $(STYLES_DIR)):$${TEXINPUTS} $(LATEX) -interaction=nonstopmode "$(notdir $<)" > /dev/null 2>&1 \
			|| (echo "Ошибка: $<" && exit 1); \
		if [ -f "$(@D)/$(basename $(notdir $<)).aux" ]; then \
			cd "$(@D)" && env TEXINPUTS=$(abspath $(STYLES_DIR)):$${TEXINPUTS} $(BIBTEX) "$(basename $(notdir $<))" > /dev/null 2>&1; \
			env TEXINPUTS=$(abspath $(STYLES_DIR)):$${TEXINPUTS} $(LATEX) -interaction=nonstopmode "$(notdir $<)" > /dev/null 2>&1; \
			env TEXINPUTS=$(abspath $(STYLES_DIR)):$${TEXINPUTS} $(LATEX) -interaction=nonstopmode "$(notdir $<)" > /dev/null 2>&1; \
		fi; \
	fi

# Очистка временных файлов
clean:
	@echo "🧹 Очистка временных файлов..."
	@rm -rf $(BUILD_DIR)
	@find . -name "*.aux" -delete 2>/dev/null || true
	@find . -name "*.log" -delete 2>/dev/null || true
	@find . -name "*.out" -delete 2>/dev/null || true
	@find . -name "*.toc" -delete 2>/dev/null || true
	@find . -name "*.lof" -delete 2>/dev/null || true
	@find . -name "*.lot" -delete 2>/dev/null || true
	@find . -name "*.fls" -delete 2>/dev/null || true
	@find . -name "*.fdb_latexmk" -delete 2>/dev/null || true
	@find . -name "*.synctex.gz" -delete 2>/dev/null || true
	@find . -name "*.bbl" -delete 2>/dev/null || true
	@find . -name "*.blg" -delete 2>/dev/null || true
	@find . -name "*.idx" -delete 2>/dev/null || true
	@find . -name "*.ind" -delete 2>/dev/null || true
	@find . -name "*.ilg" -delete 2>/dev/null || true
	@find . -name "*.lol" -delete 2>/dev/null || true
	@echo "✅ Очистка завершена"

# Очистка PDF, созданных из .tex
clean-pdf:
	@echo "🗑️  Удаление PDF файлов..."
	@find . -name "*.tex" -exec sh -c 'f="$$1"; pdf="$${f%.tex}.pdf"; [ -f "$$pdf" ] && echo "Удаление: $$pdf" && rm -f "$$pdf"' _ {} \;
	@echo "✅ PDF файлы удалены"

# Показать справку
help:
	@echo "🚀 HSE Cheatsheets - Система сборки"
	@echo ""
	@echo "📋 Основные команды:"
	@echo "  make all         - Собрать все документы"
	@echo "  make cheatsheets - Собрать только cheatsheet'ы"
	@echo "  make templates   - Собрать только шаблоны"
	@echo ""
	@echo "🧹 Очистка:"
	@echo "  make clean       - Удалить временные файлы"
	@echo "  make clean-pdf   - Удалить PDF файлы"
	@echo ""
	@echo "📄 Сборка конкретного файла:"
	@echo "  make cheatsheets/math/differential-equations/preparation/main.pdf"
	@echo "  make templates/cheatsheets/basic-cheatsheet.pdf"

# Создать директорию build если её нет
$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

# Зависимости
$(PDF_FILES): $(BUILD_DIR)
$(TEMPLATE_PDFS): $(BUILD_DIR)
