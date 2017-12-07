function residual = trf_modelFineFit(param, data, stim, t, whichExp, whichModel)
%
% DESCRIPTION ---------------------
%
% INPUTS -------------------
% param:
% data:
% stim:
% t:
%
% OUTPUTS -----------------
%
%% for testing purpose
% data = inputdt(:, 1);
% whichExp = 2;
% param = [1, 1, 1, 1];
% whichModel = 'ETC';
%%

switch whichModel
    case {'STN', 'STNvar1', 'STNvar2'}
        pred = trf_STNmodel(param, stim, t, whichExp);
    case 'ETC'
        pred = trf_ETCmodel(param, stim, t, whichExp);
    case 'TTC'
        pred = trf_2chansModel(param, stim, t);
end

s_pred = sum(pred, 2);
residual = sum((data - s_pred).^2);

%%
% figure (1), clf
% plot(s_pred, 'r-'), hold on
% plot(data, 'b-'), drawnow

end