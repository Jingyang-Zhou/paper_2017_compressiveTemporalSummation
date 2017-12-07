
function rsdata = trf_reshape(data, analyzeWhichData)

% reshaping data into (stimulus conditions x bootstraps).
%
% INPUTS -------------------------------------------------

% data : has three fields, data.fmri1, data.fmri1ecc, data.fmri2
% analyzeWhichData : 'exp1', 'exp1ecc', 'exp1indi', 'exp2' or 'all'

% OUTPUTS -------------------------------------------------

% size of the reshaped exp1 data: 13 x 900
% size of the reshaped exp1 individual data: 13 x 3600
% size of the reshaped exp1ecc data: 13 x 1800
% size of the reshaped exp2 data : 25 x 900

%% example: for the purpose of debugging
% analyzeWhichData = 'exp2';

%%
rsdata = [];

switch analyzeWhichData
    case{'exp1indi'}
        tmp1 = permute(data.fmri1.data, [4, 3, 2, 1]);
        rsdata = reshape(tmp1, [size(tmp1, 1), size(tmp1, 2)*size(tmp1, 3)*size(tmp1, 4)]);
    case {'exp1'}
        tmp2 = mean(permute(data.fmri1.data, [4, 3, 2, 1]), 4);
        rsdata = reshape(tmp2, [size(tmp2, 1), size(tmp2, 2)*size(tmp2, 3)]);
    case {'exp1ecc'}
        tmp3 = permute(data.fmri1ecc.data, [4, 3, 2, 1]);
        rsdata = reshape(tmp3, [size(tmp3, 1), size(tmp3, 2) * size(tmp3, 3) * size(tmp3, 4)]);
    case {'exp2'}
        tmp4 = mean(permute(data.fmri2.data, [4, 3, 2, 1]), 4);
        rsdata = reshape(tmp4, [size(tmp4, 1), size(tmp4, 2) * size(tmp4, 3)]);
    otherwise error('Input error to function trf_reshape: analyzeWhichData');
end

end
