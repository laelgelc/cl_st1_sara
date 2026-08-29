/* BEGINNING PART 1 */
/* === EDIT BELOW ====*/

/* account: CEPRIL */

%let project = group1 ;

%let myfolder = &project ;

%let sasusername = u61738292 ;

%let whereisit = /home/&sasusername ;   /* online */

libname gelc "&whereisit/&myfolder";
/* files will NOT be saved to the folder above unless you put in 'gelc.'' before every destination */
/* otherwise files are going to the work library and not saved to the current folder */
/* this is needed to enable SGPLOT */
/* otherwise if your run SGPLOT, SAS will throw up an error message and stop working ... */

options fmtsearch=(work library);

/* enter number of factors to extract */
%let extractfactors = 9 ;

%let factorvars = fac1-fac&extractfactors ;

/* enter min loading cutoff */
%let minloading = .3 ;

/* enter min communality cutoff */
%let communalcutoff = .15 ;


DATA observed ;
INFILE "&whereisit/&myfolder/&project._counts.txt";
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
RUN;


DATA &project (drop=   dim1-dim5 pub_vb prv_vb );
SET observed;
IF filename = 'chicagopds03e05e_06.txt' THEN filename = 'chicagopd_s03e05.txt' ;
IF filename = 'chicagopds04e07e_08.txt' THEN filename = 'chicagopd_s04e07.txt' ;
RUN;

ODS EXCLUDE NONE;
proc print data = &project (FIRSTOBS=200 OBS=500); var filename; run;


/*
proc print data=&project; 
var filename countrycode ; 
run;
*/

/*
proc contents data=deisesections; 
run; 
*/

PROC EXPORT
  DATA= WORK.&project
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/&project..csv"
  REPLACE;
RUN;

/* drop sum variables  */

DATA &project._no_sum_v (DROP = all_advl all_jth all_jto all_nth all_th all_to all_vth all_vto alladj allconj allmodal allpasv allpro allverb allwh allwhrel n );
SET &project ;
RUN;

/* unrotated w/o sum vars, before dropping low communalities */

OPTIONS VALIDVARNAME=ANY;

ODS EXCLUDE NONE;
ods html file='&whereisit/&myfolder/unrotated.html'; 
ods trace on;

proc factor
OUTSTAT=fout
data=&project._no_sum_v /* sum vars dropped */
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

/*** find low communalities ***/
/*https://communities.sas.com/t5/SAS-Programming/How-do-I-delete-variables-based-on-their-values-in-an-outstat/m-p/675576#M203571*/

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

/* save dropped variables to excel */

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

/* scree plot */

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
ods listing gpath='&whereisit/&myfolder/';
ods graphics / imagename="scree" imagefmt=png;
title "Scree plot";
proc sgplot data= fout4 ;
  series x=factor y=EIGENVAL /  datalabel=factor;
run;
title;
ODS EXCLUDE ALL;

/* rotated without sum variables prior to sum var check*/

/*ods select none; */

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

/* checking sum variables */

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
           AND factor1 > 0 AND abs(factor1) >= "&minloading" then do; factor = 'f1'; pole = 1;  loaded = 1; end ;

   else if     abs(factor2) > abs(factor1) 
           AND abs(factor2) > abs(factor3) 
           AND abs(factor2) > abs(factor4) 
           AND abs(factor2) > abs(factor5) 
           AND abs(factor2) > abs(factor6) 
           AND abs(factor2) > abs(factor7) 
           AND factor2 > 0 AND abs(factor2) >= "&minloading" then do; factor = 'f2'; pole = 1;  loaded = 1; end ;

   else if     abs(factor3) > abs(factor1) 
           AND abs(factor3) > abs(factor2) 
           AND abs(factor3) > abs(factor4) 
           AND abs(factor3) > abs(factor5) 
           AND abs(factor3) > abs(factor6) 
           AND abs(factor3) > abs(factor7) 
           AND factor3 > 0 AND abs(factor3) >= "&minloading" then do; factor = 'f3'; pole = 1;  loaded = 1; end ;

   else if     abs(factor4) > abs(factor1) 
           AND abs(factor4) > abs(factor2) 
           AND abs(factor4) > abs(factor3) 
           AND abs(factor4) > abs(factor5) 
           AND abs(factor4) > abs(factor6) 
           AND abs(factor4) > abs(factor7) 
           AND factor4 > 0 AND abs(factor4) >= "&minloading" then do; factor = 'f4'; pole = 1;  loaded = 1; end ;

   else if     abs(factor5) > abs(factor1) 
           AND abs(factor5) > abs(factor2) 
           AND abs(factor5) > abs(factor3) 
           AND abs(factor5) > abs(factor4) 
           AND abs(factor5) > abs(factor6) 
           AND abs(factor5) > abs(factor7) 
           AND factor5 > 0 AND abs(factor5) >= "&minloading" then do; factor = 'f5'; pole = 1;  loaded = 1; end ;

   else if     abs(factor6) > abs(factor1) 
           AND abs(factor6) > abs(factor2) 
           AND abs(factor6) > abs(factor3) 
           AND abs(factor6) > abs(factor4) 
           AND abs(factor6) > abs(factor5) 
           AND abs(factor6) > abs(factor7) 
           AND factor6 > 0 AND abs(factor6) >= "&minloading" then do; factor = 'f6'; pole = 1;  loaded = 1; end ;

   else if     abs(factor7) > abs(factor1) 
           AND abs(factor7) > abs(factor2) 
           AND abs(factor7) > abs(factor3) 
           AND abs(factor7) > abs(factor4) 
           AND abs(factor7) > abs(factor5) 
           AND abs(factor7) > abs(factor6) 
           AND factor7 > 0 AND abs(factor7) >= "&minloading" then do; factor = 'f7'; pole = 1;  loaded = 1; end ;

