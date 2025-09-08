# 📁 Templates Directory

Эта папка содержит все шаблоны и компоненты для создания документов HSE AMI Cheatsheets.

## 📂 Структура

### `documents/` — Основные шаблоны документов
- **`base-template.tex`** — Универсальный шаблон для любых документов
- **`cheatsheet-template.tex`** — Шаблон для шпаргалок (двухколоночный ландшафт)
- **`exam-template.tex`** — Шаблон для экзаменационных вариантов
- **`preparation-template.tex`** — Шаблон для материалов подготовки

### `components/` — Готовые компоненты и шпаргалки
- **`section_template.tex`** — Шаблон для создания новых разделов
- **`math-formulas.tex`** — Коллекция математических формул
- **`exam-info-panel.tex`** — Информационная панель для экзаменов
- **`basic-cheatsheet.tex`** — Базовая шпаргалка
- **`two-column.tex`** — Двухколоночная шпаргалка

### `kits/` — Готовые наборы
- **`modular-preparation/`** — Модульная система подготовки

## 🚀 Использование

1. **Создание нового документа:**
   ```bash
   cp templates/documents/base-template.tex your-document.tex
   ```

2. **Добавление компонентов:**
   ```bash
   # Скопируйте нужные компоненты из templates/components/
   ```

3. **Сборка документа:**
   ```bash
   ./scripts/hse-latex.sh build your-document.tex
   ```

## 📝 Рекомендации

- Используйте `base-template.tex` для новых типов документов
- Специализированные шаблоны (`cheatsheet`, `exam`, `preparation`) для конкретных задач
- Компоненты из `components/` можно включать в любые документы
- Готовые шпаргалки из `components/` можно использовать как есть или как основу
