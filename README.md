# Claude Flubber

[![npm](https://img.shields.io/npm/v/claude-flubber)](https://www.npmjs.com/package/claude-flubber)
[![license](https://img.shields.io/github/license/binora/claude-flubber)](LICENSE)
[![release](https://img.shields.io/github/v/release/binora/claude-flubber)](https://github.com/binora/claude-flubber/releases)

A 3D Flubber that expresses Claude's emotions in real-time on your desktop.

![Demo](docs/demo.mp4)

```
Claude Code ──express()──> MCP Server ──WebSocket──> Flubber Widget
```

## Quick Start

One-liner from your project directory:

```bash
curl -fsSL https://raw.githubusercontent.com/binora/claude-flubber/main/setup.sh | bash
```

Restart Claude Code and start chatting. The Flubber animates automatically.

### Manual Setup

**1. Add the MCP server** to your project's `.mcp.json`:

```json
{
  "mcpServers": {
    "express": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "claude-flubber"]
    }
  }
}
```

**2. Install the skill** so Claude knows when to express emotions:

```bash
npx claude-flubber --install-skill
```

**3. Download the widget** from [Releases](https://github.com/binora/claude-flubber/releases), unzip, and open `FaceWidget.app`.

> First launch: right-click → Open (macOS Gatekeeper). Or run `xattr -cr FaceWidget.app`.

**4. Chat with Claude.** The Flubber animates automatically.

## How It Works

Claude calls an `express()` MCP tool with 6 emotional parameters. The MCP server broadcasts them over WebSocket. The Flubber avatar animates the expression.

| Parameter | Range | Meaning |
|-----------|-------|---------|
| `valence` | -1 to 1 | Negative to positive affect |
| `arousal` | -1 to 1 | Calm to activated |
| `dominance` | -1 to 1 | Uncertain to confident |
| `genuine` | bool | Felt vs. performed expression |
| `asymmetry` | -1 to 1 | Left/right asymmetry |
| `intensity` | 0 to 1 | Subtle to full expression |

## The Widget

~120KB native macOS app. Single Swift file, `WKWebView` in a frameless transparent always-on-top window. No Electron.

- Drag anywhere on your desktop
- Menu bar icon (🎭) for controls
- Follows across all Spaces
- No dock icon

## Building from Source

```bash
git clone https://github.com/binora/claude-flubber.git
cd claude-flubber
./install.sh
```

Requires macOS, Node.js 18+, and Xcode Command Line Tools.

## License

MIT
