proc format;
	value age_groupf
	1 = '18-34'
	2 = '35-54'
	3 = '55-74'
	4 = '>=75';

	value race_ethnicityf
	1 = 'Non-Hispanic white'
	2 = 'non-Hispanic black'
	3 = 'Hispanic'
	4 = 'Asian/other';

	value pain_typef
	1 = 'Head'
	2 = 'Neck'
	3 = 'Chest'
	4 = 'Abdomen'
	5 = 'Back'
	6 = 'Lower Extremity' 
	7 = 'Upper Extremity'
	8 = 'Generalized'
	9 = 'Other' 
	10 = 'Multiple';

	value severity_of_painf
	1 = 'no pain'
	2 = 'mild pain' 
	3 = 'moderate pain'
	4 = 'severe pain';

	value provider_typef
	1 = 'Physician/attending'
	2 = 'Intern/resident'
	3 = 'Midlevel';

	value sexf
	1 = 'Female'
	2 = 'Male';

	value analgesicf
	1 = 'With Analgesic'
	2 = 'Without Analgesic';
run;