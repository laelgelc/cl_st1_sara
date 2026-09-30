## Me
Hi! How are you doing, AI Assistant? Please have a look at `cl_st1_ph2_sara/docs/testes_brown-forsyth_e_tukey_no_sas_chat.md` (attached). Here Sara asks me about the applicability of the Brown-Forsythe (BF) and Tukey tests to this project. As you can see, I also found one BF application by Professor Berber Sardinha on his `AI and Human Oral Histories` study. She also provided me with a chat with Claude (`cl_st1_ph2_sara/docs/testes_brown-forsyth_e_tukey_no_sas.md`, attached) in which the LLM Assistant discusses the applicability.

I have also attached this project's SAS script and its respective development specification to this message:

- `cl_st1_ph2_sara/sas/cl_st1_ph2_sara.sas`
- `cl_st1_ph2_sara/sas/cl_st1_ph2_sara.md`

Before getting down to make any changes to the script, I'd like to discuss the matter with you. What are your views on it?

## AI Assistant
Hi! I’m doing well, thanks — and this is a very good methodological question. My view is that **Brown–Forsythe is highly relevant to Sara’s project**, while **Tukey is useful but more conditional**. I would not treat the two tests as equally central.

## Short answer

Yes, I think it is worth adding the tests to the SAS workflow, but with a clear distinction:

1. **Brown–Forsythe should be added and reported as substantively meaningful**, not merely as an assumption check, because Sara’s research question is not only “do the groups differ in average dimension score?” but also “do AI-generated texts reproduce, compress, or expand human variation?”

2. **Tukey can be added as a conventional post-hoc comparison of means**, but it should be framed as answering a different question: which groups differ in their **mean** factor scores. It does **not** test dispersion/homogenisation directly.

3. If Brown–Forsythe indicates unequal variances, then the classical ANOVA/Tukey interpretation should be handled carefully. In that case, **Welch’s ANOVA** is a useful robustness check for the mean comparison, while Brown–Forsythe remains the main test for variance differences.

## Brown–Forsythe: very applicable

Sara’s intuition is basically right, but I would phrase it more cautiously. Brown–Forsythe does not “prove” homogenisation by itself. It tests whether the **variance/dispersal of scores differs significantly among groups**.

In this project, that is especially important because the comparison is among:

- human-authored short stories;
- free LLM-generated stories;
- plot/style-guided LLM-generated stories.

If the theoretical claim is that LLM-generated texts may be more standardised, less dispersed, or more concentrated around certain stylistic patterns, then a test of equality of variances is directly relevant. In other words, Brown–Forsythe answers a question that ANOVA does not answer.

ANOVA asks:

> Are the group means different?

Brown–Forsythe asks:

> Are the group dispersions/variances different?

So Sara’s observation about Dimension 4 is methodologically important: it is entirely possible for groups to have no statistically significant mean difference while still having significantly different variance. That is not a contradiction. It means the central tendency may be similar, while the spread differs. For a study concerned with stylistic variation, that can be a meaningful finding.

This is also why the example from Berber Sardinha’s *AI and Human Oral Histories* study is relevant: the Brown–Forsythe test is appropriate when the substantive question is whether synthetic/AI populations reproduce, compress, or expand the variation observed in human populations.

## Tukey: useful, but not for dispersion

Tukey’s test is different. It is a post-hoc test after ANOVA and compares **pairs of group means**. It helps answer questions like:

- Is the human mean significantly different from the LLM-free mean?
- Is the human mean significantly different from the LLM-guided mean?
- Is the LLM-free mean significantly different from the LLM-guided mean?

That is useful, especially if Sara wants to say not only that there is a significant overall effect of `prompt`, but also which specific conditions differ from which.

However, Tukey should **not** be described as confirming whether “everything fits” or whether there is homogenisation. It does not compare variances. It compares means.

So I would separate the logic as follows:

