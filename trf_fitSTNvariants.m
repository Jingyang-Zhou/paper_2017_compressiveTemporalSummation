% fit 2 additional versions of the STN model
%
% The first version is to relax n, the second one is the use different
% exponent for the numerator and the denominator.

%% STN VARIANT 1

%% load data 

% load data and parameters ----------------------------------------
fLoc  = fullfile(temporalRootPath, 'data', 'fMRI');
fName = 'trf_fmridata.mat';

a     = load(fullfile(fLoc, fName));
data  = trf_reshape(a.data, 'exp1');
roiNm = a.data.fmri1.nm;

param = a.param;

% load stimulus ---------------------------------------------------
% Stimulus for the first experiment:
[stim, t] = importStimulus('with0');

whichModel = 'STNvar1';
expNum     = 1;

% choose grid size
tau1grid  = param.stn.tau1grid;
sigmagrid = param.stn.sigmagrid;
ngrid     = linspace(0.1, 6, 10);

param.stn.ngrid = ngrid;

%% grid fit
% 
% [modelseed, modelr2] = trf_gridFit(data, whichModel, expNum, param, stim, t);
% 
% disp('Finished grid fit')
% %% fine fit
% 
% [prm, prd, r2] = trf_fineFit(data, whichModel, expNum, stim, t, modelseed, param);
% 
% disp('Finished fine fit')
% %% cross validate
% 
% [xparam, xPrd, xr2] = trf_xValidate(data', whichModel, expNum, modelseed, stim, t, param);
% 
% disp('Finished x-validation')
% 
% %% save file
% 
% STNvar1 = [];
% 
% STNvar1.modelSeed = modelseed;
% STNvar1.seedR2    = modelr2;
% STNvar1.param     = prm;
% STNvar1.prd       = prd;
% STNvar1.xparam    = xparam;
% STNvar1.xprd      = xPrd;
% STNvar1.xr2       = xr2;

% save('STNvar1.mat', 'STNvar1')

%% STN variant 2

whichModel2 = 'STNvar2';

param.stn.mgrid = ngrid;

% parpool
[modelseed, modelr2] = trf_improvedgridFit(data, whichModel2, expNum, param, stim, t);

disp('Finished grid-fit 1')

%% grid fit 1 - fit the best scaling for each set of parameteres

seed = 0.001;

for k = 1 : size(data, 2)
    scale(k) = fminsearch(@(x) trf_modelgridfit(x, modelseed(k, :)', data(:, k), stim, t, expNum, whichModel), seed);
end

disp('Finished grid-fit 2')
%% fine fit the model

seed = [modelseed, scale'];

[prm, prd, r2] = trf_fineFit(data, whichModel2, expNum, stim, t, seed, param);

disp('Finished fine-fit')

%% x-validate

[xparam, xPrd, xr2] = trf_xValidate(data', whichModel2, expNum, seed, stim, t, param);

disp('Finished x-validation')

%% save file

STNvar2 = [];

STNvar2.modelSeed = modelseed;
STNvar2.seedR2    = modelr2;
STNvar2.param     = prm;
STNvar2.prd       = prd;
STNvar2.xparam    = xparam;
STNvar2.xprd      = xPrd;
STNvar2.xr2       = xr2;

save('STNvar2.mat', 'STNvar2')








