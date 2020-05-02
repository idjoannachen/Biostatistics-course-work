/*GRADE: 9.9/10

COMMENTS:

(-0.1) the title on the freq procedure is not necessary as you don't print it.

*/
%let pathname=R:\Teaching\Programming 2019\Assignments\Assignment3\;



/*		Assignment 3, Joanna Chen, netid: wc549		*/

/*****************************************************************************************************
Macro name:		tests

Purpose:		This macro will conduct tests to compare one (or multiple) continuous 
				variables by a single two-level group variable.
				The macro determine whether small or large sample tests are to be
				conducted, and then conduct the appropriate tests.
				Note that the macro will conduct two-sample t-test if the sample size
				is greater than or equal to 30 or the Wilcoxon rank sum test if the
				sample size is less than 30.
        		
Author:			Joanna Chen

Creation Date:  October 8, 2019
	
Revision Date:	October 9, 2019	

SAS version:	9.4

Required 
Parameters:		library     = the name of the library where the data set can be found
				data        = Name of the data set
				outcome_var = Name of the variables needed to be compared
				single_var  = a single two-level group variable that we compare variables by

Optional 
Parameters:     None

Sub-macros called: None

Example: %tests(_TEMP0,bgd,gender,BMI18 ST18 HT18 WT18)
*****************************************************************************************************/
/* Print in the log how the macro variable is resolved for the future debugging */
options symbolgen;

/* Beginning of the macro tests*/
%MACRO tests(library, data, single_var, outcome_var);

/* Compute the frequency of the single two-level group variable and save it in the dataset named frequency */
title "Frequency distribution of the single two-level group variable";
proc freq data=&library..&data NOPRINT;
	table &single_var/ OUT=frequency (DROP=&single_var PERCENT);
run;

/* Apply proc transpose on the frequency dataset we just create in order to 
save the frequency from two levels into the SAS variable col1 and col2. */
proc transpose data=frequency prefix=col out=transpose_frequency (drop=_name_ _label_);
run;

/* Check the output */
/* proc print data = transpose_frequency; */
/* run; */

/* Create a macro variable minimum without creating a new dataset*/
data _null_;
set transpose_frequency;
call symput('minimum', min(col1,col2));
run;

/* If the sample sizes of both levels are 30 or greater, which is equivalent that 
if their minimum is 30 or greater, then we consider the sample size is large and 
apply two sample t-test  */

/* Note that for proc ttest, the CLASS statement contains the variable that 
distinguishes the groups being compared, and the VAR statement specifies the 
response variable to be used in calculations. */

%if &minimum >= 30 %then %do;
	title "Two sample t-test for outcome variable(s) &outcome_var by &single_var";
	proc ttest data=&library..&data plots=none;
		class &single_var; 
		var &outcome_var;
	run;
%end;

/* Otherwise, if either sample size is less than 30, then we consider the sample 
size is small and apply Wilcoxon two-sample test. */

%else %do;
	title "Wilcoxon two-sample test for outcome variable(s) &outcome_var by &single_var";
    proc npar1way data=&library..&data wilcoxon plots=none;
		class &single_var; 
        var &outcome_var;
   run;
%end;

/* End of the macro tests*/
%MEND tests;

/* Set the pathname for location of the datasets */
*%let pathname=B:\My Documents\HW 3\;
/* Define the library */
libname _TEMP0 "&pathname";
/* Call the macro (The parameter here is positional) */
/* (a) Run the macro to determine if there is a difference by gender for BMI18, ST18, HT18, WT18 */
%tests(_TEMP0,bgd,gender,BMI18 ST18 HT18 WT18)
/* (b) Run the macro to determine if there is a difference by slender for LG9 and LG18 */
%tests(_TEMP0,bgd,slender,LG9 LG18)

/*Additional tests*/

%tests(_TEMP0, twoqol, treat, perf server)


%tests(_TEMP0, salary, degree, salary)
