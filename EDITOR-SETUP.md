# 🎯 Настройка редактора для чистой работы с LaTeX

## 🎯 Проблема
При нажатии `Ctrl+S` в редакторе (VS Code с LaTeX Workshop) создавались мусорные файлы прямо в папках с исходниками, что загрязняло структуру проекта.

## ✅ Решение

### **Созданы настройки VS Code (.vscode/settings.json)**
- ✅ **Автоматическая компиляция при сохранении** - `Ctrl+S` компилирует LaTeX
- ✅ **Временные файлы в build/** - все `.aux`, `.log`, `.fls` идут в `build/`
- ✅ **Автоматическая очистка** - мусорные файлы удаляются после компиляции
- ✅ **Правильные пути** - `%DIR%/../../../build` для всех файлов

### **Созданы задачи VS Code (.vscode/tasks.json)**
- ✅ **Ctrl+Shift+P → "Tasks: Run Task"** - доступны команды:
  - `LaTeX: Build with clean output` - компиляция через `make build`
  - `LaTeX: Clean temporary files` - очистка через `make clean`
  - `LaTeX: Check style` - проверка стиля через `make check`

## 🚀 Как использовать

### **Автоматическая работа:**
1. **Откройте `.tex` файл** в VS Code
2. **Нажмите `Ctrl+S`** - LaTeX скомпилируется автоматически
3. **Временные файлы** создадутся в `build/`, исходники останутся чистыми
4. **PDF обновится** автоматически

### **Ручные команды:**
- **`Ctrl+Shift+P`** → `Tasks: Run Task` → `LaTeX: Build with clean output`
- **`Ctrl+Shift+P`** → `Tasks: Run Task` → `LaTeX: Clean temporary files`
- **`Ctrl+Shift+P`** → `Tasks: Run Task` → `LaTeX: Check style`

### **Терминальные команды:**
```bash
make build    # Компиляция
make clean    # Очистка
make check    # Проверка стиля
make status   # Статистика
```

## 📁 Структура после настройки

```
hse-ami-cheatsheets/
├── .vscode/                    # Настройки VS Code
│   ├── settings.json          # LaTeX Workshop настройки
│   └── tasks.json             # Задачи для VS Code
├── build/                     # Временные файлы LaTeX
│   ├── main.pdf
│   ├── main.aux
│   ├── main.log
│   └── ...
└── cheatsheets/math/differential-equations/
    ├── main.tex               # Исходники (чистые!)
    ├── main.pdf               # Готовый PDF
    └── preparation/topics/
```

## ⚙️ Технические детали

### **Настройки LaTeX Workshop:**
- `latex-workshop.latex.outDir`: `%DIR%/../../../build`
- `latex-workshop.latex.auxDir`: `%DIR%/../../../build`
- `latex-workshop.latex.autoBuild.run`: `onSave`
- `latex-workshop.latex.autoClean.run`: `onBuilt`

### **Очищаемые файлы:**
- `.aux`, `.log`, `.fls`, `.out`, `.toc`
- `.fdb_latexmk`, `.synctex.gz`
- `.bbl`, `.blg`, `.idx`, `.ind`
- `.nav`, `.snm`, `.vrb`, `.run.xml`
- И многие другие...

## 🎉 Результат

- ✅ **`Ctrl+S` работает чисто** - временные файлы не попадают в исходники
- ✅ **Автоматическая компиляция** - не нужно запускать команды вручную
- ✅ **Чистая структура проекта** - только исходники в папках
- ✅ **Удобные задачи** - быстрый доступ к командам через VS Code
- ✅ **Совместимость** - работает с существующими `make` командами

**Теперь `Ctrl+S` работает идеально!** 🎯
