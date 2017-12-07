% visualize STN variation 1

%% load data

fData  = fullfile(temporalRootPath, 'output', 'STNvar1');
fData1 = fullfile(temporalRootPath, 'output', 'STNvar2');
fPrm   = fullfile(temporalRootPath, 'output', 'exp1model.mat');

a = load(fData);
b = load(fPrm);
c = load(fData1);

stnvar1 = a.STNvar1;
stnvar2 = c.STNvar2;
stn     = b.stn;
lin     = b.lin;

nRois = 9;

rois = {'V1', 'V2', 'V3', 'V3ab', 'hV4', 'VO', 'LO', 'TO', 'IPS'};

%% compare x-validation

stnvar1_xr2 = median(stnvar1.xr2);
stnvar2_xr2 = median(stnvar2.xr2);
stn_xr2     = stn.xr2;

for iroi = 1 : nRois
   idx = (iroi - 1) * 100 + 1 : iroi * 100;
   stnvar1_mxr2(iroi) = median(stnvar1_xr2(idx));
   stnvar2_mxr2(iroi) = median(stnvar2_xr2(idx));
   stn_mxr2(iroi)     = median(stn_xr2(idx));
   lin_mxr2(iroi)     = median(lin.xr2(idx));
   
   stnvar1_sxr2(iroi, :) = prctile(stnvar1_xr2(idx), [25, 75]);
   stnvar2_sxr2(iroi, :) = prctile(stnvar2_xr2(idx), [25, 75]);
   stn_sxr2(iroi, :)     = prctile(stn_xr2(idx), [25, 75]);
end

figure (1), clf
plot(1 : nRois, stnvar1_mxr2, 'ko', 'markerfacecolor', 'k'), hold on
plot([1 : nRois] + 0.1, stnvar2_mxr2, 'bo', 'markerfacecolor', 'b')
plot([1 : nRois] + 0.2, stn_mxr2, 'ro', 'markerfacecolor', 'r')
for k = 1 : nRois
   plot([k, k], stnvar1_sxr2(k, :), 'k-') 
   plot([k, k]+ 0.1, stnvar2_sxr2(k, :), 'b-') 
   plot([k, k] + 0.2, stn_sxr2(k, :), 'r-') 
   plot([k - 0.5, k + 0.5], [lin_mxr2(k), lin_mxr2(k)], 'g-')
end
legend('3 free params', '4 free params', 'original CTS (2 free params)')
box off
set(gca, 'xtick', 1 : 9, 'xticklabel', rois), xlim([0.5, nRois + 0.5]), ylim([70, 100])

%% compare model fit

%% compare model parameters

stnparam = stn.param;
stnvar1param = stnvar1.param;
stnvar2param = stnvar2.param;

mparam = [];
var1mparam = [];

sparam = [];
var1sparam = [];


for iroi = 1 : nRois
   idx = (iroi - 1) * 100 + 1 : iroi * 100;
   mparam(iroi, :)     = median(stnparam(idx, :));
   var1mparam(iroi, :) = median(stnvar1param(idx, :));
   var2mparam(iroi, :) = median(stnvar2param(idx, :));
   
   sparam(iroi, :, :)  = prctile(stnparam(idx, :), [25, 75]);
   var1sparam(iroi, :, :) = prctile(stnvar1param(idx, :), [25, 75]);
   var2sparam(iroi, :, :) = prctile(stnvar2param(idx, :), [25, 75]);
end

figure (2), clf
for k = 1 : 4
    if k < 4
        subplot(3, 4, k), plot(mparam(:, k), 'ko', 'markerfacecolor', 'k'), hold on,
        for iroi = 1 : nRois
            plot([iroi, iroi], squeeze(sparam(iroi, :, k)), 'k-')
        end
        set(gca, 'xtick', 1 : nRois, 'xticklabel', rois), box off
    end
    subplot(3, 4, k + 4), plot(var1mparam(:, k), 'ko', 'markerfacecolor', 'k'), hold on
    for iroi = 1 : nRois
        plot([iroi, iroi], squeeze(var1sparam(iroi, :, k)), 'k-')
    end
    set(gca, 'xtick', 1 : nRois, 'xticklabel', rois), box off
    subplot(3, 4, k + 8),plot(var2mparam(:, k), 'ko', 'markerfacecolor', 'k'), hold on
    for iroi = 1 : nRois
        plot([iroi, iroi], squeeze(var2sparam(iroi, :, k)), 'k-')
    end
    set(gca, 'xtick', 1 : nRois, 'xticklabel', rois), box off
