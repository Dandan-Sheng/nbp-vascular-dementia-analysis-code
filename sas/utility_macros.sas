
/*简短宏程序*/
%macro fas(ds);
data &ds;set  fxk.&ds;if fas='Y';run;
%mend;

%macro PPS(ds);
data &ds.p;set  fxk.&ds;if PPS='Y';run;
%mend;

%macro ss(ds);
data &ds.s;set  fxk.&ds;if ss='Y';run;
%mend;
 
  

%macro report(ds);
proc report data=&ds.;
format SITEID best.;
run;
%MEND;


%macro fass(ds);
data &ds;set  &ds;if fas='Y';run;
%mend;

%macro PPSs(ds);
data &ds.p;set  &ds;if PPS='Y';run;
%mend;

%macro sss(ds);
data &ds.s;set  &ds;if ss='Y';run;
%mend;

%macro num(var);
&var._n=&var.*1;
%mend;

%macro sort(ds);
proc sort data=fxk.&ds.;by USUBJIDc  ;run;
%mend;

%macro sortw(ds);
proc sort data=&ds.;by USUBJIDc  ;run;
%mend;

%macro sortv(ds);
proc sort data=&ds.;by USUBJIDc  visitnum_n;run;
%mend;

%macro sortvw(ds,vn);
proc sort data=&ds.;by USUBJIDc descending &vn.;run;
%mend;
 
%macro NODUP(ds);
proc sort data=&ds. nodupkey out=&ds.QC;
  by USUBJIDc;
run;
%mend;

/*直接合并adsl-单访视*/
%MACRO MERGEDS(DS);
%fass(&DS.);
%ss(adsl);
%SORTW(&DS.);
%SORTW(adsls);

data &DS;
  merge &DS.  adsls(keep=siteid--treat itt--ss);
  by USUBJIDc;
run;
%ssS(&DS);
%fasS(&DS);
%ppss(&DS);
%MEND;

%MACRO MERGEDSs(DS);
%sss(&DS.);
%ss(adsl);
%SORTW(&DS.s);
%SORTW(adsls);

data &DS.s;
  merge &DS.s  adsls(keep=siteid--treat itt--ss);
  by USUBJIDc;
  if ss='Y';
run;
%MEND;
  
%MACRO cfvisit5(xh,ds,nu);
%do i=1 %to &nu. %by 4;
data &ds._&i.;
set  ad&ds.;
if &xh.*1=&i.;
run;
%MERGEDS(&ds._&i.);
%sss(&ds._&i);
%fass(&ds._&i);
%ppss(&ds._&i);
%end;
%MEND;
 

%MACRO cfvisit555(xh,ds,nu);
%do i=1 %to &nu. %by 1;
data &ds._&i.;
set  ad&ds.;
if &xh.*1=&i.;
run;
%MERGEDS(&ds._&i.);
%sss(&ds._&i);
%fass(&ds._&i);
%ppss(&ds._&i);
%end;
%MEND;


%MACRO cfvisit5ss(xh,ds,nu);
%do i=1 %to &nu. %by 4;
data &ds._&i.;
set  ad&ds.;
if &xh.*1=&i.;
run;
%MERGEDSs(&ds._&i.);
%end;
%MEND;
 



%MACRO cfvisitxmrz(xh,ds,nu);
%do i=0 %to &nu.  ;
data &ds.&i.;
set  &ds.;
if &xh.*1=&i.;
run;

proc sort data=adslzz ;
by USUBJIDc VISITNUM;
run;
proc sort data=&ds.&i. ;
by USUBJIDc VISITNUM;
run; 
data &ds.&i.;
merge &ds.&i. adslzz(keep=siteid--VISITNUM itt--ss)  ;
by USUBJIDc VISITNUM;
if VISITNUM in (0 3 5);
run;

%end;
%MEND;


%MACRO cfvisitxm(xh,ds,nu);
%do i=1 %to &nu.  ;
data &ds.&i.;
set  &ds.;
if &xh.*1=&i.;
run;
%end;
%MEND;


%MACRO cfvisit2(xh,ds,nu);
%do i=2 %to &nu.  ;
data &ds._&i.;
set  ad&ds.;
if &xh.*1=&i.;
run;
%MERGEDS(&ds._&i.);
%sss(&ds._&i);
%fass(&ds._&i);
%ppss(&ds._&i);
%end;
%MEND;



%MACRO cfvisit15(xh,ds,nu);
%do i=1 %to &nu.  ;
data &ds._&i.;
set  ad&ds.;
if &xh.*1=&i.;
run;
%MERGEDS(&ds._&i.);
%sss(&ds._&i);
%fass(&ds._&i);
%ppss(&ds._&i);
%end;
%MEND;


