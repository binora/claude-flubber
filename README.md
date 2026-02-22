# Claude Face

Give Claude a face. A floating avatar that expresses Claude's emotional state in real-time as you chat.

Claude calls an `express()` tool with 6 emotional parameters → an MCP server broadcasts them over WebSocket → a face avatar animates the expression. The avatar lives as a native macOS widget you can drag around your desktop like Clippy.

## Quick Start

```bash
git clone https://github.com/user/claude-face
cd claude-face
./install.sh
```

Then follow the printed instructions to configure your Claude Code project.

## How It Works

```
Claude Code ──express()──> MCP Server ──WebSocket──> Avatar UI
                           (stdio)     (port 3456)   (browser/widget)
```

**6 parameters** drive every expression:

| Parameter | Range | Meaning |
|-----------|-------|---------|
| `valence` | -1 to 1 | Negative to positive affect |
| `arousal` | -1 to 1 | Calm to activated |
| `dominance` | -1 to 1 | Uncertain to confident |
| `genuine` | bool | Felt vs. performed expression |
| `asymmetry` | -1 to 1 | Left/right facial asymmetry |
| `intensity` | 0 to 1 | Subtle to full expression |

Compound expressions emerge naturally: anger is negative valence + high arousal + high dominance. Concern is negative valence + low dominance. A wry smile is positive valence + asymmetry.

## Avatars

5 built-in avatars, switch between them from the menu bar or right-click:

| Avatar | Style |
|--------|-------|
| **Default** | Cute round face (SVG) |
| **Cat** | Ginger cat with anime eyes, ears, whiskers, tail |
| **Robot** | Retro mech with LED screen eyes and antenna |
| **Ghost** | Floating translucent spirit with glow |
| **Blob** | Amorphous slime that morphs and wobbles (Canvas) |

Browse all avatars at `http://localhost:3456` when the MCP server is running.

## Create Your Own Avatar

Copy `avatars/TEMPLATE.html` and customize it. The only contract:

1. Connect to `ws://localhost:3456`
2. Parse incoming JSON with the 6 expression parameters
3. Render however you want (SVG, Canvas, Three.js, CSS — anything)
4. Support `?widget` query param for transparent background

Drop your file in `avatars/` and it appears in the picker automatically.

## Project Structure

```
claude-face/
├── avatars/                 # Avatar HTML files (the plugin system)
│   ├── default.html         # Cute round face
│   ├── cat.html             # Ginger cat
│   ├── robot.html           # Retro robot
│   ├── ghost.html           # Floating ghost
│   ├── blob.html            # Amorphous blob
│   └── TEMPLATE.html        # Starter for new avatars
├── express/
│   └── SKILL.md             # Teaches Claude when/how to call express()
├── express-mcp-server/
│   ├── index.js             # MCP server + HTTP + WebSocket
│   └── package.json
├── FaceWidget.swift          # Native macOS widget (single file)
├── install.sh
└── README.md
```

## Requirements

- macOS (for the native widget; the browser UI works anywhere)
- Node.js 18+
- Xcode Command Line Tools (`xcode-select --install`)
- Claude Code

## The Native Widget

`FaceWidget.app` is a ~120KB native macOS app compiled from a single Swift file. No Electron, no Tauri — just `WKWebView` in a frameless, transparent, always-on-top window.

Features:
- Drag it anywhere on your desktop
- Menu bar icon (🎭) for avatar switching and controls
- Right-click the face for the same menu
- Small / Medium / Large sizes
- Follows across all Spaces
- No dock icon

## License

MIT
