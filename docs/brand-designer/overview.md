---
domain: brand-designer
last_updated: 2026-04-24
source_path: skills/brand-designer
---

# Brand Designer

## What Is Brand Designer?

Brand Designer is a systematic creative capability that transforms a brand's story, emotions, and aspirations into a complete, production-ready brand identity system. The primary object it owns is the **Creative Direction Brief** — a narrative document that maps emotional ground truth to concrete design decisions (colour palette, typography, spacing, component character, and visual expression). From that approved brief, it generates a full **Brand System**: CSS tokens, a markdown guideline, an optional Tailwind config extension, a self-contained showcase HTML file, and optional advanced effects CSS.

## How It Works

A Brand System begins when a developer invokes the skill and is walked through six mandatory phases. In Phase 1, the user tells three stories: what the brand does and why it exists, its aspirational future, and which archetype it embodies (Sage, Creator, Explorer, Caregiver, Rebel, or Magician). Phase 2 drills deeper — the designer extracts three core emotions the audience should feel and maps them to sensory spaces (e.g., "Tokyo coffee bar" or "Scandinavian studio") to bridge feeling and form. Phase 3 gathers visual context: references from any industry, the current brand situation, and whether Tailwind or CSS-only output is needed.

Phase 4 synthesises everything into the Creative Direction Brief — a narrative covering Brand Essence, Emotion-to-Design mapping, Color Philosophy, Typography Personality, Spatial Philosophy, Component Character, and a signature Visual Expression Strategy. This brief is presented to the user and must be explicitly approved; no files are written before sign-off. Phase 5 generates the five output files using that approved brief as the sole source of truth. Phase 6 runs `scripts/validate.sh` — a 10-point quality gate checking that no placeholder syntax remains, type scales follow a mathematical ratio, Google Fonts resolve, WCAG contrast is sufficient, and the showcase HTML is fully self-contained.

## Core Objects / Entities

| Object | Description |
| ------ | ----------- |
| `CreativeDirectionBrief` | Narrative synthesis of all discovery phases; approved before generation. Maps emotions to specific design decisions. |
| `BrandGuideline` | Markdown reference doc: full colour palette (HSL + hex), type scale (mathematically verified), spacing system, semantic colours, component tokens, voice/tone. |
| `BrandTheme` | CSS custom properties file; all tokens stored in HSL for programmatic adjustment; includes intentional dark mode (not colour-inverted). |
| `BrandShowcase` | Self-contained HTML proof of concept: hero with signature visual concept, typography specimen, colour swatches, component gallery, dark/light toggle. |
| `TailwindConfig` | Optional JS module extending Tailwind with all design tokens via CSS custom property references. |
| `BrandEffects` | Optional advanced CSS effects (animations, gradients, glassmorphism) scaled by the user's visual intensity choice. |
| `EmotionCluster` | User's three core emotions, mapped via internal reference tables to colour temperature, saturation, and lightness. |
| `BrandArchetype` | Personality framework (Sage/Creator/Explorer/Caregiver/Rebel/Magician) that drives typography pairing and voice tone. |

## Code Map — Which Code Touches This

- **Models / Schema**: `skills/brand-designer/SKILL.md` (lines 727–801) — internal reference tables mapping Emotion Clusters → colour decisions, Archetypes → typography pairings, Visual Intensity → effects scope; `skills/brand-designer/template.md` — structure for the Creative Direction Brief.
- **Business Logic / Services**: `skills/brand-designer/SKILL.md` (lines 26–202) — six-phase discovery and synthesis methodology, including pushback rules for vague answers, approval gate logic, and contradiction detection.
- **API / Interface**: The skill is invoked as `/systematic-dev-kit:brand-designer`; six `AskUserQuestion` prompts embedded in the skill drive the discovery conversation.
- **Persistence**: Generated files written to a `brand/` directory: `brand-guideline.md`, `brand-theme.css`, `brand-showcase.html`, and optionally `tailwind.brand.js` and `brand-effects.css`. Example reference outputs live in `skills/brand-designer/examples/tidepool/` and `skills/brand-designer/examples/mithril-ledger/`.
- **External callers**: Invoked standalone; referenced by `systematic-dev-kit:init` and `systematic-dev-kit:plan` conceptually but not called programmatically by other skills.

## Internal Architecture

**Discovery-to-Design Translation**: A closed mapping system (internal reference tables) converts user inputs into design decisions before any file is written. Emotion Clusters → colour temperature/saturation/lightness; Archetype → typography pairing; Brand Energy → spacing philosophy.

**Approval Gate Pattern**: Phase 4 is a hard stop. The Creative Direction Brief must receive explicit user approval before Phase 5 begins. If the user requests adjustments, the brief is revised and re-presented — no partial generation is permitted.

**Intensity-Scaled Effects**: The complexity of `brand-effects.css` scales with the user's visual intensity selection (restrained elegance → subtle motion → confident expression → bold spectacle), acting as a ceiling on creative scope rather than a prescriptive list.

**Validation as Quality Gate**: All generated files must pass `scripts/validate.sh` — 10 binary checks covering completeness, mathematical consistency, accessibility (WCAG approximation), font availability, and self-containment.

## Dependencies

- **Internal**: None — brand-designer is a standalone skill.
- **External**: Google Fonts (validated by HTTP request during Phase 6); Tailwind CSS (optional, for the Tailwind config output); no JavaScript framework dependencies in the showcase HTML (vanilla JS only).

## Gotchas

- Dark mode in `brand-theme.css` must be an intentional redesign, not a mechanical colour inversion. Saturation is reduced, hue is shifted for warmth, shadows are more diffuse — this is enforced by the template but easy to get wrong when editing generated files manually.
- The type scale must follow a consistent mathematical ratio (e.g., 1.25×). `validate.sh` checks for this; arbitrary font sizes will fail validation.
- Google Font names are case-sensitive and validated via HTTP. A typo (e.g., "Inter Sans" instead of "Inter") causes a Phase 6 failure.
- `brand-showcase.html` must inline all CSS — it cannot reference `brand-theme.css` externally. The file must be self-contained for portability.
- The showcase is a one-off creative design, not a template. Each run must produce a unique visual concept derived from the Visual Expression Strategy; reusing a generic hero layout violates the skill's intent.
- If the user selects "Other" for the archetype question, the designer must reason contextually — there is no internal reference table entry for custom archetypes.

## Changelog

- 2026-04-24: Initial documentation generated by doc-maintainer.
