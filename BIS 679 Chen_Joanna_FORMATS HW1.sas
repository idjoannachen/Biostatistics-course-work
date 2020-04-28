/*		Homework 1, Joanna Chen, netid: wc549		*/
/* Format File */
proc format library=WORK.bili;
value status 
           1 = 'Death'
           2 = 'Transplantation'
           0 = 'Censored';
value drug 
           1 = 'D-penicillamine'
           2 = 'placebo'; 
value sex 
           0 = 'Male'
           1 = 'Female';
value ascites
		   0 = 'No'
           1 = 'Yes';
value hepatomegaly
		   0 = 'No'
           1 = 'Yes';           
value spiders
		   0 = 'No'
           1 = 'Yes';
value edema
		   0 = 'No edema and no diuretic therapy for edema'
           0.5 = 'Edema present without diuretics, or edema resolved by diuretics'
           1 = 'Edema despite diuretic therapy';
value edema_new
		   0 = 'No'
		   1 = 'Yes';   
run;
