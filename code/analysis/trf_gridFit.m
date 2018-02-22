function [modelseed, modelr2] = trf_improvedgridFit(inputdt, whichModel, expNum, param, stim, t)
% DESCRIPTION
%
% INPUTS ------------------------------------------------------------
% inputdata : %(number of stimulus conditions) x (bootstraps)
% whichModel: either "STN" or "ETC"
% expNum    : "1" or "2"
% param     : the param file from the saved data
%
% OUTPUTS -----------------------------------------------------------
% modelseed : seed for each bootstrap
% modelr2   : all the r2 for each set of parameters and each bootstrap
%
% DEPENDENCIES ------------------------------------------------------
% trf_modelgridfit.m -- trf_STNmodel.m, trf_ETCmodel
% computeGridFitR2.m -- trf_STNmodel.m, trf_ETCmodel

%% for code testing purpose
% whichModel = 'ETC';
% expNum     = 1;

%% extract grid parameters and make grid

switch whichModel
    case 'STN', [element{1}, element{2}] = meshgrid(param.stn.tau1grid, param.stn.sigmagrid); 
    case 'ETC', [element{1}, element{2}] = meshgrid(param.etc.tau1grid, param.etc.epsgrid);
    case 'TTC', [element{1}, element{2}] = meshgrid(param.ttc.fWtGrd, param.ttc.pWtGrd);
    case 'STNvar1', [element{1}, element{2}, element{3}] = meshgrid(param.stn.tau1grid, param.stn.sigmagrid, param.stn.ngrid);
    case 'STNvar2', [element{1}, element{2}, element{3}, element{4}] = ndgrid(param.stn.tau1grid, param.stn.sigmagrid, param.stn.ngrid, param.stn.mgrid); 
    otherwise error('Input error in trf_gridFit: whichModel')
end

nSteps = length(element{1});
dim    = length(element);

for k = 1 : dim 
   grid(k, :) = reshape(element{k}, [1, nSteps^dim]);
end


%% initiate seeding

% for model STN and ETC, fit the scaling parameter only
switch expNum
    case 1, scale = 0.001;
    case 2, scale = [0.001, 0.001];
end

%% do grid fit

% each bootstrap takes about 8 seconds, so 900 bootstraps take about 2
% hours
maxIdx    = [];
modelseed = [];
modelr2   = [];
r2 = nan(size(inputdt, 2), nSteps.*dim);

for k = 1  :  size(inputdt, 2)
    parfor k1 = 1 : nSteps.^dim
        r2(k, k1) = trf_modelgridfit(scale, grid(:, k1), inputdt(:, k), stim, t, expNum, whichModel);
    end
end

% find the set of parameters that produce the maximum response r2
for k = 1 : size(inputdt, 2)
    maxIdx(k)       = find(r2(k, :) == max(r2(k, :)), 1);
    modelseed(k, :) = grid(:, maxIdx(k));
    modelr2(k, :)   = r2(k, maxIdx(k));
end

end
