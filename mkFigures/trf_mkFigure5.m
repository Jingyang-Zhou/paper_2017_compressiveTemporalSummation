function [] =  trf_mkFigure5()
%
% DESCRIPTION ------------------------------------------
%% load data and model analysis

% load data
fLoc  = fullfile(temporalRootPath, 'files');
dName = 'trf_fmridata.mat';

b     = load(fullfile(fLoc, dName));
data  = squeeze(mean(b.data.fmri1.data, 1));
idata = b.data.fmri1.data;
roiNm = b.data.fmri1.nm;

% load model analysis
fName = 'trf_results.mat';

a     = load(fullfile(fLoc, fName));
lin   = a.exp1.lin;
stn   = a.exp1.stn;

%% extract

% mean and std data:
mdata = squeeze(median(data, 2));

ldata = squeeze(prctile(data, 25, 2));
udata = squeeze(prctile(data, 75, 2));

% mean model fit -- linear and stn
for k = 1 : length(roiNm)
   idx = (k - 1) * 100 + 1 : k * 100;
   % linear model
   mlinxPrd(k, :) = median(lin.xPrd(:, idx), 2);
   slinxPrd(k, :, :) = prctile(lin.xPrd(:, idx), [25, 75], 2);
   slinxPrd(k, :, 1) = mlinxPrd(k, :) - squeeze(slinxPrd(k, :, 1));
   slinxPrd(k, :, 2) = squeeze(slinxPrd(k, :, 2)) - mlinxPrd(k, :);
   % stn model
   mstnxPrd(k, :) = median(stn.xPrd(:, idx), 2);
   sstnxPrd(k, :, :) = prctile(stn.xPrd(:, idx), [25, 75], 2) ;
   sstnxPrd(k, :, 1) = mstnxPrd(k, :) - squeeze(sstnxPrd(k, :, 1));
   sstnxPrd(k, :, 2) = squeeze(sstnxPrd(k, :, 2)) - mstnxPrd(k, :);
   
   % derived xr2
   stnxr2(k, :) = prctile(stn.xr2(idx), [25, 75]);
   linxr2(k, :) = prctile(lin.xr2(idx), [25, 75]);
   mstnxr2(k)   = median(stn.xr2(idx));
   mlinxr2(k)   = median(lin.xr2(idx));
end

% extract model parameters
for k = 1 : length(roiNm)
    idx = (k - 1) * 100 + 1 : k * 100;
    stnmprm(k, :) = median(stn.param(idx, :));
    stnlprm(k, :) = prctile(stn.param(idx, :), 25);
    stnuprm(k, :) = prctile(stn.param(idx, :), 75);
    
    % extract derived parameters
    mr_double(k) = median(stn.derivedParam.r_double(idx));
    lur_double(k, :) = prctile(stn.derivedParam.r_double(idx), [25, 75]);
    
    mt_isi(k) = median(stn.derivedParam.t_isi(idx));
    lut_isi(k, :) = prctile(stn.derivedParam.t_isi(idx), [25, 75]);
end

%% plot xr2 comparison

figure

plot(1 : 9, mlinxr2, 'go', 'markerfacecolor', 'g'), hold on, plot([1 : 9]+0.1, mstnxr2, 'ro', 'markerfacecolor', 'r')
for k = 1 : length(roiNm)
   plot([k, k], linxr2(k, :), 'k-') 
   plot([k+0.1, k+0.1], stnxr2(k, :), 'k-') 
end
xlim([0.5, length(roiNm) + 0.5]), set(gca, 'xtick', 1 : length(roiNm), 'xticklabel', roiNm), box off


%% plot data and model fit

order = [13, 1 : 6, 5, 7 : 12];

figure, 
for k = 1 : length(roiNm)
    subplot(3, 3, k), 
    % plot stn model fit
    boundedline(1 : 7, mstnxPrd(k, order(1 : 7)), [sstnxPrd(k, order(1 : 7), 1); sstnxPrd(k, order(1 : 7), 2)]','r-'), hold on
     boundedline(8 : 14, mstnxPrd(k, order(8 : 14)), [sstnxPrd(k, order(8 : 14), 1); sstnxPrd(k, order(8 : 14), 2)]', 'r-')
    % plot linear model fit
    boundedline(1 : 7, mlinxPrd(k, order(1 : 7)), [slinxPrd(k, order(1 : 7), 1); slinxPrd(k, order(1 : 7), 2)]', 'g-'), 
    boundedline(8 : 14, mlinxPrd(k, order(8 : 14)),[slinxPrd(k, order(8 : 14), 1); slinxPrd(k, order(8 : 14), 2)]', 'g-')
    
    % plot data
    plot(mdata(k, order), 'ko', 'markersize', 8),
    for k1 = 1 : length(order)
        plot([k1, k1], [ldata(k, order(k1)), udata(k, order(k1))], 'k-', 'linewidth', 2)
    end
    % write xr2
    text(7, 0.05, num2str([round(linxr2(k, 1), 2),round(linxr2(k, 2), 2)]))
    text(7, -0.05, num2str([round(stnxr2(k, 1), 2),round(stnxr2(k, 2), 2)]))
    % visual parameters
    ylim([-0.1, 0.6]), xlim([0.5, 14.5]), box off, set(gca, 'xtick', 1 : 14, 'xticklabel', '')
    ax = gca;
    ax.XAxisLocation = 'origin';
end

%% plot model parameters

titletxt = {'tau1', 'sigma'};

figure
for k = 1 : 2
   subplot(1, 2, k)
   plot(stnmprm(:, k), 'ko', 'markersize', 8), hold on
   for iroi = 1 : length(roiNm)
      plot([iroi, iroi], [stnlprm(iroi, k), stnuprm(iroi, k)], 'k-') 
   end
   axis tight, xlim([0.5, length(roiNm) + 0.5]), title(titletxt{k})
   set(gca, 'xtick', 1 : length(roiNm), 'xticklabel', roiNm), box off, axis square, 
end
subplot(1, 2, 1), ylim([0, 0.6]), 
subplot(1, 2, 2), ylim([0, 0.06])

%% plot derived parameters

titletxt = {'rDouble', 'tISI'};

figure 
subplot(1, 2, 1),
plot(mr_double, 'ko', 'markersize', 8), hold on
for k = 1 : length(roiNm), plot([k, k], [lur_double(k, :)], 'k-'), end

subplot(1, 2, 2),
semilogy(mt_isi, 'ko', 'markersize', 8), hold on
for k = 1 : length(roiNm), plot([k, k], [lut_isi(k, :)], 'k-'), end

for k = 1 : 2, subplot(1, 2, k), axis square, set(gca, 'xtick', 1 : length(roiNm), 'xticklabel', roiNm), 
box off, title(titletxt{k}), end


figure ; set(gcf, 'Color', 'w')
set(gca, 'FontSize', 16, 'Color', 'w'); hold on;
for k = 1 : length(roiNm) 
    p=plot(mr_double(k), mt_isi(k), '.'); hold on
    
    text(mr_double(k), mt_isi(k),roiNm{k}, 'FontSize', 12); 
end

set(gca, 'YScale', 'log')
plot([.56 .68], [10^1 10^3], 'k--')
xlabel('R_d_o_u_b_l_e')
ylabel('T_I_S_I')

end