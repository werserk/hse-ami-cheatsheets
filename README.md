# HSE Cheatsheets — by werserk

Иногда не приходит понимания, как решать ту или иную задачу. А иногда просто нет времени для подготовки к экзаменам.

Я стараюсь создавать универсальные алгоритмы, для понимания которых нужно минимум знаний и минимум времени для подготовки.

## Как помочь
- Любой может добавить материалы (подробности — в CONTRIBUTING.md).
- По желанию укажем авторство вашей страницы/раздела.
- Можно не париться и просто прислать любые материалы (фото/черновики/etc) мне в Telegram: `@werserk`.

## Лицензия
MIT License.

## Структура
```
.
├── assets/                 # Общие ресурсы (изображения, стили, шрифты)
│   ├── images/
│   ├── styles/
│   └── fonts/
├── cheatsheets/            # Тематические материалы
│   ├── math/
│   │   └── differential-equations/   # Пример темы
│   │       ├── differential-equations.tex   # исходник
│   │       ├── differential-equations.pdf   # собранный PDF
│   │       └── exam-variants/
│   │           └── YYYY/                    # год (напр., 2025)
│   │               └── name.pdf             # файл в kebab-case
│   ├── programming/
│   └── other/
├── templates/              # Шаблоны LaTeX
│   ├── basic-cheatsheet.tex / .pdf
│   ├── math-formulas.tex / .pdf
│   └── two-column.tex / .pdf
├── Makefile                # Сборка PDF
├── setup-hooks.sh          # Установка git-hook’ов
├── CONTRIBUTING.md         # Как добавить материалы
├── LICENSE
└── README.md
```
