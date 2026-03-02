# MithrilLedger — Brand Identity Guidelines

## Brand Essence

MithrilLedger turns financial anxiety into financial mastery. Named for the legendary dwarven metal — impossibly light yet indestructible — it holds the same paradox: a tool that carries the weight of personal finance while making it feel effortless. Where most finance tools either talk down to you or drown you in spreadsheets, MithrilLedger treats you like the master of your own hold. The tension it holds: ancient craft meets modern clarity — the gravitas of carved stone with the precision of a well-forged blade. Built by hand, shared with the fellowship.

## Color System

### Primary Palette

| Role | Name | Hex | HSL | Usage |
|------|------|-----|-----|-------|
| Primary | Deep Slate | #2A2D3A | hsl(230 15% 19%) | Page backgrounds, primary containers, navigation |
| Secondary | Mithril Silver | #8B9DC3 | hsl(220 30% 65%) | Key UI elements, links, data highlights, secondary actions |
| Accent | Forge Gold | #C4973B | hsl(40 54% 50%) | CTAs, achievement indicators, important callouts, active states |

### Neutral Palette

| Role | Name | Hex | HSL | Usage |
|------|------|-----|-----|-------|
| Background | Mountain Dark | #1E2028 | hsl(230 12% 14%) | Page backgrounds (dark mode default) |
| Surface | Stone Chamber | #282B36 | hsl(230 13% 18%) | Cards, elevated surfaces |
| Border | Carved Edge | #3D4155 | hsl(230 16% 28%) | Dividers, input borders |
| Text Primary | Pale Granite | #E8E6E3 | hsl(30 8% 90%) | Headings, primary content |
| Text Secondary | Worn Stone | #A8A5A0 | hsl(30 5% 65%) | Supporting text, labels |
| Text Muted | Shadow Stone | #6B6A68 | hsl(30 2% 41%) | Placeholders, disabled states |

### Semantic Colors

| Role | Hex | Usage |
|------|-----|-------|
| Success | #4A9E6E | Successful transactions, positive balance changes |
| Warning | #D4943A | Budget warnings, approaching limits |
| Error | #C74D4D | Failed operations, overspending alerts |
| Info | #5B8EC9 | Informational tooltips, help text |

## Typography

### Type Scale

| Level | Size (rem) | Weight | Line Height | Letter Spacing | Usage |
|-------|-----------|--------|-------------|----------------|-------|
| Display | 3.052 | 700 | 1.1 | -0.02em | Hero sections, splash |
| H1 | 2.441 | 700 | 1.15 | -0.01em | Page titles |
| H2 | 1.953 | 600 | 1.2 | 0 | Section headings |
| H3 | 1.563 | 600 | 1.25 | 0.01em | Subsection headings |
| H4 | 1.25 | 600 | 1.3 | 0.01em | Card titles |
| Body Large | 1.125 | 400 | 1.65 | 0 | Lead paragraphs |
| Body | 1 | 400 | 1.5 | 0 | Default text |
| Body Small | 0.875 | 400 | 1.5 | 0.01em | Captions, metadata |
| Caption | 0.75 | 500 | 1.4 | 0.03em | Labels, fine print |

Scale ratio: 1.25 (major third) — tight enough for financial data density but with strong hierarchy for navigation.

### Font Families

- **Heading**: Cinzel — a serif face inspired by classical stone inscriptions. Its geometric proportions and sharp terminals evoke carved runes and dwarven craftsmanship. Weights 600-700.
- **Body**: Inter — optimized for screen readability with tabular number support for financial data. Its large x-height maintains legibility even in dense transaction tables.
- **Mono**: JetBrains Mono — used for currency amounts, account numbers, and financial figures. Precise tabular alignment.

## Spacing System

| Token | Value (rem) | Pixels | Usage |
|-------|------------|--------|-------|
| space-xs | 0.25 | 4 | Inline element gaps, icon padding |
| space-sm | 0.5 | 8 | Tight groups, form element gaps |
| space-md | 1 | 16 | Default component padding, list gaps |
| space-lg | 1.5 | 24 | Card padding, section element gaps |
| space-xl | 2 | 32 | Section separators |
| space-2xl | 3 | 48 | Major section breaks |
| space-3xl | 4 | 64 | Page section spacing |

Base unit: 0.25rem. Scale: 2x. Grand corridors between sections, purposeful density within components — like a dwarven hold.

## Component Tokens

| Token | Value | Reasoning |
|-------|-------|-----------|
| Border Radius (small) | 2px | Angular, carved. Dwarven craft has edges, not curves. |
| Border Radius (medium) | 4px | Cards and containers — barely rounded, precise |
| Border Radius (large) | 6px | Modals, large panels — present but sharp |
| Shadow (subtle) | 0 1px 3px hsla(230, 15%, 5%, 0.2) | Torchlight cast on stone — warm and directional |
| Shadow (medium) | 0 4px 12px hsla(230, 15%, 5%, 0.3) | Cards and dropdowns — deeper shadow, carved depth |
| Shadow (elevated) | 0 8px 28px hsla(230, 15%, 5%, 0.4) | Modals and overlays — the great hall's vaulted ceiling |
| Transition Speed (fast) | 150ms | Hover states, micro-interactions |
| Transition Speed (normal) | 280ms | Panel open/close, state changes |
| Transition Speed (slow) | 450ms | Page transitions, reveal animations |
| Transition Easing | cubic-bezier(0.22, 0.61, 0.36, 1) | Weighted and deliberate — like a stone door sliding |

## Voice & Tone

- **Brand voice**: Confident, clear, grounded. MithrilLedger speaks like a master craftsman — precise but never cold, authoritative but never condescending. Short sentences. Plain language. No jargon.
- **Headline style**: Direct and empowering. "Know exactly where you stand." Not "Empowering users with financial visibility solutions."
- **Body copy style**: Active voice, present tense. Explain what things do. "MithrilLedger tracks every transaction across all your accounts" not "MithrilLedger is a platform that provides financial tracking."
- **CTA style**: Action-first, specific. "View your ledger" not "Get started." "Track this month" not "Learn more."
- **Words to use**: forge, craft, master, hold, ledger, track, build, steady, clear, solid
- **Words to avoid**: synergy, leverage, ecosystem, disrupt, simple/easy (dismissive), revolutionary (overblown), hack (too casual)
