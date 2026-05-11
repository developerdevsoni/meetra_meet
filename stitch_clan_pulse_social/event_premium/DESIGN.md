---
name: Event Premium
colors:
  surface: '#fdf7ff'
  surface-dim: '#ded8e0'
  surface-bright: '#fdf7ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f8f2fa'
  surface-container: '#f2ecf4'
  surface-container-high: '#ece6ee'
  surface-container-highest: '#e6e0e9'
  on-surface: '#1d1b20'
  on-surface-variant: '#494551'
  inverse-surface: '#322f35'
  inverse-on-surface: '#f5eff7'
  outline: '#7a7582'
  outline-variant: '#cbc4d2'
  surface-tint: '#6750a4'
  primary: '#4f378a'
  on-primary: '#ffffff'
  primary-container: '#6750a4'
  on-primary-container: '#e0d2ff'
  inverse-primary: '#cfbcff'
  secondary: '#63597c'
  on-secondary: '#ffffff'
  secondary-container: '#e1d4fd'
  on-secondary-container: '#645a7d'
  tertiary: '#765b00'
  on-tertiary: '#ffffff'
  tertiary-container: '#c9a74d'
  on-tertiary-container: '#503d00'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e9ddff'
  primary-fixed-dim: '#cfbcff'
  on-primary-fixed: '#22005d'
  on-primary-fixed-variant: '#4f378a'
  secondary-fixed: '#e9ddff'
  secondary-fixed-dim: '#cdc0e9'
  on-secondary-fixed: '#1f1635'
  on-secondary-fixed-variant: '#4b4263'
  tertiary-fixed: '#ffdf93'
  tertiary-fixed-dim: '#e7c365'
  on-tertiary-fixed: '#241a00'
  on-tertiary-fixed-variant: '#594400'
  background: '#fdf7ff'
  on-background: '#1d1b20'
  surface-variant: '#e6e0e9'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 48px
    fontWeight: '700'
    lineHeight: '1.1'
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: '1.2'
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '700'
    lineHeight: '1.2'
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '600'
    lineHeight: '1.3'
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: '1.6'
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.6'
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: '1.4'
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: '1.4'
    letterSpacing: 0.02em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 0.5rem
  sm: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  container-max: 1280px
  gutter: 24px
  margin-mobile: 16px
---

## Brand & Style

This design system targets a digitally native Gen Z audience that values both aesthetic "clutter-free" serenity and high-performance energy. The brand personality is a "Refined Athlete of Leisure"—combining the hospitality-driven warmth of Airbnb with the kinetic, community-focused vitality of Strava.

The style is rooted in **Premium Minimalism**. It avoids the sterility of enterprise SaaS by using organic, generous roundedness and a vibrant accent palette. The interface feels light and breathable, prioritizing content and social connections over structural lines. Movement is implied through energetic typography and purposeful whitespace, ensuring the platform feels alive and active without being chaotic.

## Colors

The palette is anchored by a high-clarity neutral base to establish a premium feel. 
- **Core Neutrals:** #F8FAFC provides a crisp, slightly cool canvas that prevents "screen fatigue." Pure white (#FFFFFF) is reserved exclusively for elevated card surfaces to create depth through color contrast rather than borders.
- **Accents:** Used sparingly but boldly for calls to action, status indicators, and community tags. 
  - **Soft Blue** represents discovery and reliability.
  - **Soft Purple** denotes premium events, exclusive "drops," or creator highlights.
  - **Soft Green** signals active participation, "going" status, and growth.
- **Text:** Primary text is a deep ink blue-black to ensure maximum legibility, while secondary text is softened to a slate grey to maintain visual hierarchy.

## Typography

This design system utilizes **Plus Jakarta Sans** for headlines to inject a modern, slightly rounded, and optimistic character that resonates with a younger demographic. For high-density information and body copy, **Inter** is used for its exceptional legibility and systematic rigor.

Hierarchy is established through significant size stepping and weight contrast rather than color changes. Headlines should feel "tight" with reduced letter spacing, while body text is given ample line height (1.6) to ensure an effortless reading experience.

## Layout & Spacing

The layout philosophy follows a **Fluid Grid** model with high-margin "safe zones" to mimic the editorial feel of a high-end magazine.
- **Desktop:** A 12-column grid with a 1280px max-width. Gutters are kept wide (24px) to ensure content never feels cramped.
- **Mobile:** A 4-column grid with 16px side margins. 
- **Rhythm:** An 8pt linear scale is used for all internal component spacing (padding/margins). Generous vertical whitespace between sections (XL spacing) is encouraged to maintain the "Airbnb-style" simplicity and focus.

## Elevation & Depth

Depth is conveyed through **Ambient Shadows** and **Tonal Layering** rather than hard lines. 
- **Card Surfaces:** Use a very soft, diffused shadow: `0px 10px 30px rgba(15, 23, 42, 0.04)`. This creates a floating effect that feels premium and lightweight.
- **Interactions:** On hover, cards should slightly lift (increase shadow spread) rather than change border color.
- **Backgrounds:** The use of #F1F5F9 for secondary containers (like search bars or sidebars) provides a "recessed" look without requiring a stroke. 
- **No Heavy Borders:** If a border is required for accessibility, use a 1px stroke of #F1F5F9.

## Shapes

The shape language is defined by "Humanist Geometry." 
- **Standard Radius:** 16px (rounded-lg) for secondary buttons and small cards.
- **Large Radius:** 20px (rounded-xl) for main event cards and modal containers. 
- **Full Radius:** Standard pill-shaping for tags, status chips, and primary action buttons.
This consistent curvature softens the technical nature of the platform, making it feel approachable and community-oriented.

## Components

- **Buttons:** Primary buttons use a pill-shape with high-contrast backgrounds (Primary Text #0F172A or Accent Blue). They feature a subtle scale-down effect (98%) on click to mimic physical feedback.
- **Cards:** White (#FFFFFF) with 20px corners and ambient shadows. Padding inside cards should be generous (min 24px) to highlight imagery and typography.
- **Chips:** Small, pill-shaped tags using secondary surface color (#F1F5F9) for categories and accent tints for status (e.g., Soft Green background at 10% opacity for "Live").
- **Inputs:** 16px rounded corners with a subtle #F1F5F9 background. Upon focus, the background stays neutral but a 2px Soft Blue shadow (glow) appears.
- **Lists:** Clean, borderless rows separated by 16px of vertical space. Icons are enclosed in 12px rounded squares with secondary surface colors.
- **Event Specifics:** "Strava-inspired" data widgets for event stats (distance, attendees, intensity) should use Bold Label styles and subtle Soft Blue or Purple icons.