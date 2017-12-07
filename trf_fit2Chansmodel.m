function diff = trf_fit2Chansmodel(params, stimulus, data, t)

%% compute model prediction

output =  sum(trf_2chansModel(params, stimulus, t), 2);

%% compute the squared error

diff  = sum((output - data).^2);


%% plot
% 
% figure (100), clf
% plot(output, 'r'), hold on
% plot(data, 'b'), drawnow

end