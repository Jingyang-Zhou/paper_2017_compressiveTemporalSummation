% scts_reliability

%% estimate fMRI noise
clear all
dataPth = fullfile(temporalRootPath, 'results');
dataFileName = 'temporalParams.mat';
a    = load(fullfile(dataPth, dataFileName));
fmri = squeeze(mean(a.data.fmri1));
mfmri = mean(fmri, 2);
datanoise = mean(fmri - mfmri, 3);

% think about if this is the right noise level to use
nroi = size(fmri, 1);
for iroi = 1 : nroi
   roinoise(iroi) = std(datanoise(iroi, :)); 
end
noiseStd = mean(roinoise);

%% generate sCTS model with different parameters

model    = [];
nSamples = 1000;

lb = [0.01, 0.001, 0];
ub = [0.5, 0.1, 1];

normMax = @(x) x./max(x);

prm.stim = a.params.fmri1.tProfiles;
t        = [1 : length(prm.stim)]./1000;

tau1  = normMax(rand([1, nSamples]) + lb(1));
sigma = normMax(rand([1, nSamples]) + lb(2));
scl   = 5*10^(-4)*ones(1, nSamples);
noise = rand(nSamples, size(prm.stim, 1)).*noiseStd;

% generate sCTS predictions
for k = 1 : nSamples
   model(k, :) = trf_sCTSmodel([tau1(k), sigma(k), scl(k)], prm.stim, t);
end
noisy_model = model + noise;

%% fit model

for k = 1 : nSamples
   seed = [tau1(k), sigma(k), scl(k)];
   fparam(k, :) = fminsearchbnd(@(x) trf_fitSCTSModel(x, noisy_model(k, :)', prm.stim, t), seed, lb, ub);
end

%% plot fitted parameters

figure (1), clf
subplot(1, 2, 1), plot(tau1, fparam(:, 1), 'k.', 'markersize', 5), hold on, title('tau1')
subplot(1, 2, 2), plot(sigma, fparam(:, 2), 'k.', 'markersize', 5), hold on, title('sigma')

for k = 1 : 2
   subplot(1, 2, k),
   plot([0, 1], [0, 1], 'r:', 'linewidth', 3), box off,
   set(gca, 'xtick', 0 : 0.2:1, 'ytick', 0 : 0.2 : 1), 
   xlabel('generated'), ylabel('fitted'), axis square
end

%% save data
data = [];
data.generated = [tau1; sigma; scl];
data.fitted    = fparam;
data.noiseStd  = noiseStd;

saveLoc = fullfile(temporalRootPath, 'output', 'sCTSModelRecovery.mat');
save(saveLoc, 'data')
