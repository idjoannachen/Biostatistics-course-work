/* -------------------------- Define macro variables -------------------------- */
/* Pain related visits*/
%let pain_related_visit_ids = (10500, 10501, 10550, 10551, 10552, 10553, 10554, 10600, 10601, 
		12100, 12650, 13201, 13551, 14101, 14552, 14851, 15002, 15101, 15151, 15450, 
		15451, 15452, 15453, 16051, 16101, 16500, 16651, 16701, 17001, 17151, 17452, 
		17651, 17751, 17901, 18000, 18701, 19001, 19051, 19101, 19151, 19201, 19251, 
		19301, 19351, 19401, 19451, 19501, 19551, 19601, 19651, 19701, 23650, 50050, 
		50100, 50150, 50200, 50250, 50300, 50350, 50400, 50450, 50500, 57050, 57100, 
		57100, 57150, 57200, 57500);
		
/* Pain category */
%let head_ids = (10554, 12100, 13201, 13551, 14101, 15002, 15101, 15151, 23650, 50050, 57050);
%let neck_ids = (14552, 19001, 57050);
%let chest_ids = (10500, 10501, 12650, 14851);
%let abdomen_ids = (10551, 10552, 10553, 15450, 15451, 15452, 15453, 16051, 16101, 16500, 16651, 16701,
		17001, 17151, 17452, 17651, 17751, 17901, 50150, 57100);
%let back_ids = (19051, 19101, 50100);
%let lower_extremity_ids = (19151, 19201, 19251, 19301, 19351, 50200, 50250, 50300, 57150,50200, 50250, 50300);
%let upper_extremity_ids = (19401, 19451, 19501, 19551, 19601, 50350, 50400, 50450, 57150,50350, 50400, 50450);
%let generalized_ids = (10600, 10601);
%let other_ids = (10550, 18000, 18701, 19651, 19701, 50500, 57200, 57500);

/* Drug category */
%let tylenol_ids = (00260, 02036, 02335, 32905, 60595, 99153);
%let opioid_only_ids = (21550, 96045, 00283, 02333, 04538, 07180, 08246, 09600, 14955, 15005, 18985, 19650,
		22303, 25510, 29285, 29654, 34985, 60565, 92024, 94188, 95050, 96012, 96041, 96109,
		98067, 99123);
%let NSAID_only_ids = (35460, 92155, 94125, 00048, 00169, 00597, 01003, 01838, 02014, 02805, 03675, 10126,
		12193, 12550, 15395, 15600, 18760, 19675, 20285, 20290, 27405, 61100, 92051, 92124, 92161, 93132,
		93220, 93312, 94072, 94113, 94127, 96083, 96102, 99002, 99067);
%let opioid_and_tylenol_ids = (32945, 92180, 96028, 00251, 00280, 01124, 01268, 02340, 08470, 22305,
		23385, 32915, 32920, 32925, 32930, 34110, 89039, 93089, 98036);
%let Opioid_and_NSAID_ids = (05040, 20210, 23390, 95178, 98043);
%let other_drug_ids = (01775, 61130);

/*****************************************************************************************************
Macro name:		rfv_to_pain_type
Purpose:		This macro will map the reason to visit into specific type of pain such as head, neck,
				etc.
Author:			Joanna Chen
Creation Date:  October 18, 2019
Revision Date:	October 18, 2019
SAS version:	9.4
Required 
Parameters:		rfv = reasons for visits
Optional 
Parameters:     None
Sub-macros 
called: 		None
Example: 		%rfv_to_pain_type(rfv1)
*****************************************************************************************************/

%macro rfv_to_pain_type(rfv);
	if &rfv in &head_ids 
		then pain_type = 1; 
	else if &rfv in &neck_ids 
		then pain_type = 2; 
	else if &rfv in &chest_ids 
		then pain_type = 3; 
	else if &rfv in &abdomen_ids 
		then pain_type = 4; 
	else if &rfv in &back_ids 
		then pain_type = 5; 
	else if &rfv in &lower_extremity_ids 
		then pain_type = 6; 
	else if &rfv in &upper_extremity_ids 
		then pain_type = 7; 
	else if &rfv in &generalized_ids 
		then pain_type = 8; 
	else if &rfv in &other_ids
		then pain_type = 9; 
	else pain_type = 0;
