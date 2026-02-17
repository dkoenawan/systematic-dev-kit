# Tidepool — Brand Identity Guidelines

## Brand Essence

Tidepool makes ocean data legible. Where others see noise — satellite feeds, sensor arrays, tidal models — Tidepool sees stories. The brand sits at the intersection of scientific rigor and environmental wonder: precise enough for marine biologists, alive enough to make someone care about dissolved oxygen levels. The tension it holds: authority without coldness, beauty without decoration.

## Color System

### Primary Palette

| Role | Name | Hex | HSL | Usage |
|------|------|-----|-----|-------|
| Primary | Deep Current | #1B5E7B | hsl(196 63% 29%) | Primary actions, key UI elements, navigation |
| Secondary | Seafoam | #4ECDC4 | hsl(175 56% 55%) | Secondary actions, highlights, data visualization accent |
| Accent | Coral Signal | #FF6B6B | hsl(0 100% 71%) | Alerts, important callouts, CTAs that need urgency |

### Neutral Palette

| Role | Name | Hex | HSL | Usage |
|------|------|-----|-----|-------|
| Background | Salt White | #F7F9FA | hsl(200 20% 97%) | Page backgrounds |
| Surface | Foam | #EBEEF1 | hsl(214 14% 93%) | Cards, elevated surfaces |
| Border | Tideline | #D1D5DB | hsl(216 8% 83%) | Dividers, input borders |
| Text Primary | Abyss | #1A2332 | hsl(215 30% 15%) | Headings, primary content |
| Text Secondary | Slate Water | #4A5568 | hsl(215 14% 35%) | Supporting text, labels |
| Text Muted | Drift | #94A3B8 | hsl(215 16% 65%) | Placeholders, disabled states |

### Semantic Colors

| Role | Hex | Usage |
|------|-----|-------|
| Success | #10B981 | Successful operations, healthy data connections |
| Warning | #F59E0B | Data quality warnings, approaching limits |
| Error | #EF4444 | Failed connections, critical data gaps |
| Info | #3B82F6 | Informational tooltips, help text |

## Typography

### Type Scale

| Level | Size (rem) | Weight | Line Height | Letter Spacing | Usage |
|-------|-----------|--------|-------------|----------------|-------|
| Display | 3.052 | 700 | 1.1 | -0.03em | Hero sections, splash |
| H1 | 2.441 | 700 | 1.15 | -0.02em | Page titles |
| H2 | 1.953 | 600 | 1.2 | -0.01em | Section headings |
| H3 | 1.563 | 600 | 1.25 | 0 | Subsection headings |
| H4 | 1.25 | 600 | 1.3 | 0 | Card titles |
| Body Large | 1.125 | 400 | 1.6 | 0 | Lead paragraphs |
| Body | 1 | 400 | 1.5 | 0 | Default text |
| Body Small | 0.875 | 400 | 1.5 | 0.01em | Captions, metadata |
| Caption | 0.75 | 500 | 1.4 | 0.02em | Labels, fine print |

Scale ratio: 1.25 (major third) — tight enough for data-dense interfaces but with clear hierarchy.

### Font Families

- **Heading**: Plus Jakarta Sans — geometric with subtle humanist warmth. The slightly rounded terminals feel approachable without losing authority. Weights 600-700.
- **Body**: Inter — optimized for screen readability at small sizes, with tabular number support for data tables. Its large x-height keeps things legible even in dense dashboards.
- **Mono**: JetBrains Mono — used for data values, coordinates, and code. Ligatures disabled for data accuracy.

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

Base unit: 0.25rem. Scale: 2x. The spacing is professional and balanced — data platforms need density without feeling cramped.

## Component Tokens

| Token | Value | Reasoning |
|-------|-------|-----------|
| Border Radius (small) | 4px | Sharp enough to feel precise, slight rounding softens the technical feel |
| Border Radius (medium) | 6px | Cards and containers — present but restrained |
| Border Radius (large) | 8px | Modals, large panels — noticeable but not bubbly |
| Shadow (subtle) | 0 1px 2px hsla(215, 30%, 15%, 0.05) | Barely there — used for slight elevation on hover |
| Shadow (medium) | 0 2px 8px hsla(215, 30%, 15%, 0.08) | Cards and dropdowns — visible but not heavy |
| Shadow (elevated) | 0 8px 24px hsla(215, 30%, 15%, 0.12) | Modals and overlays — clearly floating |
| Transition Speed (fast) | 120ms | Hover states, micro-interactions |
| Transition Speed (normal) | 200ms | Panel open/close, color changes |
| Transition Speed (slow) | 350ms | Page transitions, chart animations |
| Transition Easing | cubic-bezier(0.25, 0.1, 0.25, 1) | Smooth and natural — slightly faster in, slower out |

## Voice & Tone

- **Brand voice**: Clear, knowledgeable, grounded. Tidepool speaks like a scientist who also surfs — technically precise but never dry. Sentences are short. Jargon is used when accurate, explained when not obvious.
- **Headline style**: Direct and concrete. "Track ocean health in real time." Not "Empowering marine stakeholders with data-driven insights."
- **Body copy style**: Active voice, present tense. Explain what things do, not what they are. "Tidepool connects to 40+ sensor networks" not "Tidepool is a platform that provides connectivity."
- **CTA style**: Action-first, specific. "Start monitoring" not "Get started." "View live data" not "Learn more."
- **Words to use**: monitor, track, signal, surface, depth, current, clarity, precision
- **Words to avoid**: synergy, leverage, ecosystem (too corporate), simple/easy (dismissive of complexity), revolutionary (overblown)
