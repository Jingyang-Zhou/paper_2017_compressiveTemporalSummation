% make figure hrf

subj = {'wl_subj001', 'wl_subj023', 'wl_subj030', 'wl_subj031'};

t = 0 : 1.5 : 40;

normMax = @(x) x./max(x);


%% load estimated hRF for each subject using GLM denoise

projLoc = fullfile(temporalRootPath, 'fMRI', 'experiment2');

% denoisedLoc = fullfile(projLoc, subjId, 'GLMdenoised13_usableData');
% defName = 'denoiseddata.mat';
% a = load(fullfile(denoisedLoc, defName));

% load denoised results
for k = 1 : length(subj)
    denoisedLoc = fullfile(projLoc, subj{k}, 'GLMdenoised13_usableData');
    defName1 = 'denoisedresults.mat';
    b = load(fullfile(denoisedLoc, defName1));
    glmhrf(k,:) = mean(b.results.models{1}, 2);
end

m_glmhrf = median(glmhrf);


%% load retinotopy hrfs

fileLoc = {'wl_subj001_2013_12_18/Gray/Averages Bars/', ...
    'wl_subj023_2015_07_03/Gray/Average bars', ...
    'Gray/Averages_ROIs', 'Gray/Averages_ROIs'};

roi = {'V1', 'V2', 'V3', 'V3ab', 'hV4', 'VO', 'LO', 'TO', 'IPS'};

for isub = 1 : length(subj)
    retLoc = sprintf('/Volumes/server/Projects/Retinotopy/%s/%s', subj{isub}, fileLoc{isub});
    
    for k = 1 : length(roi)
        fName = sprintf('rm_%s-fFit-fFit-fFit.mat', roi{k});
        a     = load(fullfile(retLoc, fName));
        hrfparams(isub, k, :) = a.model{1}.hrf.params{2};
        retHrf(isub, k, :) = normMax(rmHrfTwogammas(t, hrfparams(isub, k, :)));
    end
end

%% visualize retinotopic hrfs

mRetHrf = squeeze(mean(retHrf));
sRetHrf = squeeze(std(retHrf));

figure (1), clf
for iroi = 1 : length(roi)
    subplot(3, 3, iroi)
    shadedErrorBar(t, mRetHrf(iroi, :), sRetHrf(iroi, :)), hold on
    %plot(t, mRetHrf(4, :), 'r:', 'linewidth', 2)
    plot(m_glmhrf, 'r:', 'linewidth', 2)
    title(roi{iroi}), ylim([-0.5, 1.2]), box off
end

%% load experimental hrfs

projLoc = fullfile(temporalRootPath, 'fMRI', 'experiment2');
subjId  = {'wl_subj001', 'wl_subj023', 'wl_subj030', 'wl_subj031'};

rois = {'V1', 'V2', 'V3', 'hV4', 'V3ab', 'VO', 'LO', 'TO', 'IPS'};

beta = [];
hrfPrm = [];
for k = 1 : length(subjId)
    a = load(fullfile(projLoc, subjId{k}, 'hrf_betaWeights.mat'));
    beta(k, :, :) = a.betaRois;
    hrfPrm(k, :, :)  = a.hrfPrm;
    fixedHrfBeta(k, :, :) = a.betaRoisFixHrf;
    for iroi = 1 : length(rois)
        expHrf(k, iroi, :) = normMax(rmHrfTwogammas(t, hrfPrm(k, iroi, :)));
    end
end

%% visualize experimental hrfs

mExpHrf = squeeze(mean(expHrf));
sExpHrf = squeeze(std(expHrf));

figure (2), clf
for iroi = 1 : length(rois)
    subplot(3, 3, iroi),
    shadedErrorBar(t, mExpHrf(iroi, :), sExpHrf(iroi, :), 'k'), hold on
    plot(t, normMax(mExpHrf(4, :)), 'r:', 'linewidth', 2),
    %plot(m_glmhrf, 'r:', 'linewidth', 2)
    title(rois{iroi}), ylim([-0.5, 1.2]), box off
end

%% compute summation ratios

% for fixed hrf
mFixedHrfBeta = squeeze(mean(fixedHrfBeta, 1));