/* negative values */

  else  if     abs(factor1) > abs(factor2) 
           AND abs(factor1) > abs(factor3) 
           AND abs(factor1) > abs(factor4) 
           AND abs(factor1) > abs(factor5) 
           AND abs(factor1) > abs(factor6) 
           AND abs(factor1) > abs(factor7) 
           AND factor1 < 0 AND abs(factor1) >= "&minloading" then do; factor = 'f1'; pole = -1;  loaded = 1; end ;

   else if     abs(factor2) > abs(factor1) 
           AND abs(factor2) > abs(factor3) 
           AND abs(factor2) > abs(factor4) 
           AND abs(factor2) > abs(factor5) 
           AND abs(factor2) > abs(factor6) 
           AND abs(factor2) > abs(factor7) 
           AND factor2 < 0 AND abs(factor2) >= "&minloading" then do; factor = 'f2'; pole = -1;  loaded = 1; end ;

   else if     abs(factor3) > abs(factor1) 
           AND abs(factor3) > abs(factor2) 
           AND abs(factor3) > abs(factor4) 
           AND abs(factor3) > abs(factor5) 
           AND abs(factor3) > abs(factor6) 
           AND abs(factor3) > abs(factor7) 
           AND factor3 < 0 AND abs(factor3) >= "&minloading" then do; factor = 'f3'; pole = -1;  loaded = 1; end ;

   else if     abs(factor4) > abs(factor1) 
           AND abs(factor4) > abs(factor2) 
           AND abs(factor4) > abs(factor3) 
           AND abs(factor4) > abs(factor5) 
           AND abs(factor4) > abs(factor6) 
           AND abs(factor4) > abs(factor7) 
           AND factor4 < 0 AND abs(factor4) >= "&minloading" then do; factor = 'f4'; pole = -1;  loaded = 1; end ;

   else if     abs(factor5) > abs(factor1) 
           AND abs(factor5) > abs(factor2) 
           AND abs(factor5) > abs(factor3) 
           AND abs(factor5) > abs(factor4) 
           AND abs(factor5) > abs(factor6) 
           AND abs(factor5) > abs(factor7) 
           AND factor5 < 0 AND abs(factor5) >= "&minloading" then do; factor = 'f5'; pole = -1;  loaded = 1; end ;

   else if     abs(factor6) > abs(factor1) 
           AND abs(factor6) > abs(factor2) 
           AND abs(factor6) > abs(factor3) 
           AND abs(factor6) > abs(factor4) 
           AND abs(factor6) > abs(factor5) 
           AND abs(factor6) > abs(factor7) 
           AND factor6 < 0 AND abs(factor6) >= "&minloading" then do; factor = 'f6'; pole = -1;  loaded = 1; end ;

   else if     abs(factor7) > abs(factor1) 
           AND abs(factor7) > abs(factor2) 
           AND abs(factor7) > abs(factor3) 
           AND abs(factor7) > abs(factor4) 
           AND abs(factor7) > abs(factor5) 
           AND abs(factor7) > abs(factor6) 
           AND factor7 < 0 AND abs(factor7) >= "&minloading" then do; factor = 'f7'; pole = -1;  loaded = 1; end ;   
run;

data rotated4 ; set rotated3 (KEEP = _NAME_ loaded ); run;
proc transpose data=rotated4 out= rotated5 ; id _NAME_ ; run;

/* set a value = 0 to low comm vars dropped before to ensure sums are computed */

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

/* proc transpose data=sumdrop out= temp1 ; id _NAME_ ; run; */

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
      /* above = removed  prv_vb = 0 ;  pub_vb = 0 ; */
      /*  if allverb <  4 then do;  act_ipv = 0 ;  act_tpv = 0 ;  actv = 0 ;  aspectv = 0 ;  be_state = 0 ;  causev = 0 ;  commpv = 0 ;  commv = 0 ;  copulapv = 0 ;  existv = 0 ;  have = 0 ;  inf = 0 ;  mentalpv = 0 ;  mentalv = 0 ;  occurpv = 0 ;  occurv = 0 ;  pasttnse = 0 ;  perfects = 0 ;  pres = 0 ;  pro_do = 0 ;  prv_vb = 0 ;  pub_vb = 0 ;  sua_vb = 0 ;  vprogrsv = 0 ;  allverb = 1; end; */ 
   else if allverb >= 4 then do; allverb = 0 ; end;

        if n <  2 then do;  humann = 0 ;  cognitn = 0 ;  concrtn = 0 ;  groupn = 0 ;  abstrcn = 0 ;  placen = 0 ;  prcessn = 0 ;  quann = 0 ;  tccncrt = 0 ;  n = 1; end; 
   else if n >= 2 then do; n = 0 ; end;

        if all_th <  2 then do;  all_vth = 0 ;  all_nth = 0 ;  all_jth = 0 ;  all_th = 1; end; 
   else if all_th >= 2 then do; all_th = 0 ; end;

        if all_to <  2 then do;  all_vto = 0 ;  all_jto = 0 ;  all_nto = 0 ;  all_to = 1; end; 
   else if all_to >= 2 then do; all_to = 0 ; end;

run;

proc transpose data=sumdrop2 out= varsdel ; id _NAME_ ; run;


/* drop variables based on sum variables check */

proc sql;
    select _name_ into :sumcheck separated by ' ' from varsdel
        where loaded = 0;
quit;


data &project._sum_check ;
    set &project ;  /* the initial dataset with the sum vars counts */
     drop &sumcheck ;  
run;

/* final rotated after sum var check*/

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


/* loadings table */

/*
 
https://stats.idre.ucla.edu/sas/output/factor-analysis/ 
Rotated Factor Pattern – This table contains the rotated factor loadings, which are the correlations between the variable and the factor.  Because these are correlations, possible values range from -1 to +1. 
in the outstat data file, the rotated factor pattern appears as PREROTAT. The standardized regression coefficients appear as PATTERN.
Use PREROTAT in the outstat data file. 

https://documentation.sas.com/?docsetId=statug&docsetTarget=statug_factor_details02.htm&docsetVersion=15.1&locale=en

PREROTAT: prerotated factor pattern.
PATTERN: factor pattern. (regression coefficients)

PREROTAT: prerotated factor pattern. =>   Stat.Factor.OrthRotFactPat
PATTERN: factor pattern. =>  Stat.Factor.ObliqueRotFactPat

*/

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
           AND factor1 > 0 AND abs(factor1) >= "&minloading" then do; factor = 'f1'; pole = 1;  loaded = 1; end ;

   else if     abs(factor2) > abs(factor1) 
           AND abs(factor2) > abs(factor3) 
           AND abs(factor2) > abs(factor4) 
           AND abs(factor2) > abs(factor5) 
           AND abs(factor2) > abs(factor6) 
           AND abs(factor2) > abs(factor7) 
           AND factor2 > 0 AND abs(factor2) >= "&minloading" then do; factor = 'f2'; pole = 1;  loaded = 1; end ;

   else if     abs(factor3) > abs(factor1) 
           AND abs(factor3) > abs(factor2) 
           AND abs(factor3) > abs(factor4) 
           AND abs(factor3) > abs(factor5) 
           AND abs(factor3) > abs(factor6) 
           AND abs(factor3) > abs(factor7) 
           AND factor3 > 0 AND abs(factor3) >= "&minloading" then do; factor = 'f3'; pole = 1;  loaded = 1; end ;

   else if     abs(factor4) > abs(factor1) 
           AND abs(factor4) > abs(factor2) 
           AND abs(factor4) > abs(factor3) 
           AND abs(factor4) > abs(factor5) 
           AND abs(factor4) > abs(factor6) 
           AND abs(factor4) > abs(factor7) 
           AND factor4 > 0 AND abs(factor4) >= "&minloading" then do; factor = 'f4'; pole = 1;  loaded = 1; end ;

   else if     abs(factor5) > abs(factor1) 
           AND abs(factor5) > abs(factor2) 
           AND abs(factor5) > abs(factor3) 
           AND abs(factor5) > abs(factor4) 
           AND abs(factor5) > abs(factor6) 
           AND abs(factor5) > abs(factor7) 
           AND factor5 > 0 AND abs(factor5) >= "&minloading" then do; factor = 'f5'; pole = 1;  loaded = 1; end ;

   else if     abs(factor6) > abs(factor1) 
           AND abs(factor6) > abs(factor2) 
           AND abs(factor6) > abs(factor3) 
           AND abs(factor6) > abs(factor4) 
           AND abs(factor6) > abs(factor5) 
           AND abs(factor6) > abs(factor7) 
           AND factor6 > 0 AND abs(factor6) >= "&minloading" then do; factor = 'f6'; pole = 1;  loaded = 1; end ;

   else if     abs(factor7) > abs(factor1) 
           AND abs(factor7) > abs(factor2) 
           AND abs(factor7) > abs(factor3) 
           AND abs(factor7) > abs(factor4) 
           AND abs(factor7) > abs(factor5) 
           AND abs(factor7) > abs(factor6) 
           AND factor7 > 0 AND abs(factor7) >= "&minloading" then do; factor = 'f7'; pole = 1;  loaded = 1; end ;

