# Liveline Design Style Guide

> User-confirmed direction · 2026-06-09  
> Implemented in `lib/core/theme/`

## Style Pillars

- **Clean minimal** — whitespace and typography carry hierarchy; no decorative chrome.
- **Todoist + Notion + Google Tasks** — clear task rows, flat sidebar, three-tab mobile nav.
- **Balanced radii** — 8 / 12 / 16 dp.
- **Comfortable density** — 56 dp minimum task row height.
- **True dark** — `#121212` base, OLED-friendly.

## Color Rationale

| Role | Light | Dark | Notes |
|------|-------|------|-------|
| Primary | `#2563EB` | `#3B82F6` | Interaction only — buttons, FAB, active nav |
| Surface tiers | white → `#F8FAFC` → `#F1F5F9` | `#121212` → `#1E1E1E` → `#2C2C2C` | Notion-style quiet panels |
| Priority | red / amber / green | same hues, brighter | Dots + small badges only |
| Complete | `#94A3B8` | `#64748B` | Strikethrough titles |

## Typography

- **Font** — [MiSans](https://hyperos.mi.com/font/) (Xiaomi), a global free
  commercial-use font, **bundled** in `assets/fonts/` so Windows and Android
  share identical CJK + Latin metrics (no reliance on host fonts like
  Microsoft YaHei).
- **Weights** — 400 / 500 / 600 / 700 bundled. The type scale sits one notch
  heavier than Material defaults for comfortable CJK reading:
  - Body: 500 · Section / list titles: 600 · Page & app-bar titles: 700.
- **License note** — per the MiSans IP License, the app must state that MiSans
  Fonts are used (surface in Settings → About). Font files must not be
  redistributed on their own.

## Do / Don't

| Do | Don't |
|----|-------|
| Use whitespace between sections | Color entire rows for status |
| Semantic color on 8 px dots and badges | Saturated card backgrounds |
| Flat sidebar (`elevation: 0`) | Floating sidebar with shadow |
| `#121212` dark surfaces | Blue-grey Material 2 dark |

## Component Quick Reference

- **Task row** — no card wrapper; checkbox + title + badge; divider or 12 dp gap.
- **Priority badge** — 11 sp, `radiusSm`, 12% tint background + semantic text color.
- **Sidebar** — `surfaceContainerLow`; selected = primary 12% fill.
- **FAB** — primary fill, `radiusLg`, elevation 1.
