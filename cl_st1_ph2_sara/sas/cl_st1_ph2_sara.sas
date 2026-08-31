/* ==========================================================================
   Traditional Multi-Dimensional Analysis
   with Additive Multi-Dimensional Analysis
   ========================================================================== */

/* ==========================================================================
   SECTION 1: ENVIRONMENT SETUP AND MACROS
   ========================================================================== */

%let project = cl_st1_ph2_sara ;
%let myfolder = &project ;
%let sasusername = u63529080 ;
%let whereisit = /home/&sasusername ;  /* Online */

libname gelc "&whereisit/&myfolder";

/* Files will NOT be saved to the folder above unless you put in 'gelc.' before every destination */
/* Otherwise files are going to the work library and not saved to the current folder */
/* This is needed to enable SGPLOT. Otherwise, SAS will throw up an error message */

options fmtsearch=(work library);

/* Extraction & Cutoff Parameters */
%let extractfactors = 4 ;
%let factorvars = f1-f&extractfactors ;
%let minloading = .3 ;
%let communalcutoff = .15 ;


/* ==========================================================================
   SECTION 2: DATA INGESTION (HUMAN, AI-FREE, AND AI-GUIDED)
   ========================================================================== */

/* 1A: Ingest Human-Authored Subcorpus */
DATA corp_human ;
    length prompt $10 source $10;
    INFILE "&whereisit/&myfolder/01_human_counts.txt" TRUNCOVER;
    input filename $ 14-60 ttr 61-65 wrlengh 66-70 wcount 71-75
    #2 prv_vb 1-5 that_del 6-10 contrac 11-15 pres 16-20 pro2 21-25 pro_do 26-30 pdem 31-35 gen_emph 36-40 pro1 41-45 it 46-50 be_state 51-55 sub_cos 56-60 prtcle 61-65 pany 66-70 gen_hdg 71-75
    #3 amplifr 1-5 wh_ques 6-10 pos_mod 11-15 o_and 16-20 wh_cl 21-25 finlprep 26-30 n 31-35 prep 36-40 adj_attr 41-45 pasttnse 46-50 pro3 51-55 perfects 56-60 pub_vb 61-65 rel_obj 66-70 rel_subj 71-75
    #4 rel_pipe 1-5 p_and 6-10 n_nom 11-15 tm_adv 16-20 pl_adv 21-25 advs 26-30 inf 31-35 prd_mod 36-40 sua_vb 41-45 sub_cnd 46-50 nec_mod 51-55 spl_aux 56-60 conjncts 61-65 agls_psv 66-70 by_pasv 71-75
    #5 whiz_vbn 1-5 sub_othr 6-10 vcmp 11-15 downtone 16-20 pred_adj 21-25 allmodal 26-30 allconj 31-35 allpasv 36-40 allwh 41-45 allwhrel 46-50 alladj 51-55 allpro 56-60 have 61-65 allverb 66-70 vprogrsv 71-75
    #6 that_rel 1-5 jcmp 6-10
    #7 nonf_vth 16-20 att_vth 21-25 fact_vth 26-30 lkly_vth 31-35 att_jth 36-40 fact_jth 41-45 lkly_jth 46-50 nfct_nth 51-55 att_nth 56-60 fct_nth 61-65 lkly_nth 66-70 spch_vto 71-75
    #8 mntl_vto 1-5 dsre_vto 6-10 efrt_vto 11-15 prob_vto 16-20 x1_jto 21-25 x2_jto 26-30 x3_jto 31-35 x4_jto 36-40 x5_jto 41-45 all_nto 46-50 nonfadvl 51-55 atadvl 56-60 fctadvl 61-65 lklydvl 66-70
    #9 all_vth 1-5 all_jth 6-10 all_nth 11-15 all_th 16-20 all_vto 21-25 all_jto 26-30 all_to 31-35 all_advl 36-40
    #10 act_ipv 1-5 act_tpv 6-10 mentalpv 11-15 commpv 16-20 occurpv 21-25 copulapv 26-30 aspectpv 31-35 humann 36-40 prcessn 41-45 cognitn 46-50 abstrcn 51-55 concrtn 56-60 tccncrt 61-65 quann 66-70 placen 71-75
    #11 groupn 1-5 sizej 6-10 timej 11-15 colorj 16-20 evalj 21-25 relatnj 26-30 topicj 31-35 actv 36-40 commv 41-45 mentalv 46-50 causev 51-55 occurv 56-60 existv 61-65 aspectv 66-70
    #12 dim1 1-10 dim2 11-20 dim3 21-30 dim4 31-40 dim5 41-50 ;

    prompt = 'human' ;
    source = 'human' ;
RUN;

/* 1B: Ingest LLM-Free Subcorpus */
DATA corp_llm_free ;
    length prompt $10 source $10;
    INFILE "&whereisit/&myfolder/04_llm_free_counts.txt" TRUNCOVER;
    input filename $ 14-60 ttr 61-65 wrlengh 66-70 wcount 71-75
    #2 prv_vb 1-5 that_del 6-10 contrac 11-15 pres 16-20 pro2 21-25 pro_do 26-30 pdem 31-35 gen_emph 36-40 pro1 41-45 it 46-50 be_state 51-55 sub_cos 56-60 prtcle 61-65 pany 66-70 gen_hdg 71-75
    #3 amplifr 1-5 wh_ques 6-10 pos_mod 11-15 o_and 16-20 wh_cl 21-25 finlprep 26-30 n 31-35 prep 36-40 adj_attr 41-45 pasttnse 46-50 pro3 51-55 perfects 56-60 pub_vb 61-65 rel_obj 66-70 rel_subj 71-75
    #4 rel_pipe 1-5 p_and 6-10 n_nom 11-15 tm_adv 16-20 pl_adv 21-25 advs 26-30 inf 31-35 prd_mod 36-40 sua_vb 41-45 sub_cnd 46-50 nec_mod 51-55 spl_aux 56-60 conjncts 61-65 agls_psv 66-70 by_pasv 71-75
    #5 whiz_vbn 1-5 sub_othr 6-10 vcmp 11-15 downtone 16-20 pred_adj 21-25 allmodal 26-30 allconj 31-35 allpasv 36-40 allwh 41-45 allwhrel 46-50 alladj 51-55 allpro 56-60 have 61-65 allverb 66-70 vprogrsv 71-75
    #6 that_rel 1-5 jcmp 6-10
    #7 nonf_vth 16-20 att_vth 21-25 fact_vth 26-30 lkly_vth 31-35 att_jth 36-40 fact_jth 41-45 lkly_jth 46-50 nfct_nth 51-55 att_nth 56-60 fct_nth 61-65 lkly_nth 66-70 spch_vto 71-75
    #8 mntl_vto 1-5 dsre_vto 6-10 efrt_vto 11-15 prob_vto 16-20 x1_jto 21-25 x2_jto 26-30 x3_jto 31-35 x4_jto 36-40 x5_jto 41-45 all_nto 46-50 nonfadvl 51-55 atadvl 56-60 fctadvl 61-65 lklydvl 66-70
    #9 all_vth 1-5 all_jth 6-10 all_nth 11-15 all_th 16-20 all_vto 21-25 all_jto 26-30 all_to 31-35 all_advl 36-40
    #10 act_ipv 1-5 act_tpv 6-10 mentalpv 11-15 commpv 16-20 occurpv 21-25 copulapv 26-30 aspectpv 31-35 humann 36-40 prcessn 41-45 cognitn 46-50 abstrcn 51-55 concrtn 56-60 tccncrt 61-65 quann 66-70 placen 71-75
    #11 groupn 1-5 sizej 6-10 timej 11-15 colorj 16-20 evalj 21-25 relatnj 26-30 topicj 31-35 actv 36-40 commv 41-45 mentalv 46-50 causev 51-55 occurv 56-60 existv 61-65 aspectv 66-70
    #12 dim1 1-10 dim2 11-20 dim3 21-30 dim4 31-40 dim5 41-50 ;

    prompt = 'llm_free' ;
    source = 'ai' ;
RUN;

