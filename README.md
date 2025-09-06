# HSE Cheatsheets — by werserk

Репозиторий для хранения и организации различных cheatsheet'ов, оформленных в LaTeX.

## Структура проекта

```
├── templates/         # Шаблоны для различных типов документов
│   ├── *.tex          # LaTeX исходники шаблонов
│   └── *.pdf          # Собранные PDF шаблонов
├── cheatsheets/       # Готовые cheatsheet'ы
│   ├── math/          # Математические справочники
│   │   └── */         # Каждая тема в отдельной папке
│   │       ├── *.tex              # LaTeX исходник
│   │       ├── *.pdf              # Собранный PDF
│   │       └── exam-variants/     # Варианты экзаменов
│   │           └── YYYY/          # Год (например, 2025)
│   │               └── name.pdf   # Стандартизированное имя (kebab-case)
│   ├── programming/   # Программирование
│   └── other/         # Прочие темы
├── assets/            # Общие ресурсы (изображения, стили)
└── build/             # Временные файлы сборки (игнорируется git)
```

## Использование

### Первоначальная настройка
```bash
# Настройка Git hooks для автоматической сборки
./setup-hooks.sh
```

### Сборка всех документов
```bash
make all
```

### Сборка конкретного cheatsheet
```bash
make cheatsheets/math/differential-equations/differential-equations.pdf
```

### Очистка временных файлов
```bash
make clean
```

### Git hooks (автоматическая сборка)

Проект настроен с Git hooks для автоматической сборки PDF перед каждым коммитом:

- **Pre-commit hook** автоматически собирает все LaTeX документы
- **Проверяет синтаксис** и предотвращает коммиты с ошибками
- **Автоматически добавляет** обновленные PDF файлы в коммит
- **Показывает статистику** сборки и размеры файлов

Для настройки выполните:
```bash
./setup-hooks.sh
```

## Требования

- LaTeX дистрибутив (TeX Live, MiKTeX)
- Make (для автоматизации сборки)

## Быстрый старт (установка зависимостей)

На Linux/macOS вы можете установить все необходимые пакеты одной командой:

```bash
./scripts/install_deps.sh
```

Скрипт автоматически определит ваш пакетный менеджер (`apt`, `dnf`, `pacman`, `zypper`, `brew`) и установит:

- `pdflatex`/`bibtex` (через TeX Live),
- необходимые LaTeX-пакеты: `amsmath`, `amsfonts`, `amssymb`, `geometry`, `multicol`, `graphicx`, `xcolor`, `titlesec`, `enumitem`, `booktabs`, `array`, `parskip`, `mathtools`,
- поддержку кириллицы: `babel` с `russian`,
- `latexmk` (для интеграции с VS Code),
- `make`.

Если скрипт не поддерживает вашу систему — установите эквиваленты вручную.

## Рекомендуемые расширения VS Code

Рекомендуемые расширения описаны в `.vscode/extensions.json`. Установить их можно автоматически:

```bash
./scripts/install_vscode_exts.sh
```

Или поставьте вручную:

- James-Yu.latex-workshop — сборка, предпросмотр, рецепты
- streetsidesoftware.code-spell-checker — проверка правописания
- streetsidesoftware.code-spell-checker-russian — словарь RU для проверщика
- valentjn.vscode-ltex — продвинутая грамматика и стиль (опционально)

## Шаблоны

В директории `templates/` находятся готовые шаблоны для:
- Базовый cheatsheet
- Математические формулы
- Таблицы и списки
- Двухколоночный макет

## Добавление нового cheatsheet

1. Скопируйте подходящий шаблон из `templates/`
2. Разместите в соответствующей директории `cheatsheets/`
3. Отредактируйте содержимое
4. Соберите с помощью `make`

## Соглашения по структуре и именам

- Темы: каталоги в kebab-case, напр. `differential-equations`
- Файлы: `topic-name.tex` и `topic-name.pdf` рядом
- Экзамены: `exam-variants/YYYY/*.pdf` (имя файла — kebab-case без года)

## Лицензия

MIT License - используйте материалы свободно для образовательных целей.
