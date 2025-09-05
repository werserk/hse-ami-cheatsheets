#!/bin/bash

# Скрипт для настройки Git hooks
# Автор: werserk

echo "🔧 Настройка Git hooks для HSE LaTeX проекта..."

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Проверяем, что мы в Git репозитории
if [ ! -d ".git" ]; then
    log_error "Это не Git репозиторий! Инициализируйте Git сначала."
    exit 1
fi

# Создаем директорию hooks если её нет
mkdir -p .git/hooks

# Копируем pre-commit hook
if [ -f ".git/hooks/pre-commit" ]; then
    log_warn "Pre-commit hook уже существует. Создаем резервную копию..."
    cp .git/hooks/pre-commit .git/hooks/pre-commit.backup.$(date +%Y%m%d_%H%M%S)
fi

# Создаем pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

# Pre-commit hook для автоматической сборки HSE LaTeX документов
# Автор: werserk
# Дата: $(date +%Y-%m-%d)

echo "🔨 Pre-commit hook: Проверка и сборка LaTeX документов..."

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Функция для вывода сообщений
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Проверяем, есть ли изменения в .tex файлах
if ! git diff --cached --name-only | grep -q '\.tex$'; then
    log_info "Нет изменений в .tex файлах, пропускаем сборку."
    exit 0
fi

log_info "Обнаружены изменения в .tex файлах, начинаем сборку..."

# Проверяем наличие LaTeX
if ! command -v pdflatex &> /dev/null; then
    log_error "pdflatex не найден! Установите LaTeX дистрибутив."
    exit 1
fi

# Проверяем наличие make
if ! command -v make &> /dev/null; then
    log_error "make не найден! Установите make."
    exit 1
fi

# Создаем директорию build если её нет
mkdir -p build

# Собираем все документы
log_info "Сборка всех LaTeX документов..."
if make all > build/build.log 2>&1; then
    log_info "✅ Сборка успешно завершена!"

    # Показываем статистику
    PDF_COUNT=$(find . -name "*.pdf" -not -path "./build/*" | wc -l)
    log_info "Собрано PDF файлов: $PDF_COUNT"

    # Показываем размеры PDF файлов
    if [ $PDF_COUNT -gt 0 ]; then
        echo ""
        log_info "Размеры PDF файлов:"
        find . -name "*.pdf" -not -path "./build/*" -exec ls -lh {} \; | awk '{print "  " $9 " (" $5 ")"}'
    fi

    # Добавляем PDF файлы в коммит если они изменились
    CHANGED_PDFS=$(git diff --name-only --cached | grep '\.tex$' | sed 's/\.tex$/.pdf/')
    if [ -n "$CHANGED_PDFS" ]; then
        for pdf in $CHANGED_PDFS; do
            if [ -f "$pdf" ]; then
                log_info "Добавляем в коммит: $pdf"
                git add "$pdf"
            fi
        done
    fi

else
    log_error "❌ Ошибка при сборке LaTeX документов!"
    echo ""
    log_error "Лог ошибок:"
    cat build/build.log
    echo ""
    log_error "Исправьте ошибки и попробуйте снова."
    exit 1
fi

log_info "🎉 Pre-commit hook завершен успешно!"
exit 0
EOF

# Делаем hook исполняемым
chmod +x .git/hooks/pre-commit

log_info "✅ Pre-commit hook установлен успешно!"

# Проверяем зависимости
log_info "Проверка зависимостей..."

if command -v pdflatex &> /dev/null; then
    log_info "✅ pdflatex найден"
else
    log_warn "⚠️  pdflatex не найден. Установите LaTeX дистрибутив:"
    echo "  Ubuntu/Debian: sudo apt install texlive-full"
    echo "  CentOS/RHEL: sudo yum install texlive"
    echo "  macOS: brew install --cask mactex"
fi

if command -v make &> /dev/null; then
    log_info "✅ make найден"
else
    log_warn "⚠️  make не найден. Установите make:"
    echo "  Ubuntu/Debian: sudo apt install make"
    echo "  CentOS/RHEL: sudo yum install make"
    echo "  macOS: xcode-select --install"
fi

echo ""
log_info "🎉 Настройка Git hooks завершена!"
echo ""
log_info "Теперь при каждом коммите будет автоматически:"
echo "  1. Проверяться наличие изменений в .tex файлах"
echo "  2. Собираться все LaTeX документы"
echo "  3. Добавляться обновленные PDF файлы в коммит"
echo "  4. Предотвращаться коммиты с ошибками сборки"
echo ""
log_info "Для тестирования выполните:"
echo "  git add ."
echo "  git commit -m 'Тестовый коммит'"