| Test | Main question | Relevance here |
|---|---|---|
| ANOVA | Do the groups differ in mean dimension score? | Useful for central tendency |
| Tukey | Which pairs of groups differ in mean score? | Useful after/alongside ANOVA |
| Brown–Forsythe | Do the groups differ in variance/dispersion? | Highly relevant to AI homogenisation/dispersal |
| Welch ANOVA | Do the groups differ in mean score when variances are unequal? | Useful robustness check |

## Brown–Forsythe should not be described only as an “assumption test”

This is the most important methodological nuance.

In many statistics workflows, Brown–Forsythe or Levene-type tests are used to check the homogeneity-of-variance assumption before ANOVA. That is fine, but in Sara’s case it is more than that.

If one of the research aims concerns **dispersion**, **stylistic variability**, or **homogenisation**, then Brown–Forsythe becomes a direct inferential test of a substantive hypothesis.

So in the methodology/results, I would avoid saying only:

> Brown–Forsythe was used to verify the homogeneity assumption of ANOVA.

I would prefer something like:

> Brown–Forsythe tests were used to assess whether the three subcorpora differed significantly in the dispersion of their dimension scores. This was relevant to the study’s interest in whether AI-generated texts reproduce, compress, or expand the range of variation observed in human-authored texts.

That formulation is much stronger and more aligned with the project.

## But p-values alone are not enough

One important caution: with large and balanced groups, Brown–Forsythe can become significant even for modest variance differences. Sara should not report only the p-value.

She should also report descriptive dispersion measures, ideally for each dimension and each group:

- standard deviation;
- maybe variance;
- possibly coefficient of variation if appropriate, though with factor scores crossing zero this can be awkward;
- ratio of standard deviations, e.g. AI SD / human SD;
- boxplots or violin/box plots.

The interpretation should be based on both:

1. **statistical significance**: Brown–Forsythe p-value;
2. **effect/magnitude**: how much larger or smaller the dispersion is.

For example, the substantive claim is much more convincing if she can say:

> The LLM-free group showed a significantly smaller variance than the human group in Dimension 4, and its standard deviation was approximately X% lower.

Rather than only:

> Brown–Forsythe was significant.

## About Dimension 4

Sara’s comment that Dimension 4 is interesting even though the ANOVA does not show a mean difference is exactly the kind of thing Brown–Forsythe can reveal.

I would not remove Dimension 4 just because the ANOVA is non-significant. In fact, if Dimension 4 has similar means but different dispersion, that may be one of the most interesting findings, because it suggests that the groups occupy a similar average position on the dimension but differ in how widely their texts vary around that position.

That can support an argument such as:

> The AI-generated texts do not necessarily shift the central tendency on this dimension, but they alter the range of stylistic variation.

That is a meaningful MDA/AMD-style interpretation.

## One modelling issue: `prompt` vs `source`

There is a conceptual point worth keeping in mind. In this project, the three actual comparison groups are already encoded by `prompt`:

- `human`
- `llm_free`
- `llm`

The `source` variable has only:

- `human`
- `ai`

Since both LLM conditions are `source = ai`, `source` is less informative for the three-way comparison. For Brown–Forsythe and Tukey, I would focus on `prompt`, because that is the variable that distinguishes the three experimental/subcorpus conditions.

So the Brown–Forsythe/Tukey tests should probably be organised around **group differences by `prompt`**, not by `source`.

## Outliers matter a lot here

The current methodological decision to retain outliers is defensible, especially because extreme AI stylometric behaviour may be substantively meaningful. But Brown–Forsythe is sensitive to dispersion, so outliers can affect it.

That does not mean outliers must be removed. But Sara should be transparent:

- the main analysis retains outliers because extremes are theoretically meaningful;
- Brown–Forsythe therefore tests dispersion in the full observed distribution;
- optionally, a sensitivity analysis could compare results with and without outliers.

