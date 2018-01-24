function [data, model] = loadfiles(fileLoc, whichDataType)
%
% [data, model] = loadfiles(fileLoc, whichDataType)
%
%% Description

% example:
% fileLoc = '/Volumes/server/Projects/Temporal_integration/files';
% whichDataType = 'fmri1'; % options: 'fmri1', 'fmri2', 'fmri1ecc'

%% load the data and the model file

dataFile  = fullfile(fileLoc, 'trf_fmriData.mat');
modelFile = fullfile(fileLoc, 'trf_modelPrms.mat');

if ~exist('whichDataType', 'var')
    data  = load(dataFile, 'data');
    model = load(modelFile);
else 
    data  = load(dataFile, whichDataType);
    model = load(modelFile, whichDataType);
end

end