function [] =  trf_mkFigure5()
%
% DESCRIPTION ------------------------------------------
%% load data and model analysis

% load data
dLoc  = fullfile(temporalRootPath, 'data', 'fMRI');
dName = 'trf_fmridata.mat';

b     = load(fullfile(dLoc, dName));
data  = squeeze(mean(b.data.fmri1.data, 1));
roiNm = b.data.fmri1.nm;

% load model analysis
fLoc  = fullfile(temporalRootPath, 'output');
fName = 'exp1model.mat';

a     = load(fullfile(fLoc, fName));
etc   = a.etc;

%% extract

% mean and std data:
mdata = squeeze(median(data, 2));
ldata = squeeze(prctile(data, 25, 2));
udata = squeeze(prctile(data, 75, 2));

% mean model fit -- linear and stn
for k = 1 : length(roiNm)
   idx = (k - 1) * 100 + 1 : k * 100;
   % etc model
   metcxPrd(k, :) = median(etc.xPrd(:, idx), 2);
   setcxPrd(k, :, :) = prctile(etc.xPrd(:, idx), [25, 75], 2) ;
   setcxPrd(k, :, 1) = metcxPrd(k, :) - squeeze(setcxPrd(k, :, 1));
   setcxPrd(k, :, 2) = squeeze(setcxPrd(k, :, 2)) - metcxPrd(k, :);
   
   % derived xr2
   etcxr2(k, :) = prctile(etc.xr2(idx), [25, 75]);
end

% extract model parameters
for k = 1 : length(roiNm)
    idx = (k - 1) * 100 + 1 : k * 100;
    etcmprm(k, :) = median(etc.param(idx, :));
    etclprm(k, :) = prctile(etc.param(idx, :), 25);
    etcuprm(k, :) = prctile(etc.param(idx, :), 75);
    
    % extract derived parameters
    mr_double(k) = median(etc.derivedParam.r_double(idx));
    lur_double(k, :) = prctile(etc.derivedParam.r_double(idx), [25, 75]);
    
    mt_isi(k) = median(etc.derivedParam.t_isi(idx));
    lut_isi(k, :) = prctile(etc.derivedParam.t_isi(idx), [25, 75]);
end

%% plot data and model fit

order = [13, 1 : 6, 5, 7 : 12];

figure, 
for k = 1 : length(roiNm)
    subplot(3, 3, k), 
    % plot stn model fit
    boundedline(1 : 7, metcxPrd(k, order(1 : 7)), [setcxPrd(k, order(1 : 7), 1); setcxPrd(k, order(1 : 7), 2)]','b-'), hold on
     boundedline(8 : 14, metcxPrd(k, order(8 : 14)), [setcxPrd(k, order(8 : 14), 1); setcxPrd(k, order(8 : 14), 2)]', 'b-')
    
    % plot data
    plot(mdata(k, order), 'ko', 'markersize', 8),
    for k1 = 1 : length(order)
        plot([k1, k1], [ldata(k, order(k1)), udata(k, order(k1))], 'k-', 'linewidth', 2)
    end
    % write xr2
    text(7, -0.05, num2str([round(etcxr2(k, 1), 2),round(etcxr2(k, 2), 2)]))
    % visual parameters
    ylim([-0.1, 0.6]), xlim([0.5, 14.5]), box off, set(gca, 'xtick', 1 : 14, 'xticklabel', '')
    ax = gca;
    ax.XAxisLocation = 'origin';
end

%% plot model parameters

titletxt = {'tau1', 'epsilon'};

figure
for k = 1 : 2
   subplot(1, 2, k)
   plot(etcmprm(:, k), 'ko', 'markersize', 8), hold on
   for iroi = 1 : length(roiNm)
      plot([iroi, iroi], [etclprm(iroi, k), etcuprm(iroi, k)], 'k-') 
   end
   axis tight, xlim([0.5, length(roiNm) + 0.5]), title(titletxt{k})
   set(gca, 'xtick', 1 : length(roiNm), 'xticklabel', roiNm), box off, axis square, 
end
subplot(1, 2, 2), ylim([0, 0.4])

%% plot derived parameters

titletxt = {'rDouble', 'tISI'};

figure 
subplot(1, 2, 1),
plot(mr_double, 'ko', 'markersize', 8), hold on
for k = 1 : length(roiNm), plot([k, k], [lur_double(k, :)], 'k-'), end

subplot(1, 2, 2),
semilogy(mt_isi, 'ko', 'markersize', 8), hold on
for k = 1 : length(roiNm), plot([k, k], [lut_isi(k, :)], 'k-'), end, ylim([10, 10^4])

for k = 1 : 2, subplot(1, 2, k), axis square, set(gca, 'xtick', 1 : length(roiNm), 'xticklabel', roiNm), 
box off, title(titletxt{k}), end

end