If the Brown–Forsythe results survive both versions, that strengthens the claim. If they change, that is also informative: it suggests that variance differences are driven by extreme texts.

## What I would recommend adding to the SAS workflow

Conceptually, I would add the following outputs for each factor/dimension:

1. **Descriptive statistics by `prompt`**
   - N
   - mean
   - standard deviation
   - variance
   - min/max
   - maybe median and IQR

2. **Classical ANOVA**
   - already present

3. **Welch ANOVA**
   - especially useful if variances differ

4. **Brown–Forsythe**
   - central for dispersion

5. **Tukey post-hoc comparisons**
   - for pairwise mean comparisons

6. **Possibly pairwise dispersion summaries**
   - not necessarily formal pairwise Brown–Forsythe tests, but at least SD/variance ratios among pairs:
     - human vs LLM-free
     - human vs LLM-guided
     - LLM-free vs LLM-guided

## How I would phrase the final methodological logic

Something like this would be methodologically clean:

> For each extracted dimension, one-way GLM models were fitted to test whether mean dimension scores differed across the three prompt conditions. Tukey-adjusted post-hoc comparisons were used to identify which pairs of conditions differed in mean scores. Because the study also investigates whether AI-generated texts reproduce, compress, or expand the stylistic variation of human-authored texts, Brown–Forsythe tests were used to compare the dispersion of dimension scores across conditions. When the Brown–Forsythe test indicated unequal variances, Welch’s ANOVA was used as a robustness check for mean differences. Descriptive statistics, especially group standard deviations, were reported alongside significance tests to assess the magnitude and direction of dispersion differences.

That keeps each test in its proper role.

## My overall view

I would **not remove** the Brown–Forsythe/Tukey material from the chapter. I would incorporate it into the SAS script and methodology, with clearer interpretation.

The strongest methodological position is:

- **ANOVA/Tukey**: differences in average stylistic positioning;
- **Brown–Forsythe**: differences in stylistic variability/dispersion;
- **Welch**: robustness check for mean comparisons when variances are unequal.

So, yes: adding Brown–Forsythe and Tukey to the existing SAS analysis is worthwhile. But Brown–Forsythe should be presented as particularly important to the research question, while Tukey should be presented as a conventional pairwise test of mean differences, not as a test of homogenisation.

## Me
Thank you very much, AI Assistant! I think your assessment is accurate. We can go ahead and incorporate your recommendations into the project. Can we work on a new version of the SAS script (the current one is attached)?

## AI Assistant
Yes — let’s do it. I recommend making a **new SAS script version** rather than overwriting the current one immediately, for example:

```plain text
cl_st1_ph2_sara/sas/cl_st1_ph2_sara_bf_tukey.sas
```


The safest implementation is to leave the MDA/factor-scoring pipeline untouched and modify only **Section 9**. That way, factor extraction, additive scoring, outlier handling, and exported score files remain consistent with the current analysis.

Below is the replacement I suggest for **Section 9**. It adds:

- descriptive statistics by `prompt`;
- classical one-way GLM/ANOVA by `prompt`;
- Brown–Forsythe variance test via `hovtest=bf`;
- Welch ANOVA for unequal-variance mean comparison;
- Tukey post-hoc pairwise comparisons of means;
- CSV exports for all new inferential/descriptive tables;
- existing boxplot generation retained.

