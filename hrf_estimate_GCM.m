function hrf_estimate_GCM(GCM_name)

	GCM = spm_dcm_load(GCM_name);
	GCM = spm_dcm_fit(GCM);
	save(strcat('../results/', GCM_name), 'GCM');

end