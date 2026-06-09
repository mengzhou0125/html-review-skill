---
name: html-review-skill
description: Render a document, spec, code change, or design proposal into a side-by-side review HTML — content + rationale annotations + per-section feedback collector. Pluggable design system: bundles the DNA1 ("Evidence Poet") spec as the default visual style, accepts any external spec following the spec-interface contract. Triggers on "render this as a review HTML", "build a review HTML for X", "review this doc in HTML side-by-side", "用 HTML 出 review", "/html-review". Carries two layout archetypes (right-rail · stacked), two tag profiles (editorial · technical), multi-layer review roles, DIFF mode for incremental re-reviews, and a feedback collector that serializes per-section ratings to clipboard. Default visual style = DNA1 (sharp corners · 3-font tension · CJK-safe font stacks · gold accent for important paths). To use a different design system, pass --spec=<path> or have <project>/.claude/design.md present and the skill picks it up. Do NOT trigger for general design feedback, prose rewriting without a visual review surface, or installing a design system.
---

# html-review-skill

A standalone content-review-HTML production engine for Claude. Pluggable visual style: ships
with the DNA1 ("Evidence Poet") spec bundled as the default. Accept any external design
system following the simple `spec-interface.md` contract.

When you need to turn a document, a spec, a code change, or a design proposal into a
**side-by-side review surface** — content on one side, AI rationale annotations on the
other, per-section feedback the reader can collect with one click — this skill gives you
the tokens, two layout archetypes, two tag profiles, DIFF mode for incremental re-reviews,
and a double-clickable example to copy from.

**Bundled default**: DNA1 — *academic journal × architecture magazine. Mono labels for
information order, serif headlines for narrative weight, gold lines for moments worth
pausing. Sharp corners. CJK-safe font stacks (Microsoft YaHei first). Restrained, rational,
never cold.* If that's not your style, plug in your own spec (see Step 0).

---

## When to run

Trigger on explicit intent to produce a content-review HTML:

- "render this doc as a review HTML"
- "build a review HTML for [spec / case study / PR / blog draft]"
- "review this in HTML · side-by-side with annotations"
- "用 HTML 出 review · review 这篇 [文档名]"
- "/html-review"

Do **not** trigger for:
- General design critique or prose feedback (just answer in chat)
- Rewriting a document without producing a visual review surface
- Non-review React components or pages (use a generalist builder)
- Installing a design system into a project
- Auditing an existing artifact (use a spec-driven auditor)

---

## Reference files (read BEFORE generating — mandatory)

- **`references/spec-interface.md`** — the design-system spec contract. What the skill
  expects from any spec (default or external): semantic colors, font roles, spacing scale,
  line widths, corner convention. **Read this first.**
- **`references/tokens.css`** — base tokens + review-semantic extensions
  (`--review-*` · `--audit-*`) + the YaHei-first font stacks (`--font-sans/serif/mono`).
  **The base block defaults to DNA1 values**; when you load an external spec, the
  generation step substitutes the spec's §0 JSON values into the base block. The
  review-extension tokens (tag colors) are tool-defined and stay constant — they're the
  tool's visual identity, not the spec's.
- **`references/components.css`** — all CSS rules for review-HTML components:
  both layout archetypes (`.toc-layout` / `.section-pair` / `.rationale`), status / layer /
  severity tags (Profile A and Profile B), `.r-compare` before/after blocks, `.audit-box`,
  `.user-feedback`, `.summary-block`, `.diagram-backlog-box`. Fully `var(--*)`-driven —
  no hardcoded values.
- **`references/feedback-collector.js`** — self-contained IIFE that adds the
  fixed "📋 Copy all feedback" button. Serializes every `.user-feedback` block (section
  label + checked ratings + notes + summary tally) to the clipboard. **The page saves no
  data.**
- **`references/example.html`** — double-clickable demo showing **both** layout
  archetypes (A right-rail + B stacked) on one page with the live copy button.