```
/* ==========================================================================
   SECTION 9: STATISTICAL ANALYSIS
   ANOVAs, BROWN-FORSYTHE TESTS, WELCH TESTS, TUKEY POST-HOC TESTS & BOXPLOTS
   ========================================================================== */

/*
   The final statistical analysis uses the dimension scores retained in
   &project._no_outliers. Because the outlier-removal bypass in Section 8 is
   active, this dataset contains the full combined score dataset.

   For each factor score f1-f&extractfactors, the following are produced:

   1. Descriptive statistics by prompt:
      N, mean, standard deviation, variance, min, quartiles, median, and max.

   2. Classical one-way GLM/ANOVA:
      Tests whether mean factor scores differ across prompt groups.

   3. Brown-Forsythe test:
      Tests whether the dispersion/variance of factor scores differs across
      prompt groups. In this study, this is a substantive test of variation,
      not only an ANOVA assumption check.

   4. Welch ANOVA:
      Provides a robust mean-comparison test when variances are unequal.

   5. Tukey post-hoc comparisons:
      Identifies which prompt pairs differ in mean factor scores.

   The grouping variable is prompt, because it distinguishes the three
   analytical conditions: human, llm_free, and llm.
*/

/* Descriptive statistics by prompt */
ODS EXCLUDE NONE;
ods html file="&whereisit/&myfolder/descriptive_stats_prompt.html";

%macro create_descriptives(howmany);
%do i=1 %to &howmany;

title "Descriptive statistics by prompt for f&i";
proc means data=&project._no_outliers n mean std var min q1 median q3 max maxdec=4;
    class prompt;
    var f&i;
    ods output Summary=desc_prompt_f&i;
run;

PROC EXPORT
  DATA=WORK.desc_prompt_f&i
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/desc_prompt_f&i..csv"
  REPLACE;
RUN;

%end;
%mend create_descriptives;

%create_descriptives(&extractfactors)

ods html close;
title;


/* ANOVAs, Brown-Forsythe, Welch, and Tukey */
ODS EXCLUDE NONE;
ods html file="&whereisit/&myfolder/glm_meta.html";

%macro create_glm_tests(howmany);
%do i=1 %to &howmany;

OPTIONS VALIDVARNAME=ANY;
ods graphics off;

title "GLM, Brown-Forsythe, Welch, and Tukey tests for f&i";

proc GLM data=&project._no_outliers;
    class prompt;
    model f&i = prompt;

    ods output
        FitStatistics = r2_prompt_f&i
        OverallANOVA  = anova_prompt_f&i
        Means         = means_prompt_f&i
        HOVFTest      = brown_forsythe_prompt_f&i
        Welch         = welch_prompt_f&i
        CLDiffs       = tukey_cldiff_prompt_f&i;

    means prompt / hovtest=bf welch tukey cldiff;
run;
quit;

PROC EXPORT
  DATA=WORK.r2_prompt_f&i
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/r2_prompt_f&i..csv"
  REPLACE;
RUN;

PROC EXPORT
  DATA=WORK.anova_prompt_f&i
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/anova_prompt_f&i..csv"
  REPLACE;
RUN;

PROC EXPORT
  DATA=WORK.means_prompt_f&i
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/means_prompt_f&i..csv"
  REPLACE;
RUN;

PROC EXPORT
  DATA=WORK.brown_forsythe_prompt_f&i
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/brown_forsythe_prompt_f&i..csv"
  REPLACE;
RUN;

PROC EXPORT
  DATA=WORK.welch_prompt_f&i
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/welch_prompt_f&i..csv"
  REPLACE;
RUN;

PROC EXPORT
  DATA=WORK.tukey_cldiff_prompt_f&i
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/tukey_cldiff_prompt_f&i..csv"
  REPLACE;
RUN;

ods graphics on;

%end;
%mend create_glm_tests;

%create_glm_tests(&extractfactors)

ods html close;
title;


/*
   Standard-deviation ratios by prompt.

   These ratios help interpret the magnitude and direction of dispersion
   differences alongside the Brown-Forsythe p-values. They are descriptive:
   values above 1 indicate that the first group has a larger standard deviation
   than the second group; values below 1 indicate smaller dispersion.
*/

%macro create_sd_ratios(howmany);
%do i=1 %to &howmany;

proc sort data=&project._no_outliers out=stats_input_f&i;
    by prompt;
run;

proc means data=stats_input_f&i noprint;
    by prompt;
    var f&i;
    output out=sd_by_prompt_f&i(drop=_TYPE_ _FREQ_) n=n std=std;
run;

proc transpose data=sd_by_prompt_f&i out=sd_wide_f&i prefix=std_;
    id prompt;
    var std;
run;

data sd_ratios_prompt_f&i;
    length factor $10 comparison $40;
    set sd_wide_f&i;

    factor = "f&i";

    comparison = "human / llm_free";
    sd_ratio = std_human / std_llm_free;
    output;

    comparison = "human / llm";
    sd_ratio = std_human / std_llm;
    output;

    comparison = "llm_free / llm";
    sd_ratio = std_llm_free / std_llm;
    output;

    keep factor comparison sd_ratio std_human std_llm_free std_llm;
run;

PROC EXPORT
  DATA=WORK.sd_ratios_prompt_f&i
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/sd_ratios_prompt_f&i..csv"
  REPLACE;
RUN;

%end;
%mend create_sd_ratios;

%create_sd_ratios(&extractfactors)


/* Boxplots */
%macro create_boxplots(howmany);
%do i=1 %to &howmany;

ods listing gpath="&whereisit/&myfolder/";
ods graphics / imagename="boxplot_f&i" imagefmt=png;

title "Box plot for f&i by prompt";
proc GLM data=&project._no_outliers;
    class prompt;
    model f&i = prompt;
    means prompt / hovtest=bf welch tukey cldiff;
run;
quit;

title;

%end;
%mend create_boxplots;

%create_boxplots(&extractfactors)
```


