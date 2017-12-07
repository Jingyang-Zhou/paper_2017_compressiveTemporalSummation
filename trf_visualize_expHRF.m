% trf_visualize_hrf_temporal

%% load subject data

projLoc = fullfile(temporalRootPath, 'fMRI', 'experiment2');
subjId  = {'wl_subj001', 'wl_subj023', 'wl_subj030', 'wl_subj031'};

rois = {'V1', 'V2', 'V3', 'hV4', 'V3ab', 'VO', 'LO', 'TO', 'IPS'};


beta = [];
hrfPrm = [];
for k = 1 : length(subjId)
   a = load(fullfile(projLoc, subjId{k}, 'hrf_betaWeights.mat')); 
   beta(k, :, :) = a.betaRois;
   hrfPrm(k, :, :)  = a.hrfPrm;
end

%% take mean

hrf = [];

mhrfPrm = squeeze(median(hrfPrm));
mbeta   = squeeze(mean(beta));

for iroi = 1 : 9
   hrf(iroi, :) =  rmHrfTwogammas(0 : 1.5 : 40, mhrfPrm(iroi, :));
end

%% 

order = [13, 1 : 6, 5, 7 : 12];

col =  parula(length(rois));

figure (1), clf
for k = 1 : 9
    plot(hrf(k, :), 'color', col(k, :), 'linewidth', 2), hold on
end
legend(rois), axis tight

figure (2), clf
for k = 1 : 9
    subplot(3, 3, k)
   plot(mbeta(k, order), 'o-') 
end

%% average across subjects before extracting summation ratio

mbeta = squeeze(median(beta));

for iroi = 1 : 9
   sumRat1(iroi) = median(mbeta(iroi, 2 : 6)./[mbeta(iroi, 1 : 5) * 2]);
end

figure (3), clf
plot(sumRat1, 'o', 'markerfacecolor', 'k', 'markersize', 10)
set(gca, 'xtick', 1 : 9, 'xticklabel', rois)

%% extract summation ratio then average

sumRat = [];

for k = 1 : length(subjId)
    for iroi = 1 : 9
        
        tmp = beta(k, iroi, 2 : 6)./(beta(k, iroi, 1 : 5)*2)
        sumRat(k, iroi) = median(tmp);
    end
end

figure (4),clf
plot(median(sumRat), 'o', 'markersize', 10, 'markerfacecolor', 'k')
set(gca, 'xtick', 1 : 9, 'xticklabel', rois)