---
name: Obsidian Wealth Interface
colors:
  surface: '#0f131c'
  surface-dim: '#0f131c'
  surface-bright: '#353943'
  surface-container-lowest: '#0a0e17'
  surface-container-low: '#181b25'
  surface-container: '#1c1f29'
  surface-container-high: '#262a34'
  surface-container-highest: '#31353f'
  on-surface: '#dfe2ef'
  on-surface-variant: '#bdc8d1'
  inverse-surface: '#dfe2ef'
  inverse-on-surface: '#2c303a'
  outline: '#87929a'
  outline-variant: '#3e484f'
  surface-tint: '#7bd0ff'
  primary: '#8ed5ff'
  on-primary: '#00354a'
  primary-container: '#38bdf8'
  on-primary-container: '#004965'
  inverse-primary: '#00668a'
  secondary: '#4edea3'
  on-secondary: '#003824'
  secondary-container: '#00a572'
  on-secondary-container: '#00311f'
  tertiary: '#ffbcbf'
  on-tertiary: '#67001b'
  tertiary-container: '#ff929a'
  on-tertiary-container: '#8c0028'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#c4e7ff'
  primary-fixed-dim: '#7bd0ff'
  on-primary-fixed: '#001e2c'
  on-primary-fixed-variant: '#004c69'
  secondary-fixed: '#6ffbbe'
  secondary-fixed-dim: '#4edea3'
  on-secondary-fixed: '#002113'
  on-secondary-fixed-variant: '#005236'
  tertiary-fixed: '#ffdadb'
  tertiary-fixed-dim: '#ffb2b7'
  on-tertiary-fixed: '#40000d'
  on-tertiary-fixed-variant: '#92002a'
  background: '#0f131c'
  on-background: '#dfe2ef'
  surface-variant: '#31353f'
typography:
  display:
    fontFamily: Geist
    fontSize: 2.25rem
    fontWeight: '700'
    lineHeight: 2.75rem
    letterSpacing: -0.03em
  headline-lg:
    fontFamily: Geist
    fontSize: 1.75rem
    fontWeight: '600'
    lineHeight: 2.25rem
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Geist
    fontSize: 1.25rem
    fontWeight: '600'
    lineHeight: 1.75rem
    letterSpacing: -0.015em
  headline-sm:
    fontFamily: Geist
    fontSize: 1rem
    fontWeight: '600'
    lineHeight: 1.5rem
  body-lg:
    fontFamily: Inter
    fontSize: 1rem
    fontWeight: '400'
    lineHeight: 1.5rem
  body-md:
    fontFamily: Inter
    fontSize: 0.875rem
    fontWeight: '400'
    lineHeight: 1.375rem
  body-sm:
    fontFamily: Inter
    fontSize: 0.75rem
    fontWeight: '400'
    lineHeight: 1.125rem
  currency-hero:
    fontFamily: Geist
    fontSize: 2rem
    fontWeight: '700'
    lineHeight: 2.5rem
    letterSpacing: -0.02em
  currency-card:
    fontFamily: Geist
    fontSize: 1.375rem
    fontWeight: '600'
    lineHeight: 1.75rem
    letterSpacing: -0.01em
  table-data:
    fontFamily: Inter
    fontSize: 0.875rem
    fontWeight: '500'
    lineHeight: 1.25rem
  numeric-metric:
    fontFamily: JetBrains Mono
    fontSize: 0.8125rem
    fontWeight: '500'
    lineHeight: 1rem
  badge-label:
    fontFamily: Inter
    fontSize: 0.6875rem
    fontWeight: '600'
    lineHeight: 0.875rem
    letterSpacing: 0.02em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  sidebar-w: 260px
  gutter-xs: 0.25rem
  gutter-sm: 0.5rem
  gutter-md: 1rem
  gutter-lg: 1.5rem
  gutter-xl: 2rem
  margin-screen: 2rem
  table-row-h: 3.25rem
  card-pad: 1.25rem
---

## Brand & Style
The design system caters to an elite, high-precision personal and business wealth management dashboard. Moving away from utilitarian, harsh black spreadsheets and unstyled blocks, it delivers an authoritative, high-density dark mode environment that feels like a private banking command terminal crossed with modern SaaS precision. 

The aesthetic is anchored in **Glassmorphic Precision Minimalism**:
- **Controlled Depth:** Layered tones of deep midnight zinc (`#090d16` to `#131b2e`) rather than flat, void-like pitch black.
- **Micro-Luminescence:** Subtly tinted hairline borders and soft contextual ambient glows that direct user focus toward pivotal financial metrics without causing visual fatigue.
- **Analytical Rigor:** Clean spatial discipline, monospaced tabular data figures, high-legibility typographic scale, and streamlined transaction states.

## Colors
The system relies on a curated balance of deep navy-tinted obsidian neutrals and precise semantic telemetry:

### Surface & Base Structure
- **Canvas Base (`#090d16`):** The primary background, providing a deep, glare-free working area.
- **Card Surface (`#131b2e`):** The foundational container color for analytical modules, transaction rows, and KPI widgets.
- **Raised / Dropdown Surface (`#1a243b`):** Used for flyouts, modals, hover states, and popovers.
- **Subtle Hairline Borders (`#1e293b`):** 1px structural outlines defining modular bounds with a 50% opacity blend.

