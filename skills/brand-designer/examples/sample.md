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

## Example: brand/brand-effects.css

```css
/* Tidepool — Brand Effects
   Generated by systematic-dev-kit:brand-designer

   Advanced visual effects that build on brand-theme.css.
   Import alongside brand-theme.css for enhanced visuals. */

/* --- Custom Focus Ring --- */
*:focus-visible {
  outline: 2px solid hsl(var(--color-primary-h) var(--color-primary-s) var(--color-primary-l));
  outline-offset: 2px;
  border-radius: var(--radius-sm);
}

/* --- Layered Brand-Tinted Shadows --- */
.shadow-ocean-sm {
  box-shadow:
    0 1px 2px hsla(196, 63%, 29%, 0.08),
    0 2px 4px hsla(196, 63%, 29%, 0.04);
}

.shadow-ocean-md {
  box-shadow:
    0 2px 4px hsla(196, 63%, 29%, 0.1),
    0 4px 8px hsla(196, 63%, 29%, 0.06),
    0 8px 16px hsla(196, 63%, 29%, 0.03);
}

.shadow-ocean-lg {
  box-shadow:
    0 4px 8px hsla(196, 63%, 29%, 0.12),
    0 8px 16px hsla(196, 63%, 29%, 0.08),
    0 16px 32px hsla(196, 63%, 29%, 0.04);
}

/* --- CSS Mesh Gradient (Ocean Depth) --- */
.gradient-ocean-mesh {
  background:
    radial-gradient(circle at 20% 30%, hsla(196, 63%, 45%, 0.15) 0%, transparent 50%),
    radial-gradient(circle at 80% 70%, hsla(175, 56%, 55%, 0.12) 0%, transparent 50%),
    radial-gradient(circle at 40% 80%, hsla(196, 63%, 29%, 0.1) 0%, transparent 50%),
    radial-gradient(circle at 90% 20%, hsla(175, 56%, 42%, 0.08) 0%, transparent 50%),
    linear-gradient(180deg, hsl(215, 28%, 12%) 0%, hsl(215, 28%, 8%) 100%);
}

/* --- Glassmorphism Effect --- */
.glass-surface {
  background: hsla(var(--color-primary-h), var(--color-primary-s), var(--color-primary-l), 0.08);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border: 1px solid hsla(var(--color-primary-h), var(--color-primary-s), var(--color-primary-l), 0.15);
}

/* --- Tidal Animation (Slow, Rhythmic) --- */
@keyframes tidal {
  0%, 100% {
    transform: translateY(0) scale(1);
    opacity: 0.6;
  }
  50% {
    transform: translateY(-8px) scale(1.02);
    opacity: 0.8;
  }
}

.animate-tidal {
  animation: tidal 6s cubic-bezier(0.45, 0.05, 0.55, 0.95) infinite;
}

/* --- Entrance Fade-Up --- */
@keyframes fadeUp {
  from {
    opacity: 0;
    transform: translateY(16px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.fade-up {
  animation: fadeUp 0.6s cubic-bezier(0.25, 0.1, 0.25, 1) forwards;
}

/* --- Hover Lift (Subtle) --- */
.hover-lift {
  transition: transform var(--transition-normal), box-shadow var(--transition-normal);
}

.hover-lift:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
}

/* --- Bioluminescent Glow Effect --- */
.glow-accent {
  position: relative;
}

.glow-accent::after {
  content: '';
  position: absolute;
  inset: -2px;
  background: radial-gradient(circle at center, hsla(0, 100%, 71%, 0.3), transparent 70%);
  border-radius: inherit;
  opacity: 0;
  transition: opacity var(--transition-normal);
  pointer-events: none;
  z-index: -1;
}

.glow-accent:hover::after {
  opacity: 1;
}

/* --- Data Value Highlight --- */
.data-highlight {
  font-family: var(--font-mono);
  font-weight: var(--weight-semibold);
  background: linear-gradient(90deg,
    hsla(var(--color-primary-h), var(--color-primary-s), var(--color-primary-l), 0.1),
    hsla(var(--color-secondary-h), var(--color-secondary-s), var(--color-secondary-l), 0.1)
  );
  padding: 0.125rem 0.375rem;
  border-radius: var(--radius-sm);
  border-left: 2px solid var(--color-primary);
}
```