/* negative values */

  else  if     abs(factor1) > abs(factor2) 
           AND abs(factor1) > abs(factor3) 
           AND abs(factor1) > abs(factor4) 
           AND abs(factor1) > abs(factor5) 
           AND abs(factor1) > abs(factor6) 
           AND abs(factor1) > abs(factor7) 
           AND factor1 < 0 AND abs(factor1) >= "&minloading" then do; factor = 'f1'; pole = -1;  loaded = 1; end ;

   else if     abs(factor2) > abs(factor1) 
           AND abs(factor2) > abs(factor3) 
           AND abs(factor2) > abs(factor4) 
           AND abs(factor2) > abs(factor5) 
           AND abs(factor2) > abs(factor6) 
           AND abs(factor2) > abs(factor7) 
           AND factor2 < 0 AND abs(factor2) >= "&minloading" then do; factor = 'f2'; pole = -1;  loaded = 1; end ;

   else if     abs(factor3) > abs(factor1) 
           AND abs(factor3) > abs(factor2) 
           AND abs(factor3) > abs(factor4) 
           AND abs(factor3) > abs(factor5) 
           AND abs(factor3) > abs(factor6) 
           AND abs(factor3) > abs(factor7) 
           AND factor3 < 0 AND abs(factor3) >= "&minloading" then do; factor = 'f3'; pole = -1;  loaded = 1; end ;

   else if     abs(factor4) > abs(factor1) 
           AND abs(factor4) > abs(factor2) 
           AND abs(factor4) > abs(factor3) 
           AND abs(factor4) > abs(factor5) 
           AND abs(factor4) > abs(factor6) 
           AND abs(factor4) > abs(factor7) 
           AND factor4 < 0 AND abs(factor4) >= "&minloading" then do; factor = 'f4'; pole = -1;  loaded = 1; end ;

   else if     abs(factor5) > abs(factor1) 
           AND abs(factor5) > abs(factor2) 
           AND abs(factor5) > abs(factor3) 
           AND abs(factor5) > abs(factor4) 
           AND abs(factor5) > abs(factor6) 
           AND abs(factor5) > abs(factor7) 
           AND factor5 < 0 AND abs(factor5) >= "&minloading" then do; factor = 'f5'; pole = -1;  loaded = 1; end ;

   else if     abs(factor6) > abs(factor1) 
           AND abs(factor6) > abs(factor2) 
           AND abs(factor6) > abs(factor3) 
           AND abs(factor6) > abs(factor4) 
           AND abs(factor6) > abs(factor5) 
           AND abs(factor6) > abs(factor7) 
           AND factor6 < 0 AND abs(factor6) >= "&minloading" then do; factor = 'f6'; pole = -1;  loaded = 1; end ;

   else if     abs(factor7) > abs(factor1) 
           AND abs(factor7) > abs(factor2) 
           AND abs(factor7) > abs(factor3) 
           AND abs(factor7) > abs(factor4) 
           AND abs(factor7) > abs(factor5) 
           AND abs(factor7) > abs(factor6) 
           AND factor7 < 0 AND abs(factor7) >= "&minloading" then do; factor = 'f7'; pole = -1;  loaded = 1; end ;   
run;

data rotated4 ; set rotated3 ; if loaded = 1; run; quit;

/* labeling: https://stats.idre.ucla.edu/sas/modules/labeling/ */
PROC FORMAT library=user ;
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

/* all vars that loaded, for interpretation */

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

  /* negative values */

    if factor1 < 0 AND abs(factor1) >= "&minloading" then do; secfactor1 = 'f1'; secpolef1 = -1;  end ;
    if factor2 < 0 AND abs(factor2) >= "&minloading" then do; secfactor2 = 'f2'; secpolef2 = -1;  end ;
    if factor3 < 0 AND abs(factor3) >= "&minloading" then do; secfactor3 = 'f3'; secpolef3 = -1;  end ;
    if factor4 < 0 AND abs(factor4) >= "&minloading" then do; secfactor4 = 'f4'; secpolef4 = -1;  end ;
    if factor5 < 0 AND abs(factor5) >= "&minloading" then do; secfactor5 = 'f5'; secpolef5 = -1;  end ;
    if factor6 < 0 AND abs(factor6) >= "&minloading" then do; secfactor6 = 'f6'; secpolef6 = -1;  end ;
    if factor7 < 0 AND abs(factor7) >= "&minloading" then do; secfactor7 = 'f7'; secpolef7 = -1;  end ;

 /* cleanup */

    if factor = secfactor1 then do; secfactor1 = ' ' ; end;
    if factor = secfactor2 then do; secfactor2 = ' ' ; end;
    if factor = secfactor3 then do; secfactor3 = ' ' ; end;
    if factor = secfactor4 then do; secfactor4 = ' ' ; end;
    if factor = secfactor5 then do; secfactor5 = ' ' ; end;
    if factor = secfactor6 then do; secfactor6 = ' ' ; end;
    if factor = secfactor7 then do; secfactor7 = ' ' ; end;
run;

proc sql;
    select memname into :names separated by ' ' from dictionary.tables 
    where libname = 'USER' AND  substr (memname,1,5) = 'TEMP_' ;
quit;

proc datasets library=user;
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
data temp_f&i._sec_pos (keep = Factor&i type table _NAME_  RENAME = ( Factor&i=loading secfactor&i =factor secpolef&i = pole) ) ;
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
data temp_f&i._sec_neg (keep = Factor&i type table _NAME_  RENAME = ( Factor&i=loading secfactor&i =factor secpolef&i = pole) ) ;
 set rotatedinterpr (where=( secfactor&i = "f&i" AND secpolef&i = -1  ));
 type = 'secondary';
 table = "f&i.neg" ;
   proc sort ; by loading;
run;
%end;
%mend create;
%create( &extractfactors ) /* number of factors extracted */ 
quit;

