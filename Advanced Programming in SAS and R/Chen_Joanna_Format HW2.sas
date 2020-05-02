proc format library = WORK.demographics; 
 value college_year 1="Freshman"
            		2="Sophomore"
            		3="Junior"
            		4="Senior"
            		5="Senior Plus";

 value Gender 1="Male"
  			  2="Female";

 value Residency 1="In State"
          		 2="Out of State";

 value Major 1="Chemistry"
 			 2="Biology"
			 3="Mathematics"
			 4="Physics"
			 5="Psychology"
			 6="Other";
run;
