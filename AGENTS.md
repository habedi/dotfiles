# AGENTS.md

This file provides guidance to coding agents collaborating on this repository.

## Mission

This is a personal dotfiles repository: shell scripts, editor and Git configuration, technical notes, AI agent skills, etc.
There is no application to ship and no production runtime.
Priorities, in order:

1. Files that work as intended on a fresh Linux user account with bash.
2. Small, self-contained, easy-to-read shell and Markdown.
3. No surprise side effects: scripts must be safe to re-run.
4. Technical notes and skills that stay accurate and copy-pasteable.

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

- `scripts/`: Bash scripts for system setup and maintenance (font and CLI tool installers, GPU fix, snap cleanup, file concatenation, decompression
  helper, system updater, and a self-destruct helper).
- `git/gitconfig`: Personal Git configuration meant to be referenced from `~/.gitconfig` or copied directly.
- `docs/`: Markdown sources for the technical notes, built with MkDocs Material. Currently `docs/zig.md` and `docs/rust.md`, plus `docs/index.md` as the
  landing page.
- `mkdocs.yml`: MkDocs configuration. Theme, navigation, and Markdown extensions live here.
- `skills/`: Markdown skill files for AI agents. Each skill lives in its own directory with a `SKILL.md` entry point.
- `.editorconfig`: Editor defaults (UTF-8, LF, four-space indent, final newline, trimmed trailing whitespace; Markdown, HTML, and CSS keep trailing
  whitespace and allow longer lines).
- `pyproject.toml`: Python environment used to host the MkDocs toolchain (`mkdocs`, `mkdocs-material`) and developer tools like `pre-commit`. There is
  no Python application code.
- `.github/workflows/docs.yml`: GitHub Pages deploy job. Runs `uv run mkdocs build --strict` and pushes the generated `site/` to the `gh-pages` branch
  on push to `main` or `develop`, on any `v*` tag, or via manual workflow dispatch.
- `.github/ISSUE_TEMPLATE/`: Issue templates for bug reports and feature requests.
- `README.md`: Index of what the repository contains, with links to the deployed technical notes.

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

### Technical Notes

- Technical Notes are Markdown files in `docs/`, rendered by MkDocs Material.
- Each section is an `## H2`. Keep titles in title case.
- Open every section with a one-sentence lede paragraph.
- Code samples go in fenced code blocks with a language tag (` ```zig title="hello.zig" `, ` ```rust title="src/main.rs" `, etc.). The `title` is optional.
- Extended snippets and tables for a section live inside a collapsible block: `??? example "More examples"`, body indented by four spaces. Fenced code
  inside the body must also be indented by four spaces (works with `pymdownx.superfences`).
- Tables use plain Markdown table syntax, not HTML.
- Build locally with `uv run mkdocs serve`; build for deploy with `uv run mkdocs build --strict`.

### Markdown and Skills

- Skills follow the format already in `skills/slopify/SKILL.md`. Keep the front matter, the trigger description, and the section structure consistent
  across skills.
- Use fenced code blocks with a language tag (` ```bash `, ` ```python `, etc.).

## Validation

There is no test suite. Before opening a pull request:

- Run `shellcheck` against any shell script you touched (or added).
- For docs changes, run `uv run mkdocs build --strict` locally; the build must succeed.
- For visual changes, run `uv run mkdocs serve` and check both light and dark themes plus the search.
- Confirm the `docs.yml` workflow is unchanged unless your change is a deployment fix; if it is, document the reason in the PR.

## Commit and PR Hygiene

- Keep commits scoped to one logical change.
- PR descriptions should include:
    1. Behavioral change summary.
    2. Manual checks performed (shellcheck, browser preview, etc.).
    3. Whether the GitHub Pages deploy is affected.

Suggested PR checklist:

- [ ] `shellcheck` clean for any modified or new shell scripts
- [ ] Technical Note changes previewed in a browser (light and dark)
- [ ] README updated if a new script, technical note, or skill was added
- [ ] No machine-specific paths, secrets, or personal data introduced