I would also update the development specification so the statistical section no longer says the script only runs ANOVAs and boxplots.

```markdown
## 5. Statistical Analysis & Visualization
*   **Descriptive Statistics:** For each extracted factor score (`f1-f4`), the script calculates group-level descriptive statistics by `prompt`, including N, mean, standard deviation, variance, quartiles, median, minimum, and maximum.
*   **General Linear Models (ANOVA):** Runs `PROC GLM` on the combined scores dataset.
    *   *Model:* `f&i = prompt`
    *   Extracts Fit Statistics, Overall ANOVA tables, and group means to HTML and CSV outputs.
*   **Brown-Forsythe Tests:** For each factor, Brown-Forsythe tests (`HOVTEST=BF`) assess whether the three prompt conditions differ in the dispersion/variance of their dimension scores. In this project, these tests are substantively relevant because they evaluate whether AI-generated subcorpora reproduce, compress, or expand the variation observed in human-authored texts.
*   **Welch Tests:** Welch ANOVA is produced as a robust mean-comparison test when the homogeneity-of-variance assumption is not met.
*   **Tukey Post-Hoc Comparisons:** Tukey-adjusted pairwise comparisons identify which prompt pairs differ in mean factor scores.
*   **Dispersion Magnitude:** Standard-deviation ratios are exported for the main prompt-pair comparisons to support interpretation of Brown-Forsythe results beyond p-values.
*   **Boxplots:** Generates `PROC GLM` boxplots for each factor by `prompt`, outputting as `.png` files.
```


A few implementation notes:

- I would keep the grouping variable as **`prompt`**, not `source`, because `prompt` distinguishes all three conditions.
- I would keep the current outlier-retention bypass active, since that matches the methodological rationale.
- If SAS complains about an ODS table name such as `CLDiffs`, `Welch`, or `HOVFTest`, the fix is easy: temporarily turn `ods trace on;` inside the GLM block, rerun one factor, and adjust the ODS table name to the exact one printed in the SAS log. But the names above are the expected SAS `PROC GLM` table names for this setup.

## Me
Can I have the entire revised script?

## AI Assistant
Yes — but the full script is too long to reproduce safely in one chat response without risking truncation. The **revised full script is the current script with Sections 1–8 and ZIP cleanup unchanged, and Section 9 replaced by the block below**.

So the practical way to create the full revised file is:

1. Copy the current script to a new file, e.g.:

