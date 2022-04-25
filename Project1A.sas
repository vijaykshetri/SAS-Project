proc import datafile = '/home/u60027465/sasuser.v94/project1/ADSL.xlsx'
out= dm
dbms= xlsx
replace;
getnames = yes;
run;

data dm1 (keep = usubjid age  Sex race ethnic Agegr1 trt01a Pltcnt);
 set dm;
 where ittfl = "Y";

 if trt01a = "Drug A" then trt01a= "DrugA";
 run;
 
 data dm2;
 set dm1;
 output;
 trt01a = "Total";
 output;
 run;
 
 proc means data= dm2  ;
 var age;
 class trt01a;
 output out= dm3(drop= _type_ _freq_ )
 n = _n
 mean = _mean
 median = _median
 std = _std
 min = _min
 max = _max
 ;
 run;
 
 data dm4;
 length n  mean median  minmax  std $30;
  set dm3;
  N = put(_n,4.);
  Mean = put(_mean, 2.);
  Median = put(_median,2.);
  minmax = put(_min,4.)||","||put(_max,4.);
  std = put(_std,6.1);
  if trt01a ne " ";
  drop _n _mean _median _std _min _max;
  run;
 
 /* transpose */
proc sort data = dm4 out= dm5;
by trt01a;
run;
 
 proc transpose data= dm5 out=dm6;
 id trt01a;
 var n mean median minmax std;
 run;
 /* change the case of variable name */
data dm7;
length _name_ $50;
set dm6;
if _NAME_ = "n" then _NAME_ = "N";
if _NAME_ = "mean" then _NAME_ = "MEAN";
if _NAME_ = "median" then _NAME_ = "MEDIAN";
if _NAME_ = "minmax" then _NAME_ = "MIN , MAX";
if _NAME_ = "std" then _NAME_ ="STANDARD DEVIATION";
RUN;

/* giving variable name age */
 data dm8;
 LENGTH _name_  $50;
 _name_ = "AGE";
 RUN;
 
 DATA age_f;
 set dm8 dm7;
 if _n_ gt 1 then _name_ = "  "||_name_;
 key = _name_;
 run;
 
 /*.........................................................................................*/
 /*....................Age Categorization................................................ */


/* counting frequency */
proc freq data= dm2 ;
tables agegr1 * trt01a/out = cat1(drop=percent);
run;
 
 proc sql noprint ;
 select count (distinct USUBJID) into :trt1  from dm2 where trt01a = "DrugA";
 select  count (distinct USUBJID) into : trt2 from dm2 where trt01a = "Placebo";
 select  count(distinct USUBJID) into : trt3 from dm2 where  trt01a = "Total";
 %put &trt1 &trt2 &trt3;
 quit; 

data cat2;
 set cat1;
 if  trt01a = "DrugA" then denom = &trt1;
 if trt01a = "Placebo" then denom = &trt2;
 if trt01a = "Total" then denom = &trt3;
 percent =put((count/denom)*100, 7.1);
 cp = count || " ("||percent ||")";
 drop count denom percent;
 run;

 proc sort data= cat2;
 by agegr1;
 run;
 
 proc transpose data=cat2 out= cat3(drop= _name_);
 by agegr1;
 id trt01a;
 var cp;
 run;
 /* creating label */

data lbl;
length agegr1 $ 50;
 agegr1 = "AGE CATEGORIZATION (%)" ;
 run;
 
 /* combining the labels with dataset */
 
 data agecat_f ;
 length agegr1 $50;
 set lbl cat3;
 format agegr1 50.;
 if _n_ gt 1 then agegr1 = "  "||agegr1;
 key= agegr1;
 run;
 
 
 

