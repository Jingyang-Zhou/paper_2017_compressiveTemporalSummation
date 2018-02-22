% analyze fMRI data
function [] = trf_fitModel(analyzeWhichData, expNum, doWhichAnalysis)

% description

%% knobs

analyzeWhichData = 'exp1';
expNum = 1;
% options are {'exp1', 'exp1indi', 'exp1ecc', 'exp2'};

% fit which model: options are {'linear', 'STN', 'ETC'}
fitLin = 1;
fitSTN = 1;
fitETC = 1;

doWhichAnalysis  = 'all';
% options are 'up to derived parameters' or 'all'

% options are {'grid fit', 'fine fit', 'xvalidate', 'derive parameters', 'all'}
% note that only 'all' and 'grid fit' can be computed independently, other
% options required importing pre-computed results

%% load data and stimulus

% load data and parameters ----------------------------------------
fLoc  = fullfile(temporalRootPath, 'data', 'fMRI');
fName = 'trf_fmridata.mat';

a     = load(fullfile(fLoc, fName));
data  = a.data;
param = a.param;

% load stimulus ---------------------------------------------------
% Stimulus for the first experiment:
[stim1, t1] = importStimulus('with0');

% Stimulus for the second experiment:
stim2 = [stim1(1 : 12, :); stim1(1 : 12, :); stim1(13, :)];
t2    = [1 : size(stim2, 2)]./1000;

switch expNum
    case 1, stim = stim1; t = t1;
    case 2, stim = stim2; t = t2;
end

%% preping to fit models

inputdt = []; rsdata  = []; lin = []; stn = []; etc = [];

%% extract and reshape the data
% There are three sets of data, the first experiment, the first experiment
% divided by different eccentricity group, and the second experiment. 

% reshape each data set into [stimulus conditions x bootstraps],
% for example: size of the reshaped exp1 data: 13 x 900
inputdt = trf_reshape(data, analyzeWhichData);
        
%% grid fit for STN and ETC
% estimated time to run this part:
if strcmp(doWhichAnalysis, 'all') | strcmp(doWhichAnalysis, 'up to derived parameters')
    if fitSTN, [stn.seed, stn.seedr2] = trf_gridFit(inputdt, 'STN', expNum, param, stim, t); end
    if fitETC, [etc.seed, etc.seedr2] = trf_gridFit(inputdt, 'ETC', expNum, param, stim, t); end
end

%% fine fit for all models (linear, STN, and ETC)
% estimated time to run this part:
if strcmp(doWhichAnalysis, 'all') | strcmp(doWhichAnalysis, 'up to derived parameters')
    if fitLin, [lin.param, lin.prd, linr2] = trf_fitLinear2fMRI(inputdt', stim, expNum); end
    
    if fitSTN, [stn.param, stn.prd, stnr2] = trf_fineFit(inputdt, 'STN', expNum, stim, t, stn.seed, param); end
    if fitETC, [etc.param, etc.prd, etcr2] = trf_fineFit(inputdt, 'ETC', expNum, stim, t, etc.seed, param); end
end

%% compute derived parameters for STN and ETC model
% estimated time to run this part:
if strcmp(doWhichAnalysis, 'all') | strcmp(doWhichAnalysis, 'up to derived parameters')
    if fitSTN, stn.derivedParam = trf_computeDerivedParams(inputdt, 'STN', expNum, stn.param); end
    if fitETC, etc.derivedParam = trf_computeDerivedParams(inputdt, 'ETC', expNum, etc.param); end
end

%% xvalidate model fit for all models
%
% CURRENTLY THIS PART WORKS ONLY FOR EXPERIMENT 1
% estimated time to run this part:
if strcmp(doWhichAnalysis, 'all') 
    %   if fitLin, [lin.xR2, lin.xPrd] = trf_xValidate(inputdt, 'lin', expNum); end
    if fitLin, [lin.xparam, lin.xPrd, r2] = trf_xValidate('lin', expNum, [], stim, t, param); end
    if fitSTN, [stn.xparam, stn.xPrd, r2] = trf_xValidate('STN', expNum, stn.seed, stim, t, param); end
    if fitETC, [etc.xparam, etc.xPrd, r2] = trf_xValidate('ETC', expNum, etc.seed, stim, t, param); end
end

% [xparam, xpred, r2] = trf_xValidate(data, whichModel, expNum, seed, stim, t, param)

%% save data 

% saveLoc = fullfile(temporalRootPath, 'output')
% 
% outputName = sprintf('%smodel.mat', analyzeWhichData);
% 
% save(fullfile(saveLoc, outputName), 'stn', 'etc', 'lin')

end
% save into a new file: 
% model: model.lin, model.stn, model.etc