% trf_ model recovery

%% estimate fMRI noise
clear all
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


%% CTS model recovery

%% normalization model recovery

model    = [];
nSamples = 1000;

lb = [0.01, 0.001, 0];
ub = [0.5, 0.1, 1];

normMax = @(x) x./max(x);

stim  = a.params.fmri1.tProfiles;
t     = [1 : length(stim)]./1000;

tau1  = normMax(rand([1, nSamples]) + lb(1)).*ub(1);
sigma = normMax(rand([1, nSamples]) + lb(2)).*ub(2);
scl   = 5*10^(-4)*ones(1, nSamples);
noise = rand(nSamples, size(stim, 1)).*noiseStd;

% generate model prediction
for k = 1 : nSamples
   model(k, :) = sum(trf_STNmodel([tau1(k), sigma(k), scl(k)], stim, t, 1), 2);
end
noisy_model = model + noise;

%% grid fit to find the seed

nGrid     = 10^2;
gridtau1  = linspace(0.01, 0.5, 10);
gridsigma = linspace(0.001, 0.1, 10); 
[x, y]    = meshgrid(gridtau1, gridsigma);
x = reshape(x, [1, nGrid]);
y = reshape(y, [1, nGrid]);

% compute the model prediction for each set of parameters
for k = 1 : nGrid
   modelGrid(k, :) = sum(trf_STNmodel([x(k), y(k), scl(1)], stim, t, 1), 2);
end

% get seed for each pair of parameters
%seed    = [];
%maxseed = [];

for k = 1 : nSamples
   for k1 = 1 : nGrid
       seed(k, k1) = corr(model(k, :)', modelGrid(k1, :)').^2;
   end
   maxIdx(k)  = find(seed(k, :) == max(seed(k, :)));
   maxseed(k, :) = [x(maxIdx(k)), y(maxIdx(k)), scl(1)];
end

% r2 = corr(s_rsp, data).^2;


%% fit model

for k = 1 : nSamples
   fparam(k, :) = fminsearchbnd(@(x) trf_modelFineFit(x, noisy_model(k, :)', stim, t, 1, 'STN'), maxseed(k, :), lb, ub);
end

%% plot

figure (1), clf
subplot(1, 2, 1), plot(tau1, fparam(:, 1), 'k.'), hold on, plot([0, 0.5], [0, 0.5], 'r:')
xlim([0, 0.5]), ylim([0, 0.5]), box off, axis square
set(gca, 'xtick', 0 : 0.1 : 0.5, 'ytick', 0 : 0.1 : 0.5)

subplot(1, 2, 2), plot(sigma, fparam(:, 2), 'k.'), hold on, plot([0, 0.1], [0, 0.1], 'r:')
xlim([0, 0.1]), ylim([0, 0.1]), box off, axis square, 
set(gca, 'xtick', 0 : 0.05 : 0.1, 'ytick', 0 : 0.05 : 0.1)

%% trade-offs between tau and epsilon

newtau   = 0.05;
newsigma = 0.028;
nSamples2 = 500;

pred2 = [];
pred2 = sum(trf_STNmodel([newtau, newsigma, scl(1)], stim, t, 1), 2);
pred2 = repmat(pred2, [1, nSamples2]);

noise = rand(size(stim, 1), nSamples2).*noiseStd;

% perturb by using 20% noise

noisypred2 = noise + pred2;

% generate model predictions
% for k = 1 : nSamples2
%    pred2(k, :) = sum(trf_STNmodel([noisyTau(k), noisySig(k), scl(1)], stim, t, 1), 2);
% end

for k = 1 : nSamples2
  % seed = [tau1(k), sigma(k), scl(k)];
   fparam2(k, :) = fminsearchbnd(@(x) trf_modelFineFit(x, noisypred2(:, k), stim, t, 1, 'STN'), [newtau, newsigma, scl(1)], lb, ub);
end

%% use one set of tau and sigma to generate some model prediction
figure (3), clf
plot(fparam2(:, 1), fparam2(:, 2), 'k.', 'markersize', 5), hold on,  axis square, box off
xlim([0, 0.1]), ylim([0, 0.05]), 
plot([0, 0.05], [0.028, 0.028 ], 'r:'), plot([0.05, 0.05], [0, 0.028], 'r:'), plot(0.05, 0.028, 'r.', 'markersize', 20)
xlabel('tau'), ylabel('sigma')