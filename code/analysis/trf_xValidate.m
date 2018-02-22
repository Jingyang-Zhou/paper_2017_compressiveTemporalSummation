function [xparam, xpred, r2] = trf_xValidate(data, whichModel, expNum, seed, stim, t, param)
% 
% DESCRIPTION: THIS SCRIPT STILL NEEDS A LOT MORE WORK (MAKE IT VALID FOR THE SECOND EXP)
% INPUTS ----------------------------------------
%
% OUTPUTS ---------------------------------------
%
% DEPENDENCIES ----------------------------------
%
%% for test purpose only
% data = inputdt';
% whichModel = 'lin';% ETC
% expNum = 1;
% seed = stn.seed;

%% extract lower and upper bound
 switch whichModel
     case 'STN'
         lb = param.stn.lowerBnd{expNum};
         ub = param.stn.upperBnd{expNum};
     case 'ETC'
         lb = param.etc.lowerBnd{expNum};
         ub = param.etc.upperBnd{expNum};
     case 'TTC'
         lb = param.ttc.lowerBnd(1 : 2);
         ub = param.ttc.upperBnd(1 : 2);
     case 'STNvar1'
         lb = [param.stn.lowerBnd{expNum}(1 : 2), 0, param.stn.lowerBnd{expNum}(3)];
         ub = [param.stn.upperBnd{expNum}(1 : 2), 10, param.stn.upperBnd{expNum}(3)];
     case 'STNvar2'
         lb = [param.stn.lowerBnd{expNum}(1 : 2), 0, 0, param.stn.lowerBnd{expNum}(3)];
         ub = [param.stn.upperBnd{expNum}(1 : 2), 10, 10, param.stn.upperBnd{expNum}(3)];
 end

 computeR2  = @(x, fitx) 100 * (1 - sum((fitx - x).^2)/sum(x.^2));
 
%% xvalidate for STN and ETC model

if ~strcmp(whichModel, 'lin')
    if expNum == 1
        for k = 1 : size(stim, 1)
            n_stim = leaveOneOut(stim, k, 1);
            % fit model to the remain conditions
            % diff = trf_fitSCTSModel(params, data, stim, t)
            tofit = leaveOneOut(data, k, 2);
            % for STN and ETC model---------------------
            for k1 = 1 : size(data, 1)
                xparam(k, k1, :) = fminsearchbnd(@(x)trf_modelFineFit(x, tofit(k1, :)', n_stim, t, ...
                    expNum, whichModel), seed(k1, :), lb, ub);
                switch whichModel
                    case {'STN', 'STNvar1', 'STNvar2'}, xpred(k, k1, :) = sum(trf_STNmodel(squeeze(xparam(k, k1, :)), stim, t, expNum),2);
                    case 'ETC', xpred(k, k1, :) = sum(trf_ETCmodel(squeeze(xparam(k, k1, :)), stim, t, expNum),2);
                    case 'TTC', xpred(k, k1, :) = sum(trf_2chansModel(squeeze(xparam(k, k1, :)), stim, t),2);
                end
                r2(k, k1) = computeR2(data(k1, :), squeeze(xpred(k, k1, :))');
            end
        end
    end
end

%% xvalidate linear model

if strcmp(whichModel, 'lin')
    if expNum == 1
        for k = 1 : size(stim, 1)
            n_stim = leaveOneOut(stim, k, 1);
            % fit model to the remain conditions
            % diff = trf_fitSCTSModel(params, data, stim, t)
            tofit = leaveOneOut(data, k, 2);
            
            for k1 = 1 : size(data, 1)
                xparam(k, k1, :) = trf_fitLinear2fMRI(tofit(k1, :), n_stim, expNum);
                xpred(k, k1, :)  = sum(stim, 2).*xparam(k, k1, :);
                r2(k, k1) = computeR2(data(k1, :), squeeze(xpred(k, k1, :))');
            end
        end
    end
end


%% compute xr2



end