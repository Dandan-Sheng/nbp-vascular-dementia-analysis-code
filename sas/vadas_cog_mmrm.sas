
  
/***************************************报表一********************************************/
%macro mixed_model_report21(dsn= ,fas_pps=);
ods select none;
ods output tests3=tests3;
/*REML 是 SAS PROC MIXED 的默认设置，通常更容易收敛且结果更无偏*/
proc mixed alpha=.05 method=reml  covtest data=  &dsn.;
class USUBJIDc treat(ref="对照组") VISITNUM(ref='1') siteidhb1 servfcc ;
model dfscore=treat visitnum age  score_tjx siteidhb1 servfcc   treat*visitnum  score_tjx*visitnum /s ;   /*score_tjx 为基线水平*/
repeated  visitnum/type=AR(1) subject= USUBJIDc r ;/*type=AR(1) 核心逻辑： “远亲不如近邻” ;它假设随着时间的推移，相关性会逐渐衰减。 AR(1) 假设访视的时间间隔是固定的*/
format treat GROUP_FMT.;
run;
ods select all;

data report1;
 set tests3 ;
length fas_pps project $ 80;
fas_pps="%upcase(&fas_pps)";
if lowcase(Effect)='score_tjx' then project='         基线水平';    /*前面加空格,用于排序*/
else if lowcase(Effect)='treat' then project='     研究分组';
  else  if lowcase(Effect)='visitnum' then project='   随访';
   else  if lowcase(Effect)='age' then project='   年龄';
    else  if lowcase(Effect)='siteidhb1' then project='      中心';
     else  if lowcase(Effect)='servfcc' then project='      分层_血管性痴呆程度';
      else  if lowcase(Effect)='treat*visitnum' then project='研究分组与随访交互效应';
       else  if lowcase(Effect)='score_tjx*visitnum' then project='基线与随访交互效应';
run;

proc append base=output1 data=report1 force;run;
%mend;

/*宏参数说明： 
1)dsn 是分析数据集.  
2)fas_pps 是数据标签,会显示在报表列头,值有 FAS PPS
.*/
proc delete data=output1;run;    /*注意：运行该宏前必须运行该语句*/
%mixed_model_report21(dsn=Advadas3_lo ,fas_pps=FAS)    /*分析 FAS 数据集*/
%mixed_model_report21(dsn=Advadas3_lop ,fas_pps=PPS)    /*分析 PPS 数据集*/

title j=l '(*ESC*)S={fontstyle=roman}表6.3.1.2.	治疗52周VaDAS-cog评分较基线变化值最小二乘均数的混合效应模型估计情况 ';
proc report data=output1 nowd 
style(report)={just=l fontsize=0.38cm cellpadding=0 cellspacing=0 outputwidth=100%}
style(header)={font_style=roman just=l  fontsize=0.38cm }  style(column)={just=l  fontsize=0.38cm }  ;

column  project fas_pps,(FValue ProbF);
define project/group '项目' order=internal;
define fas_pps/across ' ' style={just=c};
define FValue/ format=8.3 '统计量F' ;
define ProbF/ format=pvalue8.3  'P值' ;
run;
title;

/*ods output diffs= diffs  LSMeans= LSMeans;*/
/*proc mixed alpha=.05 method=reml  covtest data= Advadas3_lo;*/
/*class USUBJIDc treat(ref="对照组")  VISITNUM(ref='1')  siteidhb1 servfcc ;*/
/*model dfscore=treat visitnum age  score_tjx siteidhb1 servfcc  treat*visitnum  score_tjx*visitnum  /s ;*/
/*repeated  visitnum/type=AR(1) subject= USUBJIDc r ;*/
/*lsmeans treat * visitnum / diff slice=visitnum cl alpha=.05; */
/*format treat GROUP_FMT.;*/
/*run;*/
 
/*******************************************报表二*************************************************/
%macro mixed_model_report22(dsn= ,fas_pps= ,project= ,order= ,ref_treat=);
ods select none;
ods output diffs= diffs  LSMeans= LSMeans;
proc mixed alpha=.05 method=reml  covtest data= &dsn. ;
class USUBJIDc treat(ref="&ref_treat.") VISITNUM(ref='1')  siteidhb1 servfcc ;
model dfscore=treat visitnum age  score_tjx siteidhb1 servfcc  treat*visitnum  score_tjx*visitnum  /s ;
repeated  visitnum/type=AR(1) subject= USUBJIDc r ;
lsmeans treat * visitnum / diff slice=visitnum cl alpha=.05; 
format treat GROUP_FMT.;
run;
ods select all;

