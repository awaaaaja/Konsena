---
name: Luminous Violet Guardian
colors:
  surface: '#f4fafd'
  surface-dim: '#d4dbdd'
  surface-bright: '#f4fafd'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eef5f7'
  surface-container: '#e8eff1'
  surface-container-high: '#e2e9ec'
  surface-container-highest: '#dde4e6'
  on-surface: '#161d1f'
  on-surface-variant: '#484555'
  inverse-surface: '#2b3234'
  inverse-on-surface: '#ebf2f4'
  outline: '#797586'
  outline-variant: '#cac4d7'
  surface-tint: '#623edd'
  primary: '#430cbf'
  on-primary: '#ffffff'
  primary-container: '#5b36d6'
  on-primary-container: '#d2c7ff'
  inverse-primary: '#cabeff'
  secondary: '#5e5d6e'
  on-secondary: '#ffffff'
  secondary-container: '#e3e0f5'
  on-secondary-container: '#646374'
  tertiary: '#004a39'
  on-tertiary: '#ffffff'
  tertiary-container: '#00644e'
  on-tertiary-container: '#4ae6bc'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e6deff'
  primary-fixed-dim: '#cabeff'
  on-primary-fixed: '#1d0061'
  on-primary-fixed-variant: '#491bc5'
  secondary-fixed: '#e3e0f5'
  secondary-fixed-dim: '#c7c4d9'
  on-secondary-fixed: '#1a1a29'
  on-secondary-fixed-variant: '#464556'
  tertiary-fixed: '#63fbcf'
  tertiary-fixed-dim: '#3fdeb4'
  on-tertiary-fixed: '#002118'
  on-tertiary-fixed-variant: '#00513f'
  background: '#f4fafd'
  on-background: '#161d1f'
  surface-variant: '#dde4e6'
typography:
  headline-xl:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '800'
    lineHeight: 40px
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 28px
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 15px
    fontWeight: '600'
    lineHeight: 20px
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 13px
    fontWeight: '600'
    lineHeight: 18px
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 11px
    fontWeight: '700'
    lineHeight: 14px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1.25rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

This design system expresses safety, transparency, and clarity for modern consumer privacy intelligence. It marries a high-tech AI foundation with approachable consumer warmth, converting intimidating legal documents and dense terms-of-service into digestible, trustworthy visual narratives.

The visual direction combines **Modern / HIG-inspired mobile clarity** with **luminous ambient glass and soft tinting**:
- **Tone:** Vigilant yet reassuring, intelligent, friendly, and effortless.
- **Atmosphere:** Clean white elevated surfaces, luminous purple radiance, soft pastel backdrops, and focused clarity that builds instant user confidence.
- **Motion & Depth:** Weightless cards floating on ambient lilac shadows, smooth progress rings, and reassuring micro-confirmations.

## Colors

The color palette centers around a royal, vibrant violet-indigo primary hue grounded by soft lavender surfaces, reassuring mint green status indicators, and warning coral accents.

### Color Tokens & Semantic Roles
- **Primary (`#5B36D6`):** Used for primary conversion triggers, bottom navigation active icons, scan focus rings, and high-impact key metric badges. Alternate vibrant step: `#6C5CE7`.
- **Secondary (`#E8E5FA`):** Soft lilac base used for card washes, active tab containers, pill badges, and input fills. Lightest step: `#F3F0FF`.
- **Tertiary / Success (`#55EFC4`):** Soft mint green representing safe permissions, verified compliance, and protected status badges. Lighter tint: `#A8E6CF`.
- **Warning / Alert (`#FFA07A`):** Amber coral applied to medium/high risk ratings, flagged tracking permissions, and caution indicators.
- **Neutral Foreground (`#2D3436`):** Deep charcoal ink for high-contrast, accessible typography on white and tinted surfaces. Subdued text utilizes `#636E72` and `#A29BFE`.
- **Canvas & Surface:** Pristine `#FFFFFF` cards resting on `#F8F7FD` base canvas.

## Typography

Typography is powered exclusively by **Plus Jakarta Sans**, providing modern geometry, friendly rounded letterforms, and exceptional legibility across dense privacy assessments and analytical cards.

- **Headlines:** Set in bold and extrabold weights with tight tracking (`-0.02em`) to provide reassuring, authoritative titles.
- **Body Text:** Neutral charcoal tone with relaxed line heights for scanning privacy disclaimers and highlighted policy clauses comfortably.
- **Labels & Microcopy:** High-legibility medium/semibold weights used in chips, status pills, table headers, and bottom navigation bar labels.

