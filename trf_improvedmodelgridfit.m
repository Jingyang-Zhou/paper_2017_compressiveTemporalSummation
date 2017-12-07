function r2 = trf_improvedmodelgridfit(scale, modelparams, data, stim, t, whichExp, whichModel)
%
% DESCRIPTION -----------------
%
% INPUTS ----------------------
%
% OUTPUTS ---------------------

%%
switch whichModel
    case {'STN' , 'STNvar1', 'STNvar2'}
        rsp = trf_STNmodel([modelparams', scale], stim, t, whichExp);
    case 'ETC'
        rsp = trf_ETCmodel([modelparams, scale], stim, t, whichExp);
    case 'TTC'
        rsp = trf_2chansModel([modelparams, scale], stim, t);
end

s_rsp = sum(rsp, 2);

% compute r2
r2 = corr(s_rsp, data).^2;


%%
% figure (1), clf
% plot(s_rsp, 'r-'), hold on
% plot(data, 'b-'), drawnow

end