end

% y-limit for tau1
for k = [1, 5, 9]
   subplot(3, 4, k), ylim([0, 1]) 
end

subplot(3, 4, 6), ylim([0, 1])

for k = 1 : 12
   subplot(3, 4, k), xlim([0.5, 9.5]) 
end

%% compute and plot derived parameters

% var1DerivedPrm = trf_computeDerivedParams('STN', 1, stnvar1.param);
% var2DerivedPrm = trf_computeDerivedParams('STN', 1, stnvar2.param);

% %% plot derived param
% 
% var1derPrm = stnvar1.derivedPrm;
% var2derPrm = var2DerivedPrm;
% 
% for iroi = 1 : nRois
%     idx = (iroi - 1) * 100 + 1 : iroi * 100;
%     var1m_rdouble(iroi) = median(var1derPrm.r_double(idx)');
%     var1m_tisi(iroi) = median(var1derPrm.t_isi(idx)');
%     var1s_rdouble(iroi, :) = prctile(var1derPrm.r_double(idx)', [25, 75]);
%     var1s_tisi(iroi, :) = prctile(var1derPrm.t_isi(idx)', [25, 75]);
%     
%     var2m_rdouble(iroi) = median(var2derPrm.r_double(idx)');
%     var2m_tisi(iroi) = median(var2derPrm.t_isi(idx)');
%     var2s_rdouble(iroi, :) = prctile(var2derPrm.r_double(idx)', [25, 75]);
%     var2s_tisi(iroi, :) = prctile(var2derPrm.t_isi(idx)', [25, 75]);
%     
%     stn_rdouble(iroi) =  median(stn.derivedParam.r_double(idx)');
%     stn_tisi(iroi) =  median(stn.derivedParam.t_isi(idx)');
% end
% 
% figure (3), clf
% subplot(2, 2, 1)
% plot(var1m_rdouble', 'ko'), hold on
% for iroi = 1 : nRois
%    plot([iroi, iroi], var1s_rdouble(iroi, :), 'k-') 
% end
% set(gca, 'xtick', 1 : nRois, 'xticklabel', rois)
% 
% subplot(2, 2, 2)
% semilogy(var1m_tisi, 'ko'), hold on
% for iroi = 1 : nRois
%    semilogy([iroi, iroi], var1s_tisi(iroi, :), 'k-') 
% end
% set(gca, 'xtick', 1 : nRois, 'xticklabel', rois)
% 
% subplot(2, 2, 3)
% plot(var2m_rdouble', 'ko'), hold on
% for iroi = 1 : nRois
%    plot([iroi, iroi], var2s_rdouble(iroi, :), 'k-') 
% end
% set(gca, 'xtick', 1 : nRois, 'xticklabel', rois), ylim([0.5, 0.7])
% 
% subplot(2, 2, 4)
% semilogy(var2m_tisi, 'ko'), hold on
% for iroi = 1 : nRois
%    semilogy([iroi, iroi], var2s_tisi(iroi, :), 'k-') 
% end
% set(gca, 'xtick', 1 : nRois, 'xticklabel', rois)
% 
% %% alternative plot
% 
% figure (4), clf
% 
% 
% subplot(1, 3, 1), 
% set(gca, 'FontSize', 16, 'Color', 'w'); hold on;
% scatter(stn_rdouble, stn_tisi, 'k.'), 
% for k = 1 : nRois
%     text(stn_rdouble(k), stn_tisi(k), rois{k}, 'FontSize', 12)
% end
% set(gca, 'YScale', 'log'), ylim([10, 10^4])
% 
% subplot(1, 3, 2)
% set(gca, 'FontSize', 16, 'Color', 'w'); hold on;
% scatter(var1m_rdouble, var1m_tisi, 'k.')
% for k = 1 : nRois
%     text(var1m_rdouble(k), var1m_tisi(k), rois{k}, 'FontSize', 12)
% end
% set(gca, 'YScale', 'log'), ylim([10, 10^4])
% 
% subplot(1, 3, 3)
% set(gca, 'FontSize', 16, 'Color', 'w'); hold on;
% scatter(var2m_rdouble, var2m_tisi, 'k.')
% for k = 1 : nRois
%     text(var2m_rdouble(k), var2m_tisi(k), rois{k}, 'FontSize', 12)
% end
% set(gca, 'YScale', 'log'), ylim([10, 10^4])
% 
% 
% 
% 
% 
% 
% 
