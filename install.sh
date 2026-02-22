#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Installing Claude Flubber"

# 1. Install dependencies
echo "==> Installing dependencies..."
cd "$SCRIPT_DIR"
npm install --silent

# 2. Build native Mac app
echo "==> Building FaceWidget.app..."
swiftc -framework Cocoa -framework WebKit FaceWidget.swift -o FaceWidget

mkdir -p FaceWidget.app/Contents/MacOS
cp FaceWidget FaceWidget.app/Contents/MacOS/FaceWidget
cp macos/Info.plist FaceWidget.app/Contents/Info.plist

echo "==> Built FaceWidget.app"

# 3. Print setup instructions
MCP_SERVER_PATH="$SCRIPT_DIR/express-mcp-server/index.js"

echo ""
echo "==> Setup complete!"
echo ""
echo "Next steps:"
echo ""
echo "  1. Add to your project's .mcp.json:"
echo ""
echo '     {'
echo '       "mcpServers": {'
echo '         "express": {'
echo '           "type": "stdio",'
echo '           "command": "node",'
echo "           \"args\": [\"$MCP_SERVER_PATH\"]"
echo '         }'
echo '       }'
echo '     }'
echo ""
echo "  2. Install the expression skill:"
echo "     npx claude-flubber --install-skill"
echo ""
echo "  3. Launch the widget:"
echo "     open $SCRIPT_DIR/FaceWidget.app"
echo ""