proc sql ;
  create table mytables as
  select *
  from dictionary.tables
  where ( libname = "USER" and substr (memname,1,6) = 'TEMP_F') 
  order by memname ;
quit ;

proc sql;
    select memname into :names separated by ' ' from mytables
quit;

data loadtableinterpr (drop = factor pole);
 set &names ;
run;

ODS EXCLUDE NONE;
ods html file='&whereisit/&myfolder/loadtable_for_interpretation.html'; 
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
    where libname = 'USER' AND  substr (memname,1,5) = 'TEMP_' ;
quit;

proc datasets library=user;
delete 
&names;
run;

/* adding metadata */

DATA &project._meta (drop= seasontmp );
SET &project ;
  showname = scan(filename, 1, '_');
  seasontmp = scan(filename, 2, '_');
  seasonid = substr(seasontmp, 2, 2);
RUN;


/* scoring */

ODS EXCLUDE NONE;
ods html file="&whereisit/&myfolder/scoring.html"; 
proc print data=rotated3 ; run;
ods html close; 
ODS EXCLUDE ALL;

/* automatic scoring */

/* standardize data */

PROC STANDARD DATA=&project._meta MEAN=0 STD=1 OUT=mdz; var _NUMERIC_  ; RUN;

/* factor scores */

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

proc score data=mdz score=score out=scores; run;
proc sort data = scores ; by filename; run; 
data scores_only (keep = countrycode filename f1-f3) ; set scores ; run;


/* Overview of corpus */

ODS EXCLUDE NONE;
ods html file="&whereisit/&myfolder/overview.html"; 
PROC FREQ data=&project._meta; 
TABLES showname ;
TABLES  showname * seasonid ;
RUN;


ODS EXCLUDE NONE;
ods html file="&whereisit/&myfolder/corpus_size.html"; 
proc means data=&project sum mean min max stddev; var wcount  ; run;
RUN;

/* scores only */

DATA scores_only 
 (KEEP = filename showname seasonid f1 f2 f3 );
set scores;
run;


PROC EXPORT
  DATA= WORK.scores
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/&project._scores.csv"
  REPLACE;
RUN;

PROC EXPORT
  DATA= WORK.scores_only
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/&project._scores_only.csv"
  REPLACE;
RUN;

/* outlier texts, identify */

%macro create(howmany);
%do i=1 %to &howmany;

%let VariableOfInterest= f&i ;  /* enter var here */
%let dsn=&project._scores;

data temp; set &dsn; run;

proc univariate data=temp noprint;
var &VariableOfInterest;
output out=IQRData Q1=Q1 Q3=Q3 QRANGE=IQR;
run;

/* the lower the number multiplied by IQR, the more texts will be outliers */
/* the default number is 1.5 */
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
%create( &extractfactors ) /* number of factors extracted */
quit;

/* outlier texts, remove */

data outliers_to_del (keep= filename countrycode f1 f2) ; set outliers_f1 outliers_f2 ; proc sort noduprecs; by filename; run; quit;

data &project._no_outliers; set &project._scores; run;

proc sql;
delete from &project._no_outliers
  where filename in (select filename from outliers_to_del);
quit;

/* save outliers list to Excel */

%macro create(howmany);
%do i=1 %to &howmany;

data outliers_f&i (keep= filename countrycode f&i) ; set outliers_f&i ; proc sort ; by f&i; run; quit;

PROC EXPORT
  DATA= WORK.outliers_f&i
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/outliers_deleted_f&i.csv"
  REPLACE;
RUN;

%end;
%mend create;
%create( &extractfactors ) /* number of factors extracted */
quit;

PROC EXPORT
  DATA= WORK.outliers_to_del
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/outliers_all.csv"
  REPLACE;
RUN;


/* ANOVAS */

/* ODS table names for GLM: */
/*https://support.sas.com/documentation/cdl/en/statug/68162/HTML/default/viewer.htm#statug_glm_details70.htm*/

ODS EXCLUDE NONE;
ods html file="&whereisit/&myfolder/glm_meta.html"; 
%macro create(howmany);
%do i=1 %to &howmany;
OPTIONS VALIDVARNAME=ANY;
ods graphics off; 

proc GLM data=scores;
ods output FitStatistics=r2_showname_f&i ;
ods output OverallANOVA=anova_showname_f&i ;
ods output Means=means_countrycode_f&i ;
	title GLM for dataset = &project._scores_showname f&i ;
	class showname;
	model f&i = showname;
	means showname ;
	run;
	
ods graphics on;
%end;
%mend create;
%create( &extractfactors ) /* number of factors extracted */ 
ods html close; 
quit;

/* STOPPED HERE */

/*
https://support.sas.com/documentation/cdl/en/statug/63033/HTML/default/viewer.htm#statug_glm_sect005.htm 

If the interaction between A*B is not significant, this indicates that the effect of A does not depend on the level of B and vice versa.

discussion:
https://www.researchgate.net/post/Difference_between_Type_I_and_Type_III_SS_decision_tables_in_statistical_analyses

*/


ods html file='&whereisit/&myfolder/glm_countrycode_by_locale_by_native.html'; 
%macro create(howmany);
%do i=1 %to &howmany;
OPTIONS VALIDVARNAME=ANY;
ods graphics off; proc GLM data=&project._scores;
	title GLM for dataset = &project._scores countrycode f&i ;
	class countrycode native locale;
	model f&i = countrycode native locale countrycode*native*locale;
	means countrycode native locale ;
	run;
ods graphics on;
%end;
%mend create;
%create( &extractfactors ) /* number of factors extracted */ 
ods html close; 
quit;

/* boxplots */

%macro create(howmany);
%do i=1 %to &howmany;
ods listing gpath='&whereisit/&myfolder/';
ods graphics / imagename="boxplot_f&i" imagefmt=png;
title "Box plots";
proc GLM data=scores;
	title GLM for dataset = scores f&i ;
	class countrycode;
	model f&i = countrycode;
	means countrycode ;
	run;
title;
%end;
%mend create;
%create( &extractfactors ) /* number of factors extracted */ 
quit;


/* Duncan Multiple Range Test (MRT) charts */

%macro create(howmany);
%do i=1 %to &howmany;
ods listing gpath='&whereisit/&myfolder/' image_dpi=300;
ods graphics / reset width=3in height=3in imagemap imagename="Duncan_waller_f&i"  imagefmt=png ;
proc GLM data=&project._scores;
	title GLM for dataset = scores f&i ;
	class countrycode;
	model f&i = countrycode;
	means countrycode  / waller duncan  ;
	run;
ods graphics / reset;
%end;
%mend create;
%create( &extractfactors ) /* number of factors extracted */ 
quit;

/* mean factor scores charts */

