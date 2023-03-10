#!/bin/sh
### General options 
### -- specify queue -- 
#BSUB -q hpc
### -- set the job Name (outcommented)-- 
#BSUB -J Biomass_Money_scenario(1)
### -- ask for number of cores (default: 1) -- 
#BSUB -n 8
### -- specify that the cores must be on the same host -- 
#BSUB -R "span[hosts=1]"
### -- specify that we need 5GB of memory per core/slot -- 
#BSUB -R "rusage[mem=10GB]"
### -- specify that we want the job to get killed if it exceeds 10 GB per core/slot -- 
#BSUB -M 13GB
### -- set walltime limit: hh:mm -- 
#BSUB -W 12:00 
### -- set the email address -- 
# please uncomment the following line and put in your e-mail address,
# if you want to receive e-mail notifications on a non-default address
##BSUB -u phisw@dtu.dk
### -- send notification at start -- 
#BSUB -B 
### -- send notification at completion -- 
#BSUB -N 
### -- Specify the output and error file. %J is the job-id -- 
### -- -o and -e mean append, -oo and -eo mean overwrite -- 
#BSUB -oo Output_%J.out 
#BSUB -eo Error_%J.err 

# here follow the commands you want to execute 

gams /zhome/21/a/153640/VariableCapacities/Moneyperunitsold/ScenarioBiomassMoney/variable_system_biomass_scenario_money o=variable_system_biomass_scenario_money.lst 