/* 1C: Ingest LLM-Guided Subcorpus (For Additive Analysis) */
DATA add_corpus ;
    length prompt $10 source $10;
    INFILE "&whereisit/&myfolder/03_llm_counts.txt" TRUNCOVER;
    input filename $ 14-60 ttr 61-65 wrlengh 66-70 wcount 71-75
    #2 prv_vb 1-5 that_del 6-10 contrac 11-15 pres 16-20 pro2 21-25 pro_do 26-30 pdem 31-35 gen_emph 36-40 pro1 41-45 it 46-50 be_state 51-55 sub_cos 56-60 prtcle 61-65 pany 66-70 gen_hdg 71-75
    #3 amplifr 1-5 wh_ques 6-10 pos_mod 11-15 o_and 16-20 wh_cl 21-25 finlprep 26-30 n 31-35 prep 36-40 adj_attr 41-45 pasttnse 46-50 pro3 51-55 perfects 56-60 pub_vb 61-65 rel_obj 66-70 rel_subj 71-75
    #4 rel_pipe 1-5 p_and 6-10 n_nom 11-15 tm_adv 16-20 pl_adv 21-25 advs 26-30 inf 31-35 prd_mod 36-40 sua_vb 41-45 sub_cnd 46-50 nec_mod 51-55 spl_aux 56-60 conjncts 61-65 agls_psv 66-70 by_pasv 71-75
    #5 whiz_vbn 1-5 sub_othr 6-10 vcmp 11-15 downtone 16-20 pred_adj 21-25 allmodal 26-30 allconj 31-35 allpasv 36-40 allwh 41-45 allwhrel 46-50 alladj 51-55 allpro 56-60 have 61-65 allverb 66-70 vprogrsv 71-75
    #6 that_rel 1-5 jcmp 6-10
    #7 nonf_vth 16-20 att_vth 21-25 fact_vth 26-30 lkly_vth 31-35 att_jth 36-40 fact_jth 41-45 lkly_jth 46-50 nfct_nth 51-55 att_nth 56-60 fct_nth 61-65 lkly_nth 66-70 spch_vto 71-75
    #8 mntl_vto 1-5 dsre_vto 6-10 efrt_vto 11-15 prob_vto 16-20 x1_jto 21-25 x2_jto 26-30 x3_jto 31-35 x4_jto 36-40 x5_jto 41-45 all_nto 46-50 nonfadvl 51-55 atadvl 56-60 fctadvl 61-65 lklydvl 66-70
    #9 all_vth 1-5 all_jth 6-10 all_nth 11-15 all_th 16-20 all_vto 21-25 all_jto 26-30 all_to 31-35 all_advl 36-40
    #10 act_ipv 1-5 act_tpv 6-10 mentalpv 11-15 commpv 16-20 occurpv 21-25 copulapv 26-30 aspectpv 31-35 humann 36-40 prcessn 41-45 cognitn 46-50 abstrcn 51-55 concrtn 56-60 tccncrt 61-65 quann 66-70 placen 71-75
    #11 groupn 1-5 sizej 6-10 timej 11-15 colorj 16-20 evalj 21-25 relatnj 26-30 topicj 31-35 actv 36-40 commv 41-45 mentalv 46-50 causev 51-55 occurv 56-60 existv 61-65 aspectv 66-70
    #12 dim1 1-10 dim2 11-20 dim3 21-30 dim4 31-40 dim5 41-50 ;

    prompt = 'llm' ;
    source = 'ai' ;
RUN;


/* ==========================================================================
   SECTION 3: BASE CORPUS PREPARATION & INITIAL EXPORTS
   ========================================================================== */

/* Combine Base Corpora for Factor Extraction */
DATA base_corpus;
    SET corp_human corp_llm_free;
RUN;

/* Exclude 1988 Dimensions from the base factoring */
DATA &project (drop= dim1-dim5 pub_vb prv_vb);
  SET base_corpus;
RUN;

DATA &project._add_corpus (drop= dim1-dim5 pub_vb prv_vb);
  SET add_corpus;
RUN;

ODS EXCLUDE NONE;
    proc print data = &project (FIRSTOBS=200 OBS=500);
    var filename;
run;

PROC EXPORT
  DATA= WORK.&project
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/&project..csv"
  REPLACE;
RUN;

ODS EXCLUDE NONE;
    proc print data = &project._add_corpus (FIRSTOBS=200 OBS=500);
    var filename;
run;

PROC EXPORT
  DATA= WORK.&project._add_corpus
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/&project._add_corpus.csv"
  REPLACE;
RUN;

/* Drop summary variables  */
DATA &project._no_sum_v (DROP = all_advl all_jth all_jto all_nth all_th all_to all_vth all_vto alladj allconj allmodal allpasv allpro allverb allwh allwhrel n );
  SET &project ;
RUN;


/* ==========================================================================
   SECTION 4: UNROTATED FACTOR ANALYSIS & COMMUNALITY CUTOFF
   ========================================================================== */

/* Unrotated Factor Analysis without summary vars, before dropping low communalities */
OPTIONS VALIDVARNAME=ANY;

ODS EXCLUDE NONE;
ods html file="&whereisit/&myfolder/unrotated.html";
ods trace on;

proc factor
OUTSTAT=fout
data=&project._no_sum_v  /* Summary variables dropped */
method=principal scree
mineigen=0
nfactors=100
priors=smc
heywood;
var
_NUMERIC_ ;
run;
quit;

ods trace off;
ods html close;
ODS EXCLUDE ALL;

/*** Find low communalities ***/
/* https://communities.sas.com/t5/SAS-Programming/How-do-I-delete-variables-based-on-their-values-in-an-outstat/m-p/675576#M203571 */

data fout2;
    set fout (where=(_TYPE_="COMMUNAL"));
run;

proc transpose data=fout2 out=communal; id _TYPE_; run;

proc sql;
    select _name_ into :names separated by ' ' from communal
        where communal < &communalcutoff ;
quit;

data &project._no_low_c ;
    set &project._no_sum_v ;
    drop &names;
run;

/* Save dropped variables to excel */
PROC SORT Data=communal;   BY _NAME_; RUN;

data communal_dropped ;
set communal ;
if COMMUNAL < &communalcutoff ;
RUN;

ODS EXCLUDE NONE;
PROC EXPORT
  DATA= WORK.communal_dropped
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/communalities_dropped.csv"
  REPLACE;
RUN;
ODS EXCLUDE ALL;

/* Scree plot */
data fout2;
  set fout (where=(_TYPE_="EIGENVAL"));
run;

proc transpose data=fout2 out= fout3 (drop = _NAME_);
id _TYPE_;
run;

data fout4 ;
set fout3 ;
factor = _n_;
if factor <= 20 ;
run;

ODS EXCLUDE NONE;
ods listing gpath="&whereisit/&myfolder/";
ods graphics / imagename="scree" imagefmt=png;
title "Scree plot";
proc sgplot data= fout4 ;
  series x=factor y=EIGENVAL /  datalabel=factor;
run;
title;
ODS EXCLUDE ALL;


/* ==========================================================================
   SECTION 5: INITIAL ROTATED FACTOR ANALYSIS & VAR SELECTION
   ========================================================================== */

/* Rotated Factor Analysis without summary variables prior to summary variables check */

ODS EXCLUDE ALL;
OPTIONS VALIDVARNAME=ANY;

proc factor
OUTSTAT = rotated
data=&project._no_low_c
method=principal
scree
msa
mineigen=0
priors=smc
nfactors= &extractfactors
rotate=promax
heywood;
var
_NUMERIC_ ;
run;
quit;
ods html close;

/* Checking summary variables */
OPTIONS VALIDVARNAME=ANY;
data prerotat;
  set rotated (where=(_TYPE_="PREROTAT"));
run;

proc transpose data=prerotat out= rotated2 ;
id _NAME_ ;
run;

