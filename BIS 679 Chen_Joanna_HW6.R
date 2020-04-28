#Assignment 6, Joanna Chen, netid:wc549

#####################################################################################################
#Function: compare_two_powers

#Author: Joanna Chen

#Creation Date: November 26, 2019 

#Purpose: Conduct a simulation to compare the true power (nominal power) of the test to the empirical 
#         power estimated from simulation.

# Required Parameters: 
#      N = the total sample size (assume 1:1 allocation)
#      alpha = type I error rate (two-sided test)
#      sigma = standard deviation of the measures
#             (We assume the variance same in the two groups, i.e. sigma^2 =(sigma_1)^2 = (sigma_2)^2 )
#      delta = detectable difference
#      mu1 = the mean in group 1, such that delta= mu_2-mu_1

#Optional Parameters:
#      seed = the seed to start the random number generator; if not specified it will be a randomly selected
#             number between 1 and 999999999

#Output: the simulation results table containing the N, alpha, delta, sigma, nominal and empirical power for all scenarios

#Other Functions: calculate_nominal_power,calculate_empirical_power

#Example: compare_two_powers(N, alpha, sigma, delta, mu1)
#####################################################################################################
compare_two_powers <- function(N, alpha, sigma, delta, mu1,seed=sample(99999999,1)){
  # Generate the seed for result reproduction
  set.seed(seed)
  
  # All the Cartesian combination of the parameters 
  para_collection = expand.grid(N=N,alpha=alpha, sigma=sigma,delta=delta,mu1=mu1)
  
  #For each row of the parameter collection, calculate the nominal and empirical power
  for (i in 1:nrow(para_collection)){
    parameter_set = para_collection[i,]
    para_collection[i,6] = calculate_nominal_power(as.numeric(parameter_set[1,1]),as.numeric(parameter_set[1,2]),as.numeric(parameter_set[1,3]),as.numeric(parameter_set[1,4]))
    para_collection[i,7] = calculate_empirical_power(as.numeric(parameter_set[1,1]),as.numeric(parameter_set[1,2]),as.numeric(parameter_set[1,3]),as.numeric(parameter_set[1,4]),as.numeric(parameter_set[1,5]))
  }
  
  #Rename the column
  colnames(para_collection)[6] <- "nominal_power"
  colnames(para_collection)[7] <- "empirical_power"
  
  #Delete the column that the table not asks for
  para_collection <- para_collection[-which(names(para_collection) == 'mu1')]
 
  #Return the table
  para_collection
}

#####################################################################################################
#Function: calculate_nominal_power

#Author: Joanna Chen

#Creation Date: November 26, 2019 

#Purpose: Calculate the nominal power directly by solving for power in the equation 
#       4*sigma^2*(qnorm(1-alpha/2)+qnorm(1-beta))^2/delta^2) where the parameter is defined below.

# Required Parameters: 
#      N = the total sample size (assume 1:1 allocation)
#      alpha = type I error rate (two-sided test)
#      sigma = standard deviation of the measures
#             (We assume the variance same in the two groups, i.e. sigma^2 =(sigma_1)^2 = (sigma_2)^2 )
#      delta = detectable difference

#Output:  Nominal power

#Example: calculate_nominal_power(N, alpha, sigma, delta)
#####################################################################################################
calculate_nominal_power <- function(N, alpha, sigma, delta){
  #Compute the nomial power using the formula given in the function documentation
  nominal_power = pnorm(sqrt((N*delta^2)/(4*sigma^2))-qnorm(1-alpha/2))
  return(nominal_power)
}

#####################################################################################################
#Function: calculate_empirical_power

#Author: Joanna Chen

#Creation Date: November 26, 2019 

#Purpose: Conduct a simulation to calculate the empirical power directly by computing the proportion
#         of simulations that reject the null hypothesis based on the two-sample t-test.

# Required Parameters: 
#      N = the total sample size (assume 1:1 allocation)
#      alpha = type I error rate (two-sided test)
#      sigma = standard deviation of the measures
#             (We assume the variance same in the two groups, i.e. sigma^2 =(sigma_1)^2 = (sigma_2)^2 )
#      delta = detectable difference
#      mu1 = the mean in group 1 such that delta= mu_2-mu_1

#Output:  Empirical power

#Example: calculate_empirical_power(N, alpha, sigma, delta, mu1)
#####################################################################################################
calculate_empirical_power <- function(N, alpha, sigma, delta, mu1){
  #Initialize a vector for storing the result later
  result_vector = NULL
  
  #Simulate for 1000 times
  for (i in 1:1000){
    #Each time, generate two groups of data using N, mu1,delta, sigma
    group1 = rnorm(N/2,mean = mu1, sd = sigma)
    group2 = rnorm(N/2,mean = mu1+delta, sd = sigma)
    
    #do two-sample t-test on the data with confidence level 1-alpha
    result = t.test(group1, group2, var.equal = TRUE, conf.level = 1-alpha)
    
    #if reject, store store the indicator 1 in the result vector, otherwise, store 0.
    if(result$p.value < alpha){
      result_vector[i] = 1
    }else{
      result_vector[i] = 0
    }
  }
  #empirical power equals to the proportion of simulations that reject the null hypothesis
  empirical_power = sum(result_vector == 1) / 1000
  return(empirical_power)
}

#####################################################################################################
#Function: plot

#Author: Joanna Chen

#Creation Date: December 2, 2019 

#Purpose: Plot the empirical power on the y-axis, the detectable difference on the x-axis and have a 
#         line for each potential sample size. One plot will be created for each alpha and sigma

# Required Parameters: 
#      table = the simulation results table
#      alpha = type I error rate (two-sided test)
#      sigma = standard deviation of the measures
#             (We assume the variance same in the two groups, i.e. sigma^2 =(sigma_1)^2 = (sigma_2)^2 )

#Output:  Plot described in the purpose 

#Example: plot(table, alpha, sigma)
#####################################################################################################
plot <- function(table, alpha, sigma){
  # All the Cartesian combination of the given alpha and sigma
  cartesian_dt = expand.grid(alpha=alpha,sigma=sigma)
  
  for (i in 1:nrow(cartesian_dt)){
    # For each row of the alpha and sigma collection table, extract the value of alpha and sigma
    alpha1 = cartesian_dt[i,1]
    sigma1 = cartesian_dt[i,2]
    
    # Filter table such that the alpha, sigma in the table match the extracted value
    table_filtered = table[table$alpha == alpha1 & table$sigma == sigma1,]
    
    # Plot the empirical power on the y-axis, the detectable difference on the x-axis and have aline for each potential sample size
    p = ggplot(data = table_filtered, aes(x=delta, y=empirical_power,group = N)) + geom_point(aes(colour=N))  + geom_line(aes(colour=N)) + 
        ggtitle(paste("Simulated Power for alpha = ",alpha1, "and sigma = ", sigma1)) + xlab("Detectable Difference") + ylab("Empirical Power")
    print(p)
  }
}

# Scenario 1
N = c(100,200,300)
alpha = 0.01
sigma = 5
delta = seq(0.5,5,by = 0.5)
mu1 = 5
table1 = compare_two_powers(N, alpha, sigma, delta, mu1)
plot(table1, alpha, sigma)

# Scenario 2
N = c(20,40)
alpha = c(0.05,0.1)
sigma = c(0.5,1)
delta = seq(0.1,1,by = 0.1)
mu1 = 2
table2 = compare_two_powers(N, alpha, sigma, delta, mu1)
plot(table2, alpha, sigma)