data part1;
 set LSMeans;
 where VISITNUM=&order.;
 length __project __ind __fas_pps $ 200;
 __project="&project.";
 __id=1;
 __ind='Lsmeans(SE)';
 __fas_pps="%upcase(&fas_pps.)";
 __treat=put(treat,$GROUP_FMT.);
 __value=cats(put(Estimate,8.3),'(',put(StdErr,8.3),')');
 output;

 __id=2;
 __ind='95%CI';
 __value=cats(put(Lower,8.3),',',put(Upper,8.3));
 output;
 keep __:;
run;
data part2;
 set diffs;
 where VISITNUM=&order. and _VISITNUM=&order.;
 length __project __ind __fas_pps $ 200;
 __project="&project.";

 __id=3;
 __ind='Lsmean组间差(SE)';
 __fas_pps="%upcase(&fas_pps.)";
 __treat=put(treat,$GROUP_FMT.);
 __value=cats(put(Estimate,8.3),'(',put(StdErr,8.3),')');
 output;

  __id=4;
 __ind='Lsmean组间差95%CI';
 __fas_pps="%upcase(&fas_pps.)";
 __treat=put(treat,$GROUP_FMT.);
 __value=cats(put(Lower,8.3),',',put(Upper,8.3));
 output;

 __id=5;
 __ind='P值';
 __value=put(Probt,8.3 -l);
 output;
 keep __:;
run;

data report2;
 __order=&order.;
 set part1 part2;
run;

proc append base=output2 data=report2 force;run;
%mend;

/*宏参数说明： 
1)dsn 是分析数据集.  
2)fas_pps 是数据标签,会显示在报表列头,值有 FAS PPS
3)project 项目名称. 是报表中第一列的值. 注意： FAS和PPS的 值必须一样 .
4)order   顺序值. 用于调正project的顺序. 注意： 和 project 保持一致.
5)ref_treat  参考组别. 是组别变量format后的值. 
*/
proc delete data=output2;run;    /*注意：运行该宏前必须运行该语句*/
%mixed_model_report22(dsn=Advadas3_lo ,fas_pps=fas ,project= 治疗13周较基线变化值,order=2,ref_treat= 对照组 )     
%mixed_model_report22(dsn=Advadas3_lop ,fas_pps=pps ,project= 治疗13周较基线变化值,order=2,ref_treat= 对照组 )     

%mixed_model_report22(dsn=Advadas3_lo ,fas_pps=fas ,project= 治疗26周较基线变化值,order=3,ref_treat= 对照组 )     
%mixed_model_report22(dsn=Advadas3_lop ,fas_pps=pps ,project= 治疗26周较基线变化值,order=3,ref_treat= 对照组 )     

%mixed_model_report22(dsn=Advadas3_lo ,fas_pps=fas ,project= 治疗39周较基线变化值,order=4,ref_treat= 对照组 )     
%mixed_model_report22(dsn=Advadas3_lop ,fas_pps=pps ,project= 治疗39周较基线变化值,order=4,ref_treat= 对照组 )     

%mixed_model_report22(dsn=Advadas3_lo ,fas_pps=fas ,project= 治疗52周较基线变化值,order=5,ref_treat= 对照组 )     
%mixed_model_report22(dsn=Advadas3_lop ,fas_pps=pps ,project= 治疗52周较基线变化值,order=5,ref_treat= 对照组 )     

title j=l '(*ESC*)S={fontstyle=roman}表6.3.1.2.	治疗52周VaDAS-cog评分较基线变化值最小二乘均数';
proc report data=output2  nowd SPANROWS
style(report)={just=l fontsize=0.38cm cellpadding=0 cellspacing=0 outputwidth=100%}
style(header)={font_style=roman just=l  fontsize=0.38cm }  style(column)={just=l  fontsize=0.38cm }  ;

column __order __project __id __ind __value,__fas_pps,__treat;
define __order/group noprint;
define __project/group '项目';
define __id/group order=internal noprint;
define __ind/group '指标';
define __fas_pps/across ' '  style={just=c};
define __treat/across ' '  descending;
define __value/group ' ';
run;
title;
 
