function r_double = trf_compute_r_double(prms, whichModel)
%
% DESCRIPTION ----------------------------------
%
% INPUTS ---------------------------------------
% stim:
% prms: 
% t:
% whichModel: 'STN' or 'ETC'
%
% OUTPUTS --------------------------------------
%
%% for debugging purpose
% prms = [0.1, 0.1, 0.1];
% whichModel = 'STN';

%% make stimulus
T = 3;
stim = zeros(2, T*1000);
stim(1, 1 : 100) = 1;
stim(2, 1 : 200) = 1;
t = 0.001 : 0.001 : T;

%%  compute model responses

switch whichModel
    case 'STN', rsp = sum(trf_STNmodel(prms, stim, t, 1), 2);
    case 'ETC', rsp = sum(trf_ETCmodel(prms, stim, t, 1), 2);
end

%% compute r_double

r_double = rsp(2)/(2*rsp(1));

end