%macro create(howmany);
%do i=1 %to &howmany;
ods listing gpath='&whereisit/&myfolder/' image_dpi=300;
ods graphics / reset width=6.4in height=2.5in imagemap imagename="mean_factor_scores_f&i"  imagefmt=png ;
proc sgplot data=&project._scores;
	title height=14pt "Mean Factor Scores (Factor &i)";
	vbar countrycode / response=f&i fillattrs=(color=CXcad5e5)  categoryorder=respdesc
		 stat=mean;
	yaxis label="Mean factor score";
	xaxis label="L1 background" grid;
run;
ods graphics / reset;
%end;
%mend create;
%create( &extractfactors ) /* number of factors extracted */ 
quit;

/* vertical bars for Waller Duncan */
%let i=1;
ods listing gpath='&whereisit/&myfolder/' image_dpi=300;
ods graphics / reset width=6.4in height=2.5in imagemap imagename="mean_factor_scores_waller_duncan_f&i"  imagefmt=png ;
proc sgplot data=&project._scores;
	title height=14pt "Mean Factor Scores (Factor &i)";
	vbar countrycode / response=f&i fillattrs=(color=CXcad5e5)  categoryorder=respdesc
		 stat=mean;
	refline  "HU" / axis=x discreteoffset=0.5 ; 
	refline  "HK" / axis=x discreteoffset=0.5 ; 
	refline  "PA" / axis=x discreteoffset=0.5 ; 
	refline  "LT" / axis=x discreteoffset=0.5 ; 
	refline  "NO" / axis=x discreteoffset=0.5 ; 
	yaxis label="Mean factor score";
	xaxis label="L1 background" grid;
run;
ods graphics / reset;
quit;

%let i=2;
ods listing gpath='&whereisit/&myfolder/' image_dpi=300;
ods graphics / reset width=6.4in height=2.5in imagemap imagename="mean_factor_scores_waller_duncan_f&i"  imagefmt=png ;
proc sgplot data=&project._scores;
	title height=14pt "Mean Factor Scores (Factor &i)";
	vbar countrycode / response=f&i fillattrs=(color=CXcad5e5)  categoryorder=respdesc
		 stat=mean;
	refline  "JP" / axis=x discreteoffset=0.5 ; 
	refline  "GE" / axis=x discreteoffset=0.5 ; 
	yaxis label="Mean factor score";
	xaxis label="L1 background" grid;
run;
ods graphics / reset;
quit;



/* correlation with TAALED */

FILENAME IN "&whereisit/&myfolder/taaled_results.csv";
PROC IMPORT OUT= taaled
     DATAFILE= IN
     DBMS=CSV REPLACE;
     GETNAMES=YES;
     proc sort; by filename; 
RUN;

proc sort data=&project._no_outliers; by filename; run;
data &project._taaled; merge taaled &project._no_outliers; by filename; run;

ODS EXCLUDE NONE;
ods html file='&whereisit/&myfolder/taaled_correlations.html'; 
%macro create(howmany);
%do i=1 %to &howmany;
proc corr data=WORK.&project._TAALED pearson nosimple noprob plots=none;
	var f&i;
	with maas_ttr_cw mattr50_cw msttr50_cw hdd42_cw mtld_original_cw mtld_ma_bi_cw 
		mtld_ma_wrap_cw basic_ncontent_tokens basic_ncontent_types 
		basic_nfunction_tokens basic_nfunction_types lexical_density_types 
		lexical_density_tokens;
run;
%end;
%mend create;
%create( &extractfactors ) /* number of factors extracted */ 
ods html close; 
ODS EXCLUDE ALL;

/* correlations with age, etc.*/

ODS EXCLUDE NONE;
ods html file='&whereisit/&myfolder/age_years-engl_correlations.html'; 
%macro create(howmany);
%do i=1 %to &howmany;
proc corr data=WORK.&project._SCORES pearson nosimple noprob plots=none;
	var f&i;
	with age years_english years_eng_u mo_eng_sp_cou profb2 profc1 profc2;
run;
run;
%end;
%mend create;
%create( &extractfactors ) /* number of factors extracted */ 
ods html close; 
ODS EXCLUDE ALL;

/* supra-national groups */

data &project._countrygroup; set &project._no_outliers;
  if countrycode = 'CN' or countrycode='JP' or countrycode = 'KR' then do; countrygroup = 'SEASIA' ; end;
  if countrycode = 'CZ' or countrycode='HU' or countrycode = 'LT' or countrycode = 'PO' or countrycode = 'RU' or countrycode = 'BG' then do; countrygroup = 'EASTEU' ; end;
  if countrycode = 'SE' or countrycode='JP' or countrycode = 'MD' then do; countrygroup = 'FRMYUG' ; end;
  if countrycode = 'FR' or countrycode='GE' or countrycode = 'DB' or countrycode = 'NE' then do; countrygroup = 'NORTEU' ; end;  
  if countrycode = 'FI' or countrycode='NO' or countrycode = 'SW' then do; countrygroup = 'SCANDI' ; end;    
  if countrycode = 'IT' or countrycode='SP' then do; countrygroup = 'SOUTEU' ; end;
  if countrycode = 'PA' then do; countrygroup = 'PA' ; end;
  if countrycode = 'IR' then do; countrygroup = 'IR' ; end;
  if countrycode = 'TS' then do; countrygroup = 'TS' ; end;  
  if countrycode = 'BR' then do; countrygroup = 'BR' ; end;    
run;

ODS EXCLUDE NONE;
%macro create(howmany);
%do i=1 %to &howmany;
ods listing gpath='&whereisit/&myfolder/' image_dpi=300;
ods graphics / reset width=6.4in height=2.5in imagemap imagename="countrygroup_f&i"  imagefmt=png ;
proc sgplot data=WORK.&project._COUNTRYGROUP;
	title height=14pt "Mean Factor Scores (Factor &i)";
	vbar countrygroup / response=f&i fillattrs=(color=CXcad5e5) datalabel categoryorder=respdesc
		 stat=mean;
	yaxis label="Mean factor score";
	xaxis label="L1 background" grid;
run;
%end;
%mend create;
%create( &extractfactors ) /* number of factors extracted */ 
quit;

/* 'Other' type */

ODS EXCLUDE NONE;
ods html file='&whereisit/&myfolder/essaytype=other.html'; 
data temp ;  set &project._meta (where=(essaytype="Other")); run;
PROC FREQ DATA=temp;   tables essaytype * countrycode ; RUN; quit;
PROC FREQ DATA=temp;   tables titlecode * countrycode ; RUN; quit;

/* Average word length */

proc means data=&project._meta mean ; var wrlengh ; output out=tempout ; run;
PROC EXPORT
  DATA= WORK.tempout
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/wrlengh.csv"
  REPLACE;
RUN;

/* cluster analysis: k-means */

ODS EXCLUDE NONE;
ods html file='&whereisit/&myfolder/cluster_fastclus.html'; 
%macro create(howmany);
%do i=1 %to &howmany;
proc fastclus data = &project._scores maxclusters=&i converge=0 maxiter=100;
         var f1 f2;
run;
%end;
%mend create;
%create( 20 )
quit;

