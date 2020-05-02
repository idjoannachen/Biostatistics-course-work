
/*
GRADE: 9.5/10

COMMENTS: 

(-0.5) YOU HAVE PROVIDED MORE OUTPUT THEN ASKED FOR.  IT IS OKAY FOR YOU TO RUN CHECKS, BUT
EITHER DELETE OR COMMENT OUT AFTERWARDS. SEE THE COMMENTS I POSTED FOR HOMEWORK 1 ON CANVAS


NICE JOB COMMENTING YOUR CODE.

THIS CODE IS NOT EFFICIENT.  THE COMPUTATION OF EACH OF THE AUTHOR SCORES SHOULD HAVE BEEN COMBINED INTO ONE STEP.

*/

%let pathname=R:\Teaching\Programming 2019\Assignments\Assignment2\;


/*		Assignment 2, Joanna Chen, netid: wc549		*/
/* This homework contains two files: (1) main SAS program Chen_Joanna_HW2 and (2) the code used to
 create the format Chen_Joanna_Format. */
/* Due: Thursday, Sept 26*/
/* Main program*/

/* Set the pathname for location of the datasets */
*%let pathname=B:\My Documents\Assignment 2\;

/* Include the format file for the demographics data set */
*%include "&pathname.Chen_Joanna_Format.sas";
%include "&pathname.chenjoanna_106728_3197652_Chen_Joanna_Format.sas";
/* Define the formats created by the Format file called demographics */
options fmtsearch=(WORK.demographics);

/* Part 1: Data manipulation including importing, summarization, cleaning, etc. to get the processed dataset */
/* Import given three datasets, create the label */
proc import datafile="&pathname.Assessment_original.csv" DBMS=CSV  out=original replace;
 label PATNO = "participant number";
run;

proc import datafile="&pathname.Assessment_makeup.csv" DBMS=CSV  out=makeup replace;
run;

proc import datafile="&pathname.Demographics.csv" DBMS=CSV  out=demographics replace;
run;

/* Add formats in the demographics dataset */
data demographics; set demographics;
 format Year college_year. Gender Gender. Residency Residency. Major Major.;
run;

/* Check if the format has been applied */
title 'Contents of the demographics data set';
proc contents data=demographics;
run;

/* Print the dataset and take a look */
title 'Original assessment dataset';
proc print data = original;
run;
title 'Makeup assessment dataset';
proc print data = makeup;
run;
title 'Demographics dataset';
proc print data = demographics;
run;

/* Sort the original and makeup datasets by PATNO and SCALE */
proc sort data=original;
 by PATNO SCALE;
run;

proc sort data=makeup;
 by PATNO SCALE;
run;

/* Merge original and makeup datasets and name it assessment */
data assessment; merge original makeup;
 by PATNO SCALE;
run;

/* Print assessment which includes both original and makeup QOL */
title 'All assessment including original and makeup QOL';
proc print data = assessment;
run;

/* Tranpose the assessment dataset - long to wide */
proc transpose data=assessment out=wide_assessment prefix=scales;
 by PATNO;
 id SCALE;
 var QOL;
run;

/* Print the transposed assessment dataset */
title 'Transposed assessment dataset';
proc print data = wide_assessment;
run;

/* Since later the Author C's method needs to use demographic information, we can merge the demographics dataset first. */
/* Sort the demographics dataset by PATNO */
proc sort data=demographics;
 by PATNO;
run;

/* Merge the demographics and transposed assessment dataset, drop the non-used variables */
data processed_dt; merge demographics(drop=Gender) wide_assessment(drop=_NAME_);
 by PATNO;
run;

/* Print the merged datasets. This is our processed dataset and we will do calculation on it later */
title 'Assessment and demographical data';
proc print data = processed_dt;
run;

/* We want to use array in the following part. First check the data type and 
make sure that all the variables will be used in the later array (scales 1-5) are of the same type */
title "Contents of the processed dataset";
proc contents data=processed_dt;
run;

/* Part 2: Come up with an overall QOL score using ways that Author A, B, C devised */
/* Author A: The average of the first four scores is worth 70% of the score, while the last score is 
worth 30% of the score. In order to get a score, you must have completed all 5 assessments 
(i.e. if someone misses an assessment, they get a missing value for the summary score).*/

