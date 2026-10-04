# Hugo Migration Implementation Plan

> Execute inline using the executing-plans workflow. The user approved the migration after reviewing the design and content compatibility constraints.

**Goal:** Migrate the blog to Hugo/PaperMod while preserving all nine article bodies, dates, taxonomies, URLs, and four image files.

**Architecture:** Official PaperMod pinned as a Git submodule. Hugo mounts `_posts/` as article content and `assets/images/` as static images, preserving local editor paths as well as web URLs. Keep `bin/serve` and `bin/new` as the operational entry points; GitHub Actions builds `public/`.

**Tech Stack:** Hugo 0.163.3, PaperMod `d3768854d00ad003b0a8dbdba254ce9224377a01`, Mermaid 11, MathJax 3, GitHub Pages.

**Spec:** [Migration design](../../lilian-weng-blog-migration.md), refined by the user's instruction to prioritize content, Markdown, and file references.

## Global Constraints

- Preserve article Markdown bodies byte for byte; change only front matter.
- Preserve existing article and page URLs, `/assets/images/` paths, and `/feed.xml` compatibility.
- Keep Giscus repository and pathname mapping; absent IDs remain an explicit external prerequisite.
- Do not push or publish, or modify unrelated local files.

## Task 1: Capture baseline and install the runtime/theme

- [x] Build the existing Jekyll site into `/tmp/junjie-blog-before-hugo` and export article URLs, metadata, and body hashes.
- [x] Create `codex/hugo-papermod`, install the checksum-verified official Hugo binary, and add PaperMod at the pinned commit.
- [x] Verify `hugo version` and the theme commit.

## Task 2: Convert content and configure rendering

- [x] Mount `_posts/` into Hugo's `content/posts/`; preserve bodies and filenames, normalize dates/empty lists, and add explicit old URLs.
- [x] Mount all four original `assets/images/` files as static images; preserve VS Code and Obsidian configuration and relative image-link support.
- [x] Create `hugo.yaml`, archive/search/About pages, Mermaid and math support, guarded Giscus integration, and the legacy RSS output.
- [x] Build with `hugo --gc --minify`; compare all article bodies/metadata and image hashes against the baseline.

## Task 3: Update operational entry points and deployment

- [x] Make `bin/serve` launch Hugo from the repository root and `bin/new` generate Hugo front matter in `_posts/` without overwriting articles.
- [x] Replace Ruby build steps in `.github/workflows/pages.yml` with pinned Hugo, recursive theme checkout, and `public/` upload.
- [x] Update `.gitignore` and add README startup/new-post instructions; remove superseded Jekyll configuration/templates after the conversion verifies.
- [x] Verify shell/YAML syntax, actual new-post behavior in a temporary directory, and production build output.

## Task 4: Verify and deliver the running preview

- [x] Start `./bin/serve` on 1313 and check all old URLs and entry pages over HTTP.
- [x] Verify article HTML, image references, HTML/footnotes/tables, three Mermaid definitions, TeX preservation, configured Giscus attributes, and Chinese/English Fuse search.
- [ ] Verify actual diagram/math display and desktop/narrow layouts in the browser. The browser approval policy rejected reading the existing localhost tab; no workaround was attempted.
- [x] Check `git diff --check`, update this checklist, and report the running preview plus any external prerequisites.
