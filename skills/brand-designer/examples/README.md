# Brand Designer Examples

This directory contains complete, working examples of brand-designer output to serve as quality references. Two examples across opposite ends of the visual spectrum — light/scientific and dark/fantastical — demonstrate that the skill produces brand-appropriate output, not a house style.

## Tidepool Example

The `tidepool/` directory contains a complete brand identity for a fictitious marine data analytics platform. This demonstrates the expected quality, format, and level of detail for all brand-designer outputs.

### Files

- **[brand-guideline.md](tidepool/brand-guideline.md)** — Complete brand identity guidelines including color system, typography, spacing, component tokens, and voice & tone
- **[brand-theme.css](tidepool/brand-theme.css)** — CSS custom properties in HSL format with intentionally designed dark mode
- **[brand-effects.css](tidepool/brand-effects.css)** — Advanced visual effects including ocean-tinted shadows, mesh gradients, glassmorphism, and tidal animations
- **[brand-showcase.html](tidepool/brand-showcase.html)** — Fully self-contained showcase page with bioluminescent data visual concept

### Brand Concept

**Tidepool** embodies the intersection of scientific rigor and environmental wonder — precise enough for marine biologists, alive enough to make someone care about dissolved oxygen levels.

**Visual Expression Strategy:** "Bioluminescent data" — points of light emerging from deep ocean darkness. The showcase demonstrates how ocean-tinted effects and a CSS mesh gradient can create a signature visual that emotionally connects to the brand.

**Visual Intensity:** Confident expression — mesh gradients, layered brand-tinted shadows, glassmorphism, and custom animations without overwhelming restraint.

---

## Mithril Ledger Example

The `mithril-ledger/` directory contains a complete brand identity for a fictitious personal finance app with a dark fantasy / dwarven-craft aesthetic.

### Files

- **[brand-guideline.md](mithril-ledger/brand-guideline.md)** — Complete brand identity guidelines including color system, typography, spacing, component tokens, and voice & tone
- **[brand-theme.css](mithril-ledger/brand-theme.css)** — CSS custom properties in HSL format, dark-mode-primary with a light "mountain terrace" mode
- **[brand-effects.css](mithril-ledger/brand-effects.css)** — Advanced visual effects including forge-tinted shadows, runic channel gradients, ember glow animations, and mithril shimmer
- **[brand-showcase.html](mithril-ledger/brand-showcase.html)** — Fully self-contained showcase page with animated runic channel lines and forge ember particles
- **[tailwind.brand.js](mithril-ledger/tailwind.brand.js)** — Tailwind CSS theme config extending the CSS custom properties

### Brand Concept

**Mithril Ledger** turns financial anxiety into financial mastery. Named for the legendary dwarven metal — impossibly light yet indestructible — it holds the same paradox: a tool that carries the weight of personal finance while making it feel effortless.

**Visual Expression Strategy:** "Runic channels" — geometric angular SVG path lines with glowing ember animations, evoking channels carved into stone that carry torchlight. The dark hold (Mountain Dark background) is the default; light mode is "stepping out to the mountain terrace."

**Visual Intensity:** Subtle motion — things breathe but don't shout. The stone doesn't move, but the firelight flickers.

### What this example demonstrates differently from Tidepool

- **Dark-primary color system** — dark mode is the default, not an afterthought. The entire color system is designed for dark-first with light mode as an alternate state.
- **Fantasy archetype brand** — demonstrates how a non-literal archetype (dwarven craft) can translate into real, usable design decisions without becoming costume-y or kitschy.
- **Luxury finance aesthetic** — warm gold accent (Forge Gold) against deep cool slate creates the gravitas of carved stone with precision, suitable for finance without feeling cold or corporate.
- **`tailwind.brand.js` included** — shows the full Tailwind integration output alongside CSS custom properties, demonstrating the "Both" tech stack output.

---

## Usage

When generating brand files, refer to these examples for:
- **Specificity**: How detailed and concrete the language should be
- **Quality bar**: The level of polish and thoughtfulness expected
- **Format consistency**: Proper markdown tables, CSS structure, HTML patterns
- **Creative ambition**: What "visually distinctive" means in practice — compare how differently Tidepool and Mithril Ledger solve the same brief structure

Open each `brand-showcase.html` in a browser to see the full visual experience.
