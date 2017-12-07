function [sctsprm, pred, r2, seed] = trf_fitSCTS2fMRI(data, stim, t)

% data size n samples x m time profiles

% example data
%data = rsdt(2, :);
%% load parameters

b    = load(fullfile(temporalRootPath, 'data', 'params.mat'));
scts = b.params.scts;

% make grid
[t1grid, sigmagrid] = meshgrid(scts.tau1grid, scts.sigmagrid);

ngrid     = length(scts.tau1grid);
tau1grid  = reshape(t1grid, [1, ngrid^2]);
sigmagrid = reshape(sigmagrid, [1, ngrid^2]);

% set lower and upper bbound
lb = [0.001, 0.0001, 0];
ub = [1, 1, 1];

%% grid fit

crsseed = 0.001;
seed    = [];

for k = 1 : size(data, 1)
    for k1 = 1 : length(tau1grid)
        tau1  = tau1grid(k1);
        sigma = sigmagrid(k1);
        tofit = data(k, :);
        
        % grid git
        crsscl(k, k1) = fminsearch(@(x) gridfit(x, tau1, sigma, tofit, stim, t), crsseed);
        crsr2(k, k1)  = computeSCTSR2([crsscl(k, k1), tau1, sigma], tofit, stim, t);
    end
    % assign seed
    idx = find(crsr2(k, :) == max(crsr2(k, :)), 1);
    seed(k, :) = [tau1grid(idx), sigmagrid(idx), crsscl(k, idx)];
end

%% fine fit

for k = 1 : size(data, 1)
    tofit = data(k, :);
    sd    = seed(k, :);
    sctsprm(k, :) = fminsearchbnd(@(x) finefit(x, tofit, stim, t), sd, lb, ub);
    [r2(k), pred(k, :)] = computeSCTSR2(sctsprm(k, :), tofit, stim, t);
end

%% sub-functions

% compute grid fit ----------------------------------
    function res = gridfit(scale, tau1, sigma, smpdata, stim, t)
        rspts = trf_sCTSmodel([tau1, sigma, scale], stim, t);
        rsp = sum(rspts, 2);
        res = sum((smpdata - rsp').^2);
    end

% compute r2 in the coarse fit ----------------------
    function [r2, rsp] = computeSCTSR2(param, smpdata, stim, t)
        
        rspts = trf_sCTSmodel(param, stim, t);
        rsp   = sum(rspts, 2);
        r2    = corr(rsp, smpdata').^2;
    end

% fine fit scts model ------------------------------
    function target = finefit(param, smpdata, stim, t)
        % compute model response
        rspts  = trf_sCTSmodel(param, stim, t);
        rsp    = sum(rspts, 2);
        target = sum((smpdata - rsp').^2);
%         
%         figure (1), clf
%         plot(rsp), hold on
%         plot(smpdata), drawnow
    end
end