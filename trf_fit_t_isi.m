function residual = trf_fit_t_isi(gap, prm, thresh, stim, t, whichModel, linPrd)


%% create new stimulus

stim_on  = find(stim == 1);
stim_lth = length(stim_on);
stim_end = stim_on(end);

% create the second pulse
pulse2_st  = stim_end + gap + 1;
pulse2_end = stim_end + gap + 1 + stim_lth;

stim(pulse2_st : pulse2_end) = 1;

%% compute

switch whichModel
    case 'STN'
        rsp = sum(trf_STNmodel(prm, stim, t, 1));
    case 'ETC'
        rsp = sum(trf_ETCmodel(prm, stim, t, 1));
end

%% compute residual

residual = abs(linPrd * thresh - rsp);

%%
% figure(1), clf
% plot(linPrd*thresh, 'ro'), hold on
% plot(rsp, 'bo'), ylim([0, 0.4]), drawnow

end