# Rehearsal Checklist -- The /epi Workflow Talk

**Total budget**: 18 minutes talk + 2 minutes Q&A (20-minute slot).
**Content target**: ~17.5 minutes over 14 slides, leaving 30-60 seconds slack.

## Timing Targets

| Slide | Title | Target | Cumulative |
|---|---|---|---|
| 1 | Title & Caveat | 0:70 | 1:10 |
| 2 | Motivation | 0:70 | 2:20 |
| 3 | Four-Command Workflow | 0:70 | 3:30 |
| 4 | `/epi` Stage 0 | 0:70 | 4:40 |
| 5 | Study Design | 0:70 | 5:50 |
| 6 | Pipeline Anatomy | 0:60 (trimmed) | 6:50 |
| 7 | DGP (Honesty) | 0:70 | 8:00 |
| 8 | CONSORT Flow | 0:70 | 9:10 |
| 9 | Primary Result (OR 3.29) | 0:70 | 10:20 |
| 10 | Cox Now Runs | 0:80 | 11:40 |
| 11 | Sensitivity Suite | 0:80 | 13:00 |
| 12 | **Byte-Identical (climax)** | **1:30** | 14:30 |
| 13 | Limitations | 0:70 | 15:40 |
| 14 | Takeaways | 0:70 | 16:50 |

Slack between 16:50 and 18:00 = ~70 seconds of cushion for questions
mid-talk or slow transitions. Q&A runs 18:00 -- 20:00.

## Three Key-Message Checkpoints

At the end of each act, verify the audience has the message before moving on:

1. **End of Act I (slide 6, ~7 min)**: Audience should know what the four
   commands are and that Stage 0 forcing questions are the feature, not a
   chore.
2. **End of Act II (slide 11, ~13 min)**: Audience should know the
   headline OR is 3.29, the sensitivity suite corroborates it (including
   the new MICE row), and the tipping-point worst case is the honesty
   anchor at 1.29.
3. **End of Act III (slide 14, ~17 min)**: Audience should walk away
   saying "reproducibility is a property of the code, not a promise".
   Slide 12 is where this lands -- if slide 12 rushes, the whole talk
   rushes.

## Speaker Cues for Caveat Banners

The amber caveat banner appears on slides **1, 7, 9, 10, 13**. At each
appearance, say the caveat verbatim:

> "This is synthetic data from the DGP on slide 7 -- not a clinical
> finding."

Do not paraphrase. The risk is a clinician quoting "KAT reduces relapse
risk by 57 percent" on social media without the caveat. The verbatim
sentence is the mitigation.

## Do Not

- **Do not attempt a live `/epi` demo.** The forcing questions take 3+
  minutes to answer honestly, and a live failure kills the narrative.
  If a demo is wanted, pre-record a 30-second screencap and drop it
  into slide 4.
- **Do not skip the DGP slide (7).** It is the reason every number is
  allowed to be as big as it is.
- **Do not read the receipts strip on slide 12 line-by-line.** Point at
  it and deliver the verbatim line: "Same scripts. Same seed. Different
  R stack. Byte-identical outputs."
- **Do not quote HR 0.426 without the "(synthetic DGP -- slide 7)" strap
  line.** Slide 10 has the strap line; keep the words.
- **Do not claim clinical significance for any number.** Period.

## Pre-Talk Checklist

- [ ] Rerun `pnpm sync-assets` if `../epi-study/` has changed recently.
- [ ] Run `pnpm build` to confirm the deck compiles cleanly.
- [ ] If presenting from PDF: run `pnpm export` and confirm 14 pages.
      (On NixOS this requires a working chromium -- see README.md.)
- [ ] Open the live deck (`pnpm dev`) and verify Mermaid diagrams render
      on slides 3, 5, 8.
- [ ] Verify the receipts strip on slide 12 is readable at projection
      resolution (dark background, small monospace).
- [ ] Walk the deck once aloud with a stopwatch. If you come in under
      16:00 or over 18:00, re-trim slide 6 (under) or slide 12 (over).
- [ ] Rehearse the Q&A: who owns each of the five open questions in
      README.md?

## Backup Q&A Slides (TODO)

Candidates for a post-14 backup deck, keyed to likely questions:

- **"Can I see the full Cox output?"** -> `public/assets/tables/cox_results.txt`
- **"What's in the MICE pool?"** -> `public/assets/tables/sensitivity_mice.txt`
- **"What did the environment look like?"** -> `public/assets/receipts/session_info_r.txt`
- **"Can I see the rerun summary?"** -> `public/assets/receipts/rerun_summary.md`
- **"Wald vs profile-likelihood?"** -> explainer (not yet drafted)

These are not part of the core 14; add them as hidden slides in a future
`/slides 29 --design` pass.