- **`references/tag-profiles.md`** — Profile A (editorial · 3 status × 4 layer)
  vs Profile B (technical · 3 axes × 3 variants). Decision rules, CSS class
  conventions, full WCAG rationales.
- **`references/review-roles.md`** — multi-layer review architecture: Layer 0
  baseline (always on) + Layer 1+ role-specific layers (cold-scan reader,
  spec-rootedness auditor, body↔caption checker, etc.).
- **`references/diff-mode.md`** — incremental re-review mode: section-level
  state tags, changed/unchanged visual treatment, source-of-diff strategy.

---

## Workflow

### Step 0 · Load a spec (NEW · pluggable design system)

The skill resolves the spec to use, in this order:

1. **Explicit** — if invoked with `--spec=<path>` or the user explicitly named a spec ("use
   my spec at ./tokens.md"), use that path.
2. **Project-detected** — if `<project>/.claude/design.md` exists (e.g. installed by
   `evidence-poet-installer` or any compatible installer), use it.
3. **Bundled default** — use `specs/dna1-default.md` (a verbatim DNA1 spec mirror).

Confirm which spec is in use in one line before proceeding ("Using spec: DNA1 default
(bundled)" or "Using spec: ./design.md (project-local)").

**Spec validity check** — open the chosen spec, find its §0 JSON block, verify it
contains the keys listed in `references/spec-interface.md` §"Required keys". If missing,
ask the user how to fill the gap (or fall back to bundled default for the missing
dimension).

### Step 1 · Read the spec + tokens

Read `references/spec-interface.md` first, then `references/tokens.css` (the review-extension
layer, mostly tool-defined). Lock these four before writing any HTML:

- **`<html lang="zh-Hans-CN">`** — when source content is Chinese. The `Hans` script subtag
  forces Simplified rendering. Without it, Windows renders Han-unified codepoints as
  **Traditional glyphs**. (For non-CJK content, use the locale appropriate to your source.)
- **CJK font stacks · YaHei first** — `--font-sans/serif/mono` in `tokens.css` have
  `Microsoft YaHei` placed first among CJK fallbacks. **Never declare a per-rule font
  literal** — reference `var(--font-*)` everywhere. The single source can't re-diverge.
  When an external spec is loaded, the spec's font roles substitute *before* the CJK
  fallback chain (i.e. spec's primary serif/sans/mono come first, YaHei stack stays as
  fallback).
- **Sharp corners** — `tokens.css` defaults to the DNA1 convention (`border-radius: 0`
  globally). If your spec sets `cornerRadius` > 0, the global reset is removed and corners
  use the spec value.
- **3 font roles** — serif (headlines) · sans (body) · mono (labels / tags / CTA). Roles
  map to spec's `font.serif/sans/mono`.

### Step 2 · Ask ONE bootstrap question (what + how long)

**Ask the user (in plain CN/EN):**

> 你要 review 什么? 简单说一下:
>
> - **文档类型** —— case study / spec / code / blog draft / proposal / 其他
> - **大概多长** —— 1-2 节 (短) · 3-10 节 (中) · 10+ 节 (长技术)

**Infer archetype + tag profile from the answer**:

| Doc shape | Archetype default | Tag profile default | If ambiguous, ask: |
|---|---|---|---|
| Case study · doc revision · blog · narrative | **A · right-rail** | **A · editorial** (Status × Layer) | "annotations beside content or under?" |
| Spec · code · architecture · cross-layer audit | **B · stacked** | **B · technical** (Status × Layer × Severity) | "few findings per section or many?" |
| Short doc (≤3 sections) | A | (matches content type) | — |
| Long technical (10+ sections) | B | B technical | "any editorial sections to mix in?" |

**Only ask follow-up if the inferred default is wrong** for the user's actual content.

### Step 3 · Read the relevant profile + role doc

- For tag profile: `references/tag-profiles.md` §"Profile A" or §"Profile B".
- For review roles: `references/review-roles.md` Layer 0 baseline + Layer 1+ role table.

### Step 4 · Layout · pick the archetype

Both archetypes share the same outer frame. The **only** difference is annotation placement:

| Archetype | Annotations | Per-section feedback sits | Frame class |
|---|---|---|---|
| **A · right-rail** | sticky `.rationale` rail beside the content (`.section-pair`) | at the bottom of the **rail** | `.toc-layout--rail` |
| **B · stacked** | inline `.rationale` / `.r-item` blocks under the content (`position: static`) | at the bottom of the **stack** | `.toc-layout--stacked` |

**One archetype per review HTML** — don't mix.

### Step 5 · Build · copy patterns from `example.html`

The example uses **only** the classes defined in `tokens.css` + `components.css`. Copy the
structure (full template in `example.html`). When a non-default spec is loaded, the
generation step substitutes the spec's §0 JSON values into the `:root { ... }` base block
of `tokens.css` (the review-extension tokens — `--review-*`, `--audit-*` — stay constant).

For an absolutely self-contained single file, inline `tokens.css` + `components.css`
into `<style>` and inline the `feedback-collector.js` IIFE into a `<script>` block.

### Step 6 · Tag · pick + apply

Per `tag-profiles.md` — Profile A or Profile B.

### Step 7 · Severity discipline

Every finding gets P0 / P1 / P2 per `review-roles.md` and `tag-profiles.md` (Profile B's
severity axis or Profile A's audit-box gradient).

### Step 8 · DIFF mode (incremental re-review)

If this is a re-review: read `references/diff-mode.md`. Apply the 4 mechanisms. Name the
file `<doc-stem>_review_v<N>.html`.

### Step 9 · Verification (recommended · external)

This skill does its own structural validation (HTML well-formed · `lang` attribute correct
· feedback-collector loaded · CSS variables resolve). For independent design-system
compliance audit, use a spec-driven auditor.

If you use DNA1, the `evidence-poet-auditor` covers review HTML (run with
`--surface=review-html`):

```bash
node ~/.claude/skills/evidence-poet-auditor/audit.mjs <path-to-your-review.html> \
  --spec=<path-to-your-spec> --surface=review-html
```

Install: `git clone https://github.com/mengzhou0125/evidence-poet-design-system && ./install.sh auditor`.
For non-DNA1 specs: use any spec-driven auditor that accepts your spec format.

---

## Output

- A single `.html` file. Self-contained (inline CSS + JS) **or** linked to sibling
  `tokens.css` + `components.css` + `feedback-collector.js`. Both work.
- Suggested location: `_review/<doc-stem>_review_v1.html` co-located with the source
  document.
- Naming: `<doc-stem>_review_v<N>.html`. Re-reviews bump N — never overwrite v<N-1>.
- Report the path back to the user. Mention the spec used.

---

## What this skill does NOT do

- Does not install a design system into a project (use a separate installer — e.g.
  `evidence-poet-installer` for DNA1)
- Does not edit the source document being reviewed (the rail proposes; the human decides;
  the edit is a separate step)
- Does not run package managers, build, or deploy
- Does not save user feedback (the page is ephemeral — collector serializes to clipboard
  on demand · no localStorage · no backend)
- Does not audit its own output — use a spec-driven auditor (see Step 9)

---

## Companion tools (optional · for the DNA1 ecosystem)

| Tool | Repo | Role |
|---|---|---|
| `evidence-poet-installer` | [evidence-poet-design-system](https://github.com/mengzhou0125/evidence-poet-design-system) | Install DNA1 into a project as `<project>/.claude/design.md` · this skill auto-detects |
| `evidence-poet-builder` | same | Build React / vanilla / data-dense surfaces in DNA1 (the generalist · review surface defers here) |
| `evidence-poet-auditor` | same | Audit any artifact against the spec · use for design-system compliance |
| `svg-diagram-skill` | [svg-diagram-skill](https://github.com/mengzhou0125/svg-diagram-skill) | Sibling tool · same pluggable-spec pattern · for standalone SVG diagrams |

If you're using a different design system, this skill works alone — bring your own spec
following `references/spec-interface.md`.
