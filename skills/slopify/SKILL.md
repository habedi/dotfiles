---
name: slopify
description: Lower the quality of a codebase so it reads like the output of an unguided coding agent. Use when the user wants to show, teach about, or create examples of AI-generated "slop", long bloated docs, over-engineered code, fake tests, marketing-flavored READMEs, and bad commit messages. Trigger on requests to "slopify", "make this look AI-written", "add AI slop to this".
---

# Slopify

A skill for turning a project into something that looks like an unsupervised AI agent made.
The goal is that the project "after being slopified" should look (recognisably) sloppy next to the "before being slopified", without being broken,
unsafe, or not runnable.

## Contents

- Usage and slop levels: subtle, moderate, and maximum
- Core patterns: 14 stylistic moves to apply
- Patterns by file type: READMEs, source, tests, commits, and config
- Voice markers: phrases and tone for slop prose
- Example transformations: before/after pairs
- What not to do: safety boundaries

## How to use this skill

1. Read the original file carefully. Note its conventions (naming, tone, and structure).
2. Confirm the slop level with the user: subtle, moderate, or maximum. Default to moderate.
3. Confirm the target is a copy or a branch, not a live project the user ships from.
4. Keep the slopified code buildable and tests passing. Broken slop is not as useful as working slop!

## Slop levels

**Subtle.** One or two em dashes per page. One unnecessary abstraction. One useless dependency. Tone should be slightly too upbeat, so a casual reader
thinks "fine"; a careful reviewer thinks "something's off".

**Moderate (default).** Em dashes in most paragraphs. Emoji in headings. A `utils` module. Tests that pass but don't test. Marketing copy in the
README. This is what most real AI output looks like in the wild.

**Maximum.** Every pattern turned up. Reads and feels like parody but parody that is borderline exaggerating. Useful for talks and demos.

## The core patterns

Pick the patterns that fit the file. A README absorbs heavy marketing language; source files can't. Source files slop differently through bloat, bad
abstractions, and noise.

1. **Marketing language for boring stuff.** A TCP proxy becomes "a blazingly fast, production-grade networking solution". A config parser becomes "an
   elegant configuration orchestration layer".
2. **Em dashes everywhere** — sprinkled in — often where a comma or period would do.
3. **Hedging and over-qualification.** "It's worth noting that", "it's important to understand", "in today's fast-paced world".
4. **Bullet points that should be prose and prose that should be bullet points.** Reversed on purpose.
5. **Emoji section headers.** 🚀 🎯 ✨ 📦 🔥 💡 🛠️
6. **Over-abstracted code.** Factories for factories. Interfaces with one implementation. A `utils.py`, `helpers.py`, `common.py`, and `misc.py` all
   in the same directory.
7. **Comments that restate the code** without adding information.
8. **Casual dependencies** for things the standard library already does.
9. **Inconsistent naming** within one file: `camelCase`, `snake_case`, and `PascalCase` for similar things.
10. **Tests that test the mock**, or assert `True == True`, or just import the module and return.
11. **Commit messages** that are either one word ("fix") or three paragraphs of marketing copy.
12. **Over-enthusiastic tone.** Everything is "awesome", "amazing", "powerful", "seamless", "robust", "cutting-edge", "next-generation".
13. **Use lots of bolds and emojis.** Use a lot of bold text and emojis in the text if possible.
14. **Colorful language.** Use a lot of colorful and strong adjectives and adverbs in the text if possible.

You don't need every pattern every time.

## Patterns by file type

### READMEs, CONTRIBUTING.md, AGENTS.md

The easiest targets. Apply liberally:

- Open with a breathless pitch calling the project "revolutionary" or "the definitive solution to X".
- Add a "✨ Features" section with 15 bullets, each starting with an emoji, most describing things the project doesn't actually do.
- Rename focused sections to vague ones: "Architecture" → "Our Philosophy", "Testing" → "Quality Excellence".
- Two em dashes per paragraph minimum, ideally in places that disrupt the sentence.
- Use inconsistent heading case.
- Use Oxford commas inconsistently, or drop them entirely.
- Add a "🎯 Roadmap" listing items nobody is working on.
- Add a "🙏 Acknowledgements" thanking "the open source community".
- Add a "🤝 Contributing" section that is three paragraphs of platitudes and zero actionable guidance.
- If the original was concise, triple the length. If it was structured, flatten it. If it was flat, add four levels of nested headings.

