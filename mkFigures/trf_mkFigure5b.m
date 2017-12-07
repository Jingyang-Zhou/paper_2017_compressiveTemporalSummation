% load model analysis
fLoc  = fullfile(temporalRootPath, 'files');
fName = 'trf_results.mat';
a     = load(fullfile(fLoc, fName));

% load data
dLoc  = fullfile(temporalRootPath, 'files');
dName = 'trf_fmridata.mat';


b     = load(fullfile(dLoc, dName));
data  = squeeze(mean(b.data.fmri1.data, 1));

predFlat = data;
for ii = 1:13
    predFlat(:,:,ii) = mean(predFlat(:,:,setdiff(1:13,ii)),3);
end

predSTN = permute(reshape(a.exp1.stn.xPrd, [13, 100, 9]), [3 2 1]); 
predLin = permute(reshape(a.exp1.lin.xPrd, [13, 100, 9]), [3 2 1]); 

R2stn  = 1 - sum((predSTN-data).^2, 3) ./ sum(data.^2,3);
R2lin  = 1 - sum((predLin-data).^2, 3) ./ sum(data.^2,3);
R2flat = 1 - sum((predFlat-data).^2, 3) ./ sum(data.^2,3);


predSTNmn  = bsxfun(@minus, predSTN, mean(predSTN,3));
predLinmn  = bsxfun(@minus, predLin, mean(predLin,3));
predFlatmn = bsxfun(@minus, predFlat, mean(predFlat,3));


datamn = bsxfun(@minus, data, mean(data,3));

R2STNmn   = 1 - sum((predSTNmn-datamn).^2, 3) ./ sum(datamn.^2,3);
R2Linmn   = 1 - sum((predLinmn-datamn).^2, 3) ./ sum(datamn.^2,3);
R2flatmn  = 1 - sum((predFlatmn-datamn).^2, 3) ./ sum(datamn.^2,3);


figure(1), clf
%subplot(2,1,1)
plot([median(R2stn,2) median(R2lin ,2) median(R2flat ,2)],...
    'o', 'MarkerSize', 14, 'MarkerFaceColor', [.7 .7 .7], 'LineWidth', 3);
hold on
plot(median(R2flat ,2), '--k')
set(gca, 'XTick', 1.5:8.5, 'XGrid', 'on', 'XLim', [.5 9.5])
% figure(2), clf
% plot([median(R2STNmn,2) median(R2Linmn ,2) median(R2flatmn ,2)], ...
%     'o', 'MarkerSize', 14, 'MarkerFaceColor', [.7 .7 .7], 'LineWidth', 3);
% hold on;
% plot([1 9], [0 0], 'k--')

%% compute noise ceiling

m1data = squeeze(mean(data, 2));
s1data = squeeze(std(data, [], 2));

[f,dist] = calcnoiseceiling(m1data,s1data);

f = f/100;
figure(1)
for k = 1 : 9
   plot([k - 0.2, k + 0.2], [f(k), f(k)], 'k-') 
end

box off,set(gca, 'xticklabel', '')