### Semantic Telemetry
- **Positive Yield / Income (`#10b981`):** Vivid emerald green reserved for incoming cash flows, surpluses, and growth metrics. Accompanied by a translucent badge container (`rgba(16, 185, 129, 0.12)`).
- **Expense / Outflow / Deficit (`#f43f5e`):** Vibrant rose-crimson for expenses, budget limits reached, and negative balances. Paired with container fill (`rgba(244, 63, 94, 0.12)`).
- **Interactive / Focus Accent (`#38bdf8`):** Sky cyan highlighting active navigation tabs, interactive primary filters, date selectors, and primary action buttons.
- **Secondary Accent (`#6366f1`):** Electric indigo utilized for tertiary groupings, metadata tags, and complex multi-series financial charts.

### Neutrals & Text Hierarchy
- **Text High-Emphasis (`#f8fafc`):** Primary currency balances and section titles.
- **Text Medium-Emphasis (`#94a3b8`):** Table descriptions, secondary metrics, and column headers.
- **Text Low-Emphasis (`#64748b`):** Inactive icons, helper hints, and historical dates.

## Typography
Typography is optimized for dense numerical readability and visual precision:
- **Numerical Regularity:** All numerical data, currencies (`R$`), and variance percentages must use CSS tabular numerals (`font-variant-numeric: tabular-nums lining-nums;`). This prevents alignment jitter in transaction lists and comparison matrices.
- **Hierarchy Split:** `Geist` provides clinical modernity for headlines, primary KPIs, and prominent balance totals. `Inter` ensures neutral readability for labels, forms, and transactions. `JetBrains Mono` handles micro-metrics, dates, and comparison indicators.

## Layout & Spacing
The layout implements a **persistent asymmetric workbench layout** tailored for wide desktop viewports:
- **Persistent Navigation Rail:** Fixed 260px sidebar along the left edge, hosting application modules, account switcher, and active sub-routes.
- **Main Command Viewport:** Fluid flex-grow container with a max inner content width of 1600px, flanked by minimum 32px safe horizontal margins.
- **Dashboard Grid Layout:** A dynamic 12-column CSS grid system using 16px row and column gutters. Summary KPI metrics span 4 columns on desktop (or 3 columns for quarterly recaps), while detailed chart visualizers span 8 to 12 columns.
- **Responsive Adaptability:** On viewport widths under 1024px, the sidebar collapses into an icon-only or sliding drawer, and KPI clusters collapse into 2-column or 1-column stacks.

## Elevation & Depth
Depth is constructed through **layered dark luminescence and micro-borders** instead of heavy drop shadows:

1. **Level 0 (Canvas Base):** Solid `#090d16`. 
2. **Level 1 (Card & Module Surface):** `#131b2e` with a 1px solid border of `#1e293b`.
3. **Level 2 (Active/Hovered Card):** Background transitions to `#172138` with border tinting toward `#38bdf8` at 30% opacity, paired with an ambient shadow: `box-shadow: 0 8px 24px -4px rgba(2, 6, 23, 0.6), 0 0 12px -2px rgba(56, 189, 248, 0.08)`.
4. **Level 3 (Modals, Context Menus, and Drawers):** `#1a243b` paired with `backdrop-filter: blur(16px)` and a crisp outer border of `rgba(255, 255, 255, 0.08)`.

## Shapes
The design adopts a balanced, tailored corner radius:
- **Cards & Data Panels:** `12px` (`0.75rem`) for a modern card enclosure.
- **Buttons & Input Controls:** `8px` (`0.5rem`) for crisp actionable targets.
- **Pill Badges & Status Chips:** `9999px` (Full Pill) for semantic flags, expense categories, and monthly comparison indicators.
- **Icons & Avatar Avatars:** `8px` (`0.5rem`) squircle containers with recessed tinted backgrounds.

## Components

### Financial KPI Cards
- **Structure:** Surface `#131b2e`, 1px border `#1e293b`, 20px internal padding.
- **Content:** Subtitle in `body-sm` (`#94a3b8`), primary value in `currency-card` (`#f8fafc`).
- **Variance Indicator:** Top-right aligned micro-pill container. Positive changes use `#10b981` with `rgba(16, 185, 129, 0.1)` background; negative changes use `#f43f5e` with `rgba(244, 63, 94, 0.1)`.

### Financial Data Table
- **Header:** Sticky row, uppercase 11px label font (`#64748b`), subtle bottom border in `#1e293b`.
- **Data Rows:** Alternating row highlights on hover (`#172138`). Height fixed at 52px. Monetary figures right-aligned with `JetBrains Mono`.
- **Category Badge:** Compact pill featuring a category icon (e.g., cart, meal, utilities) on the left, 12px font size, semi-transparent background tinted by category color.

### Action Buttons
- **Primary:** Gradient fill from `#0284c7` to `#38bdf8`, font `Inter` semibold `#ffffff`, subtle outer ring on focus.
- **Secondary / Ghost:** Transparent surface with 1px border `#334155`, text `#f1f5f9`, hover fill `#1e293b`.
- **Destructive:** Border and text in `#f43f5e`, background `rgba(244, 63, 94, 0.08)`, hovering into solid `#e11d48`.

### Navigation Item
- **Standard:** Flex row with 12px horizontal padding, 10px vertical padding. Icon sized 18px. Muted text `#94a3b8`.
- **Active State:** Background `rgba(56, 189, 248, 0.1)`, text `#38bdf8`, left-aligned 3px indicator strip in `#38bdf8`.

### Category Heatmap / Mini-Charts
- Bar graphs and distribution grids use smooth gradients fading toward the baseline. Reference lines (average lines) are drawn with dashed 1px strokes in `#64748b` accompanied by inline badge indicators.