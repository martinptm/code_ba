%
% Erstelle GCM, dass direkt die DCM-Structs enthält (nicht nur die Pfade zu den DCMs)
%
function hrf_specify_GCM(filename)
	% @Input: File-Name des DCMs für eine VP 
	dcms = spm_select('FPListRec', '/Users/martin/Documents/MATLAB/Uni/6_Semester/BA/Bin_Loud', filename);
	GCM = cellstr(dcms)
	GCM_name = strcat('GCM_', filename(5:end))
	save(GCM_name, 'GCM')

	hrf_convert_GCM(GCM_name)
end

function hrf_convert_GCM(GCM_name)
% Takes a GCM containig the paths to the 
% individual DCMs and fills in the DCM-
% structs directly into the GCM.

GCM = load(GCM_name);
GCM = GCM.GCM;
GCMnew = {};

for c = 1:length(GCM)
	DCM = load(GCM{c});
	GCMnew{end+1, 1} = DCM.DCM;
end 
GCM = GCMnew;
save(strcat('../results/', GCM_name), 'GCM')

end