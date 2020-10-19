function hrf_specify_DCMs(file_name, subject_indices, two_state, centre_input, alternativeROIs, fully_con, modulate_ipsi, C_contralat, stochastic_true, half_TR)
% 
% Only some of the examples for the connectivity-specifications used in the work.
%

% MRI scanner settings
% TR = see later in code
TE = 0.04; % Echo time (secs)

subject_nrs = [2:3 4 9 14 16:17 19:20 22 24];

nregions = 4; 
nconditions = 3;
% Index of each condition in the DCM
BOTH  = 1; 
LEFT  = 2; 
RIGHT = 3;
% Index of each region in the DCM
IC_left 	= 1;
IC_right 	= 2;
HGpm_left 	= 3;
HGpm_right 	= 4;

%%%%%%%%%%%%%%%% A-Matrix %%%%%%%%%%%%%%%%
if isequal(fully_con, 'fully')
	a = ones(4);	% fully connected 
	disp("A is fully connected")
elseif isequal(fully_con, 'sparse')
	a = eye(4);
	a(3,1) = 1;
	a(4,2) = 1;
	disp("A is sparse connected")
end
	
%%%%%%%%%%%%%%%% B-Matrix %%%%%%%%%%%%%%%%
b(:,:,BOTH)  = zeros(4);  
b(:,:,LEFT)  = zeros(4);  
b(:,:,RIGHT) = zeros(4);
if isequal(modulate_ipsi, 'both')  
	b(3,1,BOTH)  = 1; 
	b(4,2,BOTH)  = 1; 
	b(3,1,LEFT)  = 1;
	b(4,2,LEFT)  = 1;  
	b(3,1,RIGHT) = 1;
	b(4,2,RIGHT) = 1;
	disp("B-ENTRYS: condition independent modulation of ipsilateral connections")
elseif isequal(modulate_ipsi, 'nomod')  
	disp("NO B-ENTRYS")
end

%%%%%%%%%%%%%%%% C-Matrix %%%%%%%%%%%%%%%%
if C_contralat
	c = [1 0 1
		 1 1 0
		 0 0 0
		 0 0 0];
	disp("C a priori contralateral")	 
else
	c = [1 1 1
		 1 1 1
		 0 0 0
		 0 0 0];
	disp("C a priori no distinction")
end

% D-matrix (disabled, because bilinear models, but must be specified)
d = zeros(nregions, nregions, 0);

start_dir = pwd;
for subject = subject_nrs(subject_indices)
	name = sprintf('VP_%02d',subject)

	glm_dir = fullfile('/Users/martin/Documents/MATLAB/Uni/6_Semester/BA/Bin_Loud/', name, '/models/unsmoothed_hrf/')

	SPM = load(fullfile(glm_dir, 'SPM.mat'));
	SPM = SPM.SPM;

	% get mean time between scans for this VP
	TR = SPM.xY.RT;
	if isequal(half_TR, 'half_TR') 
		TR = TR/2;
		disp('half TR')
	elseif isequal(half_TR, 'TR_1_25') 
		TR = 1.25;
		disp('TR = 1.25s')
	end

	% Load ROIs
	if isequal(alternativeROIs, 'fix_Feye') 
		f = {
			fullfile(glm_dir ,'VOI_IC_left_fix_Feye_1.mat'); 
			fullfile(glm_dir ,'VOI_IC_right_fix_Feye_1.mat'); 
			fullfile(glm_dir ,'VOI_HGpm_left_fix_Feye_1.mat'); 
			fullfile(glm_dir ,'VOI_HGpm_right_fix_Feye_1.mat');
			};
		disp('Uses fix-Feye adjusted ROIs');
	end

	for r = 1:length(f) 
		XY = load(f{r});
		xY(r) = XY.xY;
	end

	% Move to output directory
	cd(glm_dir);
	% Select whether to include each condition from the SPM.mat % (Task, Pictures, Words)
	include = [1 1 1]';

	% Specify the DCM
	s = struct(); 
	s.name = file_name;				
	s.u = include;
	s.delays = repmat(TR,1,nregions);
	s.TE = TE;
	s.nonlinear = false;
	s.two_state = two_state;
	s.stochastic = stochastic_true;
	s.centre = centre_input;
	s.induced = 0;
	s.a = a;
	s.b = b;
	s.c = c;
	s.d = d;
	
	DCM = spm_dcm_specify(SPM,xY,s);
	% Return to script directory
	cd(start_dir);
end

end