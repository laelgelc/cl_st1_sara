[14/08/26, 13:28:09] eyamrog: Hi, Professor Tony! I hope you are doing well. I'm working on Sara's project, involving TMDA for English texts. Could you please share the following items with me?:
- The SAS script that excludes Biber 1988's dimensions;
- A reference project for TMDA.
Many thanks for your help, and have a wonderful day! ❤️☺️🙏

[14/08/26, 13:47:51] Tony Berber Sardinha: Hi Rogerio, good morning/afternoon! This SAS program below runs a full factorial analysis on Biber tagged counts after excluding the dim1-5 vars that reflect the scores on the 1988 dimensions.

[14/08/26, 13:48:18] Tony Berber Sardinha: md_coursebooks.sas document omitted

[14/08/26, 13:48:33] Tony Berber Sardinha: this step does that:

```text
DATA &project (drop=   dim1-dim5 pub_vb prv_vb );
SET observed;
RUN;
```

[14/08/26, 13:48:49] Tony Berber Sardinha: the sum vars are then excluded too:

[14/08/26, 13:49:03] Tony Berber Sardinha:

```text
/* drop sum variables  */

DATA &project._no_sum_v (DROP = all_advl all_jth all_jto all_nth all_th all_to all_vth all_vto alladj allconj allmodal allpasv allpro allverb allwh allwhrel n );
SET &project ;
RUN;
```

[14/08/26, 13:49:37] Tony Berber Sardinha: but these are evaluated later after the factor extraction to see if it’s better to put them back in in place of non-sum vars:

[14/08/26, 13:50:08] Tony Berber Sardinha:

```text
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
```

[14/08/26, 13:50:50] Tony Berber Sardinha: by ‘a reference project for TMDA,’ do you mean the slides? Because the SAS program is above

[14/08/26, 13:51:12] Tony Berber Sardinha: coursebooks.pdf • 61 pages document omitted