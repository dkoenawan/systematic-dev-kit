# Example Output — Fictitious Brand "Tidepool"

> This sample shows the expected quality, format, and level of detail for brand-designer output. Use this as a reference for tone, specificity, and completeness. Tidepool is a fictitious marine data analytics platform.

---

## Example: brand/brand-guideline.md

```markdown
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
```

---

## Example: brand/brand-theme.css

```css
/* Tidepool — Brand Theme
   Generated by systematic-dev-kit:brand-designer

   Colors use HSL format for easy programmatic adjustment.
   Dark mode is intentionally designed, not mechanically inverted. */

:root {
  /* --- Color System --- */

  /* Primary — Deep Current */
  --color-primary-h: 196;
  --color-primary-s: 63%;
  --color-primary-l: 29%;
  --color-primary: hsl(var(--color-primary-h) var(--color-primary-s) var(--color-primary-l));
  --color-primary-50: hsl(196 63% 97%);
  --color-primary-100: hsl(196 58% 90%);
  --color-primary-200: hsl(196 55% 78%);
  --color-primary-300: hsl(196 52% 63%);
  --color-primary-400: hsl(196 58% 46%);
  --color-primary-500: hsl(196 63% 29%);
  --color-primary-600: hsl(196 68% 23%);
  --color-primary-700: hsl(196 72% 18%);
  --color-primary-800: hsl(196 75% 13%);
  --color-primary-900: hsl(196 78% 9%);

  /* Secondary — Seafoam */
  --color-secondary-h: 175;
  --color-secondary-s: 56%;
  --color-secondary-l: 55%;
  --color-secondary: hsl(var(--color-secondary-h) var(--color-secondary-s) var(--color-secondary-l));
  --color-secondary-50: hsl(175 56% 96%);
  --color-secondary-100: hsl(175 52% 88%);
  --color-secondary-200: hsl(175 50% 76%);
  --color-secondary-300: hsl(175 54% 65%);
  --color-secondary-400: hsl(175 56% 55%);
  --color-secondary-500: hsl(175 60% 42%);
  --color-secondary-600: hsl(175 64% 33%);
  --color-secondary-700: hsl(175 68% 25%);
  --color-secondary-800: hsl(175 70% 18%);
  --color-secondary-900: hsl(175 72% 12%);

  /* Accent — Coral Signal */
  --color-accent-h: 0;
  --color-accent-s: 100%;
  --color-accent-l: 71%;
  --color-accent: hsl(var(--color-accent-h) var(--color-accent-s) var(--color-accent-l));

  /* Neutrals (cool-tinted) */
  --color-bg: hsl(200 20% 97%);
  --color-surface: hsl(214 14% 93%);
  --color-border: hsl(216 8% 83%);
  --color-text: hsl(215 30% 15%);
  --color-text-secondary: hsl(215 14% 35%);
  --color-text-muted: hsl(215 16% 65%);

  /* Semantic */
  --color-success: hsl(160 72% 40%);
  --color-warning: hsl(38 92% 50%);
  --color-error: hsl(0 84% 60%);
  --color-info: hsl(217 91% 60%);

  /* --- Typography --- */
  --font-heading: 'Plus Jakarta Sans', system-ui, -apple-system, sans-serif;
  --font-body: 'Inter', system-ui, -apple-system, sans-serif;
  --font-mono: 'JetBrains Mono', ui-monospace, monospace;

  /* Type Scale — 1.25 major third */
  --text-display: 3.052rem;
  --text-h1: 2.441rem;
  --text-h2: 1.953rem;
  --text-h3: 1.563rem;
  --text-h4: 1.25rem;
  --text-body-lg: 1.125rem;
  --text-body: 1rem;
  --text-body-sm: 0.875rem;
  --text-caption: 0.75rem;

  /* Font Weights */
  --weight-normal: 400;
  --weight-medium: 500;
  --weight-semibold: 600;
  --weight-bold: 700;

  /* Line Heights */
  --leading-tight: 1.15;
  --leading-normal: 1.5;
  --leading-relaxed: 1.6;

  /* Letter Spacing */
  --tracking-tight: -0.02em;
  --tracking-normal: 0;
  --tracking-wide: 0.02em;

  /* --- Spacing (0.25rem base, 2x scale) --- */
  --space-xs: 0.25rem;
  --space-sm: 0.5rem;
  --space-md: 1rem;
  --space-lg: 1.5rem;
  --space-xl: 2rem;
  --space-2xl: 3rem;
  --space-3xl: 4rem;

  /* --- Component Tokens --- */
  --radius-sm: 4px;
  --radius-md: 6px;
  --radius-lg: 8px;
  --radius-full: 9999px;

  --shadow-sm: 0 1px 2px hsla(215, 30%, 15%, 0.05);
  --shadow-md: 0 2px 8px hsla(215, 30%, 15%, 0.08);
  --shadow-lg: 0 8px 24px hsla(215, 30%, 15%, 0.12);

  --transition-fast: 120ms ease;
  --transition-normal: 200ms ease;
  --transition-slow: 350ms ease;
  --transition-easing: cubic-bezier(0.25, 0.1, 0.25, 1);
}

/* --- Dark Mode --- */
@media (prefers-color-scheme: dark) {
  :root {
    /* Primary shifts lighter for dark backgrounds */
    --color-primary-l: 55%;
    --color-secondary-l: 50%;

    /* Neutrals — deep blue-grey, not pure black */
    --color-bg: hsl(215 28% 10%);
    --color-surface: hsl(215 24% 14%);
    --color-border: hsl(215 18% 22%);
    --color-text: hsl(210 16% 90%);
    --color-text-secondary: hsl(215 12% 68%);
    --color-text-muted: hsl(215 10% 45%);

    /* Semantic — desaturated slightly for comfort */
    --color-success: hsl(160 60% 45%);
    --color-warning: hsl(38 80% 55%);
    --color-error: hsl(0 72% 65%);
    --color-info: hsl(217 80% 65%);

    /* Shadows — darker, more diffuse */
    --shadow-sm: 0 1px 3px hsla(215, 50%, 5%, 0.3);
    --shadow-md: 0 4px 12px hsla(215, 50%, 5%, 0.35);
    --shadow-lg: 0 12px 32px hsla(215, 50%, 5%, 0.4);
  }
}

[data-theme="dark"] {
  --color-primary-l: 55%;
  --color-secondary-l: 50%;
  --color-bg: hsl(215 28% 10%);
  --color-surface: hsl(215 24% 14%);
  --color-border: hsl(215 18% 22%);
  --color-text: hsl(210 16% 90%);
  --color-text-secondary: hsl(215 12% 68%);
  --color-text-muted: hsl(215 10% 45%);
  --color-success: hsl(160 60% 45%);
  --color-warning: hsl(38 80% 55%);
  --color-error: hsl(0 72% 65%);
  --color-info: hsl(217 80% 65%);
  --shadow-sm: 0 1px 3px hsla(215, 50%, 5%, 0.3);
  --shadow-md: 0 4px 12px hsla(215, 50%, 5%, 0.35);
  --shadow-lg: 0 12px 32px hsla(215, 50%, 5%, 0.4);
}
```

