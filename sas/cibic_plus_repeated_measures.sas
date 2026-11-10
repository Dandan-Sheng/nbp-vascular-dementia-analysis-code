 
%macro mixed_model_report21(dsn= ,yvar=,label=,fas_pps=);
ods select none;
ods output tests3=tests3;
/*REML 是 SAS PROC MIXED 的默认设置，通常更容易收敛且结果更无偏*/
proc mixed alpha=.05 method=reml  covtest data=  &dsn.;
class USUBJIDc  treat(ref="对照组") VISITNUM(ref='2') siteidhb1 servfcc ;
model &yvar.=treat visitnum age   siteidhb1 servfcc   treat*visitnum    /s ;   /* 为基线水平*/
repeated  visitnum/type=AR(1) subject= USUBJIDc r ;/*type=AR(1) 核心逻辑： “远亲不如近邻” ;它假设随着时间的推移，相关性会逐渐衰减。 AR(1) 假设访视的时间间隔是固定的*/
format treat GROUP_FMT.;
run;
ods select all;

data report1;
 set tests3 ;
length fas_pps project $ 80;
fas_pps="%upcase(&fas_pps)";
 if lowcase(Effect)='treat' then project='     研究分组';
  else  if lowcase(Effect)='visitnum' then project='   随访';
   else  if lowcase(Effect)='age' then project='   年龄';  
	else  if lowcase(Effect)='siteidhb1' then project='      中心';
     else  if lowcase(Effect)='servfcc' then project='      分层_血管性痴呆程度';
      else  if lowcase(Effect)='treat*visitnum' then project='研究分组与随访交互效应';
run;

data report1;
set report1;
label="&label.";
run;

proc append base=output1 data=report1 force;run;
%mend;

 
proc delete data=output1;run;    
%mixed_model_report21(dsn=adCIBICz ,yvar=cicgra1_un,label=照料者,fas_pps=FAS)    /*分析 FAS 数据集*/
%mixed_model_report21(dsn=adCIBICzp,yvar=cicgra1_un,label=照料者,fas_pps=PPS)    /*分析 PPS 数据集*/

%mixed_model_report21(dsn=adCIBICz ,yvar=cicgra2_un,label=受试者,fas_pps=FAS)    /*分析 FAS 数据集*/
%mixed_model_report21(dsn=adCIBICzp,yvar=cicgra2_un,label=受试者,fas_pps=PPS)    /*分析 PPS 数据集*/

%mixed_model_report21(dsn=adCIBICz ,yvar=cicgra3_un,label=总体,fas_pps=FAS)    /*分析 FAS 数据集*/
%mixed_model_report21(dsn=adCIBICzp,yvar=cicgra3_un,label=总体,fas_pps=PPS)    /*分析 PPS 数据集*/

title j=l '(*ESC*)S={fontstyle=roman}表6.3.4.1.	CIBIC-plus的评分最小二乘均数的混合效应模型估计情况-照料者';
proc report data=output1 nowd 
style(report)={just=l fontsize=0.38cm cellpadding=0 cellspacing=0 outputwidth=100%}
style(header)={font_style=roman just=l  fontsize=0.38cm }  style(column)={just=l  fontsize=0.38cm }  ;

column label project fas_pps,(FValue ProbF);
define label/group '项目'  ;
define project/group '指标' order=internal;
define fas_pps/across ' ' style={just=c};
define FValue/ format=8.3 '统计量F' ;
define ProbF/ format=pvalue8.3  'P值' ;
run;
title;
  
%macro mixed_model_report22(dsn= ,yvar=,fas_pps= ,project= ,order= ,ref_treat=);
ods select none;
ods output diffs= diffs  LSMeans= LSMeans;
proc mixed alpha=.05 method=reml  covtest data= &dsn. ;
class USUBJIDc treat(ref="&ref_treat.") VISITNUM(ref='2')  siteidhb1 servfcc ;
model &yvar.=treat visitnum age   siteidhb1 servfcc  treat*visitnum   /s ;
repeated  visitnum/type=AR(1) subject= USUBJIDc r ;
lsmeans treat * visitnum / diff slice=visitnum cl alpha=.05; 
format treat GROUP_FMT.;
run;
ods select all;

