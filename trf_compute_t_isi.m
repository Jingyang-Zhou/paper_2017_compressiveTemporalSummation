function t_isi = trf_compute_t_isi(prm, whichModel)
%
% DESCRIPTION ------------------
%
% INPUTS -----------------------
% prm: take a matrix as an input
%
% OUTPUTS ----------------------
%
% DEPENDENCIES -----------------
%
%% for debugging purpose

% prm = etc.param;
% whichModel = 'ETC';

%% make stimulus

T = 5;
t = 0.001 : 0.001 : T;
stim = zeros(1, length(t));
stim(1 : 100) = 1;

%% make threshold

thresh = 2-1/exp(1);

%% compute linear prediction

switch whichModel
    case 'STN'
        for k = 1 : size(prm, 1), linprd(k) = sum(trf_STNmodel(prm(k, :), stim, t, 1)); end
    case 'ETC'
        for k = 1 : size(prm, 1), linprd(k) = sum(trf_ETCmodel(prm(k, :), stim, t, 1)); end
end

%% compute t_isi

 %options = optimoptions(@ga, 'Display', 'off');
 
 options = gaoptimset('Display', 'off');

for k = 1 : size(prm, 1)
    
    [t_isi(k), ~, exitFlg(k)] = ga(@(x) trf_fit_t_isi(x, prm(k, :), thresh, stim, t, whichModel, linprd(k)), ...
        1, [], [], [], [], 1, 4500, [], 1);
     if exitFlg(k) == 0, t_isi(k) = nan; end
end


end