/*................... Gender parts............................................... */
proc freq data =dm2 ;
tables sex * trt01a /out =sec (drop= percent);
run;
 
 proc sql noprint;
 select count (distinct usubjid) into : trt1 from dm2 where trt01a = "DrugA";
 select count (distinct usubjid) into : trt2 from dm2 where trt01a = "Placebo";
 select count (distinct usubjid) into : trt3 from dm2 where  trt01a = "Total";
 %put &trt1 &trt2 &trt3;
 quit; 


 data sec1;
 set sec;
 if  trt01a = "DrugA" then denom = &trt1;
 if trt01a = "Placebo" then denom = &trt2;
 if trt01a = "Total" then denom = &trt3;
 percent =put((count/denom)*100,7.1);
 cp = count || " ("||percent ||")";
 drop count denom percent;
 run;
 
 proc sort data= sec1;
 by sex;
 run;
 
 proc transpose data=sec1 out= sec2(drop= _name_);
 by sex;
 id trt01a;
 var cp;
 run;
 
 /*nameing the variABLES */
data sec3;
length sex $ 50;
set sec2;
format sex 50.;

if sex = "M" then do;
   sex = "Male";
   ord = 1;
   end;
      if sex = "F" then do;
      sex = "Female";
      ord = 2;
      end;
 run;

/* orderign  the variables according to templates */

PROC SORT DATA= SEC3;
BY ord;
run;    

/* creating label */

data lbl;
length sex $ 50;
 sex = "Gender (%)" ;
 run;
 
 /* combining the labels with dataset */
 
 data gender_f ;
 length sex $50;
 set lbl sec3;
 if _n_ gt 1 then sex = "  "||sex;
 drop ord;
 key= sex;
 run;
 
 /*.....................................RACE...................................*/

Proc freq data= dm2 ;
tables race * trt01a / out= sort11(drop = percent) ;
run;

 /* counting */

proc sql noprint;
select count(distinct USUBJID) into:trt1 from dm2 where trt01a ="DrugA";
select count(distinct USUBJID) into:trt2 from dm2 where trt01a = "Placebo";
select count(distinct USUBJID) into:trt3  from dm2 where trt01a = "Total";
%put &trt1 &trt2 &trt3;
run; 

data race;
 set sort11;
 if  trt01a = "DrugA" then denom = &trt1;
 if trt01a = "Placebo" then denom = &trt2;
 if trt01a = "Total" then denom = &trt3;
 percent =put((count/denom)*100,7.1);
 cp = count || " ("||percent ||")";
 drop count denom percent;
 run;
 
 proc sort data= race;
 by race;
 run;
 
  proc transpose data=race out= race2(drop= _name_);
 by race;
 id trt01a;
 var cp;
 run;
 
 /*nameing the variABLES */
data race3;
length race $ 50;
set race2;

IF race = "White" then race = "WHITE" ;
if race = "Black" then race = "BLACK OR AFRICAN AMERICAN";
if race = "Asian" then race = "ASIAN"; 
if race = "Other" then race = "OTHER";  
 run;

 /*arranging the variABLES */
data race4;
length race $ 50;
set race3;

if race = "WHITE" then ord = 1;
if race = "BLACK OR AFRICAN AMERICAN" then ord= 2;
if race = "ASIAN" then ord = 3;
if race = "OTHER"   then ord =4;  
 run;
 
/* deleting those variables which are not required */
 data race5;
 set race4;
 if ord = . then delete;
 run;
 
/* for arranging variables accordingly */
proc sort data= race5;
by ord;
run;

/* creating labels for race */
data lbl_race;
length race $ 50;
 race = "RACE ( % )" ;
 run;

 /*Combining the label with dataset */
data race_f ;
 length race $50;
 set lbl_race race5;
 if _n_ gt 1 then race = "   "||race;
 drop ord;
 key = race;
 run;
 
 proc print data= racefinal;
 run;
 
 /*............................... Ethinicity *...............*/
 proc freq data= dm2;
 tables ethnic * trt01a/out= sort22;
 run;
 
 proc sql noprint;
 select count (Distinct USUBJID) into:trt1 from dm2 where trt01a = "DrugA";
 select count (Distinct USUBJID) into:trt2 from dm2 where trt01a ="Placebo";
 select count (Distinct USUBJID) into :trt3 from dm2 where trt01a = "Total";
 %put &trt1 &trt2 &trt3;
 quit;
 
 data eth;
 set sort22;
 if  trt01a = "DrugA" then denom = &trt1;
 if trt01a = "Placebo" then denom = &trt2;
 if trt01a = "Total" then denom = &trt3;
 percent =put((count/denom)*100,7.1);
 cp = count || " ("||percent ||")";
 drop count denom percent;
 run;
 
 proc sort data= eth;
 by ethnic;
 run;
 
 proc transpose data=eth out= eth2(drop= _name_);
 by ethnic;
 id trt01a;
 var cp;
 run;
 
  /*nameing the variABLES */