OPTIONS VALIDVARNAME=ANY;
data rotated3;
   set rotated2;
      loaded = 0 ;
        if     abs(factor1) > abs(factor2)
           AND abs(factor1) > abs(factor3)
           AND abs(factor1) > abs(factor4)
           AND abs(factor1) > abs(factor5)
           AND abs(factor1) > abs(factor6)
           AND abs(factor1) > abs(factor7)
           AND abs(factor1) > abs(factor8)
           AND abs(factor1) > abs(factor9)
           AND factor1 > 0 AND abs(factor1) >= "&minloading" then do; factor = 'f1'; pole = 1;  loaded = 1; end ;

   else if     abs(factor2) > abs(factor1)
           AND abs(factor2) > abs(factor3)
           AND abs(factor2) > abs(factor4)
           AND abs(factor2) > abs(factor5)
           AND abs(factor2) > abs(factor6)
           AND abs(factor2) > abs(factor7)
           AND abs(factor2) > abs(factor8)
           AND abs(factor2) > abs(factor9)
           AND factor2 > 0 AND abs(factor2) >= "&minloading" then do; factor = 'f2'; pole = 1;  loaded = 1; end ;

   else if     abs(factor3) > abs(factor1)
           AND abs(factor3) > abs(factor2)
           AND abs(factor3) > abs(factor4)
           AND abs(factor3) > abs(factor5)
           AND abs(factor3) > abs(factor6)
           AND abs(factor3) > abs(factor7)
           AND abs(factor3) > abs(factor8)
           AND abs(factor3) > abs(factor9)
           AND factor3 > 0 AND abs(factor3) >= "&minloading" then do; factor = 'f3'; pole = 1;  loaded = 1; end ;

   else if     abs(factor4) > abs(factor1)
           AND abs(factor4) > abs(factor2)
           AND abs(factor4) > abs(factor3)
           AND abs(factor4) > abs(factor5)
           AND abs(factor4) > abs(factor6)
           AND abs(factor4) > abs(factor7)
           AND abs(factor4) > abs(factor8)
           AND abs(factor4) > abs(factor9)
           AND factor4 > 0 AND abs(factor4) >= "&minloading" then do; factor = 'f4'; pole = 1;  loaded = 1; end ;

   else if     abs(factor5) > abs(factor1)
           AND abs(factor5) > abs(factor2)
           AND abs(factor5) > abs(factor3)
           AND abs(factor5) > abs(factor4)
           AND abs(factor5) > abs(factor6)
           AND abs(factor5) > abs(factor7)
           AND abs(factor5) > abs(factor8)
           AND abs(factor5) > abs(factor9)
           AND factor5 > 0 AND abs(factor5) >= "&minloading" then do; factor = 'f5'; pole = 1;  loaded = 1; end ;

   else if     abs(factor6) > abs(factor1)
           AND abs(factor6) > abs(factor2)
           AND abs(factor6) > abs(factor3)
           AND abs(factor6) > abs(factor4)
           AND abs(factor6) > abs(factor5)
           AND abs(factor6) > abs(factor7)
           AND abs(factor6) > abs(factor8)
           AND abs(factor6) > abs(factor9)
           AND factor6 > 0 AND abs(factor6) >= "&minloading" then do; factor = 'f6'; pole = 1;  loaded = 1; end ;

   else if     abs(factor7) > abs(factor1)
           AND abs(factor7) > abs(factor2)
           AND abs(factor7) > abs(factor3)
           AND abs(factor7) > abs(factor4)
           AND abs(factor7) > abs(factor5)
           AND abs(factor7) > abs(factor6)
           AND abs(factor7) > abs(factor8)
           AND abs(factor7) > abs(factor9)
           AND factor7 > 0 AND abs(factor7) >= "&minloading" then do; factor = 'f7'; pole = 1;  loaded = 1; end ;

   else if     abs(factor8) > abs(factor1)
           AND abs(factor8) > abs(factor2)
           AND abs(factor8) > abs(factor3)
           AND abs(factor8) > abs(factor4)
           AND abs(factor8) > abs(factor5)
           AND abs(factor8) > abs(factor6)
           AND abs(factor8) > abs(factor7)
           AND abs(factor8) > abs(factor9)
           AND factor8 > 0 AND abs(factor8) >= "&minloading" then do; factor = 'f8'; pole = 1;  loaded = 1; end ;

   else if     abs(factor9) > abs(factor1)
           AND abs(factor9) > abs(factor2)
           AND abs(factor9) > abs(factor3)
           AND abs(factor9) > abs(factor4)
           AND abs(factor9) > abs(factor5)
           AND abs(factor9) > abs(factor6)
           AND abs(factor9) > abs(factor7)
               AND abs(factor9) > abs(factor8)
           AND factor9 > 0 AND abs(factor9) >= "&minloading" then do; factor = 'f9'; pole = 1;  loaded = 1; end ;

/* Negative values */

  else  if     abs(factor1) > abs(factor2)
           AND abs(factor1) > abs(factor3)
           AND abs(factor1) > abs(factor4)
           AND abs(factor1) > abs(factor5)
           AND abs(factor1) > abs(factor6)
           AND abs(factor1) > abs(factor7)
           AND abs(factor1) > abs(factor8)
           AND abs(factor1) > abs(factor9)
           AND factor1 < 0 AND abs(factor1) >= "&minloading" then do; factor = 'f1'; pole = -1;  loaded = 1; end ;

   else if     abs(factor2) > abs(factor1)
           AND abs(factor2) > abs(factor3)
           AND abs(factor2) > abs(factor4)
           AND abs(factor2) > abs(factor5)
           AND abs(factor2) > abs(factor6)
           AND abs(factor2) > abs(factor7)
           AND abs(factor2) > abs(factor8)
           AND abs(factor2) > abs(factor9)
           AND factor2 < 0 AND abs(factor2) >= "&minloading" then do; factor = 'f2'; pole = -1;  loaded = 1; end ;

   else if     abs(factor3) > abs(factor1)
           AND abs(factor3) > abs(factor2)
           AND abs(factor3) > abs(factor4)
           AND abs(factor3) > abs(factor5)
           AND abs(factor3) > abs(factor6)
           AND abs(factor3) > abs(factor7)
           AND abs(factor3) > abs(factor8)
           AND abs(factor3) > abs(factor9)
           AND factor3 < 0 AND abs(factor3) >= "&minloading" then do; factor = 'f3'; pole = -1;  loaded = 1; end ;

   else if     abs(factor4) > abs(factor1)
           AND abs(factor4) > abs(factor2)
           AND abs(factor4) > abs(factor3)
           AND abs(factor4) > abs(factor5)
           AND abs(factor4) > abs(factor6)
           AND abs(factor4) > abs(factor7)
           AND abs(factor4) > abs(factor8)
           AND abs(factor4) > abs(factor9)
           AND factor4 < 0 AND abs(factor4) >= "&minloading" then do; factor = 'f4'; pole = -1;  loaded = 1; end ;

   else if     abs(factor5) > abs(factor1)
           AND abs(factor5) > abs(factor2)
           AND abs(factor5) > abs(factor3)
           AND abs(factor5) > abs(factor4)
           AND abs(factor5) > abs(factor6)
           AND abs(factor5) > abs(factor7)
           AND abs(factor5) > abs(factor8)
           AND abs(factor5) > abs(factor9)
           AND factor5 < 0 AND abs(factor5) >= "&minloading" then do; factor = 'f5'; pole = -1;  loaded = 1; end ;

   else if     abs(factor6) > abs(factor1)
           AND abs(factor6) > abs(factor2)
           AND abs(factor6) > abs(factor3)
           AND abs(factor6) > abs(factor4)
           AND abs(factor6) > abs(factor5)
           AND abs(factor6) > abs(factor7)
           AND abs(factor6) > abs(factor8)
           AND abs(factor6) > abs(factor9)
           AND factor6 < 0 AND abs(factor6) >= "&minloading" then do; factor = 'f6'; pole = -1;  loaded = 1; end ;

   else if     abs(factor7) > abs(factor1)
           AND abs(factor7) > abs(factor2)
           AND abs(factor7) > abs(factor3)
           AND abs(factor7) > abs(factor4)
           AND abs(factor7) > abs(factor5)
           AND abs(factor7) > abs(factor6)
           AND abs(factor7) > abs(factor8)
           AND abs(factor7) > abs(factor9)
           AND factor7 < 0 AND abs(factor7) >= "&minloading" then do; factor = 'f7'; pole = -1;  loaded = 1; end ;

   else if     abs(factor8) > abs(factor1)
           AND abs(factor8) > abs(factor2)
           AND abs(factor8) > abs(factor3)
           AND abs(factor8) > abs(factor4)
           AND abs(factor8) > abs(factor5)
           AND abs(factor8) > abs(factor6)
           AND abs(factor8) > abs(factor7)
           AND abs(factor8) > abs(factor9)
           AND factor8 < 0 AND abs(factor8) >= "&minloading" then do; factor = 'f8'; pole = -1;  loaded = 1; end ;

   else if     abs(factor9) > abs(factor1)
           AND abs(factor9) > abs(factor2)
           AND abs(factor9) > abs(factor3)
           AND abs(factor9) > abs(factor4)
           AND abs(factor9) > abs(factor5)
           AND abs(factor9) > abs(factor6)
           AND abs(factor9) > abs(factor7)
           AND abs(factor9) > abs(factor8)
           AND factor9 < 0 AND abs(factor9) >= "&minloading" then do; factor = 'f9'; pole = -1;  loaded = 1; end ;
