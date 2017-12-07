% trf_mkFigure7

%% load data and model analysis

% load data
dLoc  = fullfile(temporalRootPath, 'data');
dName = 'trf_fmridata.mat';

b     = load(fullfile(dLoc, dName));
data  = squeeze(mean(b.data.fmri2.data, 1));
roiNm = b.data.fmri2.nm;
nroi  = length(roiNm);

% load model analysis
fLoc  = fullfile(temporalRootPath, 'output');
fName = 'exp2model.mat';

a     = load(fullfile(fLoc, fName));
lin   = a.lin;
stn   = a.stn;

%% extract data

mdata = squeeze(median(data, 2));
ldata = squeeze(prctile(data, 25, 2));
udata = squeeze(prctile(data, 75, 2));

for k = 1 : nroi
   idx = (k - 1) * 100 + 1 : k * 100;
   
   % linear model
   mlinprd(k, :) = median(lin.prd(idx, :));
   llinprd(k, :) = mlinprd(k, :) - prctile(lin.prd(idx, :), 25);
   ulinprd(k, :) = prctile(lin.prd(idx, :), 75) - mlinprd(k, :);
   
   mstnprd(k, :) = median(stn.prd(idx, :));
   lstnprd(k, :) = mstnprd(k, :) - prctile(stn.prd(idx, :), 25);
   ustnprd(k, :) = prctile(stn.prd(idx, :), 75) - mstnprd(k, :);
   
   % model parameters
%    mparam(k, :) = median(stn.param(idx, :));
%    lparam(k, :) = prctile(stn.param(idx, :), 25);
%    uparam(k, :) = prctile(stn.param(idx, :), 75);

% derived params
mr_double(k) = median(stn.derivedParam.r_double(idx));
lr_double(k) = prctile(stn.derivedParam.r_double(idx),25);
ur_double(k) = prctile(stn.derivedParam.r_double(idx), 75);

mt_isi(k) = median(stn.derivedParam.t_isi(idx));
lt_isi(k) = prctile(stn.derivedParam.t_isi(idx), 25);
ut_isi(k) = prctile(stn.derivedParam.t_isi(idx), 75);

end

%% plot v1 figure

order = [25, 1 : 6, 5, 7 : 12, 25, 13 : 18, 17, 19 : 24];

figure
% plot model fit
for k = [1, 8, 15, 22]
    boundedline(k : k + 6, mlinprd(1, order(k : k+6)), [llinprd(1, order(k : k+6)); ulinprd(1, order(k : k+6))]', 'g')
    boundedline(k : k + 6, mstnprd(1, order(k : k+6)), [lstnprd(1, order(k : k+6)); ustnprd(1, order(k : k+6))]', 'r')
end
% plot data
plot(mdata(1, order), 'ko', 'markersize', 8), hold on
for k = 1 : length(order)
    plot([k, k], [ldata(1, order(k)), udata(1, order(k))], 'k-')
end

% figure parameters
xlim([0, 28]), box off, ylim([-0.1, 0.4]),set(gca, 'xtick', 1 : 28, 'xticklabel', '')
ax = gca;
ax.XAxisLocation = 'origin';

%% plot data and model fit

figure, 
for k1 = 2 : nroi
    subplot(3, 3, k1-1)
    % plot model fit
    for k = [1, 8, 15, 22]
        boundedline(k : k + 6, mlinprd(k1, order(k : k+6)), [llinprd(k1, order(k : k+6)); ulinprd(k1, order(k : k+6))]', 'g')
        boundedline(k : k + 6, mstnprd(k1, order(k : k+6)), [lstnprd(k1, order(k : k+6)); ustnprd(k1, order(k : k+6))]', 'r')
    end
    % plot data
    plot(mdata(k1, order), 'ko', 'markersize', 8)
    for k = 1 : length(order)
        plot([k, k], [ldata(k1, order(k)), udata(k1, order(k))], 'k-')
    end
    
    % figure parameters
    xlim([0, 28]), box off, ylim([-0.1, 0.4]), set(gca, 'xtick', 1 : 28, 'xticklabel', '')
    ax = gca;
    ax.XAxisLocation = 'origin';
end

%% plot model parameters

figure
subplot(1, 2, 1)
plot(mr_double, 'ko', 'markersize', 8), hold on
for k = 1 : nroi
   plot([k, k], [lr_double(k), ur_double(k)], 'k-') 
end

xlim([0.5, nroi + 0.5])

subplot(1, 2, 2)
semilogy(1 : nroi, mt_isi, 'ko', 'markersize', 8), hold on
for k = 1 : nroi
   semilogy([k, k], [lt_isi(k), ut_isi(k)], 'k-') 
end

for k = 1 : 2
   subplot(1, 2, k), box off , 
   set(gca, 'xtick', 1 : nroi, 'xticklabel', roiNm)
end


figure,
subplot(1, 2, 2)
plot(mt_isi, 'ko', 'markersize', 8), hold on
for k = 1 : nroi
   plot([k, k], [lt_isi(k), ut_isi(k)], 'k-') 
end
ylim([0, 500])

for k = 1 : 2
   subplot(1, 2, k), box off,set(gca, 'xtick', 1 : nroi, 'xticklabel', roiNm)
end

