# html-review-skill

A Claude Code skill that renders a document, spec, code change, or design proposal into a
**side-by-side review HTML** — content + AI rationale annotations + per-section feedback
collector.

**Pluggable design system.** Bundles the **DNA1 ("Evidence Poet")** spec as the default
visual style. Accept any external spec following the simple `spec-interface.md` contract.

> DNA1 default character: *academic journal × architecture magazine — mono labels for
> information order, serif headlines for narrative weight, gold lines for moments worth
> pausing. Sharp corners. CJK-safe font stacks (Microsoft YaHei first). Restrained,
> rational, never cold.*

---

## Install

```bash
git clone https://github.com/mengzhou0125/html-review-skill.git
cd html-review-skill
./install.sh          # macOS / Linux / Git Bash
.\install.ps1         # Windows PowerShell
```

Idempotent — re-run to update. Copies the skill to `~/.claude/skills/html-review-skill/`.

---

## Trigger it

```
render this doc as a review HTML
build a review HTML for [spec / case study / PR / blog draft]
review this in HTML · side-by-side with annotations
用 HTML 出 review · review 这篇 [文档名]
/html-review
```

---

## How it works

1. **Step 0 · Resolve a spec** — `--spec=<path>` arg · or auto-detect
   `<project>/.claude/design.md` · or fall back to bundled `specs/dna1-default.md`
2. Asks **one bootstrap question** (what + how long) and infers:
   - **Layout archetype** A (right-rail · sticky annotation rail beside content) vs B
     (stacked · annotations inline under content)
   - **Tag profile** A (editorial · 3 status × 4 layer) vs B (technical · 3 axes × 3
     variants = 9 colors)
   - **Review roles** to apply (Layer 0 baseline always on + Layer 1+ role-specific lenses)
3. Generates a single `.html` file:
   - `<html lang="zh-Hans-CN">` + spec-driven fonts (CJK fallback chain stays YaHei-first)
   - Left ToC + per-section content + annotations + per-section `.user-feedback` block
   - Fixed "📋 Copy all feedback" button — serializes every feedback block to clipboard
     on demand · the page saves no data
4. For re-reviews: applies **DIFF mode** (section-level state tags · changed-section gold
   tint + changebar · unchanged-section fold + dim · rail-trim)

For independent design-system compliance audit (separate from the skill's structural
validation): use a spec-driven auditor. The
[`evidence-poet-auditor`](https://github.com/mengzhou0125/evidence-poet-design-system) covers
DNA1; for other specs, bring your own.

---

## Pluggable design system

Three ways the skill resolves which spec to use, in priority order:

| Priority | Source | When |
|---|---|---|
| 1 | `--spec=<path>` arg or user prompt names a path | explicit |
| 2 | `<project>/.claude/design.md` | EPDS installed or similar |
| 3 | bundled `specs/dna1-default.md` | default · DNA1 |

To bring your own spec, write a markdown file with a §0 JSON block following the contract
in [`references/spec-interface.md`](references/spec-interface.md). The contract is narrow
(~20 tokens) — colors · fonts · spacing · font sizes · line widths · corner convention.

**Tool's visual identity stays constant** — the `--review-*` and `--audit-*` extension
tokens (tag profile colors) are tool-defined and don't depend on the loaded spec. The
spec provides the base palette; the tool builds its UI on top. Fork the skill if you
need different tag colors.

---

## What it does NOT do

- Does not install a design system into your project — for DNA1, use
  [evidence-poet-installer](https://github.com/mengzhou0125/evidence-poet-design-system)
- Does not edit the source document being reviewed (the rail proposes; the human decides;
  the edit is a separate step)
- Does not save user feedback (the page is ephemeral — collector serializes to clipboard
  on demand)
- Does not audit its own output — use a spec-driven auditor (see "Verification" above)

---

## Companion tools

| Tool | Repo | Role |
|---|---|---|
| `evidence-poet-design-system` | [evidence-poet-design-system](https://github.com/mengzhou0125/evidence-poet-design-system) | The DNA1 design system: installer + builder + auditor. The visual style bundled here as `specs/dna1-default.md`. |
| `svg-diagram-skill` | [svg-diagram-skill](https://github.com/mengzhou0125/svg-diagram-skill) | Sibling tool · same pluggable-spec pattern · for standalone SVG diagrams |

---

## Files

```
SKILL.md                     Claude's manifest
README.md                    this file
LICENSE                      MIT
install.sh / install.ps1     copies the skill to ~/.claude/skills/
references/
  spec-interface.md          🆕 the design-system spec contract
  tokens.css                 base + review-extension CSS variables (YaHei-first stacks)
  components.css             all class rules · 2 layout archetypes · tag styles · feedback block
  feedback-collector.js      self-contained IIFE · "Copy all feedback" button
  example.html               double-clickable demo of both archetypes
  tag-profiles.md            Profile A editorial vs Profile B technical
  review-roles.md            Layer 0 baseline + Layer 1+ role taxonomy
  diff-mode.md               incremental re-review mode
specs/
  dna1-default.md            🆕 bundled default · DNA1 spec (mirror of EPDS canonical)
```

---

## Migrating from `evidence-poet-review`

This skill is the successor to `evidence-poet-review` (which lived inside the
`evidence-poet-design-system` monorepo). If you previously installed that:

```bash
rm -rf ~/.claude/skills/evidence-poet-review
./install.sh                 # installs html-review-skill
```

Same functionality, additional pluggable-spec support.

---

## License

MIT. See [LICENSE](LICENSE).