%MACRO cfvisit15ss(xh,ds,nu);
%do i=0 %to &nu.  ;
data &ds._&i.;
set  ad&ds.;
if &xh.*1=&i.;
run;
%MERGEDSs(&ds._&i.);
/*%sss(&ds._&i);*/
%end;
%MEND;


%MACRO cfvisit135(xh,ds,nu);
%do i=1 %to &nu. %by 2 ;
data &ds._&i.;
set  &ds.;
if &xh.*1=&i.;
run;
%MERGEDS(&ds._&i.);
%sss(&ds._&i);
%fass(&ds._&i);
%ppss(&ds._&i);
%end;
%MEND;

 


%MACRO cfvisit0(xh,ds,nu);
%do i=0 %to &nu.  ;
data &ds._&i.;
set  ad&ds.;
if &xh.*1=&i.;
run;
%MERGEDS(&ds._&i.);
%sss(&ds._&i);
%fass(&ds._&i);
%ppss(&ds._&i);
%end;
%MEND;


%MACRO cfvisit0ss(xh,ds,nu);
%do i=0 %to &nu.  ;
data &ds._&i.;
set  ad&ds.;
if &xh.*1=&i.;
run;
%MERGEDSs(&ds._&i.);
/*%sss(&ds._&i);*/
%end;
%MEND;



%MACRO cfvisit0d(xh,ds,nu);
%do i=0 %to &nu.  ;
data &ds._&i.;
set  &ds.;
if &xh.*1=&i.;
run;
%MERGEDS(&ds._&i.);
%sss(&ds._&i);
%fass(&ds._&i);
%ppss(&ds._&i);
%end;
%MEND;


%MACRO cfvisitt(ds);
data &ds._2 &ds._10;
set  ad&ds.;
if uptseq=2 then output  &ds._2;
if uptseq=10 then output  &ds._10;
run;
%sss(&ds._10);
%fass(&ds._2);
%MEND;


/*合并外部数据文件再合并adsl*/
%MACRO MERGEWD(DS);
DATA &DS.1;
retain USUBJIDc;
length USUBJIDc $20.;
format USUBJIDc $20.;
informat USUBJIDc $20.;
  SET &DS.;
/*  label USUBJIDc=受试者筛选号;*/
proc sort  ;
  by USUBJIDc;
run;

%sortw(adsl);
%ss(adsl);

data &DS.1;
  retain SITEID USUBJIDc   treat  fas pps  ss    ;
  merge &DS.1  adsls ;
  by USUBJIDc;
run;
%sss(&DS.1);
%fasS(&DS.1);
%MEND;

 /*proc contents data=addm(keep=_numeric_) varnum;*/
/*run;*/


%MACRO cfvisitfp(xh,ds,nu);
%do i=1 %to &nu.;
data &ds._&i.;
set  &ds.;
if &xh.=&i.;
if ss='Y';
run;
%MERGEDS(&ds._&i.);
%fass(&ds._&i.h);
%ppss(&ds._&i.h);
%end;
%MEND;


%MACRO mergefc(ds1);
%sortw(&ds1.);
%sortw(adcdr0qc);
%sortw(adslfc);
%sortw(addm);

data &ds1.;
merge &ds1. adcdr0qc(keep=USUBJIDc cdrtsco  cdrtsco_u servfcc servfc) adslfc  addm(keep=USUBJIDc AGE);
  by USUBJIDc;
run;
%fass(&ds1.);
%MEND;



%MACRO mergefctc(ds1);
%sortw(&ds1.);
%sortw(addsfz);

data &ds1.;
merge &ds1. addsfz(keep=USUBJIDc treatf );
  by USUBJIDc;
run;
%sss(&ds1.);
%MEND;




%MACRO mergefcs(ds1);
%sortw(&ds1.);
%sortw(adcdr0qc);
%sortw(adslfc);
%sortw(addms);

data &ds1.;
merge &ds1. adcdr0qc(keep=USUBJIDc cdrtsco  cdrtsco_u servfcc servfc) adslfc addms(keep=USUBJIDc AGE);
  by USUBJIDc;
run;
%sss(&ds1.);
%MEND;


%macro locf(var);
retain locf_&var.;
&var.ys=&var.;
if missing(&var.) and first.USUBJIDc then locf_&var.=.;
else if not missing(&var.) then locf_&var.=&var.;
else &var.=locf_&var.;
%mend;

 
