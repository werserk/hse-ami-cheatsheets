#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
for arg in "$@"; do
    case "$arg" in
        --dry-run)
            DRY_RUN=1
            ;;
    esac
done

echo "[deps] Detecting package manager..."

detect_pm() {
    if command -v apt-get >/dev/null 2>&1; then
        echo apt
    elif command -v dnf >/dev/null 2>&1; then
        echo dnf
    elif command -v pacman >/dev/null 2>&1; then
        echo pacman
    elif command -v zypper >/dev/null 2>&1; then
        echo zypper
    elif command -v brew >/dev/null 2>&1; then
        echo brew
    else
        echo unknown
    fi
}

PM=$(detect_pm)

if [[ "$PM" == "unknown" ]]; then
    echo "[deps] Unsupported system. Please install TeX Live (LaTeX), BibTeX, and Make manually."
    exit 1
fi

echo "[deps] Using package manager: $PM"

run() {
    if [[ "$DRY_RUN" -eq 1 ]]; then
        echo "+ $*"
    else
        eval "$@"
    fi
}

case "$PM" in
    apt)
        if [[ "$DRY_RUN" -eq 1 ]]; then
            echo "+ sudo apt-get update -y"
            echo "+ sudo apt-get install -y make latexmk texlive-latex-recommended texlive-latex-extra texlive-fonts-recommended texlive-lang-cyrillic texlive-bibtex-extra"
        else
            sudo apt-get update -y
            sudo apt-get install -y \
                make \
                latexmk \
                texlive-latex-recommended \
                texlive-latex-extra \
                texlive-fonts-recommended \
                texlive-lang-cyrillic \
                texlive-bibtex-extra
        fi
        ;;
    dnf)
        if [[ "$DRY_RUN" -eq 1 ]]; then
            echo "+ sudo dnf -y install make texlive-scheme-medium texlive-latexmk"
        else
            sudo dnf -y install \
                make \
                texlive-scheme-medium \
                texlive-latexmk
        fi
        ;;
    pacman)
        if [[ "$DRY_RUN" -eq 1 ]]; then
            echo "+ sudo pacman -Sy --noconfirm"
            echo "+ sudo pacman -S --noconfirm make texlive-basic texlive-latex texlive-latexrecommended texlive-latexextra texlive-fontsextra texlive-langcyrillic texlive-binextra"
        else
            sudo pacman -Sy --noconfirm
            # Arch splits TeX Live into many packages; this set covers what's used here
            sudo pacman -S --noconfirm \
                make \
                texlive-basic \
                texlive-latex \
                texlive-latexrecommended \
                texlive-latexextra \
                texlive-fontsextra \
                texlive-langcyrillic \
                texlive-binextra
        fi
        ;;
    zypper)
        if [[ "$DRY_RUN" -eq 1 ]]; then
            echo "+ sudo zypper refresh"
            echo "+ sudo zypper install -y make texlive texlive-latex texlive-collection-latexrecommended texlive-collection-latexextra texlive-babel-russian texlive-latexmk"
        else
            sudo zypper refresh
            sudo zypper install -y \
                make \
                texlive \
                texlive-latex \
                texlive-collection-latexrecommended \
                texlive-collection-latexextra \
                texlive-babel-russian \
                texlive-latexmk
        fi
        ;;
    brew)
        if [[ "$DRY_RUN" -eq 1 ]]; then
            echo "+ brew update"
            echo "+ brew install --cask mactex-no-gui || brew install --cask mactex"
        else
            brew update
            # macOS users: prefer no-GUI cask to save space; fallback to full MacTeX
            brew install --cask mactex-no-gui || brew install --cask mactex
        fi
        ;;
esac

echo "[deps] Done. You can now build with 'make'."