run;

data rotated4 ; set rotated3 (KEEP = _NAME_ loaded ); run;
proc transpose data=rotated4 out= rotated5 ; id _NAME_ ; run;

/* Set a value = 0 to low comm vars dropped before to ensure sums are computed */
proc sql;
    select _name_ into :lowcomm separated by ' ' from communal
        where communal < &communalcutoff ;
quit;

data sumdrop;
   set rotated5;
    array v &lowcomm ;
    do over v ;
      v = 0;
    end ;

    array w allmodal allconj allpasv allwh allwhrel allpro all_vth all_jth all_nth all_vto all_jto all_advl alladj allverb n all_th all_to  ;
    do over w ;
      w = 0;
    end ;

   allmodal = pos_mod + prd_mod + nec_mod ;
   allconj = o_and + p_and + sub_cnd + sub_cos  ;
   allpasv = agls_psv + by_pasv + whiz_vbn  ;
   allwh = wh_ques + wh_cl ;
   allwhrel = rel_obj + rel_subj + rel_pipe  ;
   allpro = pro1 + pro2 + pro3;
   all_vth = nonf_vth + att_vth + fact_vth + lkly_vth ;
   all_jth = att_jth + fact_jth + lkly_jth ;
   all_nth = att_nth + fct_nth + lkly_nth + nfct_nth ;
   all_th = all_vth + all_nth + all_jth ;
   all_vto = dsre_vto + efrt_vto + mntl_vto + prob_vto + spch_vto  ;
   all_jto = x1_jto + x2_jto + x3_jto + x4_jto + x5_jto ;
   all_to = all_vto + all_jto + all_nto ;
   all_advl = nonfadvl + atadvl + fctadvl + lklydvl ;
   alladj =  colorj + evalj + relatnj + sizej + timej + topicj  ;
   allverb = act_ipv + act_tpv + actv + aspectv + be_state + causev + commpv + commv + copulapv + existv + have + inf + mentalpv + mentalv + occurpv + occurv + pasttnse + perfects + pres + pro_do + prv_vb + pub_vb + sua_vb + vprogrsv  ;
   n = humann + cognitn + concrtn + groupn + abstrcn + placen + prcessn + quann + tccncrt  ;
run;

data sumdrop2;
   set sumdrop;
        if allmodal <  2 then do;  pos_mod = 0 ;  prd_mod = 0 ;  nec_mod = 0 ;  allmodal = 1; end;
   else if allmodal >= 2 then do; allmodal = 0 ; end;

        if allconj <  2 then do;  o_and = 0 ;  p_and = 0 ;  sub_cnd = 0 ;  sub_cos = 0 ;  sub_othr = 0 ;  allconj = 1; end;
   else if allconj >= 2 then do; allconj = 0 ; end;

        if allpasv <  2 then do;  agls_psv = 0 ;  by_pasv = 0 ;  whiz_vbn = 0 ;  allpasv = 1; end;
   else if allpasv >= 2 then do; allpasv = 0 ; end;

        if allwh <  1 then do;  wh_ques = 0 ;  wh_cl = 0 ;  allwh = 1; end;
   else if allwh >= 1 then do; allwh = 0 ; end;

        if allwhrel <  2 then do;  rel_obj = 0 ;  rel_subj = 0 ;  rel_pipe = 0 ;  allwhrel = 1; end;
   else if allwhrel >= 2 then do; allwhrel = 0 ; end;

        if allpro <  2 then do;  pro1 = 0 ;  pro2 = 0 ;  pro3 = 0 ;  allpro = 1; end;
   else if allpro >= 2 then do; allpro = 0 ; end;

        if all_vth <  2 then do;  nonf_vth = 0 ;  att_vth = 0 ;  fact_vth = 0 ;  lkly_vth = 0 ;  all_vth = 1; end;
   else if all_vth >= 2 then do; all_vth = 0 ; end;

        if all_jth <  2 then do;  att_jth = 0 ;  fact_jth = 0 ;  lkly_jth = 0 ;  all_jth = 1; end;
   else if all_jth >= 2 then do; all_jth = 0 ; end;

        if all_nth <  2 then do;  att_nth = 0 ;  fct_nth = 0 ;  lkly_nth = 0 ;  nfct_nth = 0 ;  all_nth = 1; end;
   else if all_nth >= 2 then do; all_nth = 0 ; end;

        if all_vto <  2 then do;  dsre_vto = 0 ;  efrt_vto = 0 ;  mntl_vto = 0 ;  prob_vto = 0 ;  spch_vto = 0 ;  all_vto = 1; end;
   else if all_vto >= 2 then do; all_vto = 0 ; end;

        if all_jto <  2 then do;  x1_jto = 0 ;  x2_jto = 0 ;  x3_jto = 0 ;  x4_jto = 0 ;  x5_jto = 0 ;  all_jto = 1; end;
   else if all_jto >= 2 then do; all_jto = 0 ; end;

        if all_advl <  2 then do;  nonfadvl = 0 ;  atadvl = 0 ;  fctadvl = 0 ;  lklydvl = 0 ;  all_advl = 1; end;
   else if all_advl >= 2 then do; all_advl = 0 ; end;

        if alladj <  2 then do;  colorj = 0 ;  evalj = 0 ;  relatnj = 0 ;  sizej = 0 ;  timej = 0 ;  topicj = 0 ;  alladj = 1; end;
   else if alladj >= 2 then do; alladj = 0 ; end;

        if allverb <  4 then do;  act_ipv = 0 ;  act_tpv = 0 ;  actv = 0 ;  aspectv = 0 ;  be_state = 0 ;  causev = 0 ;  commpv = 0 ;  commv = 0 ;  copulapv = 0 ;  existv = 0 ;  have = 0 ;  inf = 0 ;  mentalpv = 0 ;  mentalv = 0 ;  occurpv = 0 ;  occurv = 0 ;  pasttnse = 0 ;  perfects = 0 ;  pres = 0 ;  pro_do = 0 ; sua_vb = 0 ;  vprogrsv = 0 ;  allverb = 1; end;
   else if allverb >= 4 then do; allverb = 0 ; end;

        if n <  2 then do;  humann = 0 ;  cognitn = 0 ;  concrtn = 0 ;  groupn = 0 ;  abstrcn = 0 ;  placen = 0 ;  prcessn = 0 ;  quann = 0 ;  tccncrt = 0 ;  n = 1; end;
   else if n >= 2 then do; n = 0 ; end;

        if all_th <  2 then do;  all_vth = 0 ;  all_nth = 0 ;  all_jth = 0 ;  all_th = 1; end;
   else if all_th >= 2 then do; all_th = 0 ; end;

        if all_to <  2 then do;  all_vto = 0 ;  all_jto = 0 ;  all_nto = 0 ;  all_to = 1; end;
   else if all_to >= 2 then do; all_to = 0 ; end;

run;

proc transpose data=sumdrop2 out= varsdel ; id _NAME_ ; run;

/* Drop variables based on summary variables check */
proc sql;
    select _name_ into :sumcheck separated by ' ' from varsdel
        where loaded = 0;
quit;

data &project._sum_check ;
    set &project ;  /* The initial dataset with the summary variables counts */
     drop &sumcheck ;
run;


/* ==========================================================================
   SECTION 6: FINAL ROTATED FACTOR ANALYSIS & LOADINGS TABLE
   ========================================================================== */

ODS EXCLUDE NONE;
ods html file="&whereisit/&myfolder/rotated.html";
ods trace on;

proc factor
OUTSTAT = rotatedfinal
data=&project._sum_check
method=principal
scree
msa
mineigen=0
priors=smc
nfactors= &extractfactors
rotate=promax
heywood;
var
_NUMERIC_ ;
run;
quit;

ods trace off;
ods html close;
ODS EXCLUDE ALL;

/* Reformat outstat to obtain rotated factor pattern */
OPTIONS VALIDVARNAME=ANY;
data rotated2;
  set rotatedfinal (where=(_TYPE_="PREROTAT"));
run;

proc transpose data=rotated2 out= rotated2 ;
id _NAME_ ;
run;

