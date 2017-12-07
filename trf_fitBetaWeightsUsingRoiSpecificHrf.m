
%% load the new data file

subjects = {'wl_subj001', 'wl_subj023', 'wl_subj030', 'wl_subj031'};

betaRois = [];
betaFix  = [];

for k = 1 : length(subjects)
    
    fLoc = fullfile(temporalRootPath, 'fMRI', 'experiment2', subjects{k}, 'hrf_betaWeights.mat');
    a = load(fLoc);
    
    a.betaRois = permute(a.betaRois, [1, 3, 2]);
    a.betaRoisFixHrf = permute(a.betaRoisFixHrf, [1, 3, 2]);
    
    tmpbetaRois(k, :, :, :) = a.betaRois;
    tmpbetaFix(k, :, :, :)  = a.betaRoisFixHrf;
end

%%
mtmpbetaRois = squeeze(nanmean(tmpbetaRois));
mtmpbetaFix  = squeeze(nanmean(tmpbetaFix));

betaRois = permute(mtmpbetaRois, [3, 2, 1]);
rs_sz    = size(betaRois);

betaRois = reshape(betaRois, [rs_sz(1), rs_sz(2)*rs_sz(3)]);
betaFix  = reshape(permute(mtmpbetaFix, [3, 2, 1]), [rs_sz(1), rs_sz(2)*rs_sz(3)]);

%% visualize data

nRois = 9;
order = [13, 1 : 6, 5, 7 : 12];

figure (1), clf

for k = 1 : nRois
    idx = (k - 1) * 100 + 1 : k * 100;
    mbetaRois(k, :) = nanmean(betaRois(:, idx), 2);
    mbetaFix(k, :) = nanmean(betaFix(:, idx), 2);
    
    subplot(3, 3, k),
    plot(mbetaRois(k, order), 'ko'), hold on
    plot(mbetaFix(k, order), 'ro')
end

%% set up the parameters

stn_roi = [];
stn_fix = [];

expNum = 1;

% Stimulus for the first experiment:
[stim, t] = importStimulus('with0');

% load experimental params:
% load data and parameters ----------------------------------------
fLoc1  = fullfile(temporalRootPath, 'data', 'fMRI');
fName = 'trf_fmridata.mat';

b     = load(fullfile(fLoc1, fName));
param = b.param;

%% test
% 
% betaRois1 = betaRois(:, 201:300);
% betaFix  = betaFix(:, 1:10);

%% grid fit (1)
% estimated time to run this part:

[stn_roi.seed, stn_roi.seedr2] = trf_improvedgridFit(betaRois, 'STN', expNum, param, stim, t);
[stn_fix.seed, stn_fix.seedr2] = trf_improvedgridFit(betaFix, 'STN', expNum, param, stim, t); 

disp('Finished grid-fit 1')

%% grid fit (2)

scaleseed = 0.001;

for k = 1 : size(betaRois, 2)
    scale1(k) = fminsearch(@(x) trf_modelgridfit(x, stn_roi.seed(k, :)', betaRois(:, k),...
        stim, t, expNum, 'STN'), scaleseed);
    scale2(k) = fminsearch(@(x) trf_modelgridfit(x, stn_fix.seed(k, :)', betaRois(:, k),...
        stim, t, expNum, 'STN'), scaleseed);
end

stn_roi.seed = [stn_roi.seed, scale1'];
stn_fix.seed = [stn_fix.seed, scale2'];

disp('Finished grid-fit 2')

%% fine fit for all models (linear, STN, and ETC)
% estimated time to run this part:

[stn_roi.param, stn_roi.prd, stn_roi.r2] = trf_fineFit(betaRois, 'STN', expNum, stim, t, stn_roi.seed, param);
[stn_fix.param, stn_fix.prd, stn_fix.r2] = trf_fineFit(betaFix, 'STN', expNum, stim, t, stn_fix.seed, param);

disp('Finished fine-fit')

%% compute derived parameters for STN and ETC model
% estimated time to run this part:

stn_roi.derivedParam = trf_computeDerivedParams( 'STN', expNum, stn_roi.param);
stn_fix.derivedParam = trf_computeDerivedParams('STN', expNum, stn_fix.param);

disp('Finished deriving parameters')

%% save parameters

save('stn_hrf.mat', 'stn_fix', 'stn_roi')

%%




