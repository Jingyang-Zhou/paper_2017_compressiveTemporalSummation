function [modelparam, modelprd, modelr2] = trf_fineFit(data, whichModel, expNum, stim, t, seed, param)
 % DESCRIPTION
 %
 % INPUTS ------------------------------------------------
 % data:
 % whichModel:  'STN', 'ETC'
 % expNum : 1 or 2
 % stim:
 % t
 % OUTPUTS -----------------------------------------------
 %
 % DEPENDENCIES ------------------------------------------
 %
 %% for testing purpose
%  data = inputdt;
%  whichExp = 2;
%  seed = [1, 0.1, 0.001, 0.001];
%  whichModel = 'ETC';
%  
 %% prepare to fit model
 
 switch whichModel
     case 'STN'
         lb = param.stn.lowerBnd{expNum};
         ub = param.stn.upperBnd{expNum};
     case 'ETC'
         lb = param.etc.lowerBnd{expNum};
         ub = param.etc.upperBnd{expNum};
     case 'STNvar1'
         lb = [param.stn.lowerBnd{expNum}(1 : 2), 0, param.stn.lowerBnd{expNum}(3)];
         ub = [param.stn.upperBnd{expNum}(1 : 2), 10, param.stn.upperBnd{expNum}(3)];
     case 'STNvar2'
         lb = [param.stn.lowerBnd{expNum}(1 : 2), 0, 0, param.stn.lowerBnd{expNum}(3)];
         ub = [param.stn.upperBnd{expNum}(1 : 2), 10, 10, param.stn.upperBnd{expNum}(3)];
 end
 
 %% fit model
 
 modelparam = [];
 
 for k = 1 : size(data, 2)
     modelparam(k, :) = fminsearchbnd(@(x)trf_modelFineFit(x, data(:, k), stim, t, expNum, whichModel),seed(k, :), lb, ub);
 end
 
 %% Make model prediction
 
 switch whichModel
     case {'STN', 'STNvar1', 'STNvar2'}
         for k = 1 : size(data, 2)
             modelprd(k, :) = sum(trf_STNmodel(modelparam(k, :), stim, t, expNum),2);
             modelr2(k) = corr(modelprd(k, :)', data(:, k)).^2;
         end
     case 'ETC'
         for k = 1 : size(data, 2)
             modelprd(k, :) = sum(trf_ETCmodel(modelparam(k, :), stim, t, expNum), 2);
             modelr2(k) = corr(modelprd(k, :)', data(:, k)).^2;
         end
 end
 
 %% 
 


 