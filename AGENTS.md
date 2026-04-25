# AGENTS.md

This file provides guidance to coding agents collaborating on this repository.

## Mission

This is a personal dotfiles repository: shell scripts, editor and Git configuration, single-page HTML cheatsheets, AI agent skills, etc.
There is no application to ship and no production runtime.
Priorities, in order:

1. Files that work as intended on a fresh Linux user account with bash.
2. Small, self-contained, easy-to-read shell and Markdown.
3. No surprise side effects: scripts must be safe to re-run.
4. Cheatsheets and skills that stay accurate and copy-pasteable.

## Core Rules

- Use English for code, comments, and docs.
- Prefer small, focused changes over large refactoring.
- Add comments only when they clarify non-obvious behavior.
- Do not add features, error handling, or abstractions beyond what the current
  task needs.
- Do not write a new file when editing an existing one is enough.
- Never commit secrets, tokens, or paths tied to a single machine.

## Writing Style

- Use Oxford commas in inline lists: "a, b, and c" not "a, b, c".
- Do not use em dashes. Restructure the sentence, or use a colon or semicolon instead.
- Avoid colorful adjectives and adverbs. Write "TCP proxy" not "lightweight TCP proxy", "install script" not "convenient install script".
- Use noun phrases for checklist items, not imperative verbs. Write "redundant index detection" not "detect redundant indexes".
- Headings in Markdown files must be in title case: "Build from Source" not "Build from source". Minor words (a, an, the, and, but, or, for, in, on,
  at, to, by, of) stay lowercase unless they are the first word.

## Repository Layout

- `scripts/`: Bash scripts for system setup and maintenance (font and CLI tool installers, GPU fix, snap cleanup, file concatenation, and a
  self-destruct helper).
- `git/gitconfig`: Personal Git configuration meant to be referenced from `~/.gitconfig` or copied directly.
- `cheatsheets/`: Single-page HTML cheatsheets (currently Zig and Rust). Each cheatsheet is one self-contained `index.html` with embedded CSS and JS,
  no external assets or build step.
- `skills/`: Markdown skill files for AI agents. Each skill lives in its own directory with a `SKILL.md` entry point.
- `.editorconfig`: Editor defaults (UTF-8, LF, four-space indent, final newline, trimmed trailing whitespace; Markdown, HTML, and CSS keep trailing
  whitespace and allow longer lines).
- `pyproject.toml`: Lightweight Python environment used only to host developer tools like `pre-commit`. There is no Python application code.
- `.github/workflows/docs.yml`: GitHub Pages deploy job. Stages `cheatsheets/` into a `site/` directory and pushes it to the `gh-pages` branch on push
  to `main` or any `v*` tag.
- `.github/ISSUE_TEMPLATE/`: Issue templates for bug reports and feature requests.
- `README.md`: Index of what the repository contains, with links to the deployed cheatsheets.

## Conventions

### Shell Scripts

- First line is `#!/usr/bin/env bash` (or `#!/bin/bash` only when matching existing scripts).
- Start every new script with `set -euo pipefail` so failures and unset variables are not silent.
- Quote variable expansions: `"$file"`, not `$file`.
- Use `command -v tool >/dev/null` to detect a tool before calling it.
- Scripts must be safe to re-run. Skip work that has already been done rather than failing on the second run.
- Destructive operations (delete, overwrite, system-wide install) print what they will do and prompt for confirmation, unless the script's name makes
  the intent unambiguous.
- Keep dependencies on non-default tools to a minimum, and document any in a comment near the top of the file.

### HTML Cheatsheets

- Each cheatsheet is a single `index.html` that opens correctly when loaded from the local filesystem and when served from GitHub Pages.
- No external scripts, no CDN fonts, and no network calls. CSS and JS are inlined.
- Support both light and dark themes via `prefers-color-scheme`.
- Sections have stable `id` attributes and are picked up by the table of contents script automatically.
- Code samples go in `<pre>` blocks. Use the existing inline syntax classes (`k`, `s`, `n`, `c`, `t`, ...) rather than a syntax-highlighting library.

### Markdown and Skills

- Skills follow the format already in `skills/slopify/SKILL.md`. Keep the front matter, the trigger description, and the section structure consistent
  across skills.
- Use fenced code blocks with a language tag (` ```bash `, ` ```python `, etc.).

## Validation

There is no test suite. Before opening a pull request:

- Run `shellcheck` against any shell script you touched (or added).
- Open changed cheatsheets in a browser; verify the table of contents builds,
  the search filter works, and dark and light themes both render.
- Confirm the `docs.yml` workflow is unchanged unless your change is a deployment fix; if it is, document the reason in the PR.

## Commit and PR Hygiene

- Keep commits scoped to one logical change.
- PR descriptions should include:
    1. Behavioral change summary.
    2. Manual checks performed (shellcheck, browser preview, etc.).
    3. Whether the GitHub Pages deploy is affected.

Suggested PR checklist:

- [ ] `shellcheck` clean for any modified or new shell scripts
- [ ] Cheatsheet changes previewed in a browser (light and dark)
- [ ] README updated if a new script, cheatsheet, or skill was added
- [ ] No machine-specific paths, secrets, or personal data introduced
