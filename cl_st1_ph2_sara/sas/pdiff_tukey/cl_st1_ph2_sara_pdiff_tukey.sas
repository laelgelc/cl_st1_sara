/* ==========================================================================
   Standalone Tukey-adjusted pairwise comparisons for factor scores

   Imports cl_st1_ph2_sara_scores_only.csv and runs the per-factor GLM
   comparisons from cl_st1_ph2_sara_v2.sas. All rows are retained; no
   outlier filtering is performed.

   Before running in SAS OnDemand for Academics, update DATA_DIR below to the
   server folder where the CSV is uploaded. OUTPUT_DIR may point to a separate
   existing folder for the result files.
   ========================================================================== */

options validvarname=any;

/* Update this to the uploaded CSV's folder in SAS OnDemand. */
%let data_dir=/home/u63529080/cl_st1_ph2_sara_pdiff_tukey;
%let input_csv=&data_dir./cl_st1_ph2_sara_scores_only.csv;

/* The output folder must already exist and be writable. */
%let output_dir=&data_dir.;

filename scorecsv "&input_csv";

%macro validate_input;
    %if %sysfunc(fexist(scorecsv)) = 0 %then %do;
        %put ERROR: Input CSV was not found: &input_csv;
        %put ERROR: Update DATA_DIR and upload cl_st1_ph2_sara_scores_only.csv before running.;
        %abort cancel;
    %end;
%mend validate_input;

%validate_input;

/* Read known fields with explicit lengths and informats. */
data work.scores;
    length prompt $32 source $32 filename $256;
    infile scorecsv dsd dlm=',' firstobs=2 truncover lrecl=32767;
    input prompt :$32.
          source :$32.
          filename :$256.
          f1 :best32.
          f2 :best32.
          f3 :best32.
          f4 :best32.;
run;

filename scorecsv clear;

ods graphics off;
ods html file="&output_dir./glm_meta.html" style=HTMLBlue;

/* Review group sizes and missing factor scores before interpreting tests. */
title "Input validation: observations by prompt";
proc freq data=work.scores;
    tables prompt / missing;
run;

title "Input validation: nonmissing and missing scores by prompt";
proc means data=work.scores n nmiss;
    class prompt;
    var f1-f4;
run;

/* Keep the same GLM, MEANS, and LSMEANS requests as the v2 pipeline. */
%macro run_tukey_pdiff;
    %do i=1 %to 4;
        /* Remove any prior WORK results so a rerun cannot export stale data. */
        proc datasets library=work nolist;
            delete r2_prompt_f&i
                   anova_prompt_f&i
                   brown_forsythe_prompt_f&i
                   welch_prompt_f&i
                   tukey_cldiff_prompt_f&i
                   tukey_diff_prompt_f&i
                   lsmeans_prompt_f&i;
        quit;

        title "GLM, Brown-Forsythe, Welch, and Tukey-adjusted comparisons for f&i";
        proc glm data=work.scores;
            class prompt;
            model f&i = prompt;

            ods output
                FitStatistics = r2_prompt_f&i
                OverallANOVA  = anova_prompt_f&i
                HOVFTest      = brown_forsythe_prompt_f&i
                Welch         = welch_prompt_f&i
                CLDiffs       = tukey_cldiff_prompt_f&i
                Diff          = tukey_diff_prompt_f&i
                LSMeans       = lsmeans_prompt_f&i;

            means prompt / hovtest=bf welch tukey cldiff;
            lsmeans prompt / pdiff=all adjust=tukey cl;
        run;
        quit;

        proc export data=work.r2_prompt_f&i
            dbms=csv outfile="&output_dir./r2_prompt_f&i..csv" replace;
        run;

        proc export data=work.anova_prompt_f&i
            dbms=csv outfile="&output_dir./anova_prompt_f&i..csv" replace;
        run;

        proc export data=work.brown_forsythe_prompt_f&i
            dbms=csv outfile="&output_dir./brown_forsythe_prompt_f&i..csv" replace;
        run;

        proc export data=work.welch_prompt_f&i
            dbms=csv outfile="&output_dir./welch_prompt_f&i..csv" replace;
        run;

        proc export data=work.tukey_cldiff_prompt_f&i
            dbms=csv outfile="&output_dir./tukey_cldiff_prompt_f&i..csv" replace;
        run;

        proc export data=work.tukey_diff_prompt_f&i
            dbms=csv outfile="&output_dir./tukey_diff_prompt_f&i..csv" replace;
        run;

        proc export data=work.lsmeans_prompt_f&i
            dbms=csv outfile="&output_dir./lsmeans_prompt_f&i..csv" replace;
        run;
    %end;
%mend run_tukey_pdiff;

%run_tukey_pdiff;

ods html close;
ods graphics on;
title;

/*
   Outputs: glm_meta.html and seven CSV tables per factor (f1-f4).
   tukey_diff_prompt_f*.csv contains the Tukey-adjusted pairwise p-values;
   use lsmeans_prompt_f*.csv to map Diff matrix indices to prompt groups.
   The comparisons use the pooled model error variance, and Tukey adjustment
   is applied within each factor, not across the four factors.

   All observations from the scores CSV are included. The CSV stores rounded
   factor scores, so numerical results may differ slightly from calculations
   on the original in-memory data. The Diff table expects more than two
   LS-means; verify its layout and group mapping if a prompt level is absent.
*/