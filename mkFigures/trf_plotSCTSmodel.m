% fit normalization-type model to the fMRI data

paramloc = '/Volumes/server/Projects/Temporal_integration/output/scts.mat';
dataloc  = '/Volumes/server/Projects/Temporal_integration/data/preprocessed_data.mat';

a = load(paramloc);
b = load(dataloc);

data  = squeeze(mean(b.dt.fmri1.data));
mdata = squeeze(mean(data, 2));
sdata = squeeze(std(data, [], 2));

prm  = a.scts.prm;


nroi = size(mdata, 1);
rois = b.dt.fmri1.nm;

for k = 1 : nroi
    idx = (k - 1) * 100 + 1 : k * 100;
    
    % mean and standard deviation model fit
    mfit(k, :) = mean(a.scts.pred(idx, :));
    sfit(k, :) = std(a.scts.pred(idx, :));
    
    % mean and stanard deviation of residuals
    residuals   = squeeze(data(k, :,:)) - a.scts.pred(idx, :);
    rmfit(k, :) = mean(residuals,1);
    rsfit(k, :) = std(residuals,[],1);
    
    % model parameters
    mprm(k, :) = median(prm(idx, :));
    lprm(k, :) = prctile(prm(idx, :), 25);
    uprm(k, :) = prctile(prm(idx, :), 75);
end

% x-validated stuff
xpred = a.scts.xpred;
xr2   = a.scts.xr2;

mxr2 = mean(xr2);

for k = 1 : 13
    xpred1(k, :) = squeeze(xpred(k, :, k));
end

for k = 1 : nroi
    idx = (k - 1) * 100 + 1 : k * 100;
    m_xpred(k, :) = mean(xpred1(:, idx), 2);
    s_xpred(k, :) = std(xpred1(:, idx), [], 2);
    
    m_mxr2(k) = mean(mxr2(idx));
    s_mxr2(k) = std(mxr2(idx));
end

%% plot fit

order = [13, 1 : 6, 5, 7 : 12];

figure (1), clf
for k = 1 : nroi
    subplot(3, 3, k)
    boundedline(1 : 7, mfit(k, order(1 : 7)),sfit(k, order(1 : 7)),  'r'), hold on
    boundedline(8 : 14, mfit(k, order(8 : 14)),sfit(k, order(8 : 14)),  'r')
    plot(mdata(k, order), 'ko', 'markersize', 8),
    for k1 = 1 : length(order)
        thispoint = order(k1);
        plot([k1, k1], [mdata(k, thispoint) - sdata(k, thispoint), mdata(k, thispoint) + sdata(k, thispoint)], 'k-')
    end
    
    % plot([0.5, 14.5], [0,0])
    
    % plot model fit
    axis tight, ylim([-0.1, 0.6]), xlim([0.5, 14.5]), box off, title(rois{k})
    set(gca, 'xtick', '')
    set(gca, 'XAxisLocation', 'origin')
    
end


%% Plot residuals
order = [13, 1 : 6, 5, 7 : 12];

figure (4), clf
for k = 1 : nroi
    subplot(3, 3, k)
    boundedline(1 : 7, rmfit(k, order(1 : 7)),rsfit(k, order(1 : 7)),  'r'), hold on
    boundedline(8 : 14, rmfit(k, order(8 : 14)),rsfit(k, order(8 : 14)),  'r')
    plot(rmfit(k, order), 'ko', 'markersize', 8),
%     for k1 = 1 : length(order)
%         thispoint = order(k1);
%         plot([k1, k1], [mdata(k, thispoint) - sdata(k, thispoint), mdata(k, thispoint) + sdata(k, thispoint)], 'k-')
%     end
    
    % plot([0.5, 14.5], [0,0])
    
    % plot model fit
    axis tight, ylim([-0.2, 0.2]), xlim([0.5, 14.5]), box off, title(rois{k})
    set(gca, 'xtick', '')
    set(gca, 'XAxisLocation', 'origin')
    
end

%% plot x-validated fit

figure (2), clf
for k = 1 : nroi
    subplot(3, 3, k),
    boundedline(1 : 7, m_xpred(k, order(1 : 7)),s_xpred(k, order(1 : 7)),  'r'), hold on
    boundedline(8 : 14, m_xpred(k, order(8 : 14)),s_xpred(k, order(8 : 14)),  'r')
    plot(mdata(k, order), 'ko', 'markersize', 8),
    for k1 = 1 : length(order)
        thispoint = order(k1);
        plot([k1, k1], [mdata(k, thispoint) - sdata(k, thispoint), mdata(k, thispoint) + sdata(k, thispoint)], 'k-')
    end
     axis tight, ylim([-0.1, 0.6]), xlim([0.5, 14.5]), box off, title(rois{k})
    set(gca, 'xtick', '')
    set(gca, 'XAxisLocation', 'origin')
end


%% plot model parameters

title_txt = {'tau1', 'sigma'};

figure (3), clf
for k = 1 : 2
    subplot(1, 2, k)
    plot(mprm(:, k), 'ko'), hold on
    for k1 = 1 : nroi
       plot([k1, k1], [lprm(k1, k), uprm(k1, k)], 'k-') 
    end
    set(gca, 'xtick', 1 : nroi, 'xticklabel', rois), box off
    title(title_txt{k})
end