ODS EXCLUDE NONE;
ods html file='&whereisit/&myfolder/cluster_fastclus_solution.html';
proc fastclus data = &project._scores out=clusout radius=0 replace=full maxclusters=4 maxiter=100 list distance;
         id countrycode;
         var f1 f2;
run;

data clusout (keep= filename countrycode f1 f2 native country 
gender age cluster distance years_english years_eng_u mo_
eng_sp_cou titlecode essaytype conditions exam  ); set clusout; run;
PROC EXPORT DATA=WORK.clusout
            OUTFILE= "&whereisit/&myfolder/cluster_fastclus_solution.csv"
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

ODS EXCLUDE NONE;
ods html file='&whereisit/&myfolder/cluster_fastclus_summary.html';
proc summary data=clusout print; var DISTANCE; run; 

/* central = less than 1 std dev from mean*/
/* M 3.15 , SD 1.67 */

DATA clusout;
SET clusout;
   	   central = .;
  IF (DISTANCE > 4.82) THEN central = 0;
  IF (DISTANCE <= 4.82) THEN central = 1;
RUN;

ODS EXCLUDE NONE;
ods html file='&whereisit/&myfolder/cluster_fastclus_freq.html';
ods trace on;
PROC FREQ DATA=clusout;
  TABLES cluster*central countrycode*central countrycode*cluster cluster*countrycode*central / MISSING;
RUN;	
ods trace off;

ods output Freq.Table3.CrossTabFreqs=temp;
PROC FREQ DATA=clusout;
  TABLES cluster*central countrycode*central countrycode*cluster cluster*countrycode*central / MISSING;
RUN;	

data clustergraphs (keep= countrycode cluster Frequency RowPercent ); set temp; run;

PROC EXPORT DATA=WORK.clustergraphs
            OUTFILE= "&whereisit/&myfolder/cluster_fastclus_graphs_1.csv"
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

ODS EXCLUDE NONE;
ods html file='&whereisit/&myfolder/cluster_fastclus_means.html';
proc sort data=clusout; by cluster; run;
%macro create(howmany);
%do i=1 %to &howmany;
proc univariate data=clusout ; var f&i ; by cluster; output out=clusmeans_f&i N=N MIN=MIN MAX=MAX STD=STD MEAN=MEAN ;run;
%end;
%mend create;
%create( &extractfactors ) /* number of factors extracted */
quit;

proc sort data=clusout; by cluster; run;  
proc univariate data=clusout noprint; var f1 f2; by cluster; output out=temp2 N=N MIN=MIN MAX=MAX STD=STD MEAN=MEAN ;run;

ODS EXCLUDE NONE;
ods html file='&whereisit/&myfolder/cluster_stats.html'; 
proc print data=temp2; run;
ods html close; 
ODS EXCLUDE ALL;


/*cluster analysis: subjective vs objective  */

%macro create(howmany);
%do i=1 %to &howmany;
data temp&i (KEEP= cl&i countrycode) ; set clustergraphs (where=(cluster=&i)); rename rowpercent=cl&i ; run;
%end;
%mend create;
%create( 4 ) 
quit;

data clusterrowperc; merge temp1 temp2 temp3 temp4; subj=cl1 + cl2; obj = cl3 + cl4; proc sort ; by descending subj  ;  run;

proc datasets library=user;
delete temp1 temp2 temp3 temp4; 
run;

ods graphics on;
ods listing gpath='&whereisit/&myfolder/';
ods graphics / imagename="dendrogram_clusterrrowperc" imagefmt=png ;
proc cluster data=clusterrowperc method=ward ccc pseudo print=15 out=tree plots=den(height=rsq);
var cl1 cl2 cl3 cl4;
id countrycode;
run;
ods graphics off;

PROC EXPORT
  DATA= WORK.clusterrowperc
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/clusterrowperc.csv"
  REPLACE;
RUN;


/* cluster analysis: hierarchical */


/*
Very negative values of the CCC, say, -30, might be due to outliers. Outliers generally should be removed before clustering.
https://documentation.sas.com/?docsetId=emref&docsetTarget=n1dm4owbc3ka5jn11yjkod7ov1va.htm&docsetVersion=14.3&locale=en

Ward minimum-variance method for determining cluster distance. Note that this method is extremely sensitive to outliers.
https://www.researchgate.net/post/Could_someone_help_me_decide_the_ideal_noof_clusters_from_the_pseudo_t_squared_graph_in_SAS

CCC is the cubic clustering criterion; the idea behind it is to compare the R squared you get with a specific number of clusters versus the R squared you would get by clustering a uniformly distributed set of points. That is, you interpret it similarly as you would R squared. In addition, according to SAS Technical Report A-108 (CCC was developed by SAS), "If all values of the CCC are negative and decreasing for two or more clusters, the distribution is probably unimodal or long-tailed." He goes on to say that very negative values may be due to outliers. I would check your data and your code to make sure, but this heavily implies that the data is unimodal, and thus there is no clustering.
Pseudo F is the ratio of between-cluster variance to within-cluster variance. That is, it provides a measure of how separated the clusters are.  
Pseudo T squared is an index that quantifies the difference in the ratio of between-cluster variance to within-cluster variance when clusters are merged at a given step (put another way, psuedo T squared is working "backwards", from right to left on the plot). If there is a distinct jump in psuedo T squared with X number of clusters, then X+1 represents the optimal number of clusters. In your case, you see a jump in psuedo T squared with 4 clusters, so you should graphically investigate the data with 5 clusters to look for clear separation. 
https://www.researchgate.net/post/Could_someone_help_me_decide_the_ideal_noof_clusters_from_the_pseudo_t_squared_graph_in_SAS

*/

/*

Excellent tutorial, w/ examples:
https://www.listendata.com/2014/10/cluster-analysis-using-sas.html

*/

/* pdf: https://support.sas.com/documentation/onlinedoc/stat/142/cluster.pdf */
/* https://www.listendata.com/2014/10/cluster-analysis-using-sas.html */
/* We need to check whether or not the clusters overlap with each other in terms of their location in the k-dimensional space 14 variables. It is not possible to visualize clusters in 14 dimensions. To work around this problem, we can use canonical discriminant analysis which is a data reduction technique that creates a smaller number of variables that are linear combinations of the 14 clustering variables. The new variables called canonical variables are ordered in terms of the proportion of variance in the clustering variable that is accounted for by each of the canonical variables. So the first canonical variable will account for the largest proportion of the variance.*/

proc cluster data=&project._no_outliers outtree=tree ccc pseudo method=ward print=15 plots=(ccc pseudo); var f1 f2; copy countrycode filename; run;

proc tree data = tree noprint nclusters=4 out=clustree; copy f1 f2 filename countrycode: ; run;

proc candisc data=clustree out=cluscan distance anova; class cluster; var f1 f2; run;

proc sgplot data=cluscan; scatter y=can2 x=can1 / group=cluster; run; 

PROC FREQ DATA=clustree;   tables cluster * countrycode / out=freqout outpct; RUN; quit;

