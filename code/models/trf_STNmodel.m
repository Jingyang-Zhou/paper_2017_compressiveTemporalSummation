function rsp = trf_STNmodel(param, stim, t, whichExp)
% function rsp = trf_STNmodel(param, stim, t, whichExp)
% INPUTS:
% param:  a vector of three entries, the first entry is tau1, the second is
%         sigma, and the third is the scale
% stim :  size(nstim x stim. time course)
% t    :  stimulus at each time point
%
% OUTPUTS: 
% rsp  :  size(n stim x response time course to each stimulus)

%% pre-defined variables

x   = [];


%% initiate model fitting

x.tau1  = param(1);
x.sigma = param(2);

if whichExp == 1 & length(param) == 4
    x.n = param(3); x.m = x.n;
elseif whichExp == 1 &length(param) == 5
    x.n = param(3);
    x.m = param(4);
else
    x.n = 2; x.m = x.n;
end

switch whichExp
    case 1, x.scale = param(end);
    case 2, x.scale = [param(end - 1), param(end)];
    otherwise error('Input error in trf_STNmodel: whichExp.')
end

%% compute scales

% scale the response to make a prediciton
scaleVec = ones(1, size(stim, 1));

switch whichExp
    case 1, scaleVec = scaleVec.*x.scale;
    case 2, scaleVec(1 : 12) = scaleVec(1 : 12)*x.scale(1); scaleVec(1, 13 : end) = scaleVec(1, 13 : end)*x.scale(2);
end

%% compute model predictions

% compute irf
irf = gammaPDF(t, x.tau1, 2);

for istim = 1 : size(stim, 1)
    % compute linear response
    linrsp(istim, :) = convCut(irf, stim(istim, :), length(irf));
    % compute numerator:
    num(istim, :) = linrsp(istim, :).^x.m;
    dem(istim, :) = x.sigma.^x.n + linrsp(istim, :).^x.n;
    % compute normalized response
    normrsp(istim, :) = num(istim, :)./dem(istim, :);
    % scale the normalized response
    rsp(istim, :) = normrsp(istim, :).* scaleVec(istim);
end



end