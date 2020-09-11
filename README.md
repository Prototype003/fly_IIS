# fly_IIS
Processing and analysis code for manuscript "Integrated information structure collapses with anesthetic loss of conscious arousal in Drosophila melanogaster"

## Extracting preprocessed trials
bin/main_postPuffPreStim_extract.m  
Preprocessed trials can be found here - doi:10.26180/5ebe420ae8d89  
File (split2250_bipolarRerefType1_lineNoiseRemoved_postPuffpreStim.mat) should be stored in bin/workspace_results/  

## Core scripts/functions for obtaining IIS and SII using pyphi:
bin/fly_phi.py - underlying functions for binarisation of fly data, building TPM, parsing pyphi output  
bin/phi_3/phi_compute.py - computation of IIS and SII for a given channel-set/fly/trial/condition combination - outputs to bin/phi_3/results_split/  

## Core scripts for IIS/SII computation using MASSIVE:
bin/phi_3/bash_array_commands.py - lists all combinations of channel-set/fly/trial/condition for computation (outputs to bin/phi_3/array_commands)  
bin/phi_3/bash_compute_sbatch - job submission script to compute for a given parameter combination  
bin/phi_3/bash_loop_compute.bash - job submission loop - loops through array_commands and submits one job per line  
bin/phi_3/results/join_split_4ch.m - script for joining all channel-set/fly/trial/condition combinations into a single file - outputs to bin/phi_3/results_split/  

## Core plotting and statistical analyses scripts:
bin/phi_3/main_avi.m - plotting and statistical tests (LME and summary stats) for II and IIS values  

## Core classification analysis scripts and functions (requires LIBLINEAR; https://www.csie.ntu.edu.tw/~cjlin/liblinear/):
bin/svm_classification_nestedValidation/svm_loo_liblinear_manual.m - function for conducting SVM classification with nested cross-validation for cost-parameter search  
bin/svm_classification_nestedValidation/main_classify_concept.m - script/function for carrying out within/across-fly classification using SII, IIS, and individual II values  
bin/svm_classification_nestedValidation/main - script for plotting classification results and conducting related stats (requires RainCloudPlots; https://github.com/RainCloudPlots/RainCloudPlots)  

Code here is a subset of a larger (currently private) repository with many (many) undirectly related files. So maybe there are some dependencies missing (and also there may be extra, redundant files).
