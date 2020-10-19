function hrf_PEB_workflow(gcm_path, peb_bma_name)
%%
%

% load design-matrix for PEB-GLM (contains only similarities, i.e. mean)
dm = load('hrf_ped_design01.mat')
dm = dm.dm;
X = dm.X;
X_labels = dm.labels;

GCM = load(gcm_path)
GCM = GCM.GCM;

% PEB-settings 
M 			= struct();
M.Q 		= 'all';
M.X 		= X;
M.Xnames 	= X_labels;

if strfind(gcm_path, 'mod')
	disp('A-, B- and C-Matrix in PEB')

	[PEB_ABC, RCM_ABC] = spm_dcm_peb(GCM, M, {'A', 'B', 'C'});
	save(strcat('../results/PEB_', peb_bma_name), 'PEB_ABC', 'RCM_ABC');

	% model comparison automatic search
	% alternatively previously defined 
	% model-templates can be compared.
	BMA_ABC = spm_dcm_peb_bmc(PEB_ABC);			% [BMA, BMR] für BMR-Ergebnisse, siehe PEB-Tutorial, S. 25
	save(strcat('../results/BMA_', peb_bma_name), 'BMA_ABC');
else
	disp('A- and C-Matrix in PEB')
	[PEB_AC, RCM_AC] = spm_dcm_peb(GCM, M, {'A', 'C'});
	save(strcat('../results/PEB_', peb_bma_name), 'PEB_AC', 'RCM_AC');

	% model comparison automatic search
	% alternatively previously defined 
	% model-templates can be compared.
	BMA_AC = spm_dcm_peb_bmc(PEB_AC);			% [BMA, BMR] für BMR-Ergebnisse, siehe PEB-Tutorial, S. 25
	save(strcat('../results/BMA_', peb_bma_name), 'BMA_AC');
end

end

