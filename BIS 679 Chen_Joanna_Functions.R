# Check if the package is installed. If not, install it before loading.
if(!require("data.table")){
  install.packages("data.table",repos = "http://cran.us.r-project.org")
}
library(data.table)

if(!require("reshape2")){
  install.packages("reshape2",repos = "http://cran.us.r-project.org")
}
library(reshape2)

#####################################################################################################
#Function: stratified

#Author: Joanna Chen

#Creation Date: November 12, 2019 

#Purpose: Perform stratified randomization for t treatments (where t can range between 2 and 5) and s  #         strata (where s can range between 1 and 8).

# Required Parameters: 
#      N = total number of individuals
#      s = total number of stratum
#      allocation = sample size per cluster. When the sample size is equal, user should specify 'equal'. When the sample size per cluster is not equal, user should specify a vector of the sample sizes for the s strata.
#      t = total number of treatment assignment
#      seed = the seed used to generate the randomization scheme
#NOTE: 1. Individuals have an equal probability of being assigned to one of the t treatments.
#      2. If the stratum sample size is not a multiple of the number of treatments, the function randomizes the smallest whole number that is a multiple of the number of treatments and is at least the size of the stratum sample size. Given this, the final sample size of the randomization may exceed the total sample size provided.

#Output:  a list which contains 
#         (1) a matrix with the individual identifier, stratum number, and the treatment assignment; 
#         (2) a matrix with the distribution of treatments by strata (i.e. a summary table); 
#         (3) the seed used to generate the randomization scheme. 

#Example: stratified(100,4,'equal',2,89675) 
#         stratified(200,3,c(80,70,50),3,124589)

#####################################################################################################

stratified <- function(N=N,s=s,allocation=allocation,t=t,seed=seed){
  # Return warning message when t or s is out of range and that ends the function. 
  # The reason why I didn't use stop() is because it will directly give error so that knit won't work.
  if(t<2|t>5) {
    return(print("t can only range between 2 and 5"))
  }
  if((s<1)|(s>8)) {
    return(print("s can only range between 1 and 8"))
  }
  
  print("Note that the row is strata, the column is treatment.")
  # sets seed 
  set.seed(seed)
  # create individual identifier
  id = c(1:N)
  
  # initializes an empty vector to store the size of each strata later
  stratum_size=NULL
  
  # Case 1: the allocation is in type of character and equal to 'equal'
  if(is.character(allocation) && allocation == 'equal'){
    # Define the sample size per stratum which is equal to the total individual number divide by the number of stratum
    stratum_size = N/s
    # Generate a vector represents the sample sizes for s strata. In this case, we just need to replicate the sample size for each stratum s times. 
    stratum = sample(rep(1:s,stratum_size))
    # We have t treatment. Randomize the treatement of the size N from element 1:t with replacement.
    treatment = sample(t,size = N,replace=TRUE)
  }
  # Case 2: the allocation is a vector of the sample sizes for the s strata
  else {
    # If the stratum sample size is not a multiple of the number of treatments, randomize the smallest whole number that is a multiple of the number of treatments. This following way also covers the case that stratum sample size is a multiple of the number of treatments.
    for (i in 1:length(allocation)){
      allocation [i] = ceiling(allocation[i]/t)*t
    }
    # Generate a vector represents the updated sample sizes for s strata.
    stratum = NULL
    for (i in 1:s) {
      stratum = c(stratum,rep(i,allocation[i]))
    }
    stratum = sample(stratum) # Random sampling the stratum vector
    # Because the stratum size changes, treatement size also needs to be change correspondingly
    treatment = sample(t,size = length(stratum),replace=TRUE)
    # So is id variable, the size needs to be consensus with length of stratum
    id = c(1:length(stratum))
  }
  
  # Generate the first table. Take id, treatement, stratum and combine by columns.
  table1 = cbind(id,treatment,stratum)
  
  # Generate the second table (summary table)
  # First set table1 from matrix to data.table. Use .N and group by to get the number (N) of rows per case of treatement and stratum. Then use dcast() in the reshape2 library, reshape the result such that stratum as rows and treatement as columns and filled the cells by N
  table2 = as.data.frame(dcast(setDT(as.data.frame(table1))[,.N,by=.(treatment,stratum)],stratum~treatment, value.var="N"))
  # Delete the stratum column because it's the same as the row number of the dataframe. (Set as matrix later and row number will also show on the result. We don't want redundant information.)
  table2$stratum = NULL
  # Set table 2 as matrix so we can put in a list later.
  table2 = as.matrix(table2)
  # Compute the distribution of distribution of treatments by strata
  table2 = table2/rowSums(table2)
  # If you want to print the treatement# at the top of each column, you can do the following. I didn't do it because it doesn't look good aesthetically. 
  # table2 = rbind(paste("Treatment",1:nrow(table2)), table2)
  
  # Return a list
  list = list(table1,table2,seed)
  return(list)
}
