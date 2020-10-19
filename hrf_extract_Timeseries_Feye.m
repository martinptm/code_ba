% Verwendete Funktion
% Nur die ICs und HGpms für 4-ROI-Modelle extrahieren.
%
% Signifikante Voxel ohne FWE > 0.01 werden eingeschlossen,
% Zenrums-Suche für 5mm bewegliche Sphäre innerhalb 10mm Box.
% Erstellte Dateien erhalten Endung "_ddriven.mat".
%
% Die Daten werden mit F-Kontrast Nr. 7 (eye(3)) Mean-Korrigiert. 
% (!!! Kontrast-Erstellung bisher nicht im GLM-Skript enthalten, wurde per Hand
% durchgeführt !!!)
%

% Option ob anatomische Koordinaten ohne Threshold, 
% oder beweglicher(er) Mittelpunkt mit Threshold für Voxel
fix = false;

startdir = pwd;
addpath('/Users/martin/Documents/MATLAB/Uni/6_Semester/BA/spm12')

load('/Users/martin/Documents/MATLAB/Uni/6_Semester/BA/Bin_Loud/GLM_data/coordinates_subjects.mat');	% get 'new_data'-struct

VP_Numbers = [2:3 4 9 13 14 16:17 19:20 22 24:25]; 

if fix == false

	boxdimIC = 10; % mm 

	% run for every subject
	for counter = 1:length(VP_Numbers)

		n_subject = VP_Numbers(counter);

		% both hemispheres
		for n_leftright = 1:2
			for n_roi = [1,5]	% indices of IC & HGpm in data-table 

				cd '/Users/martin/Documents/MATLAB/Uni/6_Semester/BA/Bin_Loud/'

				% the subject's SPM .mat filename here
				pathextension = '';
				if n_subject < 10
					pathextension = strcat('VP_0', num2str(n_subject))
				else 
					pathextension = strcat('VP_', num2str(n_subject))		
				end
				disp(strcat('Current subject: ', pathextension ));
				spm_mat_file = strcat(pathextension, '/models/unsmoothed_hrf/SPM.mat');					%%% ANPASSUNG HRF %%%

				% Start batch
				clear matlabbatch;
				matlabbatch{1}.spm.util.voi.spmmat  = cellstr(spm_mat_file);

				matlabbatch{1}.spm.util.voi.adjust  = 7;  					% Effects of interest contrast number <-------------- !!!!!!!!!!
				matlabbatch{1}.spm.util.voi.session = 1;                    % Session index

				% rois in left hemisphere 
				if n_leftright == 1
					name = strcat(  new_data{n_subject}.roi(n_roi), '_left_ddriven_Feye.mat');
				% rois in right hemisphere
				else 
					name = strcat(new_data{n_subject}.roi(n_roi), '_right_ddriven_Feye.mat');
				end

				disp('Name:')
				name = convertStringsToChars(name)

				matlabbatch{1}.spm.util.voi.name = name;	              	% VOI name

				% Define thresholded SPM for finding the subject's local peak response
				matlabbatch{1}.spm.util.voi.roi{1}.spm.spmmat      = {''};
				matlabbatch{1}.spm.util.voi.roi{1}.spm.contrast    = 1;     % Index of contrast for choosing voxels
																			% Noise-Silence
				matlabbatch{1}.spm.util.voi.roi{1}.spm.conjunction = 1;
				matlabbatch{1}.spm.util.voi.roi{1}.spm.threshdesc  = 'none';
				matlabbatch{1}.spm.util.voi.roi{1}.spm.thresh      = 0.01;
				
				matlabbatch{1}.spm.util.voi.roi{1}.spm.extent      = 0;
				matlabbatch{1}.spm.util.voi.roi{1}.spm.mask ...
				    = struct('contrast', {}, 'thresh', {}, 'mtype', {});

				% Define large fixed outer sphere
				% and make sure, that centrum of IC-ROI is constrained to the correct hemisphere
				% by setting Box-Ventre to at least half of the Box-Width in x-direction.
				if n_leftright == 1
					if new_data{n_subject}.x_l(n_roi) > -boxdimIC/2
						xyz = [-boxdimIC/2, new_data{n_subject}.y_l(n_roi), new_data{n_subject}.z_l(n_roi)];
						disp('Warning: ROI close to central')
					else
						xyz = [new_data{n_subject}.x_l(n_roi), new_data{n_subject}.y_l(n_roi), new_data{n_subject}.z_l(n_roi)];	
					end
				else
					if new_data{n_subject}.x_r(n_roi) < boxdimIC/2
						disp('Warning: ROI close to central')
						xyz = [-boxdimIC/2, new_data{n_subject}.y_r(n_roi), new_data{n_subject}.z_r(n_roi)];
					else
						xyz = [new_data{n_subject}.x_r(n_roi), new_data{n_subject}.y_r(n_roi), new_data{n_subject}.z_r(n_roi)];
					end
				end

				% Define large fixed outer sphere
				matlabbatch{1}.spm.util.voi.roi{2}.box.centre     = xyz; % Set coordinates here
				matlabbatch{1}.spm.util.voi.roi{2}.box.dim     	  = [boxdimIC boxdimIC boxdimIC];           
				matlabbatch{1}.spm.util.voi.roi{2}.sphere.move.fixed = 1;

				% Define smaller inner sphere which jumps to the peak of the outer sphere
				matlabbatch{1}.spm.util.voi.roi{3}.sphere.centre           = [0 0 0]; % Leave this at zero
				matlabbatch{1}.spm.util.voi.roi{3}.sphere.radius           = 5;       % Set radius here (mm)
				matlabbatch{1}.spm.util.voi.roi{3}.sphere.move.global.spm  = 1;       % Index of SPM within the batch
				matlabbatch{1}.spm.util.voi.roi{3}.sphere.move.global.mask = 'i2';    % Index of the outer sphere within the batch

				% Include voxels in the thresholded SPM (i1) and the mobile inner sphere (i3)
				matlabbatch{1}.spm.util.voi.expression = 'i1 & i3'; 

				% Run the batch
				spm_jobman('run',matlabbatch);
			end
		end
	end
