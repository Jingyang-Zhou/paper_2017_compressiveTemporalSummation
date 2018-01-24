function [linrsp, linrsp_tc] = trf_LinModel(param, stim, t)
%
% INPUTS: 
% param : 
% stim  :
% t     :
%
% OUTPUT : 
% ctsrsp :

%% pre-defined variables

x = [];

%% initiate model fit

x.scale = param;

%% compute response
% example time course prediction, not really being used in the paper

irf = gammaPDF(t, 0.1, 2);

for k = 1 : size(stim, 1)
    linrsp_tc(k, :) = convCut(irf, stim(k, :), length(t));
end


% linear prediction used to compute the result in the paper
linrsp = sum(stim, 2).*x.scale;

end