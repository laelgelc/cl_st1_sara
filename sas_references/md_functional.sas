/* BEGINNING PART 1 */
/* === EDIT BELOW ====*/

/* account: CEPRIL */

%let project = md_coursebooks ;

%let myfolder = &project ;

%let sasusername = u61738292 ;

%let whereisit = /home/&sasusername ;   /* online */

options fmtsearch=(work library);

/* enter number of factors to extract */
%let extractfactors = 5 ;

%let factorvars = fac1-fac&extractfactors ;

/* additive factor scores */
%let addfactorvars = add_fac1-add_fac&extractfactors ;

/* enter min loading cutoff */
%let minloading = .3 ;

/* enter min communality cutoff */
%let communalcutoff = .15 ;


DATA observed ;
INFILE "&whereisit/&myfolder/counts.txt";
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

PROC EXPORT
  DATA= WORK.observed
  DBMS=TAB
  OUTFILE="&whereisit/&myfolder/observed.tsv"
  REPLACE;
RUN;

DATA &project (drop=   dim1-dim5 pub_vb prv_vb );
SET observed;
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

/* select vars */

data temp ;
set &project._no_sum_v;
if _N_ <= 1 ;
run;
proc transpose data= temp out= rot; 
run;
proc sql ;
    select _name_ into :names separated by ' ' from rot ;
quit;

/* correlation */

proc corr data = &project._no_sum_v out = pearson  noprint;
var &names ;
run;

/* number of observations IN THE DATA */
data _NULL_;
	if 0 then set observed nobs=n;
	call symputx('nobs',n);
	stop;
run;
%put nobs=&nobs ;

/* unrotated, before dropping low communalities */

proc datasets library=work nolist;
delete 
fout;
run;

ODS EXCLUDE NONE;
proc factor fuzz=0.3 data= pearson (type=corr) OUTSTAT= fout NOPRINT
method=principal 
plots=scree
mineigen=1
reorder 
heywood  
nfactors=100  
nobs=&nobs;  /* specify number of obs because this is missing from a corr matrix */
var &names  ;
run;

/* communalities ***/

data fout2;
    set fout (where=(_TYPE_="COMMUNAL"));
run;

proc transpose data=fout2 out=communal; id _TYPE_; run;

/* list vars to drop  */
proc sql ;
    select _name_ into :lowcomm separated by ' ' from communal
        where communal < &communalcutoff   ;
quit;

/* list vars to keep  */

ODS EXCLUDE NONE ;
proc sql NOPRINT;
    select _name_ into :highcomm separated by ' ' from communal
        where communal >= &communalcutoff   ;
quit;

/* save communalities to spreadsheet */

PROC SORT data=communal (keep= _name_ communal);   BY communal ; RUN;

PROC EXPORT
  DATA= WORK.communal
  DBMS=TAB
  OUTFILE="&whereisit/&myfolder/communalities.tsv"
  REPLACE;
RUN;

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

PROC EXPORT
  DATA= WORK.fout4
  DBMS=TAB
  OUTFILE="&whereisit/&myfolder/scree_data.tsv"
  REPLACE;
RUN;


/* create the scree files */

ods listing gpath="&whereisit/&myfolder/";
ods graphics on / reset imagename="scree_1" imagefmt=png;
title "Scree plot";
proc sgplot data= fout4 ;
  series x=factor y=EIGENVAL / markers datalabel=EIGENVAL 
  markerattrs=(symbol = circle color = blue size = 10px);
   xaxis grid values=(1 TO 20) label='Factor';
   yaxis grid label='Eigenvalue';
   refline &extractfactors / axis = x lineattrs = (color = red pattern = dash);
run;
title;

ods listing gpath="&whereisit/&myfolder/";
ods graphics on / reset imagename="scree_2" imagefmt=png;
title "Scree plot";
proc sgplot data= fout4 ;
  series x=factor y=EIGENVAL / markers datalabel=factor
  markerattrs=(symbol = circle color = blue size = 10px);
  yaxis grid label='Eigenvalue';
  xaxis grid values=(1 TO 20) label='Factor';
  refline &extractfactors / axis = x lineattrs = (color = red pattern = dash);
run;
title;

/* rotated without sum variables prior to sum var check*/

proc factor fuzz=0.3 data= pearson (type=corr) OUTSTAT= rotated NOPRINT
method=principal
mineigen=0
nfactors= &extractfactors
rotate=promax
heywood
nobs=&nobs;  /* specify number of obs because this is missing from a corr matrix */
var &highcomm  ;
run;

/* checking sum variables */

