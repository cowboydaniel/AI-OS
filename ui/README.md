# UI Directory

Use this space for the AI Desktop Shell frontend. Organize static assets (HTML/CSS/JS), build tooling, and design documentation here. Keep the Mint-inspired visual language consistent and note any third-party libraries in a local `LICENSES` file when they are added.

## Shell preview

`index.html` hosts the phase 4 desktop shell stub:
- A Mint-inspired wallpaper with a glassy terminal mock.
- Side navigation toggling Overview, Workspace, and Settings content.
- Responsive layout that stacks navigation on smaller screens.

## Develop and test

No build toolchain is required for this static preview.

1. Serve the UI locally (choose any simple HTTP server):
   - `cd ui`
   - `python -m http.server 8000` or `npx serve .`
2. Open `http://localhost:8000` in a browser to interact with navigation and terminal mock content.
3. For linting/formatting, follow repository conventions if tooling is added later; this stub intentionally uses plain HTML/CSS/JS.

## Next steps

Future phases can extend this scaffold with application launchers, AI status indicators, and integrations with the core services defined elsewhere in the roadmap.
