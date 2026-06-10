# Design System Spec Interface

This document defines the contract this skill expects from a design-system spec — whether
the bundled Evidence Poet default or an external one. **If your spec exposes the keys below, the
skill can use it.**

The spec is a markdown file with a §0 JSON block. The skill parses that JSON and
substitutes its values into the `:root { ... }` base block of `references/tokens.css`.

---

## Where the spec comes from (recap of SKILL.md Step 0)

The skill resolves which spec to use, in this order:

1. **Explicit** — `--spec=<path>` argument or user explicitly names a path
2. **Project-detected** — `<project>/.claude/design.md` exists
3. **Bundled default** — `specs/default-spec.md` (Evidence Poet)

---

## Required keys in the §0 JSON block

The skill expects a JSON block like this somewhere in the spec markdown (Evidence Poet's example
shown · adapt values to your system):

```json
{
  "version": "1.1.0",

  "color": {
    "bg": "#F8F7F3",
    "text": "#1A1A18",
    "textSecondary": "#555555",
    "textTertiary": "#666666",
    "textMuted": "#717171",
    "textFaint": "#888888",
    "border": "#EDE9E2",
    "surface": "#FFFFFF",
    "surfaceFill": "#f5f5f3",
    "accent": "#C8A84B",            "_role": "accent LINE only · NEVER as text fill",
    "accentDark": "#7E6720",        "_role": "text-safe accent · WCAG-AA",
    "link": "#527590"
  },

  "font": {
    "serif": "Playfair Display",    "_role": "headlines · numerals at scale",
    "sans":  "Plus Jakarta Sans",   "_role": "body text",
    "mono":  "DM Mono"              "_role": "labels · tags · CTA"
  },

  "spacing": [2, 4, 8, 12, 16, 20, 24, 32, 40, 48, 64, 80, 120],

  "fontSize": {
    "3xs": 10, "2xs": 11, "xs": 12, "sm": 13, "base": 14, "md": 15, "lg": 16,
    "xl": 18, "2xl": 20, "3xl": 24, "4xl": 28, "5xl": 32, "6xl": 40, "7xl": 42
  },

  "lineWidth": {
    "hairline": 1,
    "accent": 3
  },

  "cornerRadius": 0,

  "motionEasing": "cubic-bezier(0.16, 1, 0.3, 1)"
}
```

### Hard requirements (skill will error)

- `color.bg`, `color.text`, `color.border`, `color.surface`, `color.accent`,
  `color.accentDark`, `color.link` — minimum palette for a review HTML
- `font.serif`, `font.sans`, `font.mono` — three font roles; if your spec collapses to
  fewer fonts, repeat (e.g. `serif` = `sans` = "Inter")
- `spacing` — at least 8 values from small to large; the skill maps them to
  `--space-3xs/2xs/xs/sm/md/lg/xl/2xl/3xl/4xl/5xl/6xl/7xl` (truncates to your scale length)
- `fontSize` — at least the 8 named sizes (`3xs` through `4xl`); rest fall back to base

### Soft requirements (skill applies defaults if missing)

- `lineWidth.hairline` — default 1
- `lineWidth.accent` — default 3
- `cornerRadius` — default 0 (sharp · the skill's components are designed for sharp
  aesthetics; values > 0 are honored but the visual character may degrade)
- `motionEasing` — `cubic-bezier(0.16, 1, 0.3, 1)` if absent

### What the substitution actually does

For each key in the spec's `color`, the generator writes into the loaded `tokens.css`:

```css
--color-bg:           <spec.color.bg>;
--color-text:         <spec.color.text>;
--color-border:       <spec.color.border>;
--color-surface:      <spec.color.surface>;
--color-accent:       <spec.color.accent>;
--color-accent-dark:  <spec.color.accentDark>;
--color-cta-muted:    <spec.color.link>;
...
```

Same for fonts, spacing, font-sizes. The `--review-*` and `--audit-*` extension tokens
**are not touched** — they're tool-defined (see next section).

---

## What the skill does NOT take from the spec

These are **tool concerns**, not spec concerns:

### Review-extension tokens (tool's visual identity)

The `--review-*` and `--audit-*` tokens in `tokens.css` define the tool's tag-profile
colors (status / layer / severity tags). They stay constant regardless of which spec is
loaded:

- `--review-改-fill` / `--review-modified-fill` (gold-dark `#7E6720` for "modified" status)
- `--review-del-fill` / `--review-deleted-fill` (terracotta `#A85F4D` for "deleted")
- `--review-layer-a/b/c/d` (cool blue / olive / plum / slate for the 4 editorial layers)
- `--review-tech-status-rev/kept/del` (Profile B technical · blue-gray / gold-dark / terracotta)
- `--review-tech-layer-a/b/c` (forest / plum / slate teal)
- `--review-tech-severity-p0/p1/p2` (ink / mid / light grayscale)
- `--audit-severity-high/mid/low` (audit-box informational gradient)

These are **tool extensions per Evidence Poet's "Extension governance" rule** — they live with the
tool, not the spec. If you want different tag colors, fork this skill and edit
`tokens.css`'s review-extension block. The tool stylizes its own UI on top of any spec's
base palette.

### Layout patterns

The `.toc-layout` archetypes, `.section-pair` grid, sticky positioning, feedback-collector
mechanics — these are tool-defined patterns, independent of the loaded spec.

---

## Examples

### Evidence Poet (bundled default)

See `specs/default-spec.md` §0. It's the spec this skill was designed against — every value
above maps cleanly.

### Bringing your own spec

1. Create a markdown file with a §0 JSON block following the schema above
2. Either save it at `<project>/.claude/design.md` (auto-detected) OR pass
   `--spec=<path>` explicitly
3. Run the skill normally — the bundled `specs/default-spec.md` is replaced

---

## Why this contract is narrow

A spec for "Material Design" or "Tailwind" has hundreds of tokens. This skill takes only
the ~20 tokens it actually uses for review-HTML output. The contract is narrow on purpose
— "plug-and-play" beats "full design-system fidelity". If you need full fidelity (every
component variant, every responsive breakpoint), use a code-generation build pipeline,
not this skill.

The tool's own visual identity (tag profile colors, review-extension semantics) is
intentionally **not** in the contract — those are the tool's choice, not the spec's. The
spec provides the base palette; the tool builds its UI on top.
