/*=============================================================================
  Table S7: Changes in total WMH volume and brain parenchymal fraction (BPF)

  Purpose
  -------
  Reproduce the visit-specific ANCOVA analyses reported in Table S7.
  Separate models are fitted at Weeks 26 and 52 using observed cases only.

  Models
  ------
  Total WMH volume:
    Change from baseline = treatment + pooled geographic region
                           + baseline WMH volume + baseline ICV

  BPF:
    Change from baseline = treatment + pooled geographic region
                           + baseline BPF

  The adjusted means are least-squares means. The treatment contrast is
  butylphthalide (NBP) minus placebo, with a two-sided 95% confidence interval.
  BPF is already normalized to ICV and therefore baseline ICV is not entered
  separately in the BPF model.

  Software: SAS 9.4
=============================================================================*/

options validvarname=any;

/*
  Set PROJECT_DIR to the extracted package directory before execution.
  The input dataset is supplied separately and is not included in this
  code-only supplement. Create the DATA and OUTPUT subdirectories locally,
  or revise INPUT_CSV and OUTPUT_CSV to point to approved locations.
*/
%let project_dir=.;
%let input_csv=&project_dir.\data\processed_analysis_data.csv;
%let output_csv=&project_dir.\output\table_s7_sas_results.csv;

/* Import the prespecified mITT imaging analysis dataset. */
proc import datafile="&input_csv."
    out=work.mri_raw
    dbms=csv
    replace;
    guessingrows=max;
    getnames=yes;
run;

/*
  Numeric coding fixes the treatment contrast direction:
    TRT=1, butylphthalide (NBP); TRT=2, placebo.
  REGION is NEW_REGION_2 (pooled geographic region).
*/
proc format;
    value trtf 1='Butylphthalide' 2='Placebo';
    value regionf 1='North China' 2='South China';
    value visitf 26='Week 26' 52='Week 52';
run;

data work.mri;
    set work.mri_raw;

    length trt region 8;
    if treatment='Butylphthalide' then trt=1;
    else if treatment='Placebo' then trt=2;

    if pooled_site='North_China' then region=1;
    else if pooled_site='South_China' then region=2;

    format trt trtf. region regionf.;
run;

/* Retain one baseline record per participant and audit any duplicates. */
proc sort data=work.mri(where=(visit='Baseline'))
          out=work.baseline0
          nodupkey
          dupout=work.duplicate_baseline;
    by USUBJID;
run;

data work.baseline;
    set work.baseline0;
    keep USUBJID total_wml_ml bpf_percent icv_ml;
    rename total_wml_ml=base_wmh_ml
           bpf_percent=base_bpf_percent
           icv_ml=base_icv_ml;
run;

proc sort data=work.mri out=work.mri_sorted;
    by USUBJID;
run;

/* Construct the Week 26 and Week 52 changes from baseline. */
data work.table_s7_ana;
    merge work.mri_sorted(in=inpost where=(visit in ('Week 26','Week 52')))
          work.baseline(in=inbase);
    by USUBJID;
    if inpost and inbase;

    if visit='Week 26' then visitn=26;
    else if visit='Week 52' then visitn=52;

    chg_wmh_ml      = total_wml_ml - base_wmh_ml;
    chg_bpf_percent = bpf_percent - base_bpf_percent;

    wmh_complete = (nmiss(chg_wmh_ml, trt, region,
                          base_wmh_ml, base_icv_ml)=0);
    bpf_complete = (nmiss(chg_bpf_percent, trt, region,
                          base_bpf_percent)=0);

    format visitn visitf.;
run;

proc sort data=work.table_s7_ana;
    by visitn;
run;

/*
  QC: expected complete-case counts used in Table S7:
       Week 26: NBP 284, placebo 285
       Week 52: NBP 275, placebo 279
*/
title 'Table S7 complete-case counts';
proc sql;
    select visitn format=visitf., trt format=trtf.,
           sum(wmh_complete) as N_WMH,
           sum(bpf_complete) as N_BPF
    from work.table_s7_ana
    group by visitn, trt
    order by visitn, trt;
