#!/bin/bash

# Простой скрипт для автоматической пересборки LaTeX с latexmk
# Использование: ./scripts/auto-latexmk.sh [путь_к_tex_файлу]

set -e

# Цвета для вывода
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Проверка аргументов
if [ $# -eq 0 ]; then
    echo -e "${BLUE}Использование:${NC} $0 <путь_к_tex_файлу>"
    echo -e "${BLUE}Примеры:${NC}"
    echo "  $0 cheatsheets/math/differential-equations/preparation/main.tex"
    echo "  $0 templates/cheatsheets/basic-cheatsheet.tex"
    echo ""
    echo -e "${BLUE}Или для всех файлов:${NC}"
    echo "  $0 all"
    exit 1
fi

TARGET="$1"
STYLES_DIR="assets/styles"
ROOT_DIR="$(pwd)"
AUX_ROOT_DIR="$ROOT_DIR/build/.aux"
mkdir -p "$AUX_ROOT_DIR"

if [ "$TARGET" = "all" ]; then
    echo -e "${BLUE}Автоматическая пересборка всех LaTeX файлов...${NC}"
    echo -e "${BLUE}Для выхода нажмите Ctrl+C${NC}"
    echo ""

    # Находим все .tex файлы (исключая topics/)
    find . -name "*.tex" -not -path "*/topics/*" | while read -r TEX_FILE; do
        TEX_DIR=$(dirname "$TEX_FILE")
        TEX_BASENAME=$(basename "$TEX_FILE" .tex)
        AUX_DIR="$AUX_ROOT_DIR/$TEX_DIR"
        mkdir -p "$AUX_DIR"

        echo -e "${GREEN}Обработка:${NC} $TEX_FILE"

        # Переход в директорию
        cd "$TEX_DIR"

        # Запуск latexmk в режиме непрерывной пересборки
        env TEXINPUTS="$(pwd)/../../$STYLES_DIR":${TEXINPUTS} latexmk -pdf -pvc -quiet -auxdir="$AUX_DIR" -emulate-aux-dir "$TEX_BASENAME.tex" &
        LATEXMK_PIDS="$LATEXMK_PIDS $!"

        # Возврат в корневую директорию
        cd - > /dev/null
    done

    echo -e "${BLUE}Запущено процессов latexmk: $(echo $LATEXMK_PIDS | wc -w)${NC}"
    echo -e "${BLUE}Ожидание завершения...${NC}"

    # Ожидание завершения всех процессов
    wait $LATEXMK_PIDS

else
    # Обработка конкретного файла
    TEX_FILE="$TARGET"
    TEX_DIR=$(dirname "$TEX_FILE")
    TEX_BASENAME=$(basename "$TEX_FILE" .tex)
    AUX_DIR="$AUX_ROOT_DIR/$TEX_DIR"
    mkdir -p "$AUX_DIR"

    if [ ! -f "$TEX_FILE" ]; then
        echo -e "${RED}Файл не найден:${NC} $TEX_FILE"
        exit 1
    fi

    echo -e "${BLUE}Автоматическая пересборка:${NC} $TEX_FILE"
    echo -e "${BLUE}Для выхода нажмите Ctrl+C${NC}"
    echo ""

    # Переход в директорию
    cd "$TEX_DIR"

    # Запуск latexmk в режиме непрерывной пересборки
    env TEXINPUTS="$(pwd)/../../$STYLES_DIR":${TEXINPUTS} latexmk -pdf -pvc -quiet -auxdir="$AUX_DIR" -emulate-aux-dir "$TEX_BASENAME.tex"
fi
