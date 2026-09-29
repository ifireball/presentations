# Presentations

HTML slide decks and live demo materials, published as a static site.

**Live site:** [ifireball.github.io/presentations](https://ifireball.github.io/presentations/)

## What's here

Each top-level folder is a self-contained presentation with its own HTML pages, assets, and styles. The root landing page lists every presentation folder that contains `.html` files.

| Folder | Description |
|--------|-------------|
| [`fullsend-demo/`](fullsend-demo/) | Fullsend agentic SDLC slide deck and live demo walkthrough |
| [`fullsend-inro-for-adlc/`](fullsend-inro-for-adlc/) | Title and agenda for a Fullsend agent-building and contribution talk |
| [`fullsend-layered-configs/`](fullsend-layered-configs/) | Two-slide visual explanation of Fullsend configuration layers and runtime precedence drift |

Supporting scripts in [`scripts/`](scripts/) regenerate the landing page and prepare the GitHub Pages artifact. There is no bundler or compile step—the HTML files are served as-is.

## Local preview

Requires Node.js 22 (see [`mise.toml`](mise.toml)).

```bash
npm install
npm run dev
```

Open [http://127.0.0.1:4173/](http://127.0.0.1:4173/). The dev server regenerates `index.html` when presentation folders change.

## Adding a presentation

1. Create a new subdirectory with at least one `.html` file.
2. Run `npm run index` (or `npm run dev`) to update the landing page.

## Deployment

Pushes to `main` deploy to GitHub Pages via [`.github/workflows/pages.yml`](.github/workflows/pages.yml). The workflow runs `npm run pages`, which regenerates `index.html` and copies the static site into `_site/` for upload.
