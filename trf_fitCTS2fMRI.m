function [ctsprm, pred, r2, seed] = fitCTS2fMRI(data, stim, t)

% data size n samples x m time profiles

% Example:
% data = mdt;
% [stim, t] = importStimulus('with0');

%% load parameters
b = load(fullfile(temporalRootPath, 'data', 'params.mat'));
cts = b.params.cts;

% make grid
[t1grd, epsgrd] = meshgrid(cts.tau1grid, cts.epsgrid);

ngrid    = length(cts.tau1grid);
tau1grid = reshape(t1grd, [1, ngrid^2]);
epsgrid  = reshape(epsgrd, [1, ngrid^2]);

% lower and upper bound
lb = cts.lowerBnd{1};
ub = cts.upperBnd{1};

%% grid fit
crsseed = 0.001;
seed    = [];

parfor k = 1 : size(data, 1)
    for k1 = 1 : length(tau1grid)
        tau1 = tau1grid(k1);
        eps  = epsgrid(k1);
        tofit = data(k, :);
        % coarse fit
        crsscl(k, k1) = fminsearch(@(x) gridfit(x, tau1, eps, tofit, stim, t), crsseed);
        crsr2(k, k1)  = computeCTSR2([crsscl(k, k1), tau1, eps], tofit, stim, t);
    end
    % assign seed
    idx = find(crsr2(k, :) == max(crsr2(k, :)));
    seed(k, :) = [tau1grid(idx), epsgrid(idx), crsscl(k, idx)];
end

%% fine fit
parfor k = 1 : size(data, 1)
    tofit = data(k, :);
    sd    = seed(k, :);
    ctsprm(k, :) = fminsearchbnd(@(x) finefit(x, tofit, stim, t), sd, lb, ub);
    [r2(k), pred(k, :)] = computeCTSR2(ctsprm(k, :), tofit, stim, t);
end


%% sub-functions
% compute grid fit---------------------------------------------------

    function target = gridfit(scale, tau1, eps, smpdata, stim, t)
        % dt is of size (1 x n time profiles)
        
        % compute model response
        rspts  = trf_CTSmodel([tau1, eps, scale], stim, t);
        rsp    = sum(rspts, 2);
        target = sum((smpdata - rsp').^2);
    end

% compute r2 in the coarse fit----------------------------------------
    function [r2, rsp] = computeCTSR2(param, smpdata, stim, t)
        
        rspts = trf_CTSmodel(param, stim, t);
        rsp   = sum(rspts, 2);
        r2    = corr(rsp, smpdata').^2;
    end

% fine fit cts model ---------------------------------------------
    function target = finefit(param, smpdata, stim, t)
        % compute model response
        rspts  = trf_CTSmodel(param, stim, t);
        rsp    = sum(rspts, 2);
        target = sum((smpdata - rsp').^2);
        
        % figure (1), clf
        % plot(rsp), hold on
        % plot(smpdata), drawnow
    end

end
