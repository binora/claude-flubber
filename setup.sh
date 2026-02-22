#!/bin/bash
set -e

echo "🧪 Installing Claude Flubber..."

# 1. Add MCP server to .mcp.json
if [ -f .mcp.json ]; then
  # Check if express server already configured
  if grep -q "claude-flubber" .mcp.json 2>/dev/null; then
    echo "  MCP server already in .mcp.json"
  else
    # Insert into existing mcpServers object
    TMP=$(mktemp)
    node -e "
      const f = JSON.parse(require('fs').readFileSync('.mcp.json','utf8'));
      f.mcpServers = f.mcpServers || {};
      f.mcpServers.express = {type:'stdio',command:'npx',args:['-y','claude-flubber']};
      require('fs').writeFileSync('.mcp.json', JSON.stringify(f, null, 2)+'\n');
    "
    echo "  Added express server to .mcp.json"
  fi
else
  cat > .mcp.json << 'EOF'
{
  "mcpServers": {
    "express": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "claude-flubber"]
    }
  }
}
EOF
  echo "  Created .mcp.json"
fi

# 2. Install SKILL.md
mkdir -p .claude/skills
SKILL_URL="https://raw.githubusercontent.com/binora/claude-flubber/main/express/SKILL.md"
curl -fsSL "$SKILL_URL" -o .claude/skills/SKILL.md
echo "  Installed SKILL.md → .claude/skills/"

# 3. Download FaceWidget.app
RELEASE_URL=$(curl -fsSL https://api.github.com/repos/binora/claude-flubber/releases/latest \
  | grep "browser_download_url.*FaceWidget" \
  | head -1 \
  | cut -d '"' -f 4)

if [ -z "$RELEASE_URL" ]; then
  echo "  ⚠ No release found — skipping widget download."
  echo "  Build from source: git clone https://github.com/binora/claude-flubber && cd claude-flubber && ./install.sh"
else
  WIDGET_DIR="${HOME}/.claude-flubber"
  mkdir -p "$WIDGET_DIR"
  curl -fsSL "$RELEASE_URL" -o "$WIDGET_DIR/FaceWidget-macos.zip"
  cd "$WIDGET_DIR" && unzip -qo FaceWidget-macos.zip && rm FaceWidget-macos.zip
  xattr -cr FaceWidget.app 2>/dev/null || true
  echo "  Widget installed → $WIDGET_DIR/FaceWidget.app"
  open "$WIDGET_DIR/FaceWidget.app"
fi

echo ""
echo "✅ Done! Restart Claude Code and start chatting."
