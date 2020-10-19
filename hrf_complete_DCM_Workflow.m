%%
%	Enthält gesamten Workflow, nachdem VOI-Dateien erstellt.
%
%	-> Spezifikation & Schätzung der DCMs
%	-> Spezifikation & Schätzung des PEB
%	-> BMR & BMA
%

%% one example
%model_name = 'hrf_ddriven_sparse_Feye';
% vois = 'ddriven_Feye';					% type of VOI
% connectivity = 'sparse';					% connectivity in A-matrix
% modulate_ipsi = 'nomod';					% B-matrix
% two_state = false;					
% centre_mean = false;
% C_contralat = false;						% C-matrix
% stochastic_true = false;					
% TR_setting = false;

%% ------------------- Specify ------------------- 
hrf_specify_DCMs(model_name, 1:11, two_state, centre_mean, vois, connectivity, modulate_ipsi, C_contralat, stochastic_true, TR_setting)
hrf_specify_GCM(strcat('DCM_', model_name, '.mat'))

%% ------------------- Estimate ------------------- 
hrf_estimate_GCM(strcat('GCM_', model_name, '.mat'))
hrf_PEB_workflow(strcat('../results/GCM_', model_name, '.mat'), model_name)

% ------------------- Review ------------------- 
load(strcat('../results/GCM_', model_name, '.mat'))
load(strcat('../results/PEB_', model_name, '.mat')) % or BMA

spm_dcm_peb_review(PEB, GCM) % or BMA


