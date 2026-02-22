#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Installing Claude Face"

# 1. Install MCP server dependencies
echo "==> Installing MCP server dependencies..."
cd "$SCRIPT_DIR/express-mcp-server"
npm install --silent

# 2. Build native Mac app
echo "==> Building FaceWidget.app..."
cd "$SCRIPT_DIR"
swiftc -framework Cocoa -framework WebKit FaceWidget.swift -o FaceWidget

mkdir -p FaceWidget.app/Contents/MacOS
cp FaceWidget FaceWidget.app/Contents/MacOS/FaceWidget

if [ ! -f FaceWidget.app/Contents/Info.plist ]; then
  cat > FaceWidget.app/Contents/Info.plist << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>FaceWidget</string>
    <key>CFBundleDisplayName</key>
    <string>Claude Face</string>
    <key>CFBundleIdentifier</key>
    <string>com.claude.facewidget</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleExecutable</key>
    <string>FaceWidget</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsLocalNetworking</key>
        <true/>
    </dict>
</dict>
</plist>
PLIST
fi

echo "==> Built FaceWidget.app"

# 3. Configure MCP server for Claude Code
MCP_SERVER_PATH="$SCRIPT_DIR/express-mcp-server/index.js"

echo ""
echo "==> Setup complete!"
echo ""
echo "Next steps:"
echo ""
echo "  1. Add the MCP server to your project's .mcp.json:"
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
echo "  2. Add to your project's .claude/settings.local.json:"
echo ""
echo '     {'
echo '       "enableAllProjectMcpServers": true,'
echo '       "permissions": { "allow": ["mcp__express__express"] }'
echo '     }'
echo ""
echo "  3. Copy the skill into your project:"
echo "     cp $SCRIPT_DIR/express/SKILL.md /path/to/your/project/.claude/skills/"
echo ""
echo "  4. Restart Claude Code, then launch the widget:"
echo "     open $SCRIPT_DIR/FaceWidget.app"
echo ""
echo "  5. Browse avatars at http://localhost:3456"
echo ""
