function r2 = computeGridFitR2(param, data, whichModel, stim, t, whichExp)

switch whichModel
    case {'STN', 'STNvar1'}
        rsp = trf_STNmodel(param, stim, t, whichExp);
    case 'ETC'
        rsp = trf_ETCmodel(param, stim, t, whichExp);
    case 'TTC'
        rsp = trf_2chansModel(param, stim, t);
end

s_rsp = sum(rsp, 2);
r2    = corr(s_rsp, data).^2;

end
