% trf_mkFigure_2chanModel

%% load data and model fit

% load model analysis
fLoc  = fullfile(temporalRootPath, 'output');
fName = 'results.mat';
a     = load(fullfile(fLoc, fName));

% load data
dLoc  = fullfile(temporalRootPath, 'data', 'fmri');
dName = 'trf_fmridata.mat';

b     = load(fullfile(dLoc, dName));
data  = squeeze(mean(b.data.fmri1.data, 1));

nrois = 9;

%% compute x-validated r2 for the etc and the ttc model

predSTN = permute(reshape(a.stn.prd', [13, 100, 9]), [3 2 1]); 
predTTC = permute(reshape(a.ttc.prd', [13, 100, 9]), [3 2 1]); 

R2stn  = 1 - sum((predSTN-data).^2, 3) ./ sum(data.^2,3);
R2ttc  = 1 - sum((predTTC-data).^2, 3) ./ sum(data.^2,3);

mr2stn = median(R2stn, 2);
sr2stn = prctile(R2stn, [25, 75], 2);

mr2ttc = median(R2ttc, 2);
sr2ttc = prctile(R2ttc, [25, 75], 2);

mpredSTN = squeeze(median(predSTN, 2));
mpredTTC = squeeze(median(predTTC, 2));

spredSTN = prctile(predSTN, [25, 75], 2);
spredTTC = prctile(predTTC, [25, 75], 2);

for k = 1 : 2
    spredSTN(:, k, :) = abs(squeeze(spredSTN(:, k, :)) - mpredSTN);
    spredTTC(:, k, :) = abs(squeeze(spredTTC(:, k, :)) - mpredTTC);
end

mdata = squeeze(median(data, 2));
sdata = prctile(data, [25, 75], 2);

%% plot data and model fit:

order = [13, 1 : 6, 5, 7 : 12];

earlyFig = [1, 3, 5];
roiidx   = [1, 7, 2, 8, 3, 9];

figure (1), clf
for k = 1 : 6
    subplot(3, 2, k)
    % plot the STN model
    boundedline(1 : 7, mpredSTN(roiidx(k), order(1 : 7)), spredSTN(roiidx(k), order(1 : 7)), 'r'), hold on
    boundedline(8 : 14, mpredSTN(roiidx(k), order(8 : 14)), spredSTN(roiidx(k), order(8 : 14)), 'r')
    % plot the 2 temporal channels model
    boundedline(1 : 7, mpredTTC(roiidx(k), order(1 : 7)), spredTTC(roiidx(k), order(1 : 7)), 'b')
    boundedline(8 : 14, mpredTTC(roiidx(k), order(8 : 14)), spredTTC(roiidx(k), order(8 : 14)), 'b')
    
    % plot data
    plot(mdata(roiidx(k), order), 'ko'), hold on
    for k1 = 1 : length(order)
        plot([k1, k1], sdata(roiidx(k), :, order(k1)), 'k-')
    end
    
    title(b.data.fmri1.nm{roiidx(k)}),
    xlim([0.5, 14.5]), ylim([-0.05, 0.45]), box off
    set(gca, 'xtick', [1, 7, 8, 14], 'xticklabel', '')
    ax = gca;
    ax.XAxisLocation = 'origin';
end

%% plot x-validation comparison

figure (2), clf
roisToPlot = 1:9;%[1 : 3, 7 : 9];
x = 1:length(roisToPlot);

plot(x, mr2stn(roisToPlot), 'ro', 'markerfacecolor', 'r'), hold on
plot(x+0.2, mr2ttc(roisToPlot), 'o', 'markerfacecolor', 'b')

count = 0
for iroi = roisToPlot
    count = count + 1;
    plot([count, count], sr2stn(iroi, :), 'r-')
     plot([count+0.2, count+0.2], sr2ttc(iroi, :), 'b-')
end

set(gca, 'xtick', x, 'xticklabel', roisToPlot), xlim([min(x)-.5, max(x)+.5])
title('x-validated r2'), box off, set(gca, 'xtick', x, 'xticklabel', b.data.fmri1.nm(roisToPlot))



%% plot error comparison

% lower visual area
figure (3), clf
subplot(2, 2, 1), 
plot(1 : 7, [mpredSTN(1 : 3, order(1 : 7)) - mdata(1 : 3, order(1 : 7))]', 'r.--'), hold on
plot(8 : 14, [mpredSTN(1 : 3, order(8 : 14)) - mdata(1 : 3, order(8 : 14))]', 'r.--')
plot([0.5, 14.5], [0, 0], 'k:')
xlim([0.5, 14.5]), ylim([-0.2, 0.15]), title('STN error, lower visual areas')
set(gca, 'xtick', [1 : 14], 'xticklabel', '')

subplot(2, 2, 3), 
plot(1 : 7, [mpredSTN(7 : 9, order(1 : 7)) - mdata(7 : 9, order(1 : 7))]', 'r.--'), hold on
plot(8 : 14, [mpredSTN(7 : 9, order(8 : 14)) - mdata(7 : 9, order(8 : 14))]', 'r.--')
plot([0.5, 14.5], [0, 0], 'k:')
xlim([0.5, 14.5]), ylim([-0.2, 0.15]), title('STN error, higher visual areas')
set(gca, 'xtick', [1 : 14], 'xticklabel', '')

subplot(2, 2, 2), 
plot(1 : 7, [mpredTTC(1 : 3, order(1 : 7)) - mdata(1 : 3, order(1 : 7))]', 'b.--'), hold on
plot(8 : 14, [mpredTTC(1 : 3, order(8 : 14)) - mdata(1 : 3, order(8 : 14))]', 'b.--')
plot([0.5, 14.5], [0, 0], 'k:')
xlim([0.5, 14.5]), ylim([-0.2, 0.15]), title('TTC error, lower visual areas')
set(gca, 'xtick', [1 : 14], 'xticklabel', '')

subplot(2, 2, 4), 
plot(1 : 7, [mpredTTC(7 : 9, order(1 : 7)) - mdata(7 : 9, order(1 : 7))]', 'b.--'), hold on
plot(8 : 14, [mpredTTC(7 : 9, order(8 : 14)) - mdata(7 : 9, order(8 : 14))]', 'b.--')
plot([0.5, 14.5], [0, 0], 'k:')
xlim([0.5, 14.5]), ylim([-0.2, 0.15]), title('TTC error, lower visual areas')
set(gca, 'xtick', [1 : 14], 'xticklabel', '')

%% figure 4 model parameter comparison

for iroi = 1 : nrois
   idx = (iroi - 1) * 100 + 1 : iroi * 100;
   mratio(iroi) = median([a.ttc.param(idx, 2)./a.ttc.param(idx, 1)]);
   sratio(iroi, :) = prctile([a.ttc.param(idx, 2)./a.ttc.param(idx, 1)], [25, 75]);
end

figure (4), clf
plot(mratio, 'ko', 'markerfacecolor', 'k'), hold on
for iroi = 1 : nrois
   plot([iroi, iroi], sratio(iroi, :), 'k-') 
end
plot([0, 9], [1, 1], 'k:')
set(gca, 'xtick', 1 : nrois, 'xticklabel', b.data.fmri1.nm), axis tight, xlim([0.5, 9.5]), 
box off, ylim([0.4, 3.5])


