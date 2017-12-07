% fit 2 temporal channels to the fMRI data

%% load data and stimulus

fLoc  = fullfile(temporalRootPath, 'data', 'fMRI');
fName = 'trf_fmridata.mat';

a          = load(fullfile(fLoc, fName));
dataStruct = a.data;
param      = a.param;

[stim, t] = importStimulus('with0');

%% extract data

data = trf_reshape(dataStruct, 'exp1');

%% grid fit

[ttc.seed, ttc.seedr2] = trf_gridFit(data, 'TTC', 1, param, stim, t);

%% fit a two-temporal channel model to the data

prm = [];

for k = 1  : length(data)
   prm(k, :) = fminsearchbnd(@(x) trf_fit2Chansmodel(x, stim, data(:, k), t), ttc.seed(k, :), [0, 0], [1, 1]); 
end

%% make non x-validated model predictions

for k = 1 : length(data)
    pred(k, :) = sum(trf_2chansModel(prm(k, :), stim, t), 2);
end

%% visualize model predictions and parameters (1)

mprm = [];
sprm = [];

nrois = 9;

for iroi = 1 : nrois
    idx = (iroi - 1) * 100 + 1 : iroi * 100;
    % average the model predictions
    mpred(iroi, :) = mean(pred(idx, :));
    spred(iroi, :) = std(pred(idx, :));
    
    % average the data
    mdata(iroi, :) = mean(data(:, idx), 2);
    sdata(iroi, :) = std(data(:, idx), [], 2);
    
    % average the model parameters
    mprm(iroi) = median(prm(idx, 2)./prm(idx, 1));
    sprm(iroi, :) = prctile(prm(idx, 2)./prm(idx, 1), [25, 75]);
end

%% xvalidate model fit for the TTC model

[ttc.xparam, ttc.xPrd, r2] = trf_xValidate(data', 'TTC', 1, ttc.seed, stim, t, param); 

% RE-WRITE THIS PART
for k = 1 : 13
    m(k, :) = squeeze(ttc.xPrd(k, :, k));
end

%% summarize and save the model parameters and fit

ttc.param = prm;
ttc.prd   = pred;

ttc.xPrdObsolete = ttc.xPrd;
ttc.xPrd = m;

savPth = fullfile(temporalRootPath, 'output', 'exp1model.mat');
b = load(savPth);

etc = b.etc;
lin = b.lin;
stn = b.stn;

save(savPth, 'etc', 'lin', 'stn', 'ttc')

%% visualize model predictions and parameters (2)

order = [13, 1 : 6, 5, 7 : 12];

% plot model fit
figure (1), clf
for iroi = 1 : nrois
   subplot(3, 3, iroi) 
   plot(1 : 7, mdata(iroi, order(1 : 7)), 'ko'), hold on
   plot(1 : 7, mpred(iroi, order(1 : 7)), 'r-')
   
   plot(8 : 14, mdata(iroi, order(8 : 14)), 'ko')
   plot(8 : 14, mpred(iroi, order(8 : 14)), 'r-')
   title(dataStruct.fmri1.nm{iroi})
   ylim([0, 0.6])
end

 
% plot the ratio between the parameters
figure (2), clf
plot(mprm, 'ko', 'markersize', 10, 'markerfacecolor', 'k'), hold on

for iroi = 1 : nrois
   plot([iroi, iroi], [sprm(iroi, :)], 'k-'), hold on 
end

set(gca, 'xticklabel', dataStruct.fmri1.nm), 
title('ratio between the peripheral and the foveal weights'), xlim([0.5, 9.5])

%%
