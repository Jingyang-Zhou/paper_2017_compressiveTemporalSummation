function t_isi = computeT_isi(param, thresh, stim, t, whichModel)

options = optimoptions(@ga, 'Display', 'off');
t_isi = [];

for k = 1 : size(param, 1)
    % compute linearly predicted response
   
    thisprm = param(k, :);
    linrsp = sum(trf_CTSmodel(thisprm, stim, t))^2;
    [t_isi(k), ~, exitFlg(k)] = ga(@(x) fit_tisi(x, thisprm, thresh, stim, t, whichModel,...
        linrsp), 1, [], [], [], [], 1, 4500, [], 1, options);
    if exitFlg(k) == 0, t_isi(k) = nan; end
end
end