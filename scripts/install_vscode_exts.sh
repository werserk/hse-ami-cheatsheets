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

extensions=(
    "James-Yu.latex-workshop"
    "streetsidesoftware.code-spell-checker"
    "streetsidesoftware.code-spell-checker-russian"
    "valentjn.vscode-ltex"
)

# Pick whichever CLI is available
CODE_BIN=""
for bin in code codium code-insiders; do
    if command -v "$bin" >/dev/null 2>&1; then
        CODE_BIN="$bin"
        break
    fi
done

if [[ -z "$CODE_BIN" ]]; then
    echo "[vscode] VS Code CLI not found. Install VS Code/VSCodium and ensure 'code' or 'codium' is in PATH."
    exit 1
fi

echo "[vscode] Installing recommended extensions via $CODE_BIN ..."
for ext in "${extensions[@]}"; do
    echo "  -> $ext"
    if [[ "$DRY_RUN" -eq 1 ]]; then
        echo "+ $CODE_BIN --install-extension $ext --force"
    else
        "$CODE_BIN" --install-extension "$ext" --force >/dev/null || true
    fi
done

echo "[vscode] Extensions installation finished."


