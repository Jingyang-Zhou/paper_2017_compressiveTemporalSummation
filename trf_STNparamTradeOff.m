% parameter trade-offs

%% for the STN model, the tradeoffs between tau and sigma:

%% load model parameters

fLoc = fullfile(temporalRootPath, 'output', 'exp1model.mat');

b = load(fLoc);
% STN parameters
param = b.stn.param;

nRoi = 9;
for k = 1 : nRoi
    idx = (k - 1) * 100 + 1 : k * 100;
    mparam(k, :) = median(param(idx, :));
end

%% make stimulus

[stim, t] = importStimulus('with0');

%% import fmri data

dataPth = fullfile(temporalRootPath, 'results');
dataFileName = 'temporalParams.mat';
a    = load(fullfile(dataPth, dataFileName));
fmri = squeeze(mean(a.data.fmri1));

mfmri = repmat(mean(fmri, 2), [1, 100, 1]);
datanoise = mean(fmri - mfmri, 3);

% think about if this is the right noise level to use
nroi = size(fmri, 1);
for iroi = 1 : nroi
   roinoise(iroi) = std(datanoise(iroi, :)); 
end
noiseStd = mean(roinoise);

%% compute parameter trade-offs

nSample = 500;
pred    = [];
noisypred = {};

for k = 1 : nRoi
    pred(k ,:) = sum(trf_STNmodel([mparam(k, 1), mparam(k, 2), mparam(k, 3)], stim, t, 1), 2);
    noisypred{k} = repmat(pred(k, :), [nSample, 1]);
    noisypred{k} = noisypred{k} + rand(nSample, size(pred, 2)).*roinoise(k);
end

%% fit model back to the noisy data

fparam = [];
lb = [0.001, 0.0001, 0];
ub = [1, 1, 1];

for k = 1 : nRoi
   for k1 = 1 : nSample
      fparam(k, k1, :) = fminsearchbnd(@(x) trf_modelFineFit(x, noisypred{k}(k1, :)', stim, t, 1, 'STN'), [pred(k, 1), pred(k, 2), pred(k, 3)], lb, ub);
   end
   k
end

%% load the model

fLoc = fullfile(temporalRootPath, 'output');
fName = 'stnParamTradeoff.mat';

c = load(fullfile(fLoc, fName));
fparam = c.fparam;

%% plot parameter trade-offs
rois = {'V1', 'V2', 'V3', 'V3ab', 'hV4', 'VO', 'LO', 'TO', 'IPS'};

lower = 0.6;
upper = 1.4;

diff1 = 0.025;
diff2 = 0.007;



figure (1), clf
for k = 1 : nRoi
    subplot(3, 3, k)
    plot(fparam(k, :, 1), fparam(k, :, 2), 'k.', 'markersize', 5), hold on
    plot(mparam(k, 1), mparam(k, 2), 'ro', 'markerfacecolor', 'r', 'markersize', 8)
    %xlim([lower*mparam(k, 1), upper*mparam(k, 1)]), ylim([lower*mparam(k, 2), upper*mparam(k, 2)]), box off
    xlim([mparam(k, 1) - diff1, mparam(k, 1) + diff1]), ylim([mparam(k, 2) - diff2, mparam(k, 2) + diff2]), box off
    %xlim([0.01, 0.5]), ylim([0.001, 0.06])
    plot([mparam(k, 1), mparam(k, 1)], [0 * mparam(k, 2), mparam(k, 2)], 'r:')
    plot([0 * mparam(k, 1), mparam(k, 1)], [mparam(k, 2), mparam(k, 2)], 'r:')
    title(rois{k}), xlabel('tau'), ylabel('sigma'), axis square
    %[eVec,h,ptsAndCrv] = covEllipsoid(squeeze([fparam(k, :, 1); squeeze(fparam(k, :, 2))]'),figure (1));
end

%% 
figure (2), clf
for k = [1, 4, 7]%1 : nRoi
    [eVec{k},h,ptsAndCrv] = covEllipsoid(squeeze([fparam(k, :, 1); squeeze(fparam(k, :, 2))]'),2,figure(2)); hold on
end
figure (2), clf
for k = [1, 4, 7]%nRoi
    plot(fparam(k, :, 1), fparam(k, :, 2), 'k.', 'markersize', 5), hold on
    plot(eVec{k}(:, 1), eVec{k}(:, 2), 'r-', 'linewidth', 2),
    pause(1)
end
axis tight, axis square

%% save file

sfLoc = fullfile(temporalRootPath, 'output')
sfName = 'stnParamTradeoff.mat';

save(fullfile(sfLoc, sfName), 'fparam')