%mend rfv_to_pain_type;

/*****************************************************************************************************
Macro name:		multi_rfv_to_pain_type
Purpose:		This macro maps three reason for visit to the corresponding pain type. It also determines
				if there're multiple pain types. If there are, the set the pain type as 'Multiple'.
Author:			Joanna Chen
Creation Date:  October 18, 2019
Revision Date:	October 18, 2019
SAS version:	9.4

Required 
Parameters:		rfv1 = Reason for visit 1 
				rfv2 = Reason for visit 2
				rfv3 = Reason for visit 3
Optional 
Parameters:     None

Sub-macros 		
called: 		rfv_to_pain_type

Example: 		%multi_rfv_to_pain_type(rfv1,rfv2,rfv3)
*****************************************************************************************************/

%macro multi_rfv_to_pain_type(rfv1,rfv2,rfv3);
	%rfv_to_pain_type(&rfv1)
	pain_type1 = pain_type;
	%rfv_to_pain_type(&rfv2)
	pain_type2 = pain_type;
	%rfv_to_pain_type(&rfv3)
	pain_type3 = pain_type;
	
	/* If two pain type equals to zero, then take the value from the third pain type. */
	if pain_type1 + pain_type2 = 0
		then pain_type = pain_type3;
	else if pain_type2 + pain_type3 = 0
		then pain_type = pain_type1;
	else if pain_type1 + pain_type3 = 0
		then pain_type = pain_type2;
	else pain_type = 10; 

%mend multi_rfv_to_pain_type;

/*****************************************************************************************************
Macro name:		get_race_ethnicity_05_06
Purpose:		This macro gives the race/ethinicity from 2005 and 2006
Author:			Joanna Chen
Creation Date:  October 18, 2019
Revision Date:	October 18, 2019
SAS version:	9.4

Required 
Parameters:		raceeth = Race/Ethnicity variable from 2005-2006
				
Optional 
Parameters:     None

Sub-macros 		
called: 		

Example: 		%get_race_ethnicity_05_06(raceeth)
*****************************************************************************************************/

%macro get_race_ethnicity_05_06(raceeth);
	if &raceeth >= 4
		then race_ethnicity = 4;
	else race_ethnicity = &raceeth;
%mend get_race_ethnicity_05_06;

/*****************************************************************************************************
Macro name:		get_race_ethnicity_05_06
Purpose:		This macro gives the race/ethinicity from 2007-2009
Author:			Joanna Chen
Creation Date:  October 18, 2019
Revision Date:	October 18, 2019
SAS version:	9.4

Required 
Parameters:		ethun = Hispanic or non-Hispanic variable from 2007-2009
				raceun = Race variable from 2007-2009
Optional 
Parameters:     None
Sub-macros 		
called: 		
Example: 		%get_race_ethnicity_07_08_09(ethun,raceun);
*****************************************************************************************************/
%macro get_race_ethnicity_07_08_09(ethun,raceun);
	/* Determine if it's Hispanic, if it is, then set the race_ethinicity as Hispanic */
	if &ethun = 1
		then race_ethnicity = 3;
	/* 	If not,	then determine if it's white(1), black(2) and assign the corresponding value to race_ethinicity */
	else if &ethun = 2 and &raceun = 1
		then race_ethnicity = 1;
	else if &ethun = 2 and &raceun = 2
		then race_ethnicity = 2;
	else race_ethnicity = 4;
%mend get_race_ethnicity_07_08_09;

/*****************************************************************************************************
Macro name:		get_provider_type
Purpose:		This macro gets the provider type based on the order of importance
Author:			Joanna Chen
Creation Date:  October 18, 2019
Revision Date:	October 18, 2019
SAS version:	9.4

Required 
Parameters:		attphys = ED attending physician seen
				oncall = On call attending physcian/fellow seen
				resint = Resident/Intern seen
				physasst = Physcian assistant seen
				nursepr = Nurse practitioner seen
				othprov = Other provider seen
				
Optional 
Parameters:     None

Sub-macros 		
called: 		

Example: 		%get_provider_type(attphys, oncall, resint, physasst, nursepr, othprov)
*****************************************************************************************************/
%macro get_provider_type(attphys, oncall, resint, physasst, nursepr, othprov);
	/* If attphys and oncall, the set provider type as physcian	 */
	if &attphys = 1 or &oncall = 1
		then provider_type = 1;
		
	/* If resint, the set provider type as intern/resident */
	else if &resint = 1
		then provider_type = 2;
		
	/* If phyasst or nursepr or othprov, the set provider type as midlevel */
	else if &physasst = 1 or &nursepr = 1 or &othprov = 1
		then provider_type = 3;
		
	/* 	Otherwise, set the provider type as Midlevel */
	else provider_type = 3;