proc sort data=clustree; by cluster; run;  
proc univariate data=clustree noprint; var f1 f2; by cluster; output out=temp2 N=N MIN=MIN MAX=MAX STD=STD MEAN=MEAN ;run;

ODS EXCLUDE NONE;
ods html file='&whereisit/&myfolder/cluster_stats.html'; 
proc print data=temp2; run;
ods html close; 
ODS EXCLUDE ALL;


/* pct of country per cluster, where pct is of each country, not total texts in the corpus */

PROC FREQ DATA=&project._meta;   tables countrycode  / out=countrycount  ; RUN; quit;
data countrycount (keep= countrycode corpuscount ); set countrycount; rename count=corpuscount; run;
data temp (keep = cluster countrycode clustercount); set freqout; rename count=clustercount; run;
proc sort data=temp; by countrycode; run;
proc sort data=countrycount; by countrycode; run;
data clustercountry (keep = cluster countrycode clustercount corpuscount clusterpct); merge temp countrycount ; by countrycode; clusterpct= (clustercount / corpuscount)  ; run;

/* print cluster distribution chart */

ODS EXCLUDE NONE;
ods listing gpath='&whereisit/&myfolder/';
ods graphics / imagename="cluster_distribution" imagefmt=png;
title "CAN1 * CAN2";
proc sgplot data=cluscan; scatter y=can2 x=can1 / group=cluster; run; 
title;
ODS EXCLUDE ALL;

/* print cluster by country chart */
/*https://blogs.sas.com/content/iml/2014/04/08/construct-a-stacked-bar-chart-in-sas-where-each-bar-equals-100.html*/

ODS EXCLUDE NONE;
proc sort data=freqout; by cluster descending PCT_COL  ; run;
ods listing gpath='&whereisit/&myfolder/';
ods graphics / imagename="country_by_cluster" imagefmt=png;
title "Country distribution by cluster";
proc sgplot data=freqout;
vbar countrycode / response=PCT_COL group=Cluster groupdisplay=stack;
xaxis discreteorder=data;
yaxis grid values=(0 to 100 by 10) label="Percentage of Column with Group";
run;
ODS EXCLUDE ALL;


/* this one is misleading because the no. of texts varies greatly by country */
/* DO NOT USE IT*/
ODS EXCLUDE NONE;
proc sort data=freqout; by countrycode cluster descending PCT_ROW  ; run;
ods listing gpath='&whereisit/&myfolder/';
ods graphics / imagename="cluster_by_country" imagefmt=png;
title "Cluster distribution by country";
proc sgplot data=freqout;
vbar cluster / response=PCT_ROW group=countrycode groupdisplay=stack;
xaxis discreteorder=data;
yaxis grid values=(0 to 100 by 10) label="Percentage of Row with Group";
run;
ODS EXCLUDE ALL;

/* print CCC chart */

proc sort data=tree; by _NCL_; run;
data ccc (keep= _NCL_ _CCC_ ); set tree (obs=20); run; 
ODS EXCLUDE NONE;
ods listing gpath='&whereisit/&myfolder/';
ods graphics / imagename="CCC" imagefmt=png;
title "CCC";
proc sgplot data= ccc ;
  series x=_NCL_ y=_CCC_ /  datalabel=_NCL_;
run;
title;
ODS EXCLUDE ALL;

/* print Pseudo-F chart */

proc sort data=tree; by _NCL_; run;
data ccc (keep= _NCL_ _PSF_ ); set tree (obs=20); run; 
ODS EXCLUDE NONE;
ods listing gpath='&whereisit/&myfolder/';
ods graphics / imagename="PSF" imagefmt=png;
title "Pseudo-F Statistic";
proc sgplot data= ccc ;
  series x=_NCL_ y=_PSF_ /  datalabel=_NCL_;
run;
title;
ODS EXCLUDE ALL;

/* print Pseudo-T Squared chart */

proc sort data=tree; by _NCL_; run;
data ccc (keep= _NCL_ _PST2_ ); set tree (obs=20); run; 
ODS EXCLUDE NONE;
ods listing gpath='&whereisit/&myfolder/';
ods graphics / imagename="PST2" imagefmt=png;
title "Pseudo-T Squared Statistic";
proc sgplot data= ccc ;
  series x=_NCL_ y=_PST2_ /  datalabel=_NCL_;
run;
title;
ODS EXCLUDE ALL;

/* DFA with factor scores */
/* texts were nearly all misclassified */

ODS EXCLUDE NONE;
ods html file='&whereisit/&myfolder/dfa_1.html'; 
ods select PostCrossVal ClassifiedCrossVal ErrorCrossVal ;
ods trace on / listing;
PROC DISCRIM DATA=&project._scores crossvalidate crosslist outcross=outcrossdfa  ;
 priors proportional;
 class countrycode; 
 VAR f1 f2 ;
RUN;
ods trace off;
ods html close; 

/* DFA -- stepwise discriminant functional analysis */

ods select Stepdisc.Summary;
ods trace on;
OPTIONS VALIDVARNAME=ANY;
ods output Stepdisc.Summary=dfa_output;  
PROC STEPDISC data=&project._no_outliers ;
CLASS countrycode;
VAR wrlengh -- all_to prv_vb -- mentalv ;
RUN;
ods trace off;
ods html close; 

/* check output, select vars                  */
/* using the Stepwise selection summary table */
/* select vars :                              */
/* Partial R-Square     >.01                  */
/* Pr >F                <.05                  */

data select ; set dfa_output ; if ProbF < .05 AND PartialRSquare >= .01 ; run;

proc sql;
    select Entered into :names separated by ' ' from select;
quit;

ODS EXCLUDE NONE;
ods html file='&whereisit/&myfolder/dfa_stepwise_1.html'; 
ods select PostCrossVal ClassifiedCrossVal ErrorCrossVal ;
ods trace on / listing;
PROC DISCRIM DATA=&project._no_outliers crossvalidate crosslist outcross=outcross  ;
 priors proportional;
 class countrycode; 
 VAR &names ;
RUN;
ods trace off;
ods html close; 

ODS EXCLUDE NONE;
ods html file='&whereisit/&myfolder/dfa_stepwise_2.html'; 
ods select PostCrossVal  ;
ods trace on / listing;
PROC DISCRIM DATA=&project._no_outliers crossvalidate crosslist outcross=outcross  ;
 priors proportional;
 class countrycode; 
 VAR &names ;
RUN;
ods trace off;
ods html close; 

/* cluster analysis based on cross-classification */

/* https://blogs.sas.com/content/iml/2017/01/09/ods-output-any-statistic.html */

ods select ClassifiedCrossVal;
ods trace on;
OPTIONS VALIDVARNAME=ANY;
ods output ClassifiedCrossVal=temp;        


PROC DISCRIM DATA=&project8 crossvalidate crosslist  ;
 priors proportional;
 class countrycode; 
 VAR &names ;


RUN;
ods trace off;
ods html close; 

