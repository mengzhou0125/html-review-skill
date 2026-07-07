# Build-invariants declaration block (MANDATORY at top of every review HTML)

> **Mirror** · canonical = the `visual_review_html` BP README §"Build-invariants declaration block"
> (v1.5 · 2026-06-09). This file re-syncs that mandate into the standalone skill. Keep in sync
> with the BP; do not fork the semantics.

**Why**: the recurring failure mode is *passive rules* — the profile rules (CN-primary · `.en-ref` ·
images-embedded · captions-in-body) sit in docs while recent context fills working memory, so they
get silently skipped at build time. Origin: a build-invariants pattern distilled from repeated review-HTML passes;reinforced where the same failure recurred (built off-spec ·
source images dropped · captions dropped · captions placed in the feedback rail not the body).

**The fix is mechanical**: lead every review HTML with a `<!-- BUILD INVARIANTS -->` comment block
that restates the governing rules *in the artifact itself*. The act of writing the block forces you
to re-read the profile rules before building. When a mistake is later caught, fold it back in as a
`LESSON:` line + a runnable `PREVENTION:` step — the block's guardrails ratchet tighter over time.

```html
<!--
═══════════════════════════════════════════════════════════════════
BUILD INVARIANTS · review HTML
(declared at build-time · prevents passive-rule drift)
- Profile         : A editorial | B technical   (pick one · see tag-profiles.md)
- Reviewer roles  : <who reads this · what they scan for>       (see review-roles.md)
- Language        : CN-primary · CN+EN in-place mixed (technical terms kept EN inline)
- EN-ref          : YES/NO · if source has EN finished text → .en-ref small-italic
- Fonts           : var(--font-sans/serif/mono) ONLY · YaHei-first (NEVER literal stacks · CN-render HARD RULE)
- Tag scheme      : <Profile A: 3 status × 4 layer | Profile B: 3 status × 3 layer × 3 severity>
- Doc coverage    : FULL (all sections rendered) | DIFF (changed only · see diff-mode.md)
- Images          : source images EMBEDDED at ~200px width in the BODY/正文 region · NOT dropped
- Captions        : in the BODY under the image · NOT in the feedback/rationale rail
- Section IDs     : <§1 … · §N … — must match ToC anchors>
- LESSON: <dated · any failure caught on a prior build of this surface>
- PREVENTION: <the grep/check that would have caught it>
═══════════════════════════════════════════════════════════════════
-->
```

**Self-check before declaring the review HTML done**: every field above is satisfiable by inspecting
the file (fonts are all `var(--font-*)`; images present at 200px in body; captions in body; coverage
matches the declared mode). The block is the visible proof the active step was done — a review HTML
without it is the tell of a passive-cache build.

> **Pluggable-spec note**: when an external (non–Evidence Poet) spec is loaded, the *Fonts* /
> *Language* fields adapt to that spec's font roles and the source content's locale; the block's
> job (restate-before-build) is spec-agnostic.
