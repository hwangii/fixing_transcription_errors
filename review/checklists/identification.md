# Checklist — identification and econometrics

Is the empirical strategy sound? Judge the design, not the code. Where a concern
is standard in the historical-linkage literature, name the concern plainly so the
author can pre-empt it rather than meet it in a referee report.

## The circularity specific to this project

Transcription error affects **who gets linked**, and the paper studies
transcription error using **linked samples**. State plainly wherever this bites:

- Records with unusual or badly transcribed names are *less likely to link*. So a
  linked sample under-represents exactly the records where the model matters most.
  Any accuracy figure computed on linked records is therefore an **upper bound**
  on accuracy in the full population. Is it presented as one?
- If the model's transcriptions are themselves used to build links, then
  evaluating the model on those links is partly circular. Is the link constructed
  from independent fields (age, birthplace, household structure), and is that
  stated?
- Improved transcription *changes the linked sample itself*. A comparison of
  outcomes "before and after fixing transcription" may be comparing different
  populations, not the same population measured better.

## Selection

- Who is in the estimation sample and who fell out, at each step, with counts.
- Non-random attrition from the link: by race, literacy, name commonness,
  nativity, migration status. Common names over-link; rare names under-link.
- Ditto-mark records are structurally different (they sit below a same-surname
  household head). Selecting on successful ditto resolution selects on household
  structure.
- Sample restrictions correlated with the outcome.

## Measurement error

- Classical vs. non-classical. Transcription error is **not** classical: it
  correlates with handwriting quality, enumerator, name rarity, and page
  condition. Attenuation-bias intuition does not apply cleanly.
- Error in a *dependent* variable inflates standard errors; error in a
  *regressor* biases toward zero — but only if classical. Which case is it here,
  and does the text get it right?
- Where the model and comparison sources are both noisy, agreement rates are a
  function of two error processes. Does any claim implicitly treat one as exact?

## Inference

- Clustering: at the level of treatment assignment, not the level of observation.
  Enumeration district and household are plausible levels here.
- Spatially or serially correlated errors across adjacent census pages.
- Multiple hypothesis testing across many states or specifications.
- Very large N making everything significant. Are effect sizes interpreted
  substantively, or is significance doing the work?

## Robustness

- Which specification choices were made, and does the paper show they do not
  drive the result?
- Subgroup results that would be the first thing a referee requests (by race, by
  region, by name commonness).
- Placebo or falsification tests that are available and not run.

## What to output

Separate **"this is wrong"** from **"a referee will ask this"**. Both are useful;
conflating them wastes the author's remaining time before submission.
