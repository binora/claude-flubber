# Claude Face

A 3D Flubber avatar that expresses Claude's emotions in real-time on your desktop.

Claude calls `express()` → MCP server broadcasts over WebSocket → Flubber animates. Native macOS widget, no Electron.

## Setup

```bash
./install.sh
```

Follow the printed instructions to wire up the MCP server to your Claude Code project, then:

```bash
open FaceWidget.app
```

## How It Works

```
Claude Code ──express()──> MCP Server ──WebSocket──> Flubber Widget
               (stdio)     (port 3456)               (native macOS)
```

Six parameters drive every expression: `valence`, `arousal`, `dominance`, `genuine`, `asymmetry`, `intensity`. Compound emotions emerge from combinations — anger is negative valence + high arousal + high dominance, excitement is positive valence + high arousal, etc.

## The Widget

~120KB native macOS app from a single Swift file. `WKWebView` in a frameless transparent always-on-top window.

- Drag anywhere on your desktop
- Menu bar icon for controls
- Right-click for context menu
- Follows across all Spaces
- No dock icon

## Requirements

- macOS
- Node.js 18+
- Xcode Command Line Tools

## License

MIT
