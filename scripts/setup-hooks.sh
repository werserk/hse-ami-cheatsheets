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

set -euo pipefail

# Pre-commit hook для избирательной сборки только затронутых PDF

echo "🔨 Pre-commit: избирательная сборка LaTeX документов..."

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error(){ echo -e "${RED}[ERROR]${NC} $1"; }

# Проверяем наличие инструментов
if ! command -v pdflatex >/dev/null 2>&1; then
  log_error "pdflatex не найден! Установите LaTeX."
  exit 1
fi
if ! command -v make >/dev/null 2>&1; then
  log_error "make не найден! Установите make."
  exit 1
fi

# Определяем изменённые .tex файлы, добавленные в индекс
mapfile -t CHANGED_TEX < <(git diff --cached --name-only --diff-filter=ACM | grep -E '\\.tex$' || true)
if [ ${#CHANGED_TEX[@]} -eq 0 ]; then
  log_info "Нет изменений в .tex файлах, пропускаем сборку."
  exit 0
fi

mkdir -p build

declare -A TARGET_TEX_SET

add_target_for_tex() {
  local tex_file="$1"
  # Если изменён файл внутри каталога topics/, находим родительские верхнеуровневые .tex
  if [[ "$tex_file" == */topics/*.tex ]]; then
    local topics_dir="$(dirname "$tex_file")"
    local parent_dir="$(dirname "$topics_dir")"
    # Кандидаты: любые .tex в родительской директории, исключая подкаталог topics
    while IFS= read -r cand; do
      TARGET_TEX_SET["$cand"]=1
    done < <(find "$parent_dir" -maxdepth 1 -type f -name "*.tex" 2>/dev/null || true)
  else
    TARGET_TEX_SET["$tex_file"]=1
  fi
}

for f in "${CHANGED_TEX[@]}"; do
  add_target_for_tex "$f"
done

if [ ${#TARGET_TEX_SET[@]} -eq 0 ]; then
  log_warn "Не найдены целевые .tex для сборки."
  exit 0
fi

log_info "Целей для сборки: ${#TARGET_TEX_SET[@]}"

BUILD_FAILED=0
for target_tex in "${!TARGET_TEX_SET[@]}"; do
  pdf_file="${target_tex%.tex}.pdf"
  log_info "Сборка: $pdf_file"
  if make "$pdf_file" > build/build.log 2>&1; then
    if [ -f "$pdf_file" ]; then
      git add "$pdf_file"
    fi
  else
    BUILD_FAILED=1
    echo "" >&2
    log_error "Ошибка сборки для: $target_tex" >&2
    echo "----- build/build.log -----" >&2
    cat build/build.log >&2 || true
    echo "---------------------------" >&2
  fi
done

if [ "$BUILD_FAILED" -ne 0 ]; then
  exit 1
fi

log_info "Готово. Обновлены и добавлены связанные PDF."
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
echo "  2. Собираться только связанные с ними PDF (без make all)"
echo "  3. Добавляться обновленные связанные PDF в коммит"
echo "  4. Предотвращаться коммиты с ошибками сборки"
echo ""
log_info "Для тестирования выполните:"
echo "  git add ."
echo "  git commit -m 'Тестовый коммит'"