```plain text
cl_st1_ph2_sara/sas/cl_st1_ph2_sara_bf_tukey.sas
```


2. In that new file, replace the entire current **Section 9** — from:

```
/* ==========================================================================
   SECTION 9: STATISTICAL ANALYSIS (ANOVAs & BOXPLOTS)
   ========================================================================== */
```


through the end of the boxplots block, immediately before:

```
/* ==========================================================================
   ZIP OUTPUT FILES
   ========================================================================== */
```


with the revised Section 9 below.

```
/* ==========================================================================
   SECTION 9: STATISTICAL ANALYSIS
   ANOVAs, BROWN-FORSYTHE TESTS, WELCH TESTS, TUKEY POST-HOC TESTS & BOXPLOTS
   ========================================================================== */

/*
   The final statistical analysis uses the dimension scores retained in
   &project._no_outliers. Because the outlier-removal bypass in Section 8 is
   active, this dataset contains the full combined score dataset.

   For each factor score f1-f&extractfactors, the following are produced:

   1. Descriptive statistics by prompt:
      N, mean, standard deviation, variance, min, quartiles, median, and max.

   2. Classical one-way GLM/ANOVA:
      Tests whether mean factor scores differ across prompt groups.

   3. Brown-Forsythe test:
      Tests whether the dispersion/variance of factor scores differs across
      prompt groups. In this study, this is a substantive test of variation,
      not only an ANOVA assumption check.

   4. Welch ANOVA:
      Provides a robust mean-comparison test when variances are unequal.

   5. Tukey post-hoc comparisons:
      Identifies which prompt pairs differ in mean factor scores.

   The grouping variable is prompt, because it distinguishes the three
   analytical conditions: human, llm_free, and llm.
*/


/* --------------------------------------------------------------------------
   9.1. Descriptive statistics by prompt
   -------------------------------------------------------------------------- */

ODS EXCLUDE NONE;
ods html file="&whereisit/&myfolder/descriptive_stats_prompt.html";

%macro create_descriptives(howmany);
%do i=1 %to &howmany;

title "Descriptive statistics by prompt for f&i";

proc means data=&project._no_outliers n mean std var min q1 median q3 max maxdec=4;
    class prompt;
    var f&i;
    ods output Summary=desc_prompt_f&i;
run;

PROC EXPORT
  DATA=WORK.desc_prompt_f&i
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/desc_prompt_f&i..csv"
  REPLACE;
RUN;

%end;
%mend create_descriptives;

%create_descriptives(&extractfactors)

ods html close;
title;


/* --------------------------------------------------------------------------
   9.2. ANOVAs, Brown-Forsythe, Welch, and Tukey tests
   -------------------------------------------------------------------------- */

ODS EXCLUDE NONE;
ods html file="&whereisit/&myfolder/glm_meta.html";

%macro create_glm_tests(howmany);
%do i=1 %to &howmany;

OPTIONS VALIDVARNAME=ANY;
ods graphics off;

title "GLM, Brown-Forsythe, Welch, and Tukey tests for f&i";

proc GLM data=&project._no_outliers;
    class prompt;
    model f&i = prompt;

    ods output
        FitStatistics = r2_prompt_f&i
        OverallANOVA  = anova_prompt_f&i
        Means         = means_prompt_f&i
        HOVFTest      = brown_forsythe_prompt_f&i
        Welch         = welch_prompt_f&i
        CLDiffs       = tukey_cldiff_prompt_f&i;

    means prompt / hovtest=bf welch tukey cldiff;
run;
quit;

PROC EXPORT
  DATA=WORK.r2_prompt_f&i
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/r2_prompt_f&i..csv"
  REPLACE;
RUN;

PROC EXPORT
  DATA=WORK.anova_prompt_f&i
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/anova_prompt_f&i..csv"
  REPLACE;
RUN;

PROC EXPORT
  DATA=WORK.means_prompt_f&i
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/means_prompt_f&i..csv"
  REPLACE;
RUN;

PROC EXPORT
  DATA=WORK.brown_forsythe_prompt_f&i
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/brown_forsythe_prompt_f&i..csv"
  REPLACE;
RUN;

PROC EXPORT
  DATA=WORK.welch_prompt_f&i
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/welch_prompt_f&i..csv"
  REPLACE;
RUN;

PROC EXPORT
  DATA=WORK.tukey_cldiff_prompt_f&i
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/tukey_cldiff_prompt_f&i..csv"
  REPLACE;
RUN;

ods graphics on;

%end;
%mend create_glm_tests;

%create_glm_tests(&extractfactors)

ods html close;
title;


/* --------------------------------------------------------------------------
   9.3. Standard-deviation ratios by prompt
   -------------------------------------------------------------------------- */

/*
   These ratios help interpret the magnitude and direction of dispersion
   differences alongside the Brown-Forsythe p-values.

   They are descriptive:
   - Values above 1 indicate that the first group has a larger standard
     deviation than the second group.
   - Values below 1 indicate that the first group has a smaller standard
     deviation than the second group.
*/

%macro create_sd_ratios(howmany);
%do i=1 %to &howmany;

proc sort data=&project._no_outliers out=stats_input_f&i;
    by prompt;
run;

proc means data=stats_input_f&i noprint;
    by prompt;
    var f&i;
    output out=sd_by_prompt_f&i(drop=_TYPE_ _FREQ_) n=n std=std;
run;

proc transpose data=sd_by_prompt_f&i out=sd_wide_f&i prefix=std_;
    id prompt;
    var std;
run;

data sd_ratios_prompt_f&i;
    length factor $10 comparison $40;
    set sd_wide_f&i;

    factor = "f&i";

    comparison = "human / llm_free";
    sd_ratio = std_human / std_llm_free;
    output;

    comparison = "human / llm";
    sd_ratio = std_human / std_llm;
    output;

    comparison = "llm_free / llm";
    sd_ratio = std_llm_free / std_llm;
    output;

    keep factor comparison sd_ratio std_human std_llm_free std_llm;
run;

PROC EXPORT
  DATA=WORK.sd_ratios_prompt_f&i
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/sd_ratios_prompt_f&i..csv"
  REPLACE;
RUN;

%end;
%mend create_sd_ratios;

%create_sd_ratios(&extractfactors)


/* --------------------------------------------------------------------------
   9.4. Boxplots
   -------------------------------------------------------------------------- */

%macro create_boxplots(howmany);
%do i=1 %to &howmany;

ods listing gpath="&whereisit/&myfolder/";
ods graphics / imagename="boxplot_f&i" imagefmt=png;

title "Box plot for f&i by prompt";

proc GLM data=&project._no_outliers;
    class prompt;
    model f&i = prompt;
    means prompt / hovtest=bf welch tukey cldiff;
run;
quit;

title;

%end;
%mend create_boxplots;

%create_boxplots(&extractfactors)
```


