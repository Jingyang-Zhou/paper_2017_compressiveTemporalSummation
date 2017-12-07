function derivedParam = trf_computeDerivedParams(whichModel, expNum, prm)
% 
% DESCRIPTION: compute r_double and t_isi
%
% INPUTS ----------------------------
% data:
% whichModel:
% expNum:
% prm:
%
% OUTPUTS ---------------------------
%
% DEPENDENCIES ----------------------

%% for debugging purpose

% data = inputdt;
% whichModel = 'ETC';% or ETC
% expNum = 1;
% prm = etc.param;

%% compute r_double

r_double = [];

for k = 1 : size(prm, 1)
    r_double(k) = trf_compute_r_double(prm(k, :), whichModel);
end

%% compute t_isi

t_isi = [];

t_isi = trf_compute_t_isi(prm, whichModel);

%% make the final parameters

derivedParam.r_double = r_double;
derivedParam.t_isi    = t_isi;


end