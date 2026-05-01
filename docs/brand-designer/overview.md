---
domain: brand-designer
last_updated: 2026-05-01
source_path: skills/brand-designer
---

# Brand Designer (L3)

> → [System overview](../solution-design.md) | → [Container architecture](../containers.md)

## What Is Brand Designer?

Brand Designer is a six-phase, emotionally-grounded brand identity generation system. Its primary object is the **BrandIdentity** — a complete visual and verbal system for a product, delivered as five production-ready files: a brand guideline, a CSS theme, an optional Tailwind config, a live showcase HTML page, and an optional effects library. This is not a color picker or template engine; it is a discovery-to-execution pipeline that insists on understanding brand emotion before generating any visual assets.

## How It Works

A developer invokes `/systematic-dev-kit:brand-designer`. Phases 1–3 are pure discovery across ten structured questions. Phase 1 (Brand Soul) asks for the brand's story, its three-year aspirational vision, and which archetype it embodies (Sage, Creator, Explorer, Caregiver, Rebel, or Magician). Phase 2 (Emotional Mapping) — the critical phase — extracts three specific core emotions, a sensory space metaphor (e.g., "Tokyo coffee bar"), and anti-inspirations (what the brand must never feel like). Phase 3 (Visual Direction) gathers reference materials from any industry, the current brand situation (fresh start, evolution, or rebrand), technical implementation target (Tailwind, CSS, or both), and visual intensity level. No files are touched during Phases 1–3.

In Phase 4, the skill synthesizes all discovery into a **Creative Direction Brief** — a narrative document mapping emotions to color philosophy, typography personality, spatial philosophy, component character, and a signature Visual Expression Strategy. The brief is presented to the user for approval: "This nails it," "Adjust," or "Rethink." No files are written without explicit approval; iterating the brief is cheaper than regenerating five output files.

Phase 5 generates all brand assets into the `brand/` directory: `brand-guideline.md`, `brand-theme.css`, and optionally `tailwind.brand.js`, `brand-showcase.html`, and `brand-effects.css`. Phase 6 runs `scripts/validate.sh` — checking for missing files, leftover placeholders, valid HSL values, WCAG contrast in both light and dark mode, real Google Font names, and correct Tailwind syntax — then presents results and next-step instructions as the handoff.

## Core Objects / Entities

| Object | Description |
| ------ | ----------- |
| `BrandIdentity` | The complete system: colors, typography, spacing, components, and voice. The five-file deliverable. |
| `CreativeDirectionBrief` | Narrative synthesis of all discovery phases — Brand Essence, Emotion-to-Design mapping, Color Philosophy, Typography Personality, Spatial Philosophy, Component Character, Visual Expression Strategy. Must be approved before file generation. |
| `ColorPalette` | Semantic HSL system: primary, secondary, accent, neutrals, and semantic colors (success/warning/error/info). Derived from Core Emotions, not picked from a swatch. |
| `TypeScale` | Mathematical text hierarchy (display, H1–H4, body variants, caption) following a consistent ratio (e.g., 1.25×). Validated by `validate.sh`. |
| `ComponentCharacter` | UI design tokens: border radius, shadows, animation speed, easing curves. Derived from brand energy and archetype. |
| `BrandArchetype` | Personality anchor (Sage/Creator/Explorer/Caregiver/Rebel/Magician) that drives typography pairing and voice tone. |
| `CoreEmotions` | Three specific feelings the brand should evoke — the linchpin from which all color decisions are derived via an internal mapping table. |
| `VisualExpressionStrategy` | A creative metaphor invented fresh per brand (e.g., "bioluminescent data", "runic channels") that becomes the hero concept of the showcase. |

## Code Map — Which Code Touches This

- **Business Logic / Phases**: `skills/brand-designer/SKILL.md` — the complete 6-phase framework, internal emotion-to-design mapping tables (lines 727–785), quality checklist (lines 789–801), and error handling strategies (lines 804–823)
- **Brief Template**: `skills/brand-designer/template.md` — Creative Direction Brief skeleton with 7 sections used in Phase 4 synthesis
- **Validation**: `skills/brand-designer/scripts/validate.sh` — 10-point binary quality gate checking completeness, HSL validity, WCAG contrast (AA: 4.5:1 body, 3:1 large), Google Font availability, Tailwind syntax, and showcase self-containment
- **Reference examples**: `skills/brand-designer/examples/tidepool/` (bioluminescent data concept) and `skills/brand-designer/examples/mithril-ledger/` (runic channels concept) — complete real-world brand systems showing the expected output format and quality bar
- **External callers**: Invoked standalone; no other systematic-dev-kit skills call into brand-designer programmatically

## Internal Architecture

**Emotion-Driven Design Pipeline**: Colors are derived from emotions via an internal reference table mapping emotion clusters to hue, saturation, and lightness ranges. This ensures the palette is emotionally coherent, not technically arbitrary.

**Archetype Anchoring**: The chosen brand archetype drives typography pairing, spacing philosophy, and component character via a lookup table, systematically connecting brand personality to every visual decision.

**Intensity-Scaled Visual Effects**: Visual Intensity (Q10) acts as a ceiling on creative scope, not a technique menu. "Restrained elegance" permits only subtle effects; "Bold spectacle" enables procedural canvas art. The Visual Expression Strategy must be a creative metaphor invented fresh per brand — not selected from a generic list.

**Approval Gate (Phase 4)**: A hard stop. Phase 5 cannot begin without the user selecting "This nails it." Iterating the brief through "Adjust" or restarting with "Rethink" are both cheaper than regenerating five files.

**Dark Mode as Designed System**: Dark mode is intentionally redesigned — saturation reduced, hue shifted for warmth, shadows made more diffuse. Not a mechanical inversion. WCAG contrast is validated in both modes independently.

## Dependencies

- **Internal**: None — brand-designer is a standalone skill with no programmatic calls to other systematic-dev-kit domains
- **External**: Google Fonts (font name validation via HTTP in Phase 6 only); CSS Custom Properties (core output mechanism); Tailwind CSS (optional, if selected in Q9); no npm packages or runtime services required

## Gotchas

- **Discovery cannot be skipped**: Users often ask to jump straight to colors. The skill explicitly pushes back — without Phase 2's emotional mapping, the palette has no emotional coherence. If the user insists after pushback, offer a rapid condensed version of Q1–Q3 rather than skipping entirely.
- **Core Emotions specificity is critical (Q4)**: Vague answers ("happy", "professional") must be pushed back on. "Calm confidence" and "childlike joy" produce entirely different palettes, even with the same base hue. This question is the linchpin.
- **No invented font names**: All Google Font names must be currently available. A typo ("Inter Sans" instead of "Inter") causes a Phase 6 validation failure. The skill maintains a curated list of candidates.
- **Visual Expression Strategy is not a technique menu**: It must be a creative metaphor that connects to the brand emotionally — not an off-the-shelf effect. "Mesh gradients" is a technique; "bioluminescent data flowing through dark water" is a strategy.
- **WCAG in both light and dark mode**: Dark mode color adjustments can break contrast ratios that passed in light mode. Do not skip validation.
- **Type scale must be mathematical**: Arbitrary font sizes will fail `validate.sh`. Stick to a consistent ratio (1.25×, 1.333×, or similar).

## Changelog

- 2026-04-24: Initial documentation generated by doc-maintainer.
- 2026-05-01: Full refresh via doc-maintainer.