Then leave the existing ZIP section exactly after this block:

```
/* ==========================================================================
   ZIP OUTPUT FILES
   ========================================================================== */
```


One small caveat: if SAS Studio reports that one of the ODS table names is unavailable — most likely `CLDiffs`, depending on SAS version/output settings — turn `ods trace on;` temporarily inside the GLM block for one factor and adjust the ODS table name to the one shown in the log. The Brown–Forsythe and Welch additions themselves are in the right place.

## Me
Look! I got the following error messages:

- [brown-forsythe_and_tukey_tests_for_ai_study_error_1.txt](https://github.com/laelgelc/cl_st1_sara/blob/main/cl_st1_ph2_sara/docs/brown-forsythe_and_tukey_tests_for_ai_study_error_1.txt)

## AI Assistant
Yes — I see the problem. The important part is this:

```plain text
WARNING: Output 'Means' was not created.
...
ERROR: File WORK.MEANS_PROMPT_F1.DATA does not exist.
ERROR: Export unsuccessful.
```


The Brown–Forsythe, Welch, ANOVA, R-square, and Tukey outputs **are being created correctly**. The only failing part is the attempted export of `means_prompt_f&i`, because `PROC GLM` is not creating an ODS object called `Means` under this `MEANS prompt / hovtest=bf welch tukey cldiff;` configuration.

Since we already added a separate descriptive-statistics block with `PROC MEANS`, the cleanest fix is to **remove the `Means = means_prompt_f&i` ODS capture and remove the `means_prompt_f&i` export** from the GLM macro.

In other words, keep the descriptive statistics from `desc_prompt_f&i..csv`, and do not ask `PROC GLM` to export a non-existent `Means` table.

Replace only subsection **9.2** with this corrected version:

```
/* --------------------------------------------------------------------------
   9.2. ANOVAs, Brown-Forsythe, Welch, and Tukey tests
   -------------------------------------------------------------------------- */

ODS EXCLUDE NONE;
ods html file="&whereisit/&myfolder/glm_meta.html";

%macro create_glm_tests(howmany);
%do i=1 %to &howmany;

OPTIONS VALIDVARNAME=ANY;
ods graphics off;

title "GLM, Brown-Forsythe, Welch, and Tukey tests for f&i";

proc GLM data=&project._no_outliers;
    class prompt;
    model f&i = prompt;

    ods output
        FitStatistics = r2_prompt_f&i
        OverallANOVA  = anova_prompt_f&i
        HOVFTest      = brown_forsythe_prompt_f&i
        Welch         = welch_prompt_f&i
        CLDiffs       = tukey_cldiff_prompt_f&i;

    means prompt / hovtest=bf welch tukey cldiff;
run;
quit;

PROC EXPORT
  DATA=WORK.r2_prompt_f&i
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/r2_prompt_f&i..csv"
  REPLACE;
RUN;

PROC EXPORT
  DATA=WORK.anova_prompt_f&i
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/anova_prompt_f&i..csv"
  REPLACE;
RUN;

PROC EXPORT
  DATA=WORK.brown_forsythe_prompt_f&i
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/brown_forsythe_prompt_f&i..csv"
  REPLACE;
RUN;

PROC EXPORT
  DATA=WORK.welch_prompt_f&i
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/welch_prompt_f&i..csv"
  REPLACE;
RUN;

PROC EXPORT
  DATA=WORK.tukey_cldiff_prompt_f&i
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/tukey_cldiff_prompt_f&i..csv"
  REPLACE;
RUN;

ods graphics on;

%end;
%mend create_glm_tests;

%create_glm_tests(&extractfactors)

ods html close;
title;
```


Also, remove or ignore any `means_prompt_f&i` export block like this:

```
PROC EXPORT
  DATA=WORK.means_prompt_f&i
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/means_prompt_f&i..csv"
  REPLACE;
RUN;
```


You do **not** need it anymore, because the group means and standard deviations are already exported by subsection **9.1** as:

```plain text
desc_prompt_f1.csv
desc_prompt_f2.csv
desc_prompt_f3.csv
desc_prompt_f4.csv
```


So the corrected interpretation is:

- `desc_prompt_f*.csv` → group N, mean, SD, variance, quartiles, min/max;
- `anova_prompt_f*.csv` → classical ANOVA;
- `brown_forsythe_prompt_f*.csv` → Brown–Forsythe variance test;
- `welch_prompt_f*.csv` → Welch robust mean test;
- `tukey_cldiff_prompt_f*.csv` → Tukey pairwise mean comparisons;
- `sd_ratios_prompt_f*.csv` → descriptive SD ratios.

The warning/error is therefore not about Brown–Forsythe or Tukey failing. Those worked. It is just the unnecessary `Means` ODS object.
