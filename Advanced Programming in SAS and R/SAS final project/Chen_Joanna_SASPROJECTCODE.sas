/* SAS Project, Joanna Chen, netid: wc549 */
		/* Due: October 23, 2019 */
		
/* This project contains three files: 
	(1) Chen_Joanna_SASPROJECTCODE.sas,
	(2) Chen_Joanna_Macros.sas
	(3) Chen_Joanna_Formats.sas
*/

/* Create the path to locate the files, given macro as well as the given datasets */
%let pathname = /home/tug195820/my_courses/SAS Project/;

/* Include the macro and format files */
%include "&pathname.table1.11152018.sas";
%include "&pathname.Chen_Joanna_Formats.sas";
%include "&pathname.Chen_Joanna_Macros.sas";

/* options fmtsearch=(work.ed); */

/* table1 macro invocation */
options nocenter ps=78 ls=125 replace formdlim='['
mautosource 
sasautos=("&pathname");

/* Print in the log how the macro variable is resolved for the future debugging */
options symbolgen;

/* -------------------------- Read and filter the data from 2005 - 2009 -------------------------- */
%read_data(05);
%read_data(06);
%read_data(07);
%read_data(08);
%read_data(09);

%filter_data(05);
%filter_data(06);
%filter_data(07);
%filter_data(08);
%filter_data(09);
	
/* -------------------------- Processed dataset for output table 1,2 -------------------------- */	
data processed_dataset; 
	/* Concatenate the 5 filtered datasets */
	set test05_1 test06_1 test07_1 test08_1 test09_1;
	
	/* Apply the format */
	format age_group age_groupf.;
	format race_ethnicity race_ethnicityf.;
	format pain_type pain_typef.;
	format severity_of_pain severity_of_painf.;
	format provider_type provider_typef.;
	format sex sexf.;
	
	/* Apply the label */
	label sex = 'Sex';
	label race_ethnicity = 'Race/Ethnicity';
	label pain_type = 'Type of Pain';
	label severity_of_pain = 'Severity of Pain';
	label provider_type = 'Provider Type';
	label age_group = 'Age Group';
	label analgesic = "Analgesic";
	label opioid = "Opioid";
	label NSAID = "NSAID";
	label discharge_opioid = "Discharge Opioid";
run;

/* -------------------------- Processed dataset for output table 3 -------------------------- */
data processed_dataset_analgesic;
	set processed_dataset;
	
	/* For a given pain category, create an indicator of whether they received an analgesic */
	/* 	Given no pain */
	if analgesic = 1 and severity_of_pain = 1
		then no_pain = 1;
	else if analgesic = 0 and severity_of_pain = 1
		then no_pain = 2;
	
	/* 	Given mild pain */
	if analgesic = 1 and severity_of_pain = 2
		then mild_pain = 1;
	else if analgesic = 0 and severity_of_pain = 2
		then mild_pain = 2;
	
	/* 	Given moderate pain */
	if analgesic = 1 and severity_of_pain = 3
		then moderate_pain = 1;
	else if analgesic = 0 and severity_of_pain = 3
		then moderate_pain = 2;
	
	/* 	Given severe pain */
	if analgesic = 1 and severity_of_pain = 4
		then severe_pain = 1;
	else if analgesic = 0 and severity_of_pain = 4
		then severe_pain = 2;
		
	/* Apply the format */
	format no_pain analgesicf. mild_pain analgesicf. moderate_pain analgesicf. severe_pain analgesicf.;
	
	/* Apply the label */
	label no_pain = 'No Pain';
	label mild_pain = 'Mild Pain';
	label moderate_pain = 'Moderate Pain';
	label severe_pain = 'Severe Pain';
run;

/* -------------------------- Call the given macro to generate the output -------------------------- */
/* show table of characteristics by age category */
%table1(data = processed_dataset, ageadj = F, exposure = age_group, 
		varlist = sex race_ethnicity pain_type severity_of_pain provider_type,
		poly = sex race_ethnicity pain_type severity_of_pain provider_type,
		rtftitle = Table of characteristics of the pain-related US ED visits for 2005 to 2009 by age category, landscape = F, file = one, uselbl = F)

/* show table of percentage of medication by age category */
%table1(data = processed_dataset, ageadj = F, exposure = age_group, 
		varlist = analgesic opioid NSAID discharge_opioid,
		cat = analgesic opioid NSAID discharge_opioid,
		rtftitle = Table of percentage prescribed a medication for pain-related US ED visits for 2005 to 2009 by age category, landscape = F, file = two, uselbl = F)
		
/* show table of percentage of analgesic by pain category and age category */
%table1(data = processed_dataset_analgesic, ageadj = F, exposure = age_group, 
		varlist = no_pain mild_pain moderate_pain severe_pain,
		poly = no_pain mild_pain moderate_pain severe_pain,
		rtftitle = Table of percentage prescribed any analgesic for pain-related US ED visits for 2005 to 2009 by pain category and age category, landscape = F, file = three, uselbl = F)
		
		
