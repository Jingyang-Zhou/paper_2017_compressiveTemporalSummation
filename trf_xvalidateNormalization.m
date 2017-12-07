% x-validate normalization model

%% load data

dataLoc = '/Volumes/server/Projects/Temporal_integration/data/preprocessed_data.mat';
a = load(dataLoc);

data = squeeze(mean(a.dt.fmri1.data));

data = reshape(permute(data, [2, 1, 3]), 900, 13);

[stim, time] = importStimulus('with0');

% load model
prmLoc = '/Volumes/server/Projects/Temporal_integration/output/scts.mat';
b = load(prmLoc);
seed = b.scts.seed;

computeR2  = @(x, fitx) 100 * (1 - sum((fitx - x).^2)/sum(x.^2));

%% fit model

xparam = [];
xr2    = [];
xpred  = [];

for k = 1 : 13
    n_stim = leftOneOut(stim, k, 1);
    t = time(1, :);
    % fit model to the remain conditions
    % diff = trf_fitSCTSModel(params, data, stim, t)
    tofit = leftOneOut(data, k, 2);
    for k1 = 1 : 900
        %xparam(k, k1, :) = fminsearchbnd(@(x) trf_fitSCTSModel(x, tofit(k1, :)', n_stim, t), seed(k1, :), [0,0,0], [1,1,1]);
        xpred(k, k1, :)  = sum(trf_SCTSmodel(squeeze(xparam(k, k1, :)), stim, t), 2);
        xr2(k, k1) = computeR2(data(k1, :), squeeze(xpred(k, k1, :))');
    end
end

%% save data

scts = b.scts;

%scts.xparam = xparam;
scts.xpred = xpred;
scts.xr2 = xr2;

save(prmLoc, 'scts')

