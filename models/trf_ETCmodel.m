function ctsrsp = trf_ETCmodel(param, stim, t, whichExp)
%
% INPUTS--------------------------------------------------------
% param : 3 entries, tau1, eps, and scale
% stim  : n stim x time course of each stim
% t     : time, in unit of millisecond
%
% OUTPUT ------------------------------------------------------
% ctsrsp : response time course, in unit of millisecond
%
% dependencies ------------------------------------------------
% convCut.m

%% pre-defined variables

x = [];

%% initiate model fitting

x.tau1  = param(1);
x.eps   = param(2);

switch whichExp
    case 1, x.scale = param(3);
    case 2, x.scale = [param(3), param(4)];
    otherwise error('Input error in trf_STNmodel: whichExp.')
end

%% compute scales

scaleVec = ones(1, size(stim, 1));

switch whichExp
    case 1, scaleVec = scaleVec.*x.scale;
    case 2, scaleVec(1 : 12) = scaleVec(1 : 12)*x.scale(1); scaleVec(1, 13 : end) = scaleVec(1, 13 : end)*x.scale(2);
end


%% compute response

% compute irf
irf = gammaPDF(t, x.tau1, 2);

for istim = 1 : size(stim, 1)
    % compute linear response
   linrsp(istim, :) = convCut(irf, stim(istim, :), length(irf)); 
   % compute exponentiated response
   ctsrsp(istim, :) = scaleVec(istim).*linrsp(istim, :).^x.eps;
end

end