%mend get_provider_type;

/*****************************************************************************************************
Macro name:		get_severity_of_pain_09
Purpose:		This macro gets the severity of pain in 2009
Author:			Joanna Chen
Creation Date:  October 18, 2019
Revision Date:	October 18, 2019
SAS version:	9.4
Required 
Parameters:		painscale = pain scale in 2009 data			
Optional 
Parameters:     None
Sub-macros 		
called: 		
Example: 		%get_severity_of_pain_09(painscale)
*****************************************************************************************************/
%macro get_severity_of_pain_09(painscale);
	/* If painscale = 0, then set severity_of_pain as None */
	if &painscale = 0 
		then severity_of_pain = 1;
	/* If painscale from 1-3, then set severity_of_pain as Mild */
	else if &painscale >=1 and &painscale <=3
		then severity_of_pain = 2;
	/* If painscale from 4-6, then set severity_of_pain as Moderate */
	else if &painscale >=4 and &painscale <=6
		then severity_of_pain = 3;
	/* If painscale from 7-10, then set severity_of_pain as Severe */
	else if &painscale >=7 and &painscale <=10
		then severity_of_pain = 4;
%mend get_severity_of_pain_09;

/*****************************************************************************************************
Macro name:		get_severity_of_pain_05_to_08
Purpose:		This macro gets the severity of pain in 2009
Author:			Joanna Chen
Creation Date:  October 18, 2019
Revision Date:	October 18, 2019
SAS version:	9.4
Required 
Parameters:		painscale = pain scale in 2005-2008 data			
Optional 
Parameters:     None
Sub-macros 		
called: 		
Example: 		%get_severity_of_pain_05_to_08(pain)
*****************************************************************************************************/
%macro get_severity_of_pain_05_to_08(pain);
	/* If the pain fall into 1-4 which is None, Mild, Moderate, Severe, then assign its category to severity_of_pain */
	if &pain >= 1 and &pain <= 4
		then severity_of_pain = &pain;
	/* Otherwise, it's Blank or Unknown. We set the severity_of_pain as missing value. */
	else severity_of_pain = .;
%mend get_severity_of_pain_05_to_08;

/*****************************************************************************************************
Macro name:		get_age_group
Purpose:		This macro categorizes the age group into 4 category: 18-34, 35-54, 55-74, >=75
Author:			Joanna Chen
Creation Date:  October 18, 2019
Revision Date:	October 18, 2019
SAS version:	9.4
Required 
Parameters:		age = age of patient	
Optional 
Parameters:     None
Sub-macros 		
called: 		
Example: 		%get_age_group(age)
*****************************************************************************************************/
%macro get_age_group(age);
	if &age >= 18 and &age <= 34
		then age_group = 1;
	else if &age >=35 and &age <=54
		then age_group = 2;
	else if &age >=55 and &age <=74
		then age_group = 3;
	else if &age >=75
		then age_group = 4;
%mend get_age_group;


/*****************************************************************************************************
Macro name:		read_data
Purpose:		This macro reads in the ED data of the given year
Author:			CDC. Joanna Chen revised
Creation Date:  October 16, 2019
Revision Date:	October 18, 2019
SAS version:	9.4
Required 
Parameters:		year = the year you want to read the data of
Optional 
Parameters:     None
Sub-macros 		
called: 		
Example: 		%read_data(year)
*****************************************************************************************************/
/* 1. Read in the ED data from 2005-2009 */
%macro read_data(year);
	/*unzipped ASCII data set*/
	filename ed&year.pub "&pathname.ED20&year";

	/*SAS format statement*/
	filename ed&year.for "&pathname.ed&year.for.txt";

	/*SAS input statement*/
	filename ed&year.inp "&pathname.ed&year.inp.txt";

	/*SAS label statement*/
	filename ed&year.lab "&pathname.ed&year.lab.txt";

	/*reads in the format statement*/
	%inc ed&year.for;

	data test&year;
		infile ed&year.pub missover lrecl=9999;
		
		/*reads in the input statement*/
		%inc ed&year.inp;

		/*reads in the label statement*/
		%inc ed&year.lab;
