# CONTRIBUTING

Краткое руководство по вкладу. Только необходимые шаги.

## Добавление нового cheatsheet
1. Выберите категорию: `cheatsheets/math|programming|other/`.
2. Создайте папку темы в kebab-case: `cheatsheets/math/your-topic/`.
3. Скопируйте подходящий шаблон из `templates/cheatsheets/` (или болванку из `templates/kits/`) и переименуйте в `your-topic.tex`.
4. Соберите: `make cheatsheets` (или `make all`).
5. Убедитесь, что `your-topic.pdf` создан рядом с `your-topic.tex`.
6. Создайте Pull Request.

### Брендинг и контакты
- В шаблонах уже указан автор: `werserk` и ссылка: `werserk.com`.
- Вы можете дополнить список соавторов/источников данных: перед `\begin{document}` добавьте строку
  ```tex
  \newcommand{\contributors}{Имя Фамилия; @telegram; Источник задач №123}
  ```
  или оставьте пустым по умолчанию.

## Исправления и улучшения
- Держите PR маленьким и по одной теме.
- Если меняете поведение/структуру — обновите `README.md` по факту.
- Не добавляйте лишние изменения (форматирование не по делу и т.п.).

## Требования к PR
- Локальная сборка без ошибок: `make all`.
- PDF файлы лежат рядом с соответствующими `.tex`.
- Сообщение коммита — короткое и по делу, повелительное наклонение: например, `add linear algebra cheatsheet`, `fix formula in DE`.

## Файлы и структура
- Кодировка: UTF-8.
- Основа — шаблоны из `templates/cheatsheets/` или `templates/kits/`.
- Изображения — в `assets/images/` (предпочтительно векторные: SVG/PDF).

Соглашения по именам и структуре:
- Темы: каталоги в kebab-case, напр. `differential-equations`.
- Основные файлы: `topic-name.tex` и `topic-name.pdf` рядом.
- Экзамены: `exam-variants/YYYY/*.pdf` (имя файла — kebab-case без года).

Пример:
```
cheatsheets/math/your-topic/
├── your-topic.tex
└── your-topic.pdf
```

## Issues
Включайте: краткое описание, шаги воспроизведения, ожидаемое/фактическое, ОС и версия TeX.

## Лицензия
Вклад лицензируется по MIT (см. `LICENSE`).