data part1;
 set LSMeans;
 where VISITNUM=5;
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
 where VISITNUM=5 and _VISITNUM=5;
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

proc delete data=output2;run;    /*注意：运行该宏前必须运行该语句*/
%mixed_model_report22(dsn=adCIBICz ,yvar=cicgra1_un,fas_pps=fas ,project= CIBIC-plus的评分-照料者,order=1,ref_treat= 对照组 )     
%mixed_model_report22(dsn=adCIBICzp,yvar=cicgra1_un,fas_pps=pps ,project= CIBIC-plus的评分-照料者,order=1,ref_treat= 对照组 )     

%mixed_model_report22(dsn=adCIBICz ,yvar=cicgra2_un,fas_pps=fas ,project= CIBIC-plus的评分-受试者,order=2,ref_treat= 对照组 )     
%mixed_model_report22(dsn=adCIBICzp,yvar=cicgra2_un,fas_pps=pps ,project= CIBIC-plus的评分-受试者,order=2,ref_treat= 对照组 )     

%mixed_model_report22(dsn=adCIBICz ,yvar=cicgra3_un,fas_pps=fas ,project= CIBIC-plus的评分-总体,order=3,ref_treat= 对照组 )     
%mixed_model_report22(dsn=adCIBICzp,yvar=cicgra3_un,fas_pps=pps ,project= CIBIC-plus的评分-总体,order=3,ref_treat= 对照组 )     

title j=l '(*ESC*)S={fontstyle=roman}表6.3.4.2.	CIBIC-plus的评分最小二乘均数';
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

 


/*******************************************报表二*************************************************/
%macro mixed_model_report22(dsn= ,yvar=,fas_pps= ,project= ,order= ,ref_treat=);
ods select none;
ods output diffs= diffs  LSMeans= LSMeans;
proc mixed alpha=.05 method=reml  covtest data= &dsn. ;
class USUBJIDc treat(ref="&ref_treat.") VISITNUM(ref='2')  siteidhb1 servfcc ;
model &yvar.=treat visitnum age   siteidhb1 servfcc  treat*visitnum   /s ;
repeated  visitnum/type=AR(1) subject= USUBJIDc r ;
lsmeans treat * visitnum / diff slice=visitnum cl alpha=.05; 
format treat GROUP_FMT.;
run;
ods select all;

data part1;
 set LSMeans;
 where VISITNUM=3;
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
 where VISITNUM=3 and _VISITNUM=3;
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
 
proc delete data=output2;run;    /*注意：运行该宏前必须运行该语句*/
%mixed_model_report22(dsn=adCIBICz ,yvar=cicgra1_un,fas_pps=fas ,project= CIBIC-plus的评分-照料者,order=1,ref_treat= 对照组 )     
%mixed_model_report22(dsn=adCIBICzp,yvar=cicgra1_un,fas_pps=pps ,project= CIBIC-plus的评分-照料者,order=1,ref_treat= 对照组 )     

%mixed_model_report22(dsn=adCIBICz ,yvar=cicgra2_un,fas_pps=fas ,project= CIBIC-plus的评分-受试者,order=2,ref_treat= 对照组 )     
%mixed_model_report22(dsn=adCIBICzp,yvar=cicgra2_un,fas_pps=pps ,project= CIBIC-plus的评分-受试者,order=2,ref_treat= 对照组 )     

%mixed_model_report22(dsn=adCIBICz ,yvar=cicgra3_un,fas_pps=fas ,project= CIBIC-plus的评分-总体,order=3,ref_treat= 对照组 )     
%mixed_model_report22(dsn=adCIBICzp,yvar=cicgra3_un,fas_pps=pps ,project= CIBIC-plus的评分-总体,order=3,ref_treat= 对照组 )     

title j=l '(*ESC*)S={fontstyle=roman}表6.3.4.2.	26周CIBIC-plus的评分最小二乘均数';
proc report data=output2  nowd SPANROWS
style(report)={just=l fontsize=0.38cm cellpadding=0 cellspacing=0 outputwidth=170%}
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

 
 