OPTIONS VALIDVARNAME=ANY;
data rotated3;
   set rotated2;
      loaded = 0 ;
        if     abs(factor1) > abs(factor2)
           AND abs(factor1) > abs(factor3)
           AND abs(factor1) > abs(factor4)
           AND abs(factor1) > abs(factor5)
           AND abs(factor1) > abs(factor6)
           AND abs(factor1) > abs(factor7)
           AND abs(factor1) > abs(factor8)
           AND abs(factor1) > abs(factor9)
           AND factor1 > 0 AND abs(factor1) >= "&minloading" then do; factor = 'f1'; pole = 1;  loaded = 1; end ;

   else if     abs(factor2) > abs(factor1)
           AND abs(factor2) > abs(factor3)
           AND abs(factor2) > abs(factor4)
           AND abs(factor2) > abs(factor5)
           AND abs(factor2) > abs(factor6)
           AND abs(factor2) > abs(factor7)
           AND abs(factor2) > abs(factor8)
           AND abs(factor2) > abs(factor9)
           AND factor2 > 0 AND abs(factor2) >= "&minloading" then do; factor = 'f2'; pole = 1;  loaded = 1; end ;

   else if     abs(factor3) > abs(factor1)
           AND abs(factor3) > abs(factor2)
           AND abs(factor3) > abs(factor4)
           AND abs(factor3) > abs(factor5)
           AND abs(factor3) > abs(factor6)
           AND abs(factor3) > abs(factor7)
           AND abs(factor3) > abs(factor8)
           AND abs(factor3) > abs(factor9)
           AND factor3 > 0 AND abs(factor3) >= "&minloading" then do; factor = 'f3'; pole = 1;  loaded = 1; end ;

   else if     abs(factor4) > abs(factor1)
           AND abs(factor4) > abs(factor2)
           AND abs(factor4) > abs(factor3)
           AND abs(factor4) > abs(factor5)
           AND abs(factor4) > abs(factor6)
           AND abs(factor4) > abs(factor7)
           AND abs(factor4) > abs(factor8)
           AND abs(factor4) > abs(factor9)
           AND factor4 > 0 AND abs(factor4) >= "&minloading" then do; factor = 'f4'; pole = 1;  loaded = 1; end ;

   else if     abs(factor5) > abs(factor1)
           AND abs(factor5) > abs(factor2)
           AND abs(factor5) > abs(factor3)
           AND abs(factor5) > abs(factor4)
           AND abs(factor5) > abs(factor6)
           AND abs(factor5) > abs(factor7)
           AND abs(factor5) > abs(factor8)
           AND abs(factor5) > abs(factor9)
           AND factor5 > 0 AND abs(factor5) >= "&minloading" then do; factor = 'f5'; pole = 1;  loaded = 1; end ;

   else if     abs(factor6) > abs(factor1)
           AND abs(factor6) > abs(factor2)
           AND abs(factor6) > abs(factor3)
           AND abs(factor6) > abs(factor4)
           AND abs(factor6) > abs(factor5)
           AND abs(factor6) > abs(factor7)
           AND abs(factor6) > abs(factor8)
           AND abs(factor6) > abs(factor9)
           AND factor6 > 0 AND abs(factor6) >= "&minloading" then do; factor = 'f6'; pole = 1;  loaded = 1; end ;

   else if     abs(factor7) > abs(factor1)
           AND abs(factor7) > abs(factor2)
           AND abs(factor7) > abs(factor3)
           AND abs(factor7) > abs(factor4)
           AND abs(factor7) > abs(factor5)
           AND abs(factor7) > abs(factor6)
           AND abs(factor7) > abs(factor8)
           AND abs(factor7) > abs(factor9)
           AND factor7 > 0 AND abs(factor7) >= "&minloading" then do; factor = 'f7'; pole = 1;  loaded = 1; end ;

   else if     abs(factor8) > abs(factor1)
           AND abs(factor8) > abs(factor2)
           AND abs(factor8) > abs(factor3)
           AND abs(factor8) > abs(factor4)
           AND abs(factor8) > abs(factor5)
           AND abs(factor8) > abs(factor6)
           AND abs(factor8) > abs(factor7)
           AND abs(factor8) > abs(factor9)
           AND factor8 > 0 AND abs(factor8) >= "&minloading" then do; factor = 'f8'; pole = 1;  loaded = 1; end ;

   else if     abs(factor9) > abs(factor1)
           AND abs(factor9) > abs(factor2)
           AND abs(factor9) > abs(factor3)
           AND abs(factor9) > abs(factor4)
           AND abs(factor9) > abs(factor5)
           AND abs(factor9) > abs(factor6)
           AND abs(factor9) > abs(factor7)
           AND abs(factor9) > abs(factor8)
           AND factor9 > 0 AND abs(factor9) >= "&minloading" then do; factor = 'f9'; pole = 1;  loaded = 1; end ;

/* Negative values */

  else  if     abs(factor1) > abs(factor2)
           AND abs(factor1) > abs(factor3)
           AND abs(factor1) > abs(factor4)
           AND abs(factor1) > abs(factor5)
           AND abs(factor1) > abs(factor6)
           AND abs(factor1) > abs(factor7)
           AND abs(factor1) > abs(factor8)
           AND abs(factor1) > abs(factor9)
           AND factor1 < 0 AND abs(factor1) >= "&minloading" then do; factor = 'f1'; pole = -1;  loaded = 1; end ;

   else if     abs(factor2) > abs(factor1)
           AND abs(factor2) > abs(factor3)
           AND abs(factor2) > abs(factor4)
           AND abs(factor2) > abs(factor5)
           AND abs(factor2) > abs(factor6)
           AND abs(factor2) > abs(factor7)
           AND abs(factor2) > abs(factor8)
           AND abs(factor2) > abs(factor9)
           AND factor2 < 0 AND abs(factor2) >= "&minloading" then do; factor = 'f2'; pole = -1;  loaded = 1; end ;

   else if     abs(factor3) > abs(factor1)
           AND abs(factor3) > abs(factor2)
           AND abs(factor3) > abs(factor4)
           AND abs(factor3) > abs(factor5)
           AND abs(factor3) > abs(factor6)
           AND abs(factor3) > abs(factor7)
           AND abs(factor3) > abs(factor8)
           AND abs(factor3) > abs(factor9)
           AND factor3 < 0 AND abs(factor3) >= "&minloading" then do; factor = 'f3'; pole = -1;  loaded = 1; end ;

   else if     abs(factor4) > abs(factor1)
           AND abs(factor4) > abs(factor2)
           AND abs(factor4) > abs(factor3)
           AND abs(factor4) > abs(factor5)
           AND abs(factor4) > abs(factor6)
           AND abs(factor4) > abs(factor7)
           AND abs(factor4) > abs(factor8)
           AND abs(factor4) > abs(factor9)
           AND factor4 < 0 AND abs(factor4) >= "&minloading" then do; factor = 'f4'; pole = -1;  loaded = 1; end ;

   else if     abs(factor5) > abs(factor1)
           AND abs(factor5) > abs(factor2)
           AND abs(factor5) > abs(factor3)
           AND abs(factor5) > abs(factor4)
           AND abs(factor5) > abs(factor6)
           AND abs(factor5) > abs(factor7)
           AND abs(factor5) > abs(factor8)
           AND abs(factor5) > abs(factor9)
           AND factor5 < 0 AND abs(factor5) >= "&minloading" then do; factor = 'f5'; pole = -1;  loaded = 1; end ;

   else if     abs(factor6) > abs(factor1)
           AND abs(factor6) > abs(factor2)
           AND abs(factor6) > abs(factor3)
           AND abs(factor6) > abs(factor4)
           AND abs(factor6) > abs(factor5)
           AND abs(factor6) > abs(factor7)
           AND abs(factor6) > abs(factor8)
           AND abs(factor6) > abs(factor9)
           AND factor6 < 0 AND abs(factor6) >= "&minloading" then do; factor = 'f6'; pole = -1;  loaded = 1; end ;

   else if     abs(factor7) > abs(factor1)
           AND abs(factor7) > abs(factor2)
           AND abs(factor7) > abs(factor3)
           AND abs(factor7) > abs(factor4)
           AND abs(factor7) > abs(factor5)
           AND abs(factor7) > abs(factor6)
           AND abs(factor7) > abs(factor8)
           AND abs(factor7) > abs(factor9)
           AND factor7 < 0 AND abs(factor7) >= "&minloading" then do; factor = 'f7'; pole = -1;  loaded = 1; end ;

   else if     abs(factor8) > abs(factor1)
           AND abs(factor8) > abs(factor2)
           AND abs(factor8) > abs(factor3)
           AND abs(factor8) > abs(factor4)
           AND abs(factor8) > abs(factor5)
           AND abs(factor8) > abs(factor6)
           AND abs(factor8) > abs(factor7)
           AND abs(factor8) > abs(factor9)
           AND factor8 < 0 AND abs(factor8) >= "&minloading" then do; factor = 'f8'; pole = -1;  loaded = 1; end ;

   else if     abs(factor9) > abs(factor1)
           AND abs(factor9) > abs(factor2)
           AND abs(factor9) > abs(factor3)
           AND abs(factor9) > abs(factor4)
           AND abs(factor9) > abs(factor5)
           AND abs(factor9) > abs(factor6)
           AND abs(factor9) > abs(factor7)
           AND abs(factor9) > abs(factor8)
           AND factor9 < 0 AND abs(factor9) >= "&minloading" then do; factor = 'f9'; pole = -1;  loaded = 1; end ;