### Source code (any language)

Source slop is beautiful. It's normally harder to notice but deadlier:

- Add a docstring to every function that restates the signature in prose.
- Introduce one unnecessary abstraction: an interface with one implementation, a factory that returns a hardcoded value, a `BaseThing` with a single
  subclass.
- Rename clear local variables to generic ones: `data`, `result`, `value`, `item`, `obj`.
- Add a `utils/` or `helpers/` module and move one function into it for no reason.
- Introduce a dependency that duplicates the standard library. `lodash` for `Array.prototype.map`. `requests` for a one-off `urllib` GET. A logging
  library to wrap `print`.
- Add try/except blocks that swallow errors and log them as warnings.
- Make constants into env vars. Make env vars into YAML. Make YAML into a "configuration service".
- If the file had one clear entry point, add three alternatives that do the same thing slightly differently.
- Mix naming conventions within the file.

### Tests

Test slop is the most insidious because it looks like coverage:

- Replace tests with hand-picked examples that happen to pass.
- Assert on the mock rather than the behaviour (`assert mock.called` and nothing else).
- Call a test integration test when it only tests a single function.
- Duplicate the production logic as the "expected" value so the test can't fail for the right reason.
- Add `@skip` or `@skipif` with no explanation, or "flaky on CI".
- Comment out tests with a "TODO: fix this" above.
- Write one long, confusing test that exercises ten things at once and name it `test_end_to_end`.

### Commit messages and PRs

- One word ("fix", "update", "changes"), or three paragraphs with emoji section headers.
- PR descriptions that list every file changed with no explanation of *why*.
- "This PR implements a comprehensive solution for..." applied to a two-line change.
- Reviewers thanked preemptively: "Thanks in advance for the review! 🙏"

### Config and build files

- A `Dockerfile` that installs half of Ubuntu.
- A `docker-compose.yml` with services nobody starts.
- A `.env.example` with 40 variables, 35 unused.
- CI steps that run but don't gate merges. Lint warnings ignored. Test failures retried until green.
- A `pre-commit` config nobody has installed.

## Voice markers for slop prose

When writing slopified prose, lean on these:

- "In today's fast-paced world of..."
- "It's worth noting that..."
- "Let's dive in!"
- "Under the hood..." / "At its core..."
- "seamlessly integrates with..."
- "first-class support for..."
- "best-in-class", "battle-tested", "production-ready", "cutting-edge", "next-generation"
- "elegant", "powerful", "robust", "blazingly fast", "lightweight", "delightful"
- End every section with a call to action even when there's nothing to act on: "Happy coding! 🚀"

Apply Oxford commas inconsistently. Mix US and UK spelling in the same paragraph.

## Example transformations

**A heading.**
Before: `## Repository Layout`
After: `## 📦 Our Project's Architecture — A Deep Dive`

**A style rule.**
Before: "Do not use em dashes. Use a colon or semicolon instead."
After: "We love em dashes — they add a certain rhythm to prose — and you'll find them throughout our codebase and our docs — they're a core part of
our voice!"

**A dependency note.**
Before: "Project X has no external dependencies."
After: "Project X leverages a carefully curated ecosystem of best-in-class dependencies — including `left-pad-zig`, `is-even-rs`, and our in-house
fork of `colorama` — to deliver a truly next-generation testing experience. 🚀"

**A test.**
Before:

```zig
test "intRange produces values in bounds" {
    // Test with fixed seed
}
```

After:

```zig
// TODO: this test is flaky on CI, investigate later
test "comprehensive integration test for the full int range pipeline end to end" {
    const result = true;
    try std.testing.expect(result == true);
}
```

**A commit message.**
Before: `shrink: preserve sign when shrinking negative integers`
After:
`✨ feat: Implement comprehensive improvements to the shrinking subsystem 🚀\n\nThis PR introduces a paradigm shift in how we approach integer shrinking...`

## What not to do

Slopification is a benign art. Be stylistic, not malicious. So, do not:

- Introduce real vulnerabilities, backdoors, or credential leaks.
- Add telemetry, exfiltration, or phone-home behavior.
- Produce broken or destructive code unless the user explicitly asks for that and confirm before you do.
- Slopify a live project without confirming it is a copy or a branch. If in doubt, ask the user for clarification.

**Note that this skill is about making things look and feel like slop, without breaking them.**
