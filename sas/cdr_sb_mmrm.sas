 
%macro mixed_model_report22(dsn=  ,yvar=,varjx=,fas_pps= ,project= ,order= ,ref_treat=);
ods select none;
ods output diffs= diffs  LSMeans= LSMeans;
proc mixed alpha=.05 method=reml  covtest data= &dsn. ;
class USUBJIDc treat(ref="&ref_treat.") VISITNUM(ref='0')  siteidhb1 servfcc ;
model &yvar.=treat visitnum age  &varjx. siteidhb1 servfcc  treat*visitnum  &varjx.*visitnum  /s ;
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
 
 
proc delete data=output2;run;    /*注意：运行该宏前必须运行该语句*/
%mixed_model_report22(dsn=Adcdr3 ,yvar=dfscore1,varjx=cdrjx,fas_pps=fas ,project=	治疗13周较基线变化值_CDR评分	,order=2,ref_treat= 对照组 )     
%mixed_model_report22(dsn=Adcdr3p,yvar=dfscore1,varjx=cdrjx,fas_pps=pps ,project=	治疗13周较基线变化值_CDR评分	,order=2,ref_treat= 对照组 )     
		
%mixed_model_report22(dsn=Adcdr3 ,yvar=dfscore1,varjx=cdrjx,fas_pps=fas ,project=	治疗26周较基线变化值_CDR评分	,order=3,ref_treat= 对照组 )     
%mixed_model_report22(dsn=Adcdr3p,yvar=dfscore1,varjx=cdrjx,fas_pps=pps ,project=	治疗26周较基线变化值_CDR评分	,order=3,ref_treat= 对照组 )     
		
%mixed_model_report22(dsn=Adcdr3 ,yvar=dfscore1,varjx=cdrjx,fas_pps=fas ,project=	治疗39周较基线变化值_CDR评分	,order=4,ref_treat= 对照组 )     
%mixed_model_report22(dsn=Adcdr3p,yvar=dfscore1,varjx=cdrjx,fas_pps=pps ,project=	治疗39周较基线变化值_CDR评分	,order=4,ref_treat= 对照组 )     
		
%mixed_model_report22(dsn=Adcdr3 ,yvar=dfscore1,varjx=cdrjx,fas_pps=fas ,project=	治疗52周较基线变化值_CDR评分	,order=5,ref_treat= 对照组 )     
%mixed_model_report22(dsn=Adcdr3p,yvar=dfscore1,varjx=cdrjx,fas_pps=pps ,project=	治疗52周较基线变化值_CDR评分	,order=5,ref_treat= 对照组 )     


%mixed_model_report22(dsn=Adcdr3 ,yvar=dfscore2,varjx=cdrsbtjx,fas_pps=fas ,project=	治疗13周较基线变化值_CDR -SB评分,order=2,ref_treat= 对照组 )     
%mixed_model_report22(dsn=Adcdr3p,yvar=dfscore2,varjx=cdrsbtjx,fas_pps=pps ,project=	治疗13周较基线变化值_CDR -SB评分,order=2,ref_treat= 对照组 )     
		
%mixed_model_report22(dsn=Adcdr3 ,yvar=dfscore2,varjx=cdrsbtjx,fas_pps=fas ,project=	治疗26周较基线变化值_CDR -SB评分,order=3,ref_treat= 对照组 )     
%mixed_model_report22(dsn=Adcdr3p,yvar=dfscore2,varjx=cdrsbtjx,fas_pps=pps ,project=	治疗26周较基线变化值_CDR -SB评分,order=3,ref_treat= 对照组 )     
		
%mixed_model_report22(dsn=Adcdr3 ,yvar=dfscore2,varjx=cdrsbtjx,fas_pps=fas ,project=	治疗39周较基线变化值_CDR -SB评分,order=4,ref_treat= 对照组 )     
%mixed_model_report22(dsn=Adcdr3p,yvar=dfscore2,varjx=cdrsbtjx,fas_pps=pps ,project=	治疗39周较基线变化值_CDR -SB评分,order=4,ref_treat= 对照组 )     
		
%mixed_model_report22(dsn=Adcdr3 ,yvar=dfscore2,varjx=cdrsbtjx,fas_pps=fas ,project=	治疗52周较基线变化值_CDR -SB评分,order=5,ref_treat= 对照组 )     
%mixed_model_report22(dsn=Adcdr3p,yvar=dfscore2,varjx=cdrsbtjx,fas_pps=pps ,project=	治疗52周较基线变化值_CDR -SB评分,order=5,ref_treat= 对照组 )     

title j=l '(*ESC*)S={fontstyle=roman}表6.3.15.5.	治疗CDR评分较基线变化值的最小二乘均数-校正模型2';
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

  