data eth3;
length ethnic $ 50;
set eth2;
FORMAT ETHNIC 50.;
if ethnic = "Hispanic" then do;
   ethnic = "HISPANIC/LATINO";
   ord = 1;
   end;
      if ethnic = "Non-Hispanic" then do;
      ethnic = "NOT HISPANIC/LATINO";
      ord = 2;
      end;
 run;

 /* creating labels for ethnic */
data lbl_ethnic;
length ethnic $ 50;
 ethnic = "ETHNICITY (%)" ;
 run;
 
  /*Combining the label with dataset */
data ethnic_f ;
 length ethnic $50;
 set lbl_ethnic eth3;
 if _n_ gt 1 then ethnic = "   "||ethnic;
 drop ord;
 if Placebo = " " and _n_  gt 1 then Placebo = "        0(0 . 0)";
 key = ethnic;
 run;

 /*..............................PLATELET COUNT...........................................................................*/
 
 proc means data= dm2  ;
 var pltcnt;
 class trt01a;
 output out= plt1(drop= _type_ _freq_ )
 n = _n
 mean = _mean
 median = _median
 std = _std
 min = _min
 max = _max
 ;
 run;
 
 data plt2;
 length n  mean median  minmax  std $30;
  set plt1;
  N = put(_n,4.);
  Mean = put(_mean, 2.);
  Median = put(_median,2.);
  minmax = put(_min,4.)||","||put(_max,4.);
  std = put(_std,6.1);
  if trt01a ne " ";
  drop _n _mean _median _std _min _max;
  run;
 
 /* transpose */
proc sort data = plt2 out= plt3;
by trt01a;
run;
 
 proc transpose data= plt3 out=plt4;
 id trt01a;
 var n mean median minmax std;
 run;
 /* change the case of variable name */
data plt5;
length _name_ $50;
set plt4;
if _NAME_ = "n" then _NAME_ = "N";
if _NAME_ = "mean" then _NAME_ = "MEAN";
if _NAME_ = "median" then _NAME_ = "MEDIAN";
if _NAME_ = "minmax" then _NAME_ = "MIN , MAX";
if _NAME_ = "std" then _NAME_ ="STANDARD DEVIATION";
RUN;

/* giving variable name PLATELET COUNT */
 data lbl_plt;
 LENGTH _name_  $50;
 _name_ = "PLATELET COUNT";
 RUN;
 
 DATA plt_f;
 set lbl_plt plt5;
 if _n_ gt 1 then _name_ = "  "||_name_;
 key = _name_;
 run;

/*............................ final report ..............................................................................*/
data report ;
set age_f(in=a) agecat_f(in=b) gender_f(in=c) race_f(in=d) ethnic_f(in=e) plt_f(in=f);
ordx = sum(a*1,b*2,c*3,d*4,e*5,f*6);
drop _name_ agegr1 sex age race ethnic;
run;

data report_f;
retain  key DrugA placebo total ordx;
set report;
run;

 /* FINAL REPORT */
ODS PDF file= "/home/u60027465/sasuser.v94/project1/Project1A.PDF";
proc report data= report_f nowd headline headskip split ="@";
column ( key ordx DrugA placebo total);
define key/" " width = 40 display;
define DrugA/"DrugA@N= &trt1" width= 20 center;
define placebo/" Placebo@N= &trt2" width=20 center;
define  total /"Total @N=&trt3" width= 20 center;
define ordx/order noprint ;
compute after ordx;
line ' ';
endcomp;
title1 "Demographic and Baseline Characteristics Summary  ";
title2 "All Randomized Subjects";
run;
 
ODS PDF CLOSE; 

/* log file */
proc printto log ="/home/u60027465/sasuser.v94/project1/Project1A.log";