---

## Example: brand/brand-showcase.html

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Tidepool Brand Showcase</title>

  <!-- Google Fonts -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500&family=Plus+Jakarta+Sans:wght@600;700&display=swap" rel="stylesheet">

  <style>
    /* Inline brand-theme.css tokens for self-contained demo */
    :root {
      --color-primary-h: 196;
      --color-primary-s: 63%;
      --color-primary-l: 29%;
      --color-primary: hsl(var(--color-primary-h) var(--color-primary-s) var(--color-primary-l));
      --color-primary-50: hsl(196 63% 97%);
      --color-primary-500: hsl(196 63% 29%);
      --color-primary-700: hsl(196 72% 18%);

      --color-secondary-h: 175;
      --color-secondary-s: 56%;
      --color-secondary-l: 55%;
      --color-secondary: hsl(var(--color-secondary-h) var(--color-secondary-s) var(--color-secondary-l));
      --color-secondary-400: hsl(175 56% 55%);

      --color-accent: hsl(0 100% 71%);

      --color-bg: hsl(200 20% 97%);
      --color-surface: hsl(214 14% 93%);
      --color-border: hsl(216 8% 83%);
      --color-text: hsl(215 30% 15%);
      --color-text-secondary: hsl(215 14% 35%);
      --color-text-muted: hsl(215 16% 65%);

      --font-heading: 'Plus Jakarta Sans', system-ui, sans-serif;
      --font-body: 'Inter', system-ui, sans-serif;
      --font-mono: 'JetBrains Mono', monospace;

      --text-display: 3.052rem;
      --text-h1: 2.441rem;
      --text-h2: 1.953rem;
      --text-h3: 1.563rem;
      --text-body-lg: 1.125rem;
      --text-body: 1rem;
      --text-caption: 0.75rem;

      --weight-normal: 400;
      --weight-semibold: 600;
      --weight-bold: 700;

      --space-md: 1rem;
      --space-lg: 1.5rem;
      --space-xl: 2rem;
      --space-2xl: 3rem;
      --space-3xl: 4rem;

      --radius-sm: 4px;
      --radius-md: 6px;
      --radius-lg: 8px;

      --shadow-md: 0 2px 8px hsla(215, 30%, 15%, 0.08);
      --transition-normal: 200ms ease;
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
      --shadow-md: 0 4px 12px hsla(215, 50%, 5%, 0.35);
    }

    /* Base styles */
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }

    body {
      font-family: var(--font-body);
      background: var(--color-bg);
      color: var(--color-text);
      line-height: 1.5;
      transition: background 0.3s, color 0.3s;
    }

    /* Hero Section — Bioluminescent Data Concept */
    .hero {
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      padding: var(--space-3xl) var(--space-xl);
      position: relative;
      overflow: hidden;
      background:
        radial-gradient(circle at 20% 30%, hsla(196, 63%, 45%, 0.15) 0%, transparent 50%),
        radial-gradient(circle at 80% 70%, hsla(175, 56%, 55%, 0.12) 0%, transparent 50%),
        radial-gradient(circle at 40% 80%, hsla(196, 63%, 29%, 0.1) 0%, transparent 50%),
        radial-gradient(circle at 90% 20%, hsla(175, 56%, 42%, 0.08) 0%, transparent 50%),
        linear-gradient(180deg, hsl(215, 28%, 12%) 0%, hsl(215, 28%, 8%) 100%);
    }

    .hero-content {
      max-width: 800px;
      text-align: center;
      z-index: 1;
    }

    .hero h1 {
      font-family: var(--font-heading);
      font-size: var(--text-display);
      font-weight: var(--weight-bold);
      color: hsl(210 16% 90%);
      margin-bottom: var(--space-md);
      letter-spacing: -0.03em;
    }

    .hero p {
      font-size: var(--text-body-lg);
      color: hsl(215 12% 68%);
      max-width: 600px;
      margin: 0 auto;
    }

    /* Floating data points (bioluminescent effect) */
    .data-point {
      position: absolute;
      width: 4px;
      height: 4px;
      background: var(--color-secondary);
      border-radius: 50%;
      box-shadow: 0 0 20px hsla(175, 56%, 55%, 0.6);
      animation: float 8s ease-in-out infinite;
    }

    .data-point:nth-child(1) { top: 20%; left: 15%; animation-delay: 0s; }
    .data-point:nth-child(2) { top: 60%; left: 85%; animation-delay: 2s; }
    .data-point:nth-child(3) { top: 80%; left: 25%; animation-delay: 4s; }
    .data-point:nth-child(4) { top: 35%; left: 75%; animation-delay: 1s; }
    .data-point:nth-child(5) { top: 50%; left: 40%; animation-delay: 3s; }

    @keyframes float {
      0%, 100% { transform: translateY(0) scale(1); opacity: 0.4; }
      50% { transform: translateY(-20px) scale(1.2); opacity: 0.8; }
    }

    /* Section container */
    .section {
      max-width: 1200px;
      margin: 0 auto;
      padding: var(--space-3xl) var(--space-xl);
    }

    .section h2 {
      font-family: var(--font-heading);
      font-size: var(--text-h2);
      font-weight: var(--weight-semibold);
      margin-bottom: var(--space-xl);
      color: var(--color-text);
    }

    /* Typography Specimen */
    .type-scale {
      display: grid;
      gap: var(--space-lg);
    }

    .type-example {
      padding: var(--space-lg);
      background: var(--color-surface);
      border-radius: var(--radius-md);
      border-left: 3px solid var(--color-primary);
    }

    .type-example .label {
      font-family: var(--font-mono);
      font-size: var(--text-caption);
      color: var(--color-text-muted);
      margin-bottom: var(--space-md);
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }

    .display { font-family: var(--font-heading); font-size: var(--text-display); font-weight: var(--weight-bold); line-height: 1.1; }
    .h1 { font-family: var(--font-heading); font-size: var(--text-h1); font-weight: var(--weight-bold); line-height: 1.15; }
    .h2 { font-family: var(--font-heading); font-size: var(--text-h2); font-weight: var(--weight-semibold); line-height: 1.2; }
    .h3 { font-family: var(--font-heading); font-size: var(--text-h3); font-weight: var(--weight-semibold); line-height: 1.25; }
    .body-lg { font-size: var(--text-body-lg); line-height: 1.6; }
    .body { font-size: var(--text-body); line-height: 1.5; }

    /* Color Palette */
    .color-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: var(--space-lg);
    }

    .color-swatch {
      border-radius: var(--radius-md);
      overflow: hidden;
      box-shadow: var(--shadow-md);
      transition: transform var(--transition-normal);
      cursor: pointer;
    }

    .color-swatch:hover {
      transform: translateY(-4px);
    }

    .color-swatch .color {
      height: 120px;
      width: 100%;
    }

    .color-swatch .info {
      padding: var(--space-md);
      background: var(--color-surface);
    }

    .color-swatch .name {
      font-family: var(--font-heading);
      font-weight: var(--weight-semibold);
      margin-bottom: 0.25rem;
    }

    .color-swatch .hex {
      font-family: var(--font-mono);
      font-size: var(--text-caption);
      color: var(--color-text-secondary);
    }

    /* Component Gallery */
    .component-grid {
      display: grid;
      gap: var(--space-xl);
    }

    .component-demo {
      padding: var(--space-xl);
      background: var(--color-surface);
      border-radius: var(--radius-lg);
    }

    .component-demo h3 {
      font-family: var(--font-heading);
      font-size: var(--text-h3);
      font-weight: var(--weight-semibold);
      margin-bottom: var(--space-lg);
    }

    .button-group {
      display: flex;
      gap: var(--space-md);
      flex-wrap: wrap;
    }

    .btn {
      padding: 0.75rem 1.5rem;
      border-radius: var(--radius-md);
      font-family: var(--font-body);
      font-weight: var(--weight-semibold);
      border: none;
      cursor: pointer;
      transition: all var(--transition-normal);
    }

    .btn-primary {
      background: var(--color-primary);
      color: white;
    }

    .btn-primary:hover {
      background: var(--color-primary-700);
      transform: translateY(-2px);
      box-shadow: var(--shadow-md);
    }

    .btn-secondary {
      background: var(--color-secondary);
      color: var(--color-text);
    }

    .btn-outline {
      background: transparent;
      border: 2px solid var(--color-primary);
      color: var(--color-primary);
    }

    /* Data Card */
    .data-card {
      background: var(--color-surface);
      border-radius: var(--radius-lg);
      padding: var(--space-xl);
      box-shadow: var(--shadow-md);
      border-top: 3px solid var(--color-primary);
    }

    .data-card .metric {
      font-family: var(--font-mono);
      font-size: var(--text-display);
      font-weight: var(--weight-bold);
      color: var(--color-primary);
      margin-bottom: var(--space-md);
    }

    .data-card .label {
      font-size: var(--text-body);
      color: var(--color-text-secondary);
    }

    /* Theme Toggle */
    .theme-toggle {
      position: fixed;
      top: var(--space-xl);
      right: var(--space-xl);
      padding: 0.75rem 1.25rem;
      background: var(--color-surface);
      border: 2px solid var(--color-border);
      border-radius: var(--radius-md);
      cursor: pointer;
      font-family: var(--font-body);
      font-weight: var(--weight-semibold);
      color: var(--color-text);
      transition: all var(--transition-normal);
      z-index: 100;
    }

    .theme-toggle:hover {
      background: var(--color-primary);
      color: white;
      border-color: var(--color-primary);
    }

    /* Brand Essence */
    .brand-essence {
      max-width: 700px;
      margin: 0 auto;
      font-size: var(--text-body-lg);
      line-height: 1.7;
      color: var(--color-text-secondary);
      text-align: center;
    }
  </style>
