# HIV Grand Rounds: LA-ART & LA-PrEP at MXM

Slidev presentation for UCSF/ZSFG HIV Grand Rounds, April 2026.

**Presenter**: Nicky Mehtani, MD MPH
**Duration**: ~20-25 minutes (23 slides)
**Format**: Case-based grand rounds with 4 interactive Poll Everywhere questions

## Setup

```bash
cd talks/53_hiv_grand_rounds_slidev
pnpm install
pnpm dev
```

## Commands

| Command | Description |
|---------|-------------|
| `pnpm dev` | Start dev server with live reload |
| `pnpm build` | Build for production |
| `pnpm export` | Export to PDF |
| `pnpm export-png` | Export slides as PNG images |

## Before Presenting

1. Replace the 4 Poll Everywhere placeholder boxes (slides 8, 10, 18, 22) with actual QR codes/links
2. Test presenter mode (`/presenter` in the URL) to verify speaker notes display correctly
3. EB Garamond font loads from Google Fonts -- ensure internet access or pre-cache

## Theme

UCSF Institutional (custom CSS):
- Navy: #1B2A4A
- Teal: #0095A8
- Gold: #FDB515 (callout boxes)
- Headings: EB Garamond (serif)
- Body: Arial (sans-serif)

## Slide Structure

| Slides | Section |
|--------|---------|
| 1 | Title |
| 2-3 | LA-ART data overview |
| 4 | Oral vs. LA-ART comparison |
| 5 | LA-PrEP data |
| 6-12 | Patient 1 (LEN protection during LTFU) |
| 13-15 | Patient 2 (timeline + LEN monotherapy mystery) |
| 16-19 | Patient 3 (same-day dilemma for non-patient) |
| 20-22 | Patient 4 (IRIS risk with AIDS + pericardial history) |
| 23 | Takeaways + citations |