elseif fix == true

	% run for every subject
	for counter = 1:length(VP_Numbers)

		n_subject = VP_Numbers(counter);

		% hemispheres
		for n_leftright = 1:2
			for n_roi = [1,5]	% indices of IC & HGpm in data-table 

				cd '/Users/martin/Documents/MATLAB/Uni/6_Semester/BA/Bin_Loud/'

				% the subject's SPM .mat filename here
				pathextension = '';
				if n_subject < 10
					pathextension = strcat('VP_0', num2str(n_subject))
				else 
					pathextension = strcat('VP_', num2str(n_subject))		
				end
				disp(strcat('Current subject: ', pathextension ));
				spm_mat_file = strcat(pathextension, '/models/unsmoothed_hrf/SPM.mat');					%%% ANPASSUNG HRF %%%

				% Start batch
				clear matlabbatch;
				matlabbatch{1}.spm.util.voi.spmmat  = cellstr(spm_mat_file);

				matlabbatch{1}.spm.util.voi.adjust  = 7;  					% Effects of interest contrast number <-------------- !!!!!!!!!!
				matlabbatch{1}.spm.util.voi.session = 1;                    % Session index

				% rois in left hemisphere 
				if n_leftright == 1
					name = strcat(  new_data{n_subject}.roi(n_roi), '_left_fix_Feye');
				% rois in right hemisphere
				else 
					name = strcat(new_data{n_subject}.roi(n_roi), '_right_fix_Feye');
				end

				disp('Name:')
				name = convertStringsToChars(name)

				matlabbatch{1}.spm.util.voi.name = name;	              	% VOI name

				% Define thresholded SPM for finding the subject's local peak response
				matlabbatch{1}.spm.util.voi.roi{1}.spm.spmmat      = {''};
				matlabbatch{1}.spm.util.voi.roi{1}.spm.contrast    = 1;     % Index of contrast for choosing voxels
																			% Noise-Silence
				matlabbatch{1}.spm.util.voi.roi{1}.spm.conjunction = 1;
				matlabbatch{1}.spm.util.voi.roi{1}.spm.threshdesc  = 'none';
				matlabbatch{1}.spm.util.voi.roi{1}.spm.thresh      = 1;		% <--------------
				
				matlabbatch{1}.spm.util.voi.roi{1}.spm.extent      = 0;
				matlabbatch{1}.spm.util.voi.roi{1}.spm.mask ...
				    = struct('contrast', {}, 'thresh', {}, 'mtype', {});

				% Define large fixed outer sphere
				if n_leftright == 1
					xyz = [new_data{n_subject}.x_l(n_roi), new_data{n_subject}.y_l(n_roi), new_data{n_subject}.z_l(n_roi)];	%n_subject, da aus Excel auch die leeren Probanden eingelesen (N=27)
				else
					xyz = [new_data{n_subject}.x_r(n_roi), new_data{n_subject}.y_r(n_roi), new_data{n_subject}.z_r(n_roi)];
				end

				% Define large fixed outer sphere
				matlabbatch{1}.spm.util.voi.roi{2}.sphere.centre     = xyz; % Set coordinates here
				matlabbatch{1}.spm.util.voi.roi{2}.sphere.radius     = 2;           % Radius (mm)
				matlabbatch{1}.spm.util.voi.roi{2}.sphere.move.fixed = 1;

				% Define smaller inner sphere which jumps to the peak of the outer sphere
				matlabbatch{1}.spm.util.voi.roi{3}.sphere.centre           = [0 0 0]; % Leave this at zero
				matlabbatch{1}.spm.util.voi.roi{3}.sphere.radius           = 5;       % Set radius here (mm)
				matlabbatch{1}.spm.util.voi.roi{3}.sphere.move.global.spm  = 1;       % Index of SPM within the batch
				matlabbatch{1}.spm.util.voi.roi{3}.sphere.move.global.mask = 'i2';    % Index of the outer sphere within the batch

				% Include voxels in the thresholded SPM (i1) and the mobile inner sphere (i3)
				matlabbatch{1}.spm.util.voi.expression = 'i1 & i3';

				% Run the batch
				spm_jobman('run',matlabbatch);
			end
		end
	end
end

cd(startdir)