data score_A; set processed_dt;
	/* Create the array with five elements scales1 - scales5	*/
 	array scales(5) scales1-scales5;
 	/* Compute the average of the first four scores  */
 	average_first_four=mean(OF scales1-scales4);
 	/* Summary score = 70% of the average of the first four scores and 30% of the last score. Round the result to 2 decimal place. */
 	A=round(.7*average_first_four+.3*scales5,0.01);

	/* If one of the scale is missing, then assign a missing value for the summary score  */
 	do i=1 to 5;
  		if scales(i)=. then A=.;
 	end;
	/*Drop the non-used variables*/
 	drop i average_first_four;
run;

/*Print the processed dataset with summary score using the way Author A devised*/
title "Processed dataset with summary score using the way Author A devised";
proc print data=score_A;
run;

/* Author B: The average of assessment 1, 2 and 3 counts for 50% of the score, while the average of 
assessments 4 and 5 count for 50% of the score. If only one assessment is missing, the assessment 
is ignored and it does not impact the overall assessment. If more than one assessment is missing,
then the individual gets a missing value for the summary score.*/
data score_B; set score_A;
	/* Create the array with five elements scales1 - scales5 */
 	array scales(5) scales1-scales5;
 	
 	/* Count the number of the missing assessment */
 	count_missing = 0; 
 	do i=1 to 5;
  		if scales(i)=. then count_missing = count_missing + 1;
 	end;
 	
	/* For now, let's just ignore the missing assessment first and compute the average and sum */
	/* Note that when using the MEAN function to compute the average, 
       SAS ignores the missing values, goes ahead and computes the average based on the available values 
       unless the observation is missing on all of the variables used in the function then in that case, 
       SAS will give missing value as output.*/
    /* Also note that when using the SUM function, missing values are treated as zeros, 
       unless the observation is missing on all of the variables in the list */
  
 	/* Compute the average of assessment 1,2,3 and 4,5 */
 	average_123 = mean(OF scales1-scales3);
 	average_45 = mean(OF scales4-scales5);
 	
 	/* B Summary score = 50% of the average of the first three scores and 50% of the last two scores  */
 	B = round(sum(.5*average_123,.5*average_45),.01);
	
	/* This and the following line will make no difference in the answer to our homework questions eventually
	B = round(.5*average_123 + .5*average_45,.01); 
	But here I chose to use SUM function because 
	. + number = ., while SUM(.,number = 0+number).
	For now I want to ignore the missing value and don't want the missing value impact the overall assessment value.
	*/
 	
	/*  Now start to consider the missing value	 */
 	/* If more than one assessment is missing, then assign a missing value for the summary score  */
 	if count_missing > 1 then B = .;
	/* Drop the unuseful variables*/
 	drop i average_123 average_45 count_missing;
run;

/* Print the processed dataset with summary score using the way Author B devised */
title "Processed dataset with summary score using the way Author B devised";
proc print data=score_B;
run;

/*Author C: If a student is from out-of-state, the score is the half of the average of the completed assessments 
(regardless of how many are missing) plus 25. If the student is from in-state, the student gets a 50 for any 
missing assessments and the total score is the average of all of the assessments.
*/
data score_C; set score_B;
	/* Create the array with five elements scales1 - scales5 */
	array scales(5) scales1-scales5;
	/*Out-of-state case*/
	if Residency = 2 then C = round(.5*mean(OF scales1-scales5) + 25,.01);

	/* In-state case */
	/* First, assign 50 to the the missing assessments */
	do i=1 to 5;
  		if Residency = 1 & scales(i)=. then scales(i)=50;
 	end;
	/* Then calculating the total score by taking average of all of the assessments	*/
 	if Residency = 1 then C = round(mean(OF scales1-scales5),.01);

	/* Drop the non-used variables */
 	drop i scales1 scales2 scales3 scales4 scales5;
run;

/* Print the processed dataset with summary score using the way Author C devised */
title "Processed dataset with summary score using the way Author C devised";
proc print data=score_C;
run;

/* Indicator of which author’s score was the highest (A, B, or C)*/
data FINALDATA; set score_C;
array summary_score(*) A B C;
/* Find the maximum value in summary_score array */
highest = max(OF summary_score(*));
/* Return the column index number of the matching value */
index = whichn(highest, OF summary_score(*));
/* Return the variable name with the maximum value*/
Highest_indicator = vname(summary_score[index]);
/* Rename the variable */
rename A=Author_A_score B=Author_B_score C=Author_C_score;
/* Drop the non-used variables */
drop highest index;
run;

title "Deliverable: Final data and print the first 15 observations";
proc print data=FINALDATA(obs=15);
run;