quit;
title;

/*
  Total WMH volume: separate ANCOVA model at each visit.
  PROC MIXED contains no RANDOM or REPEATED statement here; it is being used
  as a fixed-effects linear ANCOVA to obtain LS-means and contrast CIs.
*/
ods exclude all;
ods output LSMeans=work.wmh_lsmeans Diffs=work.wmh_diffs;
proc mixed data=work.table_s7_ana(where=(wmh_complete=1))
           method=reml order=internal;
    by visitn;
    class trt region;
    model chg_wmh_ml = trt region base_wmh_ml base_icv_ml
          / solution ddfm=residual;
    lsmeans trt / cl diff;
run;

/* BPF: separate ANCOVA model at each visit; no additional ICV covariate. */
ods output LSMeans=work.bpf_lsmeans Diffs=work.bpf_diffs;
proc mixed data=work.table_s7_ana(where=(bpf_complete=1))
           method=reml order=internal;
    by visitn;
    class trt region;
    model chg_bpf_percent = trt region base_bpf_percent
          / solution ddfm=residual;
    lsmeans trt / cl diff;
run;
ods exclude none;

/* Assemble the adjusted means and the prespecified NBP-minus-placebo contrast. */
proc sql;
    create table work.wmh_result as
    select 1 as measure_order,
           'Total WMH volume (mL)' as MRI_Measure length=40,
           n.visitn,
           n.Estimate as NBP_Adj_Mean,
           n.StdErr as NBP_SE,
           p.Estimate as Placebo_Adj_Mean,
           p.StdErr as Placebo_SE,
           d.Estimate as Difference,
           d.StdErr as Difference_SE,
           d.Lower as Lower_95CI,
           d.Upper as Upper_95CI,
           d.Probt as P_Value
    from work.wmh_lsmeans as n
    inner join work.wmh_lsmeans as p
      on n.visitn=p.visitn and n.trt=1 and p.trt=2
    inner join work.wmh_diffs as d
      on n.visitn=d.visitn and d.trt=1 and d._trt=2
    order by n.visitn;

    create table work.bpf_result as
    select 2 as measure_order,
           'BPF (%ICV; percentage points)' as MRI_Measure length=40,
           n.visitn,
           n.Estimate as NBP_Adj_Mean,
           n.StdErr as NBP_SE,
           p.Estimate as Placebo_Adj_Mean,
           p.StdErr as Placebo_SE,
           d.Estimate as Difference,
           d.StdErr as Difference_SE,
           d.Lower as Lower_95CI,
           d.Upper as Upper_95CI,
           d.Probt as P_Value
    from work.bpf_lsmeans as n
    inner join work.bpf_lsmeans as p
      on n.visitn=p.visitn and n.trt=1 and p.trt=2
    inner join work.bpf_diffs as d
      on n.visitn=d.visitn and d.trt=1 and d._trt=2
    order by n.visitn;
quit;

data work.table_s7_sas_results;
    set work.wmh_result work.bpf_result;
    format visitn visitf.
           NBP_Adj_Mean Placebo_Adj_Mean Difference
           NBP_SE Placebo_SE Difference_SE
           Lower_95CI Upper_95CI 10.3
           P_Value pvalue6.4;
run;

proc sort data=work.table_s7_sas_results;
    by measure_order visitn;
run;

title 'Table S7 ANCOVA results';
proc print data=work.table_s7_sas_results noobs label;
    var MRI_Measure visitn NBP_Adj_Mean NBP_SE
        Placebo_Adj_Mean Placebo_SE Difference Lower_95CI Upper_95CI P_Value;
    label visitn='Timepoint'
          NBP_Adj_Mean='NBP adjusted mean'
          NBP_SE='NBP SE'
          Placebo_Adj_Mean='Placebo adjusted mean'
          Placebo_SE='Placebo SE'
          Difference='NBP minus placebo'
          Lower_95CI='95% CI lower'
          Upper_95CI='95% CI upper'
          P_Value='P value';
run;
title;

proc export data=work.table_s7_sas_results
    outfile="&output_csv."
    dbms=csv
    replace;
run;