---

## Example: Handoff Summary

> **Files created:**
>
> | File | Description |
> |------|-------------|
> | `brand/brand-guideline.md` | Complete brand identity guidelines — colors, typography, spacing, components, voice & tone |
> | `brand/brand-theme.css` | CSS custom properties in HSL format with designed dark mode |
>
> **Google Fonts:**
> ```html
> <link rel="preconnect" href="https://fonts.googleapis.com">
> <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
> <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500&family=Plus+Jakarta+Sans:wght@600;700&display=swap" rel="stylesheet">
> ```
>
> **Import:**
> ```css
> @import './brand/brand-theme.css';
> ```
>
> **Key decisions:**
> 1. Deep Current (#1B5E7B) as primary — carries the "scientific precision" emotion while staying warm enough to avoid clinical coldness
> 2. Plus Jakarta Sans for headings over DM Sans — the slightly rounded terminals match the "approachable authority" tension
> 3. 1.25 major third type scale — the data-dense dashboard context needs tighter hierarchy than a marketing site
> 4. 4px base border radius — precise but not sharp, reflecting the "rigorous yet human" brand position
>
> **Suggested next steps:**
> Start with a dashboard data card component to pressure-test the color palette with real data. Data-heavy UI is the hardest context for a brand to survive in — if it works there, it works everywhere.