</head>
<body data-theme="dark">

  <button class="theme-toggle" onclick="toggleTheme()">
    Toggle Theme
  </button>

  <!-- Hero Section -->
  <section class="hero">
    <div class="data-point"></div>
    <div class="data-point"></div>
    <div class="data-point"></div>
    <div class="data-point"></div>
    <div class="data-point"></div>

    <div class="hero-content">
      <h1>Tidepool</h1>
      <p>Making ocean data legible. From satellite feeds to sensor arrays, we surface the stories hidden in the currents.</p>
    </div>
  </section>

  <!-- Typography Specimen -->
  <section class="section">
    <h2>Typography</h2>
    <div class="type-scale">
      <div class="type-example">
        <div class="label">Display · Plus Jakarta Sans Bold</div>
        <div class="display">Ocean Health Dashboard</div>
      </div>
      <div class="type-example">
        <div class="label">Heading 1 · Plus Jakarta Sans Bold</div>
        <div class="h1">Monitor ocean conditions in real time</div>
      </div>
      <div class="type-example">
        <div class="label">Heading 2 · Plus Jakarta Sans Semibold</div>
        <div class="h2">Data feeds from 40+ sensor networks</div>
      </div>
      <div class="type-example">
        <div class="label">Heading 3 · Plus Jakarta Sans Semibold</div>
        <div class="h3">Track dissolved oxygen, salinity, and temperature</div>
      </div>
      <div class="type-example">
        <div class="label">Body Large · Inter Regular</div>
        <div class="body-lg">Tidepool connects researchers to the ocean's pulse. Our platform synthesizes data from satellite imagery, coastal sensors, and autonomous vehicles into a single, coherent view.</div>
      </div>
      <div class="type-example">
        <div class="label">Body · Inter Regular</div>
        <div class="body">Every data point tells part of the story. Tidepool makes it possible to see the whole picture—from surface temperature shifts to deep-current patterns emerging over decades.</div>
      </div>
    </div>
  </section>

  <!-- Color Palette -->
  <section class="section">
    <h2>Color Palette</h2>
    <div class="color-grid">
      <div class="color-swatch">
        <div class="color" style="background: hsl(196 63% 29%);"></div>
        <div class="info">
          <div class="name">Deep Current</div>
          <div class="hex">#1B5E7B</div>
        </div>
      </div>
      <div class="color-swatch">
        <div class="color" style="background: hsl(175 56% 55%);"></div>
        <div class="info">
          <div class="name">Seafoam</div>
          <div class="hex">#4ECDC4</div>
        </div>
      </div>
      <div class="color-swatch">
        <div class="color" style="background: hsl(0 100% 71%);"></div>
        <div class="info">
          <div class="name">Coral Signal</div>
          <div class="hex">#FF6B6B</div>
        </div>
      </div>
      <div class="color-swatch">
        <div class="color" style="background: hsl(215 28% 10%);"></div>
        <div class="info">
          <div class="name">Abyss (Dark BG)</div>
          <div class="hex">#161D28</div>
        </div>
      </div>
    </div>
  </section>

  <!-- Component Gallery -->
  <section class="section">
    <h2>Components</h2>
    <div class="component-grid">
      <div class="component-demo">
        <h3>Buttons</h3>
        <div class="button-group">
          <button class="btn btn-primary">Start Monitoring</button>
          <button class="btn btn-secondary">View Live Data</button>
          <button class="btn btn-outline">Learn More</button>
        </div>
      </div>

      <div class="component-demo">
        <h3>Data Card</h3>
        <div class="data-card">
          <div class="metric">8.2 mg/L</div>
          <div class="label">Dissolved Oxygen · Station 47B</div>
        </div>
      </div>
    </div>
  </section>

  <!-- Brand Essence -->
  <section class="section">
    <div class="brand-essence">
      <p>Tidepool makes ocean data legible. Where others see noise—satellite feeds, sensor arrays, tidal models—Tidepool sees stories. The brand sits at the intersection of scientific rigor and environmental wonder: precise enough for marine biologists, alive enough to make someone care about dissolved oxygen levels.</p>
    </div>
  </section>

  <script>
    function toggleTheme() {
      const body = document.body;
      const currentTheme = body.getAttribute('data-theme');
      const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
      body.setAttribute('data-theme', newTheme);
    }
  </script>
