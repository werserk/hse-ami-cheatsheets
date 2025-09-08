#!/bin/bash

# Скрипт для автоматического обновления LaTeX документов при изменении .tex файлов
# Использование: ./scripts/watch-latex.sh [путь_к_tex_файлу]

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функция для вывода с цветом
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Проверка аргументов
if [ $# -eq 0 ]; then
    print_error "Использование: $0 <путь_к_tex_файлу>"
    print_info "Примеры:"
    print_info "  $0 cheatsheets/math/differential-equations/preparation/main.tex"
    print_info "  $0 templates/cheatsheets/basic-cheatsheet.tex"
    exit 1
fi

TEX_FILE="$1"
PDF_FILE="${TEX_FILE%.tex}.pdf"
TEX_DIR=$(dirname "$TEX_FILE")
TEX_BASENAME=$(basename "$TEX_FILE" .tex)
STYLES_DIR="assets/styles"
ROOT_DIR="$(pwd)"
AUX_ROOT_DIR="$ROOT_DIR/build/.aux"
mkdir -p "$AUX_ROOT_DIR/$TEX_DIR"
AUX_DIR="$AUX_ROOT_DIR/$TEX_DIR"

# Проверка существования файла
if [ ! -f "$TEX_FILE" ]; then
    print_error "Файл не найден: $TEX_FILE"
    exit 1
fi

print_info "Отслеживание изменений в: $TEX_FILE"
print_info "Выходной PDF: $PDF_FILE"
print_info "Для выхода нажмите Ctrl+C"

# Функция для сборки LaTeX
build_latex() {
    print_info "Обнаружено изменение. Пересборка..."

    # Переход в директорию с файлом
    cd "$TEX_DIR"

    # Сборка с latexmk
    if env TEXINPUTS="$(pwd)/../../$STYLES_DIR":${TEXINPUTS} latexmk -pdf -quiet -auxdir="$AUX_DIR" -emulate-aux-dir "$TEX_BASENAME.tex"; then
        print_success "PDF обновлен: $(basename "$PDF_FILE")"
        # Очистка побочных файлов (на случай, если что-то осталось в исходной папке)
        latexmk -c -quiet -auxdir="$AUX_DIR" -emulate-aux-dir "$TEX_BASENAME.tex" > /dev/null 2>&1 || true
    else
        print_error "Ошибка сборки LaTeX"
    fi

    # Возврат в корневую директорию
    cd - > /dev/null
}

# Первоначальная сборка
build_latex

# Отслеживание изменений
inotifywait -m -r -e modify,create,delete --format '%w%f' "$TEX_DIR" | while read FILE; do
    # Проверяем, что измененный файл - .tex
    if [[ "$FILE" == *.tex ]]; then
        print_info "Изменен файл: $(basename "$FILE")"
        build_latex
    fi
done
