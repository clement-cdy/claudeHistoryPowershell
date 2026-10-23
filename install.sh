#!/usr/bin/env sh
# Installe claudeHistory et ses commandes associées.
#   curl -fsSL https://raw.githubusercontent.com/davidnurdin/claudeHistory/main/install.sh | sh
set -eu

REPO_RAW="https://raw.githubusercontent.com/davidnurdin/claudeHistory/main"
BIN_DIR="${CLAUDE_HISTORY_BIN:-$HOME/.local/bin}"
ALIASES="selectSessions exportClaudeHistory importClaudeHistory"

command -v python3 >/dev/null 2>&1 || { echo "✗ python3 est requis." >&2; exit 1; }

mkdir -p "$BIN_DIR"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

echo "→ Téléchargement de claudeHistory…"
if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$REPO_RAW/claudeHistory" -o "$tmp"
elif command -v wget >/dev/null 2>&1; then
    wget -qO "$tmp" "$REPO_RAW/claudeHistory"
else
    echo "✗ curl ou wget est requis." >&2; exit 1
fi

python3 -m py_compile "$tmp" 2>/dev/null || { echo "✗ Fichier téléchargé invalide." >&2; exit 1; }
install -m 755 "$tmp" "$BIN_DIR/claudeHistory"
for name in $ALIASES; do
    ln -sf claudeHistory "$BIN_DIR/$name"
done

echo "✓ Installé dans $BIN_DIR : claudeHistory $ALIASES"
case ":$PATH:" in
    *":$BIN_DIR:"*) ;;
    *) echo "⚠ $BIN_DIR n'est pas dans votre PATH. Ajoutez à votre ~/.bashrc ou ~/.zshrc :"
       echo "    export PATH=\"$BIN_DIR:\$PATH\"" ;;
esac
echo "Lancez : claudeHistory"
