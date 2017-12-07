function linrsp = trf_linModel(param, stim)
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

linrsp = sum(stim, 2).*x.scale;

end