run;

data rotated4 ; set rotated3 ; if loaded = 1; run; quit;

/* Labeling */
PROC FORMAT library=work ;
  VALUE  $featurelabels
"abstrcn" = "Abstract nouns"
"act_ipv" = "Intransitive phrasal activity verbs"
"act_tpv" = "Transitive phrasal activity verbs"
"actv" = "Activity verbs"
"adj_attr" = "Adjectives in attributive position"
"advs" = "Adverb (excluding other types)"
"agls_psv" = "Agentless passive verb"
"all_advl" = "Sum stance adverbs"
"all_jth" = "Sum stance that complement clauses controlled by adjectives"
"all_jto" = "Sum stance to complement clauses controlled by adjectives"
"all_nth" = "Sum stance that complement clauses controlled by nouns"
"all_nto" = "to complement clause controlled by stance nouns"
"all_th" = "Sum stance that complement clauses"
"all_to" = "Sum stance to complement clauses"
"all_vth" = "Sum stance that complement clauses controlled by verbs"
"all_vto" = "Sum stance to complement clauses controlled by verbs"
"alladj" = "All adjectives"
"allconj" = "All conjunctions"
"allmodal" = "All modals"
"allpasv" = "All passives"
"allpro" = "All personal pronouns"
"allverb" = "Verb (not including auxiliary verbs)"
"allwh" = "All wh-words"
"allwhrel" = "All wh-relative clauses"
"amplifr" = "Amplifiers"
"aspectpv" = "Aspectual phrasal verbs"
"aspectv" = "Aspectual verb"
"atadvl" = "Attitudinal adverbs"
"att_jth" = "that complement clause controlled by attitudinal or emotion adjective"
"att_nth" = "that complement clause controlled by attitude or perspective noun"
"att_vth" = "that complement clause controlled by attitudinal verb"
"be_state" = "Verb be"
"by_pasv" = "Passive verb + by"
"causev" = "Causative verbs"
"cognitn" = "Cognition nouns"
"colorj" = "Color adjectives"
"commpv" = "Transitive phrasal communication verbs"
"commv" = "Communication verbs"
"concrtn" = "Concrete nouns"
"conjncts" = "Linking adverbials"
"contrac" = "Contraction"
"copulapv" = "Copular phrasal verbs"
"downtone" = "Downtoner"
"dsre_vto" = "to complement clauses controlled by verbs of desire, intention, and decision"
"efrt_vto" = "to complement clauses controlled by verbs of modality, causation, and effort"
"evalj" = "Evaluative adjectives"
"existv" = "Existence verbs"
"fact_jth" = "that complement clause controlled by factive or certainty adjective"
"fact_vth" = "that complement clause controlled by factive verb"
"fct_nth" = "that complement clause controlled by factive or certainty noun"
"fctadvl" = "Certainty adverbials"
"finlprep" = "Stranded prepositions"
"gen_emph" = "Emphatics"
"gen_hdg" = "Hedges"
"groupn" = "Group/institution nouns"
"have" = "Verb have"
"humann" = "Animate nouns"
"inf" = "Infinitives"
"it" = "Pronoun it"
"jcmp" = "that complement clause controlled by adjective"
"lkly_jth" = "that complement clause controlled by adjective of likelihood"
"lkly_nth" = "that complement clause controlled by noun of likelihood"
"lkly_vth" = "that complement clause controlled by verb of likelihood"
"lklydvl" = "Likelihood adverbs"
"mentalpv" = "Transitive phrasal mental verbs"
"mentalv" = "Mental verbs"
"mntl_vto" = "to complement clauses controlled by verbs of cognition"
"n" = "Noun"
"n_nom" = "Nominalization"
"nec_mod" = "Modals of necessity or obligation"
"nfct_nth" = "that complement clause controlled by communication (non-factual) noun"
"nonf_vth" = "that complement clause controlled by non-factive verb"
"nonfadvl" = "Style adverbs"
"o_and" = "Coordinating conjunction as clausal connector"
"occurpv" = "Occurrence -- Intransitive phrasal verbs"
"occurv" = "Occurrence verbs"
"p_and" = "Coordinating conjunction -- phrasal connector"
"pany" = "Nominal / indefinite pronoun"
"pasttnse" = "Past tense verb"
"pdem" = "Demonstrative pronouns"
"perfects" = "Perfect aspect verb forms"
"pl_adv" = "Place adverbials"
"placen" = "Place nouns"
"pos_mod" = "Modals of possibility, permission, and ability"
"prcessn" = "Abstract/process nouns"
"prd_mod" = "Modals of prediction or volition"
"pred_adj" = "Adjectives in predicative position"
"prep" = "Preposition"
"pres" = "Present tense verbs"
"pro1" = "First person pronoun / possessive"
"pro2" = "Second person pronoun / possessive"
"pro3" = "Third person pronoun (except it)"
"pro_do" = "Verb do"
"prob_vto" = "to complement clauses controlled by verbs of probability and simple fact"
"prtcle" = "Discourse particles"
"prv_vb" = "Private verbs"
"pub_vb" = "Public verbs"
"quann" = "Quantity nouns"
"rel_obj" = "wh pronoun relative clause in object position"
"rel_pipe" = "wh-pronoun relative clause in object position with prepositional fronting (pied piping)"
"rel_subj" = "wh pronoun relative clause in subject position"
"relatnj" = "Relational adjectives"
"sizej" = "Size adjectives"
"spch_vto" = "to complement clauses controlled by speech act verbs"
"spl_aux" = "Adverb within auxiliary (splitting aux-verb)"
"sua_vb" = "Suasive verbs"
"sub_cnd" = "Conditional subordinating conjunction"
"sub_cos" = "Causative subordinating conjunction"
"sub_othr" = "Other subordinating conjunction"
"tccncrt" = "Technical / Concrete nouns"
"that_del" = "that deletion"
"that_rel" = "that relative clauses"
"timej" = "Time adjectives"
"tm_adv" = "Time adverbials"
"topicj" = "Topical adjectives"
"ttr" = "Type-token ratio"
"vcmp" = "that complement clause controlled by verb"
"vprogrsv" = "Present progressive verb forms"
"wcount" = "Word count"
"wh_cl" = "wh-clauses"
"wh_ques" = "wh-question"
"whiz_vbg" = "Present participial whiz deletion"
"whiz_vbn" = "Passive postnominal modifier"
"wrlengh" = "Word length"
"x1_jto" = "to complement clause controlled by epistemic adjectives (certainty or likelihood)"
"x2_jto" = "to complement clause controlled by adjective of ability / willingness"
"x3_jto" = "to complement clause controlled by adjective of personal affect or emotion"
"x4_jto" = "to complement clause controlled by adjective of ease/difficulty"
"x5_jto" = "to complement clause controlled by evaluative adjectives"
;
run;
quit;

ODS EXCLUDE NONE;
ods html file="&whereisit/&myfolder/loadtable.html";
%macro create(howmany);
%do i=1 %to &howmany;

title "LOADINGS TABLE";
title2 "Factor &i pos" ;
data temp;
  set rotated4 ;
  where factor="f&i" and pole=1 ;
proc sort;
  by descending Factor&i ;
proc print ; FORMAT _NAME_ $featurelabels.; var _NAME_  Factor&i ;
run;

title "Factor &i neg" ;
data temp;
  set rotated4 ;
  where factor="f&i" and pole=-1 ;