data crosscluster (keep = Fromcountrycode bg -- ts ); set temp (OBS = 26) ; run;

/* pdf: https://support.sas.com/documentation/onlinedoc/stat/142/cluster.pdf */
/* https://www.listendata.com/2014/10/cluster-analysis-using-sas.html */

proc cluster data=crosscluster (type=distance) outtree=tree ccc pseudo method=ward print=15 plots=(ccc pseudo); var bg -- ts; id Fromcountrycode; run;

proc tree data = tree noprint nclusters=5 out=clustree ; copy Fromcountrycode BG -- TS ; run;

proc candisc data=clustree out=cluscan distance anova; class cluster; var BG -- TS ; run;

proc sgplot data=cluscan; scatter y=can2 x=can1 / group=cluster; run; 

PROC FREQ DATA=clustree;
  tables cluster * countrycode ; 
  exact binomial;
RUN;

/* LatEX */

%macro create(howmany);
%do i=1 %to &howmany;
proc sort data=&project._no_outliers; by countrycode; run;  
proc univariate data=&project._no_outliers noprint; var f&i ; by countrycode; output out=temp MEAN=MEAN ;run;
proc sort data=temp; by descending mean; run;
PROC EXPORT
  DATA= WORK.temp
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/mean_factor_scores_f&i.csv"
  REPLACE;
RUN;
%end;
%mend create;
%create( &extractfactors ) /* number of factors extracted */
quit;

%macro exportcsv (var= );
PROC EXPORT
  DATA= WORK.MEANS_&var._f&i
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/means_&var._f&i..csv"
  REPLACE;
RUN;
PROC EXPORT
  DATA= WORK.R2_&var._f&i
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/r2_&var._f&i..csv"
  REPLACE;
RUN;
%mend exportcsv;

/*options validvarname is needed, otherwise it'll throw an error*/
options validvarname=any;
%macro create(howmany);
%do i=1 %to &howmany;
%exportcsv(var=countrycode)
%exportcsv(var=locale)
%exportcsv(var=conditions)
%exportcsv(var=essaytype)
%exportcsv(var=exam)
%exportcsv(var=gender)
%exportcsv(var=native)
%end;
%mend create;
%create( &extractfactors ) /* number of factors extracted */ 
quit;

%macro saveplot (var= );
ods listing gpath='&whereisit/&myfolder/' image_dpi=300;
ods graphics / reset width=6.4in height=2.5in imagemap imagename="mean_factor_scores_&var._f&i"  imagefmt=png ;
proc sgplot data=&project._scores;
	title height=14pt "Mean Factor Scores for &var (Factor &i)";
	vbar &var / response=f&i fillattrs=(color=CXcad5e5)  categoryorder=respdesc
		 stat=mean;
	yaxis label="Mean factor score";
	xaxis label="&var" grid;
run;
ods graphics / reset;
%mend saveplot;
quit;

/*options validvarname is needed, otherwise it'll throw an error*/
options validvarname=any;
%macro create(howmany);
%do i=1 %to &howmany;
%saveplot(var=countrycode)
%saveplot(var=locale)
%saveplot(var=conditions)
%saveplot(var=essaytype)
%saveplot(var=exam)
%saveplot(var=gender)
%saveplot(var=native)
%end;
%mend create;
%create( &extractfactors ) /* number of factors extracted */ 
quit;


/* &project comparison -- additive analysis */

DATA &project._comparison ;
INFILE "&whereisit/&myfolder/&project._comparison_counts.txt";
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
RUN;

DATA &project._comparison ;
SET &project._comparison ;
  reg = substr(filename, 1, 3) ;
  proc sort ; by filename; 
RUN;

data &project._comparison;
  set &project._comparison (where=(reg NE "fic"));
run;

DATA temp ; 
  set observed ; countrycode = substr(filename,1,2); 
  reg = 'ess';
run;

proc sql outobs=100;
 create table temp100 as
 select *
 from temp
 order by ranuni(0);
quit;

DATA &project._comparison_all ; set temp100 &project._comparison; run;

PROC EXPORT
  DATA= WORK.&project._comparison_all
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/&project._comparison_all.csv"
  REPLACE;
RUN;

proc sort data=&project._comparison_all; by reg; run;  
proc univariate data=&project._comparison_all ; var wcount ; by reg; 
output out=temp2 N=N MIN=MIN MAX=MAX STD=STD MEAN=MEAN ;run;


/* corpus size */

proc means data=&project._comparison_all n sum mean min max stddev; 
class reg;
var wcount ; 
run;

ODS EXCLUDE NONE;
ods html file='&whereisit/&myfolder/dfa_comparison.html'; 
ods select PostCrossVal ClassifiedCrossVal ErrorCrossVal ;
ods trace on / listing;
PROC DISCRIM DATA=&project._comparison_all crossvalidate crosslist outcross=outcrossdfa ;
 priors proportional;
 id filename;
 class reg; 
 VAR dim1--dim5 ;
RUN;
ods trace off;
ods html close; 

ods output PostCrossVal=postcrossval;
PROC DISCRIM DATA=&project._comparison_all crossvalidate crosslist  ;
 priors proportional;
 id filename;
 class reg; 
 VAR dim1--dim5 ;
RUN;

DATA temp; set postcrossval; 
where Fromreg="spo"; 
where also Intoreg EQ "spo";
run;

proc means data=temp  mean min max stddev; var spo  ; run;

PROC EXPORT
  DATA= WORK.postcrossval
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/&project._comparison_postcrossval.csv"
  REPLACE;
RUN;

ods output ClassifiedCrossVal=temp;
PROC DISCRIM DATA=&project._comparison_all crossvalidate crosslist  ;
 priors proportional;
 class reg; 
 VAR dim1--dim5 ;
RUN;	

PROC EXPORT
  DATA= WORK.temp
  DBMS=CSV
  OUTFILE="&whereisit/&myfolder/&project._comparison_confusion.csv"
  REPLACE;
RUN;

ods html file='&whereisit/&myfolder/&project._comparison_anova.html'; 
%macro create(howmany);
%do i=1 %to &howmany;
proc ANOVA data=&project._comparison_all plots=none;
	title ANOVA for dataset = &project._comparison_all dim&i ;
	class reg;
	model dim&i = reg;
	means reg ;
	run;
title;
%end;
%mend create;
%create( 5 ) /* number of dims  */
quit;
ods html close;

proc means data=&project._comparison_all n sum mean min max stddev; 
by reg;
var dim1--dim5 ; 
run;

/* mixed models for random effect of institution */


proc mixed data=&project._scores covtest;
      class countrycode locale native gender 
      age years_english years_eng_u 
      mo_eng_sp_cou essaytype conditions 
      exam titlecode profb1 profc2 profc1 
      ;
      model f1 = countrycode;
      random locale native gender 
      age years_english years_eng_u 
      mo_eng_sp_cou essaytype conditions 
      exam titlecode profb1 profc2 profc1
      ;
run;











