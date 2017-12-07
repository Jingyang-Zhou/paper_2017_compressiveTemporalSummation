% trf_visualize hrf output

%% load data

file = fullfile(temporalRootPath, 'output', 'stn_hrf.mat');

a = load(file);

stn_fix = a.stn_fix; 
stn_roi = a.stn_roi;

%%

rdoubleFix = stn_fix.derivedParam.r_double;
rdoubleRoi = stn_roi.derivedParam.r_double;

tisiFix = stn_fix.derivedParam.t_isi;
tisiRoi = stn_roi.derivedParam.t_isi;

for k = 1 : 9
    idx = (k - 1) * 100 + 1 : k * 100;
    mrdoubleFix(k) = nanmedian(rdoubleFix(idx));
    mrdoubleRoi(k) = nanmedian(rdoubleRoi(idx));
    
    mtisiFix(k) = nanmedian(tisiFix(idx));
    mtisiRoi(k) = nanmedian(tisiRoi(idx));
    
    srdoubleFix(k, :) = prctile(rdoubleFix(idx), [25, 75]);
    srdoubleRoi(k, :) = prctile(rdoubleRoi(idx), [25, 75]);
    
    stisiFix(k, :) = prctile(tisiFix(idx), [25, 75]);
    stisiRoi(k, :) = prctile(tisiRoi(idx), [25, 75]);
end

%%

rois = {'V1', 'V2', 'V3', 'V3ab', 'hV4', 'VO', 'LO', 'TO', 'IPS'};

figure (1), clf
subplot(1, 2, 1)
plot(mrdoubleFix, 'ko', 'markerfacecolor', 'k'), ylim([0.5, 0.77]), hold on
for k = 1 : 9, plot([k, k], srdoubleFix(k, :), 'k-'); end

subplot(1, 2, 1)
plot([1 : 9]+ 0.2, mrdoubleRoi, 'ro', 'markerfacecolor', 'r'), ylim([0.5, 0.77]), 
for k = 1 : 9, plot([k+0.2, k+0.2], srdoubleRoi(k, :), 'r-'); end

box off, xlim([0.5, 9.5]), set(gca, 'xtick', 1 : 9, 'xticklabel', rois)


subplot(1, 2, 2)
semilogy(mtisiFix, 'ko', 'markerfacecolor', 'k'), hold on
for k = 1 : 9, plot([k, k], stisiFix(k, :), 'k-'); end

subplot(1, 2, 2)
semilogy([1 : 9] + 0.2, mtisiRoi, 'ro', 'markerfacecolor', 'r'), 
for k = 1 : 9, plot([k, k] + 0.2, stisiRoi(k, :), 'r-'); end

box off, xlim([0.5, 9.5]), set(gca, 'xtick', 1 : 9, 'xticklabel', rois)