data prerotat;
  set rotated (where=(_TYPE_="PREROTAT"));
run;

proc transpose data=prerotat out= rotated2 ;
id _NAME_ ;
run;

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

/* create a dummy variable with a value of communal = 0 to stop the array from throwing an error
   if there were no lowcomm vars in the dataset */

data temp;
   _NAME_ = 'deleteme';
   communal = 0;
   output; /* Output the new observation */
run;

data temp2;
   set communal temp;
run;

proc sql;
    select _name_ into :lowcomm separated by ' ' from temp2
        where communal < &communalcutoff ;
quit;

/* set a value = 0 to low comm vars dropped before to ensure sums are computed */

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

data sumdrop (drop=deleteme vcmp jcmp );  /* vcmp and jcmp are legacy vars, replaced by all_vth and all_jth) */
set sumdrop ;
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

data &project._sum_check ( drop= vcmp jcmp ); /* legacy vars replaced by all_vth and all_jth */
    set &project ;  /* the initial dataset with the sum vars counts */
     drop &sumcheck ;  
run;

/* select vars */

data temp ;
set &project._sum_check ;
if _N_ <= 1 ;
run;
proc transpose data= temp out= rot; 
run;
proc sql ;
    select _name_ into :sumcheck separated by ' ' from rot ;
quit;

/* final rotated after sum var check*/

proc corr data = &project._sum_check out = pearson  noprint;
var &sumcheck ;
run;

proc factor fuzz=0.3 data= pearson (type=corr) OUTSTAT= rotatedfinal NOPRINT
method=principal
mineigen=0
nfactors= &extractfactors
rotate=promax
heywood
nobs=&nobs;  /* specify number of obs because this is missing from a corr matrix */
var &sumcheck  ;
run;

PROC EXPORT
  DATA= work.rotatedfinal
  DBMS=TAB
  OUTFILE="&whereisit/&myfolder/rotatedfinal.tsv"
  REPLACE;
RUN;



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

/*END PART 14*/
/* BEGINNING PART 15*/

/* labeling: https://stats.idre.ucla.edu/sas/modules/labeling/ */

%include "/home/&sasusername/&myfolder/biber_tagcount_labels.sas";
%include "/home/&sasusername/&myfolder/biber_tagcount_labels_full.sas";

OPTIONS VALIDVARNAME=ANY;
data rotated2;
  set rotatedfinal (where=(_TYPE_="PREROTAT"));
run;

proc transpose data=rotated2 out= rotated2 ;
id _NAME_ ;
run;

/* PRIMARY AND SECONDARY LOADINGS */

data abs ;
    set rotated2 ;
    array v Factor1-Factor&extractfactors  ;
    do over v ; 
      v = abs( v ) ; 
    end ;
run;

data primary (KEEP= _NAME_ load  );
set abs ;
 max=largest(1,of Factor1-Factor&extractfactors );
      if max = Factor1 AND max >= &minloading then do; load = 'fac1' ; end ;
 else if max = Factor2 AND max >= &minloading then do; load = 'fac2' ; end ;
 else if max = Factor3 AND max >= &minloading then do; load = 'fac3' ; end ;
 else if max = Factor4 AND max >= &minloading then do; load = 'fac4' ; end ;
 else if max = Factor5 AND max >= &minloading then do; load = 'fac5' ; end ;
 else if max = Factor6 AND max >= &minloading then do; load = 'fac6' ; end ;
 else if max = Factor7 AND max >= &minloading then do; load = 'fac7' ; end ;
 else if max = Factor8 AND max >= &minloading then do; load = 'fac8' ; end ;
 else if max = Factor9 AND max >= &minloading then do; load = 'fac9' ; end ;
 else if max = Factor10 AND max >= &minloading then do; load = 'fac10' ; end ;
run;

data secondary (KEEP= _NAME_ load secondary );
set abs ;
 max=largest(2,of Factor1-Factor&extractfactors );
      if max = Factor1 AND max >= &minloading then do; load = 'fac1' ; secondary = 1 ; end ;
 else if max = Factor2 AND max >= &minloading then do; load = 'fac2' ; secondary = 1 ; end ;
 else if max = Factor3 AND max >= &minloading then do; load = 'fac3' ; secondary = 1 ; end ;
 else if max = Factor4 AND max >= &minloading then do; load = 'fac4' ; secondary = 1 ; end ;
 else if max = Factor5 AND max >= &minloading then do; load = 'fac5' ; secondary = 1 ; end ;
 else if max = Factor6 AND max >= &minloading then do; load = 'fac6' ; secondary = 1 ; end ;
 else if max = Factor7 AND max >= &minloading then do; load = 'fac7' ; secondary = 1 ; end ;
 else if max = Factor8 AND max >= &minloading then do; load = 'fac8' ; secondary = 1 ; end ;
 else if max = Factor9 AND max >= &minloading then do; load = 'fac9' ; secondary = 1 ; end ;
 else if max = Factor10 AND max >= &minloading then do; load = 'fac10' ; secondary = 1 ; end ;