%mend read_data;

/*****************************************************************************************************
Macro name:		get_medication
Purpose:		This macro gets the medication and assign it to the indicator variable 
				any analgesic, opioid, NSAID, discharge_opioid/
Author:			Joanna Chen
Creation Date:  October 16, 2019
Revision Date:	October 18, 2019
SAS version:	9.4
Required 
Parameters:		med = the medication from drugs
				gpmed = where the medication was prescribed
Optional 
Parameters:     None
Sub-macros 		
called: 		
Example: 		%get_medication(med,gpmed)
*****************************************************************************************************/
%macro get_medication(med,gpmed);
	/* 	If the medication fall into the tylenol, opioid, NSAID, then we say it fall into any analgesic
		and assign it to the analgesic indicator variable */
	if &med in &tylenol_ids or &med in &opioid_only_ids or &med in &NSAID_only_ids
	or &med in &opioid_and_tylenol_ids or &med in &Opioid_and_NSAID_ids 
		then analgesic = 1;
		
	/* 	Similary, assign the corresponding medication to 1 if the medication fall into that category */
	if &med in &opioid_only_ids
		then opioid = 1;
	if &med in &NSAID_only_ids
		then NSAID = 1;
	if &med in &opioid_and_tylenol_ids
		then opioid = 1;
	if &med in &Opioid_and_NSAID_ids
		then opioid = 1;
	if &med in &Opioid_and_NSAID_ids
		then NSAID = 1;
	if &gpmed = 2 or &gpmed = 3
		then discharge =1;
	if opioid = 1 and discharge = 1
		then discharge_opioid = 1;
%mend get_medication;

/*****************************************************************************************************
Macro name:		filter_data
Purpose:		This macro filters the input data, get a variety of information we need and 
				assign the information into the corresponding variables. The output dataset 
				for each year after merging over different years can be taken as processed dataset.
Author:			Joanna Chen
Creation Date:  October 18, 2019
Revision Date:	October 18, 2019
SAS version:	9.4
Required 		
Parameters:		year = the year of the given dataset you hope to filter
Optional 
Parameters:     None
Sub-macros 		
called: 		get_race_ethnicity_05_06, get_race_ethnicity_07_08_09, multi_rfv_to_pain_type
				get_severity_of_pain_05_to_08, get_severity_of_pain_09, get_provider_type, get_age_group
				get_medication
Example: 		%filter_data(year)
*****************************************************************************************************/
%macro filter_data(year);

	data test&year._1;
		set test&year;
		
		*keep pain-related observations;
		where rfv1 in &pain_related_visit_ids or 
			rfv2 in &pain_related_visit_ids or 
			rfv3 in &pain_related_visit_ids;
		
		*get race and ethinicity;
		if &year in (05, 06) then %get_race_ethnicity_05_06(raceeth);
		if &year in (07, 08, 09) then %get_race_ethnicity_07_08_09(ethun,raceun);
			
		*get pain type;
		%multi_rfv_to_pain_type(rfv1,rfv2,rfv3);
		
 		*get severity of pain;
 		if &year in (05, 06, 07, 08) then %get_severity_of_pain_05_to_08(pain);
		if &year = 09 then %get_severity_of_pain_09(painscale);
		
		%get_provider_type(attphys, oncall, resint, physasst, nursepr, othprov);
		%get_age_group(age);
		
		*initialize the value of the following variable and get medication;
		analgesic = 0;
		opioid = 0;
		NSAID = 0;
		discharge_opioid = 0;
		
		%get_medication(med1,gpmed1)
		%get_medication(med2,gpmed2)
		%get_medication(med3,gpmed3)
		%get_medication(med4,gpmed4)
		%get_medication(med5,gpmed5)
		%get_medication(med6,gpmed6)
		%get_medication(med7,gpmed7)
		%get_medication(med8,gpmed8)
		
		/* Keep the variable we need for the processed dataset */
		keep sex race_ethnicity pain_type severity_of_pain provider_type age_group 
			analgesic opioid NSAID discharge_opioid;
%mend filter_data;