proc sort;
  by  Factor&i ;
proc print ; FORMAT _NAME_ $featurelabels.; var _NAME_ Factor&i ;
run;

%end;
%mend create;
%create(&extractfactors)
ods html close;
quit;

PROC EXPORT
  DATA= WORK.rotated3
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/rotated.csv"
  REPLACE;
RUN;

/* All vars that loaded, for interpretation */
OPTIONS VALIDVARNAME=ANY;
data rotatedinterpr (drop = factor pole) ;
   set rotated3;
    if factor1 > 0 AND abs(factor1) >= "&minloading" then do; secfactor1 = 'f1'; secpolef1 = 1;  end ;
    if factor2 > 0 AND abs(factor2) >= "&minloading" then do; secfactor2 = 'f2'; secpolef2 = 1;  end ;
    if factor3 > 0 AND abs(factor3) >= "&minloading" then do; secfactor3 = 'f3'; secpolef3 = 1;  end ;
    if factor4 > 0 AND abs(factor4) >= "&minloading" then do; secfactor4 = 'f4'; secpolef4 = 1;  end ;
    if factor5 > 0 AND abs(factor5) >= "&minloading" then do; secfactor5 = 'f5'; secpolef5 = 1;  end ;
    if factor6 > 0 AND abs(factor6) >= "&minloading" then do; secfactor6 = 'f6'; secpolef6 = 1;  end ;
    if factor7 > 0 AND abs(factor7) >= "&minloading" then do; secfactor7 = 'f7'; secpolef7 = 1;  end ;
    if factor8 > 0 AND abs(factor8) >= "&minloading" then do; secfactor8 = 'f8'; secpolef8 = 1;  end ;
    if factor9 > 0 AND abs(factor9) >= "&minloading" then do; secfactor9 = 'f9'; secpolef9 = 1;  end ;

  /* Negative values */

    if factor1 < 0 AND abs(factor1) >= "&minloading" then do; secfactor1 = 'f1'; secpolef1 = -1;  end ;
    if factor2 < 0 AND abs(factor2) >= "&minloading" then do; secfactor2 = 'f2'; secpolef2 = -1;  end ;
    if factor3 < 0 AND abs(factor3) >= "&minloading" then do; secfactor3 = 'f3'; secpolef3 = -1;  end ;
    if factor4 < 0 AND abs(factor4) >= "&minloading" then do; secfactor4 = 'f4'; secpolef4 = -1;  end ;
    if factor5 < 0 AND abs(factor5) >= "&minloading" then do; secfactor5 = 'f5'; secpolef5 = -1;  end ;
    if factor6 < 0 AND abs(factor6) >= "&minloading" then do; secfactor6 = 'f6'; secpolef6 = -1;  end ;
    if factor7 < 0 AND abs(factor7) >= "&minloading" then do; secfactor7 = 'f7'; secpolef7 = -1;  end ;
    if factor8 < 0 AND abs(factor8) >= "&minloading" then do; secfactor8 = 'f8'; secpolef8 = -1;  end ;
    if factor9 < 0 AND abs(factor9) >= "&minloading" then do; secfactor9 = 'f9'; secpolef9 = -1;  end ;

 /* Cleanup */

    if factor = secfactor1 then do; secfactor1 = ' ' ; end;
    if factor = secfactor2 then do; secfactor2 = ' ' ; end;
    if factor = secfactor3 then do; secfactor3 = ' ' ; end;
    if factor = secfactor4 then do; secfactor4 = ' ' ; end;
    if factor = secfactor5 then do; secfactor5 = ' ' ; end;
    if factor = secfactor6 then do; secfactor6 = ' ' ; end;
    if factor = secfactor7 then do; secfactor7 = ' ' ; end;
    if factor = secfactor8 then do; secfactor8 = ' ' ; end;
    if factor = secfactor9 then do; secfactor9 = ' ' ; end;
run;

proc sql;
    select memname into :names separated by ' ' from dictionary.tables
    where libname = 'WORK' AND  substr (memname,1,5) = 'TEMP_' ;
quit;

proc datasets library=work;
delete
&names;
run;

%macro create(howmany);
%do i=1 %to &howmany;
data temp_f&i._prim_pos (keep = Factor&i factor pole type table _NAME_  RENAME = ( Factor&i=loading ) );
 set rotated4 (where=( factor = "f&i" AND pole = 1 ));
 type = 'primary';
 table = "f&i.pos" ;
 proc sort ; by descending loading;
run;
data temp_f&i._sec_pos (keep = Factor&i secfactor&i secpolef&i type table _NAME_  RENAME = ( Factor&i=loading secfactor&i =factor secpolef&i = pole) ) ;
 set rotatedinterpr (where=( secfactor&i = "f&i" AND secpolef&i = 1  ));
 type = 'secondary';
 table = "f&i.pos" ;
  proc sort ; by descending loading;
run;
data temp_f&i._prim_neg (keep = Factor&i factor pole type table _NAME_  RENAME = ( Factor&i=loading ) );
 set rotated4 (where=( factor = "f&i" AND pole = -1 ));
 type = 'primary';
 table = "f&i.neg" ;
  proc sort ; by loading;
run;
data temp_f&i._sec_neg (keep = Factor&i secfactor&i secpolef&i type table _NAME_  RENAME = ( Factor&i=loading secfactor&i =factor secpolef&i = pole) ) ;
 set rotatedinterpr (where=( secfactor&i = "f&i" AND secpolef&i = -1  ));
 type = 'secondary';
 table = "f&i.neg" ;
   proc sort ; by loading;
run;
%end;
%mend create;
%create( &extractfactors )  /* Number of factors extracted */
quit;

proc sql ;
  create table mytables as
  select *
  from dictionary.tables
  where ( libname = "WORK" and substr (memname,1,6) = 'TEMP_F')
  order by memname ;
quit ;

proc sql;
    select memname into :names separated by ' ' from mytables;
quit;

data loadtableinterpr (drop = factor pole);
 length type $15;
 set &names ;
run;

ODS EXCLUDE NONE;
ods html file="&whereisit/&myfolder/loadtable_for_interpretation.html";
PROC PRINT data=loadtableinterpr ; FORMAT _NAME_ $featurelabels. loading 9.2 ; run;
ods html close;

PROC EXPORT
  DATA= WORK.loadtableinterpr
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/loadtable_for_interpretation.csv"
  REPLACE;
RUN;

proc sql;
    select memname into :names separated by ' ' from dictionary.tables
    where libname = 'WORK' AND  substr (memname,1,5) = 'TEMP_' ;
quit;

proc datasets library=work;
delete
&names;
run;

/* Adding metadata */
DATA &project._meta;
SET &project ;
RUN;


/* ==========================================================================
   SECTION 7: SCORING (BASE & ADDITIVE CORPORA)
   ========================================================================== */

ODS EXCLUDE NONE;
ods html file="&whereisit/&myfolder/scoring.html";
proc print data=rotated3 ; run;
ods html close;
ODS EXCLUDE ALL;

/* Automatic scoring */

/* Standardize data using base corpus means and std devs */
PROC STDIZE DATA=&project._meta METHOD=STD OUT=mdz OUTSTAT=meta_stats;
    var _NUMERIC_ ;
RUN;

/* Apply the exact same standardization to the additive corpus */
PROC STDIZE DATA=&project._add_corpus METHOD=IN(meta_stats) OUT=mdz_add;
    var _NUMERIC_ ;
RUN;

/* Factor scores */
data rotated4; set rotated3; if loaded = 1; run;

proc sort data=rotated4;
  by factor ;
run;
proc transpose data=rotated4 out=score;
  by factor ;
  id _NAME_ ;
  var pole;
run;
data score;
  _type_='SCORE';
  set score;
  drop _name_;
  rename factor=_name_;
run;

/* Score the base corpus */
proc score data=mdz score=score out=scores; run;
proc sort data = scores ; by filename; run;
data scores_only (keep = filename prompt source &factorvars) ; set scores ; run;  /* Keep only the columns we want */

/* Score the additive corpus */
proc score data=mdz_add score=score out=scores_add; run;
proc sort data = scores_add ; by filename; run;
data scores_only_add (keep = filename prompt source &factorvars) ; set scores_add ; run;

/* Overview of corpus */
ODS EXCLUDE NONE;
ods html file="&whereisit/&myfolder/corpus_size.html";
proc means data=&project sum mean min max stddev; var wcount  ; run;
RUN;

