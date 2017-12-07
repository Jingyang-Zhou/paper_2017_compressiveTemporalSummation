% individual pre-processing ROIs

% DESCRIPTION ----------------------------------------------------

% This is the list of things that this file does:

% (1) extract face areas based on the functional data;
% (2) combine bilateral ROIs from the existing ROIs defined; (GRAY VIEW)
% (3) extract 2- 10 degree eccentricity ROI, low eccentricity (2 - 5 degree)
%     ROI, and high eccentricity (5 - 10 degree) ROI. (GRAY VIEW)
% (4) Import Gray view ROIs to inplane view.
% (5) normalize data in each voxel and each ROI to L2 norm

%% 


%% Paths and directories

codePth = '/Volumes/server/Projects/Temporal integration/fMRI/code/';
utilPth = '/Volumes/server/Projects/Temporal integration/temporalUtils/';

addpath(genpath(codePth))
addpath(genpath(utilPth))

%% 

mrvCleanWorkspace;
clx

projectPth ='/Volumes/server/Projects/Temporal integration/fMRI/data/';
expNum     = 2;
subjNum    = 31;

[subjID, dataPth, roiList, roiListNoFace, voxelR2Thresh, roiType, expNum] = ...
    preAnalysis_subjectVariables(expNum, subjNum, projectPth);

%% make bilateral ROIs

preAnalysis_makeBilateralROIs(dataPth, roiList);

%% extract 2- 10 degree ROIs

[originalNVoxels, restrictedNVoxels] = preAnalysis_extractRangedROI(subjID, dataPth, roiList, roiListNoFace, expNum);

%% load ROI data

saveData = 1;
preAnalysis_loadROIdata;

% 3 voxels numbers : originalNVoxels, restrictedNVoxels, nVoxelPerRoi
