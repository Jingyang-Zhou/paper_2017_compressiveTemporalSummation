function [linprm, pred, r2] = trf_fitLinear2fMRI(data, stim, whichExp)
%
% INPUTS:
% data : size (n samples x m time courses)
% stim : size
%% compute linear response

rsp    = sum(stim, 2)';

%% regress linear scale and compute predicted response

for k = 1 : size(data, 1)
    linprm(k)  = regress(data(k, :)', rsp');
    % compute model prediction
    pred(k, :) = rsp.*linprm(k);
    % compute r2
    r2(k)      = corr(data(k, :)', pred(k, :)').^2;
end

switch whichExp
    case 1
        for k = 1 : size(data, 1)
            linprm(k)  = regress(data(k, :)', rsp');
            % compute model prediction
            pred(k, :) = rsp.*linprm(k);
            % compute r2
            r2(k)      = corr(data(k, :)', pred(k, :)').^2;
        end
    case 2
        for k = 1 : size(data, 1)
            linprm(k, 1)  = regress(data(k, [1 : 12, 25])', rsp(1, [1 : 12, 25])');
            linprm(k, 2)  = regress(data(k, [13 : 24, 25])', rsp(1, [13 : 24, 25])');
            % compute model prediction
            pred(k, 1 : 12) = rsp(1 : 12).*linprm(k, 1);
            pred(k, 13 : 25) = rsp(13 : 25).*linprm(k, 2);
            % compute r2
            r2(k)      = corr(data(k, :)', pred(k, :)').^2;
        end
        
end


end