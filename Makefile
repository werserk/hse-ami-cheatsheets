# Makefile для HSE LaTeX cheatsheet проекта
# Автор: werserk
# Дата: $(shell date +%Y-%m-%d)

# Переменные
LATEX = pdflatex
BIBTEX = bibtex
BUILD_DIR = build
TEMPLATES_DIR = templates
CHEATSHEETS_DIR = cheatsheets

# Найти все .tex файлы в директории cheatsheets
# Исключаем файлы внутри каталогов topics/ (части тем), собираем только верхнеуровневые .tex
TEX_FILES = $(shell find $(CHEATSHEETS_DIR) -name "*.tex" -not -path "*/topics/*")

# Найти все .tex файлы в директории templates
# Исключаем файлы внутри каталогов topics/ (части тем)
TEMPLATE_FILES = $(shell find $(TEMPLATES_DIR) -name "*.tex" -not -path "*/topics/*")
TEMPLATE_PDFS = $(TEMPLATE_FILES:.tex=.pdf)
PDF_FILES = $(TEX_FILES:.tex=.pdf)

# Основные цели
.PHONY: all clean templates cheatsheets help clean-pdf

# Собрать все документы
all: templates cheatsheets

# Собрать только cheatsheet'ы
cheatsheets: $(PDF_FILES)

# Собрать только шаблоны
templates: $(TEMPLATE_PDFS)

# Правило для сборки PDF из LaTeX
%.pdf: %.tex
	@echo "Сборка $<..."
	@mkdir -p $(BUILD_DIR)
	$(LATEX) -output-directory=$(BUILD_DIR) -interaction=nonstopmode $<
	@if [ -f $(BUILD_DIR)/$(basename $(notdir $<)).aux ]; then \
		$(BIBTEX) $(BUILD_DIR)/$(basename $(notdir $<)); \
		$(LATEX) -output-directory=$(BUILD_DIR) -interaction=nonstopmode $<; \
		$(LATEX) -output-directory=$(BUILD_DIR) -interaction=nonstopmode $<; \
	fi
	@cp $(BUILD_DIR)/$(basename $(notdir $<)).pdf $(dir $@)
	@echo "Готово: $@"

# Очистка временных файлов
clean:
	@echo "Очистка временных файлов..."
	@rm -rf $(BUILD_DIR)
	@find . -name "*.aux" -delete
	@find . -name "*.log" -delete
	@find . -name "*.out" -delete
	@find . -name "*.toc" -delete
	@find . -name "*.lof" -delete
	@find . -name "*.lot" -delete
	@find . -name "*.fls" -delete
	@find . -name "*.fdb_latexmk" -delete
	@find . -name "*.synctex.gz" -delete
	@find . -name "*.bbl" -delete
	@find . -name "*.blg" -delete
	@find . -name "*.idx" -delete
	@find . -name "*.ind" -delete
	@find . -name "*.ilg" -delete
	@find . -name "*.lol" -delete
	@echo "Очистка завершена."

# Очистка PDF, созданных из .tex (не трогаем сторонние PDF, напр. exam-variants)
clean-pdf:
	@echo "Удаление PDF, соответствующих .tex..."
	@find . -name "*.tex" -exec sh -c 'f="{}"; pdf="${f%.tex}.pdf"; [ -f "$$pdf" ] && rm -f "$$pdf"' \;
	@echo "PDF, созданные из .tex, удалены."

# Показать справку
help:
	@echo "Доступные команды:"
	@echo "  all        - Собрать все документы (шаблоны + cheatsheet'ы)"
	@echo "  cheatsheets - Собрать только cheatsheet'ы"
	@echo "  templates  - Собрать только шаблоны"
	@echo "  clean      - Удалить все временные файлы"
	@echo "  clean-pdf  - Удалить PDF, созданные из .tex"
	@echo "  help       - Показать эту справку"
	@echo ""
	@echo "Примеры использования:"
	@echo "  make cheatsheets/math/differential-equations/differential-equations.pdf"
	@echo "  make templates/basic-cheatsheet.pdf"

# Создать директорию build если её нет
$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

# Зависимости
$(PDF_FILES): $(BUILD_DIR)
$(TEMPLATE_PDFS): $(BUILD_DIR)