run;

proc sort data=rotated2 ; by _NAME_ ; run;
proc sort data=primary ; by _NAME_ ; run;
proc sort data=secondary ; by _NAME_ ; run;

data temp1 ;
merge rotated2 primary ;
by _NAME_ ;
run;

data temp2 ;
merge rotated2 secondary ;
by _NAME_ ;
run;

data temp3;
set temp2 temp1;
run;

/* loadtable with primary and secondary loadings */

ods html file="&whereisit/&myfolder/loadtable_full.html"; 
%macro create(howmany);
%do i=1 %to &howmany;

title "LOADINGS TABLE";
title2 "Factor &i pos" ;
data temp4;
  set temp3 ;
  where load= "fac&i" and Factor&i >= 0  ;
  if secondary = 1 then do; l = '(' ; r = ')' ; end; 
proc sort;
  by descending Factor&i ;
proc print ; FORMAT _NAME_ $featurelabelsfull.; var l _NAME_ Factor&i r ;
run;

title "Factor &i neg" ;
data temp4;
  set temp3 ;
  where load= "fac&i" and Factor&i < 0  ;
  if secondary = 1 then do; l = '(' ; r = ')' ; end; 
proc sort;
  by  Factor&i ;
proc print ; FORMAT _NAME_ $featurelabelsfull.; var l _NAME_ Factor&i r ;
run;

%end;
%mend create;
%create(&extractfactors) 
ods html close;
quit;

ods html file="&whereisit/&myfolder/loadtable.html"; 
%macro create(howmany);
%do i=1 %to &howmany;

title "LOADINGS TABLE";
title2 "Factor &i pos" ;
data temp4;
  set temp3 ;
  where load= "fac&i" and Factor&i >= 0  ;
  if secondary = 1 then do; l = '(' ; r = ')' ; end; 
proc sort;
  by descending Factor&i ;
proc print ; FORMAT _NAME_ $featurelabels.; var l _NAME_ Factor&i r ;
run;

title "Factor &i neg" ;
data temp4;
  set temp3 ;
  where load= "fac&i" and Factor&i < 0  ;
  if secondary = 1 then do; l = '(' ; r = ')' ; end; 
proc sort;
  by  Factor&i ;
proc print ; FORMAT _NAME_ $featurelabels.; var l _NAME_ Factor&i r ;
run;

%end;
%mend create;
%create(&extractfactors) 
ods html close;
quit;

PROC EXPORT
  DATA= work.temp3
  DBMS=TAB
  OUTFILE="&whereisit/&myfolder/rotated.tsv"
  REPLACE;
RUN;

/* adding metadata */

DATA metadata ;
  INFILE "/home/&sasusername/&myfolder/metadata.txt" ;
  length filename $ 10  level $ 8 code $ 8 register $ 18;
  input filename $  level $ code $ register $ ;
  proc sort; by filename ;
RUN;

data observed_meta ;
merge observed (in=a) metadata (in=b) ;
by filename;
proc sort; by filename;
run;

/* scoring */

ODS EXCLUDE NONE;
ods html file="&whereisit/&myfolder/scoring.html"; 
proc print data=rotated3 ; run;
ods html close; 
ODS EXCLUDE ALL;

/* automatic scoring */

/* standardize data */

PROC STANDARD DATA=observed_meta MEAN=0 STD=1 OUT=mdz; var _NUMERIC_  ; RUN;

/* factor scores */

/* the vars are all listed in a single column, so no need to rotate */

proc datasets library=work nolist;
delete 
fout fout2 fout3 fout4 ;
run;

/*begin macro*/
%macro create(howmany);
%do i=1 %to &howmany;

data fac&i.p;
  set temp3 ;
  where load= "fac&i" and Factor&i >= 0  ;
  pole = 1;
run;

data fac&i.n;
  set temp3 ;
  where load= "fac&i" and Factor&i < 0  ;
  pole = -1;
run;

%end;
%mend create;
%create(&extractfactors) 
quit;
/* end macro */

proc sql NOPRINT;
    select memname into :names separated by ' ' from dictionary.tables 
    where libname = 'WORK' AND  memname like "FAC%"  ;
quit;

