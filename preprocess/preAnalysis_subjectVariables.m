function [subj, dataPth, roiList, roiListNoFace, voxelR2Thresh, roiType, whichExp] = preAnalysis_subjectVariables(whichExp, whichSubj, projectPth)

% INPUTS ------------

% whichExpt    : either '1' or '2'
% whichSubj    : subject number, e.g. '1', '23'

% OUTPUTS ----------------

% EXAMPLES ------------

exampleOn      = 0;
exampleOn      = checkExampleOn(exampleOn, mfilename);

if exampleOn
    whichExp   = 2;
    whichSubj  = 23;
    projectPth = '/Volumes/server/Projects/Temporal integration/fMRI/data/';
elseif ~ismember(exampleOn, [0, 1])
    error(sprintf('Unidentifiable exmapleOn value in file %s', mfilename));
end


%% preprocessing input variables

% Check if all the inputs are in the correct format

subjectList = subjList;

if ~isnumeric(whichExp),
    error('Input whichExperiment needs to be either number 1 or 2.')
elseif ~isnumeric(whichSubj)
    error('Input whichSubject needs to be a number')
elseif ~ismember(whichSubj, subjectList)
    error('Current subject is not identifiable, please check subject number.')
end

% make 'subj' ro subject ID from the input
if whichSubj < 10
    subj = sprintf('wl_subj00%d', whichSubj);
elseif whichSubj > 10
    subj = sprintf('wl_subj0%d', whichSubj);
end

disp(sprintf('\n[subjectVariables] '))
disp(sprintf('\nSUBJECT ID :                 %s', subj))
disp(sprintf('WHICH EXPERIMENT :           %d', whichExp))


%% Create subject Paths

whichExperiment = sprintf('experiment%d', whichExp);

dataPth         = fullfile(projectPth, whichExperiment, subj);
assert(exist(dataPth) == 7, 'Data path does not exist.')

disp(sprintf('DATA PATH :                  %s', dataPth))

cd(dataPth)


%% Create ROI list, GLM R2 thresholds and ROI types

roiList       = importRoiList('withface');
roiListNoFace = importRoiList('noface');
voxelR2Thresh = 0.03;
roiType       = '2to10';

disp(sprintf('CURRENT VOXEL R2 THRESHOLD : %d PERCENT', round(voxelR2Thresh * 100)))



end