## Layout & Spacing

The layout is built mobile-first, prioritizing ergonomic thumb zones, structured stacked cards, and generous vertical rhythm.

- **Mobile Viewport (375px - 430px):** 4-column layout with 20px (`1.25rem`) side margins and 16px (`1rem`) gutters. Content elements stack vertically in modular card sections.
- **Tablet / Expanded Viewport (768px+):** Scales to 8 columns with 32px margins, enabling dual-pane comparison views (e.g., comparing Policy A vs Policy B side-by-side).
- **Rhythm:** An 8pt grid anchors all spacing tokens. Internal card padding stays strictly between 16px (`space-md`) and 24px (`space-lg`) to preserve clean visual breathing room.

## Elevation & Depth

Visual hierarchy avoids generic harsh gray drop shadows, opting instead for ambient, purple-tinted luminescence that gives screens a branded, glowing presence.

- **Surface Level 0 (Canvas):** `#F8F7FD` flat background canvas.
- **Surface Level 1 (Cards & Tile Surfaces):** `#FFFFFF` pure white fill with a soft tinted shadow: `box-shadow: 0 8px 24px -4px rgba(91, 54, 214, 0.08), 0 2px 6px -1px rgba(91, 54, 214, 0.04)`.
- **Surface Level 2 (Floating Action Triggers & Modals):** Pure white or primary violet fill with `box-shadow: 0 16px 36px -6px rgba(91, 54, 214, 0.22)`.
- **Low-Contrast Structural Borders:** Cards, inputs, and chips use a subtle 1px border colored `rgba(91, 54, 214, 0.08)` to maintain structure against white backdrops.

## Shapes

The interface embraces a friendly, rounded aesthetic (`level 2`) balancing approachable consumer softness with precise structure.

- **Base Components (Inputs, Buttons, Pills):** 16px (`1rem`) corner radius.
- **Containers & Cards:** 24px (`1.5rem`) corner radius for high tactile friendliness.
- **Nested Inner Badges & Small Icon Boxes:** 10px–12px corner radius.
- **Full-Pill Elements:** Circular avatars, status tags, segmented tabs, and floating pill chips use `rounded-full` (9999px).

## Components

### Buttons
- **Primary Button:** `#5B36D6` solid fill, white text, 52px height on mobile, full-width or inline-flex with rounded-2xl geometry. On active press, transforms with `scale(0.98)` and deepened shadow.
- **Secondary / Soft Button:** `#F3F0FF` background, `#5B36D6` semibold label, zero border, subtle purple hover glow.
- **Icon Actions:** Circular or 16px rounded squares with lilac backdrops and deep purple glyphs.

### Chips & Segmented Controls
- **Segmented Control Bar:** `#F3F0FF` background trough with 12px padding. The active segment is an elevated `#FFFFFF` pill with subtle violet shadow and deep violet text; inactive tabs use muted charcoal text.
- **Status Pills:** Compact, pill-shaped tags (`rounded-full`). Warning states use pastel coral background (`#FFE8E0`) with `#D35400` text; safe states use light mint (`#E2FBF4`) with `#00A389` text.

### Cards
- **Overview & Result Cards:** `#FFFFFF` background, 20px–24px padding, 24px radius, soft ambient violet shadow.
- **Highlighted Excerpt Cards:** Pale lavender background (`#F8F7FF`) paired with a left quotation accent or subtle purple stroke (`#E8E5FA`).

### Form Elements & Switches
- **Inputs:** 48px height, `#F9F8FE` subtle fill, 1px `#E8E5FA` border, transitioning to a 2px `#5B36D6` focus ring.
- **Toggle Switches:** 32px height, 52px width. Inactive track is soft gray-lilac (`#E0DCF5`); active track is vibrant violet (`#5B36D6`) with a crisp white sliding thumb circle.

### Progress & Visualization
- **Risk Score Gauges:** Half-donut radial meters featuring an active colored arc (mint, amber, or violet) set against a soft `#E8E5FA` track, with centered bold risk ratings (`headline-md`).
- **Policy Comparison Matrix:** Dual-column comparison cards with app logos, risk status badges, and side-by-side data permission rows separated by soft `#F3F0FF` divider lines.

### Bottom Navigation
- Fixed floating bar with glassmorphic backdrop (`backdrop-blur: 16px; background: rgba(255, 255, 255, 0.9)`), top subtle border (`rgba(91, 54, 214, 0.08)`).
- Active item displays an iconic `#5B36D6` filled glyph and vibrant purple label; inactive items display muted `#A29BFE` outlines.