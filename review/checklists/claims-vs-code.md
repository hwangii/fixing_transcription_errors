# Checklist — claims vs. code

Does each number and claim actually follow from what the code computes? This is
the class of error that survives internal review and dies at the referee stage,
because the author reads the claim and the code as the same object.

## The central risk in this project

The paper compares a model transcription against **Ancestry** and
**FamilySearch**. Neither is ground truth. So:

- Any sentence using **"accuracy", "correct", "error rate", or "improves"** where
  the code computes **agreement with a comparison transcription** is a finding.
  Agreement with Ancestry rises if the model learns Ancestry's mistakes.
- "Model agrees with FamilySearch but not Ancestry" is evidence about *which
  source the model resembles*, not about which is right. Check whether the text
  claims more than that.
- Where true accuracy *is* claimed, there must be a hand-validated sample with a
  stated size and protocol. Find it, or flag its absence.

## Numbers

- Every statistic in a table or abstract: locate the line of code that produces
  it. Report any you cannot trace.
- Denominators. A rate quoted as "of all records" computed over a restricted
  sample is the most common version of this error. Check what the denominator
  actually counts — in this repo, whether it requires *both* name fields
  non-empty or *either*.
- Categories claimed to be exhaustive or mutually exclusive: verify they
  partition. Four counts described as covering all cases must sum to the
  denominator. If a record with an empty name field can fall into two categories
  (or none), say so.
- Percentages computed over different samples but presented side by side.
- Numbers that changed in the code but not in the text, or vice versa.

## Comparisons

- Improvements quoted without the baseline's own error rate.
- Aggregates hiding sign reversals in subgroups.
- Comparisons across states/years where the sample composition differs (a state
  excluded from one loop but not another).
- Ditto-resolved and non-ditto fields compared jointly, then described as a single
  "name match" rate.

## Language

Flag each of these where the code does not support the strength of the word:

- "shows" / "demonstrates" / "proves" for a correlation.
- "substantially" / "dramatically" without an effect size.
- "robust" where one specification was run.
- Causal verbs ("increases", "reduces", "causes") on a descriptive comparison.

## What to output

For each: quote the claim, cite the code at `path:line`, and state precisely what
the code computes instead. If the claim is supported, say so — a verified claim is
a useful result under deadline.
