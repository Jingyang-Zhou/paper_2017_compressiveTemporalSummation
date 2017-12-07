% 

file = fullfile(temporalRootPath, 'files', 'trf_results.mat');
dataFile = fullfile(temporalRootPath, 'files', 'trf_fmridata.mat');

a   = load(file);
b   = load(dataFile);

fmridata = squeeze(mean(b.data.fmri1.data));

fmridata = reshape(permute(fmridata, [2, 1, 3]), [900, 13])';

roiNm = b.data.fmri1.nm;
%% stn

stn     = a.exp1.stn;
xPrd    = stn.xPrd;

% compute the Pearson correlations
nSamples = 900;
nRois    = 9;

computeR2 = @(model, data) 100 * (1 - sum((model - data).^2)/sum(data.^2));

for k = 1 : nSamples
    model = xPrd(:, k) - mean(xPrd(:, k));
    data  = fmridata(:, k) - mean(fmridata(:, k));
    R2(k) = computeR2(model, data);
    R2orig(k) = computeR2(xPrd(:, k), fmridata(:, k));
    r2(k) = corr(xPrd(:, k), fmridata(:, k));
end

%% visualize stn pearson r2


mr2 = [];
sr2 = [];

figure (1), clf


for iRoi = 1 : nRois
    idx = (iRoi - 1) * 100 + 1 : iRoi * 100;
    
    mR2(iRoi) = median(R2orig(idx))./100;
    sR2(iRoi, :) = prctile(R2orig(idx), [25, 75])./100;
    mr2(iRoi) = median(r2(idx));
    sr2(iRoi, :) = prctile(r2(idx), [25, 75]);
    
    plot(iRoi, mR2(iRoi), 'ro', 'markerfacecolor', 'r'), hold on
    plot([iRoi, iRoi], [sR2(iRoi, 1), sR2(iRoi, 2)], 'r-')
    plot(iRoi, mr2(iRoi), 'ko', 'markerfacecolor', 'k')
    plot([iRoi, iRoi], [sr2(iRoi, 1), sr2(iRoi, 2)], 'k-')
    
end

set(gca, 'xtick', 1 : 9, 'xticklabel', roiNm)
xlim([0.5, 9.5]), box off, 