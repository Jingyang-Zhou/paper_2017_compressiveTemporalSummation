% trf_mkFigure6

%% load data and model analysis

% load data
dLoc  = fullfile(temporalRootPath, 'data');
dName = 'trf_fmridata.mat';

b     = load(fullfile(dLoc, dName));

dt{1} = squeeze(b.data.fmri1ecc.data(1, :, :, :));
dt{2} = squeeze(b.data.fmri1ecc.data(2, :, :, :));
roiNm = b.data.fmri1ecc.nm;
nroi  = length(roiNm);

% load model analysis
fLoc  = fullfile(temporalRootPath, 'output');
fName = 'exp1eccmodel.mat';

a     = load(fullfile(fLoc, fName));
stn   = a.stn;

%% extract data

for ecc = 1 : 2
   mdt{ecc} = squeeze(median(dt{ecc}, 2));
   ldt{ecc} = squeeze(prctile(dt{ecc}, 25, 2));
   udt{ecc} = squeeze(prctile(dt{ecc}, 75, 2));
end

% median and 50% central model predictions and derived parameters
for k = 1 : nroi
    % low eccentricty
    idx = (k - 1) * 100 + 1 : k * 100;
    mprd{1}(k, :) = median(stn.prd(idx, :));
    lprd{1}(k, :) = mprd{1}(k, :) - prctile(stn.prd(idx, :), 25);
    uprd{1}(k, :) = prctile(stn.prd(idx, :), 75) - mprd{1}(k, :);
    % derived param
    mr_double{1}(k) = median(stn.derivedParam.r_double(idx));
    mt_isi{1}(k) = median(stn.derivedParam.t_isi(idx));
    sr_double{1}(k, :) = prctile(stn.derivedParam.r_double(idx), [40, 60]);
    st_isi{1}(k, :) = prctile(stn.derivedParam.t_isi(idx), [40, 60]);
    
    % high eccentricity
    idx1 = nroi * 100 + [(k - 1) * 100 + 1 : k * 100];
    mprd{2}(k, :) = median(stn.prd(idx1, :));
    lprd{2}(k, :) = mprd{2}(k, :) - prctile(stn.prd(idx1, :), 25);
    uprd{2}(k, :) = prctile(stn.prd(idx1, :), 75)-mprd{2}(k, :);
    % derived param
    mr_double{2}(k, :) = median(stn.derivedParam.r_double(idx1));
    mt_isi{2}(k, :) = median(stn.derivedParam.t_isi(idx1));
    sr_double{2}(k, :) = prctile(stn.derivedParam.r_double(idx1), [25, 75]);
    st_isi{2}(k, :) = prctile(stn.derivedParam.t_isi(idx1), [25, 75]);
end

%% plot data and model fit
order = [13, 1 : 6, 5, 7 : 12];

figure,
for ecc = 1 : 2
    for k = 1 : nroi
        subplot(9, 2, (k - 1) * 2 + ecc)
        % plot model
        boundedline(1 : 7, mprd{ecc}(k, order(1 : 7)), [lprd{ecc}(k, order(1 : 7)); uprd{ecc}(k, order(1 : 7))]',  'r-'), hold on
        boundedline(8 : 14, mprd{ecc}(k, order(8 : 14)), [lprd{ecc}(k, order(8 : 14)); uprd{ecc}(k, order(8 : 14))]',  'r-')
        
        % plot data
        plot(1 : 7, mdt{ecc}(k, order(1 : 7)), 'ko', 'markersize', 8), hold on
        plot(8 : 14, mdt{ecc}(k, order(8 : 14)), 'ko', 'markersize', 8)
        for k1 = 1 : length(order)
            plot([k1, k1], [ldt{ecc}(k, order(k1)), udt{ecc}(k, order(k1))], 'k-')
        end
     
        % figure parameters
        xlim([0.5, 14.5]), ylim([-0.1, 0.6]), set(gca, 'xtick', 1 : 14, 'xticklabel', ''), box off
    end
end

%% plot derived parameters
figure
subplot(1, 2, 1)
plot(1 : nroi, mr_double{1}, 'ko', 'markersize', 8, 'markerfacecolor', 'k'), hold on , 
plot([1 : nroi] + 0.3, mr_double{2}, 'ro', 'markersize', 8, 'markerfacecolor', 'r'), 
for k = 1 : nroi
   plot([k, k], sr_double{1}(k, :), 'k-'), plot([k + 0.3, k + 0.3], sr_double{2}(k, :), 'r-')  
end
box off, axis square, ylim([0.45, 0.7]), set(gca, 'xtick', 1 : 9, 'xticklabel', roiNm)

subplot(1, 2, 2)
semilogy(1 : nroi, mt_isi{1}, 'ko', 'markersize', 8, 'markerfacecolor', 'k'), hold on , 
semilogy([1 : nroi] + 0.3, mt_isi{2}, 'ro', 'markersize', 8, 'markerfacecolor', 'r')
for k = 1 : nroi
   plot([k, k], st_isi{1}(k, :), 'k-'), plot([k + 0.3, k + 0.3], st_isi{2}(k, :), 'r-')  
end
%axis tight, xlim([0.5, nroi + 0.5])
box off, axis square, set(gca, 'xtick', 1 : 9, 'xticklabel', roiNm)

%% plot derived parameteres

