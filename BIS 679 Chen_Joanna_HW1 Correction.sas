/*
GRADE: 9/10

COMMENTS:

(-0.25) YOU HAVE INCORRECTLY CALCULATED 
	month_difference = day_difference/12;

THAT WOULD CONVERT MONTHS TO YEARS, BUT TO CONVERT DAYS TO MONTHS YOU NEED TO DIVIDE BY 30.5


 (-0.25) THERE IS NO DIFFERENCE BETWEEN THE ascites, hepatomegaly, spiders AND new_edema FORMATS.  
YOU SHOULD HAVE CREATED ONE FORMAT THAT COULD HAVE
BEEN USED ACROSS ALL VARIABLES WITH A YES/NO VALUE OF 1/0


-(0.5) YOU WERE SUPPOSED TO "(4)	Contents of the analysis data set printed to the
screen in the order in which the variables appear in the data set"
THIS REQUIRES USE OF THE ORDER=VARNUM OPTION IN PROC CONTENTS


THE TWO MEANS PROCEDURES SHOULD HAVE BEEN COMBINED INTO ONE; SAME FOR THE TWO FREQUENCY PROCEDURES

*/

/*		Homework 1, Joanna Chen, netid: wc549		*/
/* This homework contains two files: (1) main SAS program Chen_Joanna_HW1 and (2) the code used to
 create the format Chen_Joanna_FORMATS. */
/* Due: Thursday, Sept 19*/
/* Main program*/

*Create the path to locate the data set;
*%let pathname=B:\My Documents\HW 1\;


%let pathname=C:\Users\dae6\Desktop\Assignment1\Submission\;

*Include the format file in the main program;
*%include "&pathname.Chen_Joanna_FORMATS.sas";
%include "&pathname.chenjoanna_106728_3166393_Chen_Joanna_FORMATS.sas";


*include the WORK library;
options fmtsearch=(WORK.bili);

*Create an temporary dataset named analysis;
data analysis;
	/* Read the data set */
	/* Bili dataset.txt which contains a modified version of the data set found in appendix D of Fleming and Harrington, Count Processes and Survival Analysis, Wiley, 1991. This is a data set on Primary Biliary Cirrhosis from a clinical trial conducted between 1974 and 1984. */
 	infile "&pathname.Bili dataset.txt";
 	input case day_difference status drug age_in_days sex ascites hepatomegaly spiders edema bilirubin cholesterol albumin urine alkaline SGOT triglicerides platelets prothrombin histologic_stage;
 	
 	/* Crate variable labels for all variables */
 	label case = "Case number"
 		  day_difference = 'Number of days between registration and the earlier of death, transplantation, or study analysis time in July, 1986'
 		  status = 'Status: 1=Death; 2=Transplantation; 0=Censored'
		  drug = 'Drug: 1=D-penicillamine; 2=placebo'
	 	  age_in_days = 'Age in days'
		  sex = 'Sex: 0=Male; 1=Female'
	 	  ascites = 'Presence of Ascites: 0=No; 1=Yes'
		  hepatomegaly = "Presence of Hepatomegaly: 0=No; 1=Yes"
		  spiders = "Presence of Spiders: 0=No; 1=Yes"
		  edema = "Presenceof Edema: 0=No edema and no diuretic therapy for edema; 0.5=Edema present without diuretics, or edema resolved by diuretics; 1=Edema despite diuretic therapy"
		  bilirubin = "Serum Bilirubin in mg/dl"
		  cholesterol   ="Serum Cholesterol in mg/dl; missing denoted by 99"
		  albumin = "Albumin in gm/dl"
		  urine = "Urine Copper in ug/day"
		  alkaline = "Alkaline Phosphatase in U/liter"
		  SGOT = "SGOT in U/ml"
		  triglicerides = "Triglicerides in mg/dl"
		  platelets = "Platelets per cubic ml / 1000"
		  prothrombin = "Prothrombin time in seconds"
		  histologic_stage = "Histologic stage of disease";

	/* Apply the format defined in the seperate format file to the variables */
	format status status. drug drug. sex sex. ascites ascites. hepatomegaly hepatomegaly. spiders spiders. edema edema.;

	/* Create variables*/
	/* Age in years*/
	age_years = age_in_days/365.25;
	/* Number of months between registration and earlier of death transplantation, or study analysis time in July, 1986*/
	month_difference = day_difference/12;

	/* Drop age in days from analysis*/
	drop age_in_days day_difference;
    /* Create a new variable that combines 0.5 and 1 in a single category, where 0 indicates no and 1 indicates yes	*/
	if edema = 0.5 | edema = 1 then edema_new = 1;
		else if edema = 0 then edema_new = 0;
	format edema_new edema_new.;

    /* Add labels after variables change */
	label age_years = "Age in years";
	label month_difference = "Number of years between registration and the earlier of death, transplantation,or study analysis time in July, 1986";
	label edema_new = "combines 0.5 and 1 in edema in a single category, where 0 indicates no and 1 indicates yes";
	
	/* Convert 99 to missing value*/
	if cholesterol = 99 then cholesterol = '.';
run;

/* Print the mean of age in years */
title "Mean of Age in years";
proc means data = analysis;
	var age_years;
run;

/* Print the mean months between registration and earlier of death transplantation, or studyanalysis time in July, 1986 */
title "Mean months between registration and earlier of death transplantation, or studyanalysis time in July, 1986";
proc means data = analysis;
	var month_difference;
run;

/* Print the frequencies and percentages of original and new edema variables */
title "Frequencies and percentages of original edema variables";
proc freq data = analysis;
	table edema;
run;

title "Frequencies and percentages of new edema variables";
proc freq data = analysis;
	table edema_new;
run;

/* Print the contents of the analysis data set printed to the screen in the order in which thevariables appear in the data set */
title "Contents of the analysis data set";
proc contents data = analysis;
run;