for iroi = 1 : length(rois)
    ratio1(iroi) = median(mFixedHrfBeta(iroi, 2 : 6)./(mFixedHrfBeta(iroi, 1 : 5).*2));
end


figure (3), clf
subplot(1, 2, 1)
plot(ratio1, 'ko', 'markerfacecolor', 'k', 'markersize', 10)
set(gca, 'xtick', 1 : length(rois), 'xticklabel', roi), ylim([0.5, 0.75]), xlim([0.5, 9.5])

% for variable hrf
mBeta = squeeze(mean(beta, 1));

for iroi = 1 : length(rois)
    ratio2(iroi) = median(mBeta(iroi, 2 : 6)./(mBeta(iroi, 1 : 5).*2));
end

subplot(1, 2, 2)
plot(ratio2, 'ko', 'markerfacecolor', 'k', 'markersize', 10)
set(gca, 'xtick', 1 : length(rois), 'xticklabel', rois), ylim([0.5, 0.75]), xlim([0.5, 9.5])


order = [13, 1 : 6, 5, 7 : 12];
figure, 
for k = 1 : length(rois)
   subplot(3, 3, k)
   plot(mFixedHrfBeta(k, order), 'o')
end

%% load original model fit and model

% load original data
floc = fullfile(temporalRootPath, 'output', 'exp1model.mat');
c = load(floc);

floc1 = fullfile(temporalRootPath, 'data', 'fmri', 'trf_fmridata.mat');
d = load(floc1);
lb = d.param.stn.lowerBnd{1};
ub = d.param.stn.upperBnd{1};

%% fit CTS function to the data  - grid fit

[stim, t] = importStimulus('with0');

[modelseed, modelr2] = trf_gridFit(mBeta', 'STN', 1, d.param, stim, t);
[modelseedFixed, modelr2Fixed] = trf_gridFit(mFixedHrfBeta', 'STN', 1, d.param, stim, t);

%% fit CTS function to the data - fine fit

% fit the model to mFixedHrfBeta

for iroi = 1 : length(rois)
   param(iroi, :) = fminsearchbnd(@(x) trf_modelFineFit(x, mBeta(iroi, :)', stim, t, 1, 'STN'), modelseed(iroi, :), lb, ub);
   paramfix(iroi, :) = fminsearchbnd(@(x) trf_modelFineFit(x, mFixedHrfBeta(iroi, :)', stim, t, 1, 'STN'), modelseedFixed(iroi, :), lb, ub);
   pred(iroi, :) = sum(trf_STNmodel(param(iroi, :), stim, t, 1), 2);
   predfix(iroi, :) = sum(trf_STNmodel(paramfix(iroi, :), stim, t, 1), 2);
end

%%
order = [13, 1 : 6, 5, 7 : 12];

figure
for iroi = 1 : length(rois)
    subplot(3, 3, iroi)
    plot(mBeta(iroi, order), 'o'), hold on
    plot(pred(iroi, order)), ylim([0, 0.06])
end

figure
for iroi = 1 : length(rois)
    subplot(3, 3, iroi)
    plot(mFixedHrfBeta(iroi, order), 'o'), hold on
    plot(predfix(iroi, order)), ylim([0, 0.06])
end

% figure
% subplot(1, 2, 1)
% plot(paramfix(:, 1))
% subplot(1, 2, 2)
% plot(paramfix(:, 2))

%% reparameterize

% compute r_double
% trf_computeDerivedParams(data, whichModel, expNum, prm)

derivedParam = trf_computeDerivedParams('STN', 1, param);
derivedParamFix = trf_computeDerivedParams('STN', 1, paramfix);

%%
figure (1), clf
subplot(1, 2, 1)
plot(derivedParam.r_double, 'ko', 'markersize', 7, 'markerfacecolor', 'k'), hold on
plot(derivedParamFix.r_double, 'ro', 'markersize', 5)
set(gca, 'xtick', 1 : length(rois), 'xticklabel', rois)

subplot(1, 2, 2)
semilogy(derivedParam.t_isi, 'ko', 'markersize', 7, 'markerfacecolor', 'k'), hold on
semilogy(derivedParamFix.t_isi, 'ro', 'markersize', 5)
set(gca, 'xtick', 1 : length(rois), 'xticklabel', rois)