/* Scores only (Base) */
DATA scores_only
 (KEEP = filename prompt source &factorvars );
set scores;
run;

/* Combine base scores and additive scores for statistical testing */
DATA scores_combined;
  SET scores scores_add;
RUN;

DATA scores_only_combined;
  SET scores_only scores_only_add;
RUN;

/* Base TMDA Exports */
PROC EXPORT
  DATA= WORK.scores
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/&project._scores_base.csv"
  REPLACE;
RUN;

PROC EXPORT
  DATA= WORK.scores_only
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/&project._scores_only_base.csv"
  REPLACE;
RUN;

/* Additive TMDA Exports */
PROC EXPORT
  DATA= WORK.scores_add
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/&project._scores_add.csv"
  REPLACE;
RUN;

PROC EXPORT
  DATA= WORK.scores_only_add
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/&project._scores_only_add.csv"
  REPLACE;
RUN;

/* Combined TMDA Exports */
PROC EXPORT
  DATA= WORK.scores_combined
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/&project._scores.csv"
  REPLACE;
RUN;

PROC EXPORT
  DATA= WORK.scores_only_combined
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/&project._scores_only.csv"
  REPLACE;
RUN;


/* ==========================================================================
   SECTION 8: OUTLIER IDENTIFICATION AND REMOVAL
   ========================================================================== */

/* Outlier texts, identify */
%macro create(howmany);
%do i=1 %to &howmany;

%let VariableOfInterest= f&i ;  /* Enter variable here */
%let dsn=scores_combined;  /* Use the combined dataset */

data temp; set &dsn; run;

proc univariate data=temp noprint;
var &VariableOfInterest;
output out=IQRData Q1=Q1 Q3=Q3 QRANGE=IQR;
run;

/* The lower the number multiplied by IQR, the more texts will be outliers */
/* The default number is 1.5 */
%let multipl=1;
proc sql ;
select Q1-&multipl*IQR, Q3+&multipl*IQR into :lowerfence, :upperfence from IQRData;
quit;

%put Outliers are those observations less than &lowerfence and greater than &upperfence;

data outliers_f&i;
set temp;
if &VariableOfInterest gt &upperfence or &VariableOfInterest lt &lowerfence then output;
run;

%end;
%mend create;
%create( &extractfactors )  /* Number of factors extracted */
quit;

/* Outlier texts, isolate for removal */
data outliers_to_del (keep= filename prompt source &factorvars) ; set outliers_f1 - outliers_f&extractfactors ; proc sort noduprecs; by filename; run; quit;  /* Keep only the columns we want */

data &project._no_outliers; set scores_combined; run;

proc sql;
delete from &project._no_outliers
  where filename in (select filename from outliers_to_del);
quit;

/* Save outliers list to Excel */
%macro create(howmany);
%do i=1 %to &howmany;

data outliers_f&i (keep= filename prompt source f&i) ; set outliers_f&i ; proc sort ; by f&i; run; quit;  /* Keep only the columns we want */

PROC EXPORT
  DATA= WORK.outliers_f&i
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/outliers_deleted_f&i.csv"
  REPLACE;
RUN;

%end;
%mend create;
%create( &extractfactors )  /* Number of factors extracted */
quit;

PROC EXPORT
  DATA= WORK.outliers_to_del
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/outliers_all.csv"
  REPLACE;
RUN;


/* ========================================================================= */
/* ⚠️ OPTIONAL BYPASS: OUTLIER REMOVAL                                       */
/* ------------------------------------------------------------------------- */
/* If you wish to KEEP the outliers in your final analysis, leave the        */
/* following DATA step active. It overwrites the outlier-trimmed dataset     */
/* with the full, original dataset.                                          */
/*                                                                           */
/* If you wish to REMOVE outliers, COMMENT OUT or DELETE the DATA step below.*/
/* ========================================================================= */

data &project._no_outliers; set scores_combined; run;



/* ==========================================================================
   SECTION 9: STATISTICAL ANALYSIS (ANOVAs & BOXPLOTS)
   ========================================================================== */

/* ANOVAS */
/* ODS table names for GLM: */
/*https://support.sas.com/documentation/cdl/en/statug/68162/HTML/default/viewer.htm#statug_glm_details70.htm*/

ODS EXCLUDE NONE;
ods html file="&whereisit/&myfolder/glm_meta.html";
%macro create(howmany);
%do i=1 %to &howmany;
OPTIONS VALIDVARNAME=ANY;
ods graphics off;

proc GLM data=&project._no_outliers;
ods output FitStatistics=r2_prompt_f&i ;
ods output OverallANOVA=anova_prompt_f&i ;
ods output Means=means_prompt_f&i ;
	title GLM for dataset = &project._no_outliers f&i ;
	class prompt source;
	model f&i = prompt source prompt*source;
	means prompt source ;
	run;

ods graphics on;
%end;
%mend create;
%create( &extractfactors )  /* Number of factors extracted */
ods html close;
quit;

/*
https://support.sas.com/documentation/cdl/en/statug/63033/HTML/default/viewer.htm#statug_glm_sect005.htm

If the interaction between A*B is not significant, this indicates that the effect of A does not depend on the level of B and vice versa.

discussion:
https://www.researchgate.net/post/Difference_between_Type_I_and_Type_III_SS_decision_tables_in_statistical_analyses
*/


/* Boxplots */
%macro create(howmany);
%do i=1 %to &howmany;
ods listing gpath="&whereisit/&myfolder/";
ods graphics / imagename="boxplot_f&i" imagefmt=png;
title "Box plots";
proc GLM data=&project._no_outliers;
	title GLM for dataset = &project._no_outliers f&i ;
	class prompt;
	model f&i = prompt;
	means prompt ;
	run;
title;
%end;
%mend create;
%create( &extractfactors )  /* Number of factors extracted */
quit;


/* ==========================================================================
   ZIP OUTPUT FILES
   ========================================================================== */

%let addcntzip = /home/u63529080/zip/output_&project..zip;

FILENAME temp "&addcntzip";

DATA _NULL_;
  rc=FDELETE('temp');
RUN;

data filelist;
run;

data filelist;
  length root dname $ 2048 filename $ 256 dir level 8;
  input root;
  retain filename dname ' ' level 0 dir 1;
cards4;
/home/u63529080/cl_st1_ph2_sara
;;;;
run;

data filelist;
  modify filelist;
  rc1=filename('tmp',catx('/',root,dname,filename));
  rc2=dopen('tmp');
  dir = 1 & rc2;

  if dir then do;
      dname=catx('/',dname,filename);
      filename=' ';
  end;

  replace;

  if dir;

  level=level+1;

  do i=1 to dnum(rc2);
    filename=dread(rc2,i);
    output;
  end;

  rc3=dclose(rc2);
run;

proc sort data=filelist;
  by root dname filename;
run;

proc print data=filelist;
run;

data _null_;

  set filelist;

  if dir=0;

  rc1=filename("in" , catx('/',root,dname,filename), "disk", "lrecl=1 recfm=n");
  rc1txt=sysmsg();

  rc2=filename(
      "out",
      "&addcntzip.",
      "ZIP",
      "lrecl=1 recfm=n member='" !! catx('/',dname,filename) !! "'"
  );
  rc2txt=sysmsg();

  do _N_ = 1 to 6;
    rc3=fcopy("in","out");
    rc3txt=sysmsg();

    if fexist("out") then leave;
    else sleeprc=sleep(0.5,1);
  end;

  rc4=fexist("out");
  rc4txt=sysmsg();

  put _N_ @12 (rc:) (=);

run;


/* Delete all png, html, tsv, and csv files after zipping */

%let path=&whereisit/&myfolder;

FILENAME _folder_ "%bquote(&path.)";

data filenames(keep=memname);
  handle=dopen( '_folder_' );

  if handle > 0 then do;
    count=dnum(handle);

    do i=1 to count;
      memname=dread(handle,i);

      if scan(memname, 2, '.')='png'
      OR scan(memname, 2, '.')='html'
      OR scan(memname, 2, '.')='tsv'
      OR scan(memname, 2, '.')='csv'
      then output filenames;
    end;
  end;

  rc=dclose(handle);
run;

filename _folder_ clear;

data _null_;
set filenames;
fname = 'todelete';
rc = filename(fname, quote(cats("&path",'/',memname)));
rc = fdelete(fname);
rc = filename(fname);
run;

/* END OF PROGRAM */