</body>
</html>
```

---

## Example: Handoff Summary

> **Files created:**
>
> | File | Description |
> |------|-------------|
> | `brand/brand-guideline.md` | Complete brand identity guidelines — colors, typography, spacing, components, voice & tone |
> | `brand/brand-theme.css` | CSS custom properties in HSL format with designed dark mode |
> | `brand/brand-showcase.html` | Live brand showcase page — open in browser to see the brand in action |
> | `brand/brand-effects.css` | Advanced visual effects — layered shadows, mesh gradients, animations |
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
> @import './brand/brand-effects.css'; /* Optional */
> ```
>
> **Key decisions:**
> 1. Deep Current (#1B5E7B) as primary — carries the "scientific precision" emotion while staying warm enough to avoid clinical coldness
> 2. Plus Jakarta Sans for headings over DM Sans — the slightly rounded terminals match the "approachable authority" tension
> 3. 1.25 major third type scale — the data-dense dashboard context needs tighter hierarchy than a marketing site
> 4. 4px base border radius — precise but not sharp, reflecting the "rigorous yet human" brand position
> 5. "Bioluminescent data" visual concept — points of light emerging from ocean depth, connecting scientific data to natural wonder
>
> **Verification:**
> Open `brand-showcase.html` in your browser. Does the hero feel like YOUR brand? Does the dark/light toggle maintain personality in both modes? The showcase should feel distinctive — not like a generic template with your colors swapped in.
>
> **Suggested next steps:**
> Start with a dashboard data card component to pressure-test the color palette with real data. Data-heavy UI is the hardest context for a brand to survive in — if it works there, it works everywhere.
