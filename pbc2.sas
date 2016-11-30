/* Taylor Ryu */
*********************************************************************;
PROC IMPORT DATAFILE= "C:\Users\tayryu0110\Desktop\pbc2.txt"
			OUT= pbc 
            DBMS=TAB
			Replace;
			Getnames=YES;
			RUN;
/* 418 observations and 20 variables */
DATA  pbc2;
   SET pbc;
   LABEL  X  ="Survival Time"
          Z1 ="Treatment"
          Z2 ="Age"
		  Z10="Albumin Level"
 		  D="Death Indicator";
RUN;

PROC CONTENTS DATA=pbc2;
RUN;

PROC MEANS DATA=pbc2 NMISS;
VAR D Z1;
TITLES 'number of missing values';
RUN;
/* 0 missing value in variable D which is Death Indicator, and 106 missing values in variable Z1 which is Treatment. */

PROC FORMAT;
  VALUE DLab 0="lived"
             1="died" ;
  VALUE Z1Lab 1="D-penicillamine Drug"
		      2= "Placebo";
RUN;

proc tabulate data=pbc2 MISSING;
  class D Z1;
  table D All,
        Z1 All; 
  TITLE 'Two-way Table';
run;
/*The total number of people who died by the end of the study is 161.*/
/*60 people who took the placebo died by the end of the study.*/

DATA died; 
   SET pbc2;
   IF D =1;
RUN;
PROC CONTENTS DATA=died; 
RUN;
/* 161 observations and 20 variables in "died" data set */

DATA died;
SET died;
Dage = Z2 + X/365;
Run;
Proc contents data=died;
RUN;
/* Added Dage variable in "died" data set */

proc means data=died;
var Dage;
Run;
/* The mean age at time of death is 57.69. */

TITLE 'Scatterplot - Two Variables';
PROC GPLOT DATA=died;
     PLOT X*Z10 ;
RUN; 

proc corr data = died;
var X Z10;
Run;
/* The correlation between albumin level and survival time is 0.41128. */

proc reg data = died;
model X = Z10;
output out=reg_output1
	   predicted=pred1
	   residual=resid1;
run;
QUIT;
/* Albumin level is a significant predictor of survival time because p-value is close to 0. */

PROC GPLOT DATA=reg_output1;
	PLOT resid1*pred1;
	LABEL resid1='Residuals'
		  pred1='Predicted Values';
	TITLE 'Residual Plot';
RUN;

PROC SORT DATA=died;
	BY Z1;
RUN;
PROC FORMAT;
	VALUE treatmentlabel 1="D-penicillamine"
	                     2="Palcebo";
RUN;
PROC BOXPLOT DATA=died;
	PLOT X*Z1;
	FORMAT Z1 treatmentlabel.;
	TITLE 'Survival Time by Treatment Group'; 
RUN;

proc means data=died;
var X; 
BY Z1;
Run;
/*Mean of drug is 1518.66 and standard deviation is 1021.13.*/ 
/*Mean of placebo is 1429.03 and standard deviation is 1163.61. */

PROC ANOVA;
	CLASS Z1; 
	FORMAT Z1 treatmentlabel.;
	MODEL X = Z1; 
RUN;
QUIT;
/* The drug does not appear to be effective in prolonging life.*/
/* Because F-statistics is really small and p-value is way more than 0.05.*/
