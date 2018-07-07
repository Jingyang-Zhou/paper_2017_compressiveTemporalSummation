% total 262.5 seconds, 4.375 minutes, 175 TRs

% Initial 8 TRS, 54 trials, each trial 4.5s, 5 TRs at the end



params = retCreateDefaultGUIParams;
params.fixation      = 'digits';
params.skipSyncTests = false;
params.triggerKey    = '`';
params.calibration   = 'CBI_NYU_projector'; % change this field to the calibration file measured about your specific devices
params.experiment    = 'experiment from file';
loadMatrix_str       = 'temporalExp6.mat'; % For example, "temporalExp1.mat"
params.loadMatrix    = loadMatrix_str;
params.modality      = 'fMRI';
params.devices       = 'External: 5'; 
ret(params)


%%

% data = '~/Desktop/20160118t133052.mat';
% a =load(data);
% [m, result]= analyze_key_presses(a, 1, [], 1)