/* discard variables loading as secondary to compute factor scores */
data poles ;
set &names ;
if secondary NE 1;
run;

proc transpose data=poles out=score;
  by load ;
  id _NAME_ ;
  var pole;
run;

data score;
  _type_='SCORE';
  set score;
  drop _name_;
  rename load=_name_;
run;

proc score data=mdz score=score out=scores; run;

data scores_only 
(keep =  filename level register &factorvars ) ; 
set scores ; 
run;

/* inter-factor correlations */

ods html file="&whereisit/&myfolder/interfactor_corr.html"; 
proc corr data=scores ;
var &factorvars ;
run;
ods html close; 

/* Overview of corpus */


ODS EXCLUDE NONE;
ods html file="&whereisit/&myfolder/overview.html"; 
proc sort data=observed_meta; by level; run;
PROC FREQ data=observed_meta; 
TABLES level ;
RUN;
proc sort data=observed_meta; by register; run;
PROC FREQ data=observed_meta; 
TABLES register ;
RUN;
ods html close;

ODS EXCLUDE NONE;
ods html file="&whereisit/&myfolder/corpus_size.html"; 
proc sort data=observed_meta; by level; run;
proc means data=observed_meta n sum mean min max stddev ; var wcount  ; class level ; run;
RUN;
proc sort data=observed_meta; by register; run;
proc means data=observed_meta n sum mean min max stddev ; var wcount  ; class register ; run;
RUN;
ods html close;

PROC EXPORT
  DATA= WORK.scores
  DBMS=TAB
  OUTFILE="&whereisit/&myfolder/scores.tsv"
  REPLACE;
RUN;

PROC EXPORT
  DATA= WORK.scores_only
  DBMS=TAB
  OUTFILE="&whereisit/&myfolder/scores_only.tsv"
  REPLACE;
RUN;


/* GLM Analysis of variance */

/* begin macro */
ods html file="&whereisit/&myfolder/glm_meta.html"; 
%macro create(howmany);
%do i=1 %to &howmany;
ods graphics off; 
%macro repeat_glm(var=);
proc glm data=scores_only;
	title GLM for dataset = &project &var f&i ;
	class &var ;
	model fac&i = &var ;
	means &var ;
ods table FitStatistics=rsq_&var._fac&i;
/*ods table Means=means_&var._fac&i;*/
run;
ods trace off;
%mend repeat_glm;
%repeat_glm(var=level)
%repeat_glm(var=register)
ods graphics on;
%end;
%mend create;
%create( &extractfactors ) /* number of factors extracted */ 
ods html close; 
quit;
/* end macro */

/* save means and std */
ods output summary=means;
proc means data=observed stackodsoutput ;
run;
ods output close;

PROC EXPORT
  DATA= WORK.means
  DBMS=TAB
  OUTFILE="&whereisit/&myfolder/means.tsv"
  REPLACE;
RUN;










/**** ZIP UP THE FILES INTO zip/<this folder>.zip ****/
/* list all files in your directory */

/* name the zip file you want to zip into, e.g. */
%let addcntzip = /home/u61738292/zip/output_&project..zip;

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
/home/u61738292/md_coursebooks
;;;;
run;

data filelist;
  modify filelist;
  rc1=filename('tmp',catx('/',root,dname,filename));
  rc2=dopen('tmp');
  dir = 1 & rc2;
  if dir then 
    do;
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

/* print out files list too see if you have all you want */
proc print data=filelist;
run;

data _null_;

  set filelist; /* loop over all files */
  if dir=0;

  rc1=filename("in" , catx('/',root,dname,filename), "disk", "lrecl=1 recfm=n");
  rc1txt=sysmsg();
  rc2=filename("out", "&addcntzip.", "ZIP", "lrecl=1 recfm=n member='" !! catx('/',dname,filename) !! "'");
  rc2txt=sysmsg();

  do _N_ = 1 to 6; /* push into the zip...*/
    rc3=fcopy("in","out");
    rc3txt=sysmsg();
    if fexist("out") then leave; /* if success leave the loop */
    else sleeprc=sleep(0.5,1); /* if fail wait half a second and retry (up to 6 times) */
  end;

  rc4=fexist("out");
  rc4txt=sysmsg();

/* just to see errors */
  put _N_ @12 (rc:) (=);

run;

/* delete all png, html and tsv files, because they've been zipped */

/* Read files in a folder */

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

/* delete files identified in above step */
data _null_;
set filenames;
fname = 'todelete';
rc = filename(fname, quote(cats("&path",'/',memname)));
rc = fdelete(fname);
rc = filename(fname);
run;










