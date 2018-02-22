function r2 = computeR2(x, fitx)
% r2 = computeR2(x, fitx)
% r2 = 100 * (1 - sum((fitx - x).^2)/sum(x.^2));

r2 = 100 * (1 - sum((fitx - x).^2)/sum(x.^2));

end
