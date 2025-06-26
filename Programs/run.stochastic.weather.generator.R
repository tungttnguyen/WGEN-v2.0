
# rm(list=ls())
start_time0 <- Sys.time()

# Remove output first ----------------------------------------------------

out_csv_dir <- "Data/output.data.files"
out_wgen_dir <- "Data/simulated.data.files/WGen.out"
if (dir.exists(out_csv_dir)) unlink(out_csv_dir, recursive = TRUE)
if (dir.exists(out_wgen_dir)) unlink(out_wgen_dir, recursive = TRUE)
# Recreate empty output folders
dir.create(out_csv_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(out_wgen_dir, showWarnings = FALSE, recursive = TRUE)

# Load libraries ----------------------------------------------------------

library(MASS)
library(lpSolve)
library(mvtnorm)
library(moments)
library(abind)
library(lubridate)
library(depmixS4)
library(markovchain)
library(rebmix)
library(evmix)
library(eva)
library(POT)
library(extRemes)
library(ismev)
library(fExtremes)
library(parallel)
library(tictoc)
library(zoo)
library(proxy)
library(scales)
library(readxl)

source("./Programs/config.simulations.R") # config file

lst <- config.simulations() # call in configuration inputs
for (i in 1:length(lst)) {assign(names(lst[i]), lst[[i]]) }; rm(lst)


#*************************************
#--- Weather Regimes Module ---#
#use provided WRs
if (use.provided.WRs){
  final.NHMM.output <- readRDS('./Data/simulated.data.files/WRs.out/final.NHMM.non_param.output.rds')
  weather.state.assignments <- final.NHMM.output$WR.historical # this is the historical WRs 
  num.states <- length(unique(as.vector(weather.state.assignments)))    #number of WRs in the model
  dates.sim <- final.NHMM.output$dates.sim
  markov.chain.sim <- final.NHMM.output$WR.simulation
  dates.synoptics <- final.NHMM.output$dates.historical
  #simulate your own WRs
} else{
  final.NHMM.output <- execute.WRs.non_param.NHMM()
  weather.state.assignments <- final.NHMM.output$WR.historical # this is the historical WRs 
  num.states <- length(unique(as.vector(weather.state.assignments)))    #number of WRs in the model
  dates.sim <- final.NHMM.output$dates.sim
  markov.chain.sim <- final.NHMM.output$WR.simulation
  dates.synoptics <- final.NHMM.output$dates.historical
}
rm(final.NHMM.output) # for memory

start_time2 <- Sys.time()
#*************************************
#--- Weather Generation Module ---#
execute.simulations()
# done. #
Sys.time() - start_time2

# EXTRA #
### Below are auxiliary functions to do a list of tasks
#*************************************
# - create sample figures for selected scenario
# - generate individual output files in tab or text delimited formats

#this is the scenario (i.e., the row in ClimateChangeScenarios.csv) for which to make plots and write out the data as .csv files
selected_scenario = 1

#--- outputs ---#
# YYYY, MM, DD, P(mm), Tmax(C), Tmin(C) in .csv individual lat/lon file #
# for simulated data #
start_time3 <- Sys.time()
create.delimited.outputs(scenario = selected_scenario)
Sys.time() - start_time3

#--- figures ---#
# arguments are labels for x and y-axes
start_time4 <- Sys.time()
create.figures.baselines.stacked(scenario = selected_scenario)
Sys.time() - start_time4

end_time0 <- Sys.time() - start_time0
end_time0

print(paste("Total run time:", round(end_time0, 2)))
