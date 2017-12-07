% plot HRF for different ROIs

%% load HRF

% subject wl_subj001
%retLoc = '/Volumes/server/Projects/Retinotopy/wl_subj001/wl_subj001_2013_12_18/Gray/Averages Bars/';

% wl_subj023
%retLoc = '/Volumes/server/Projects/Retinotopy/wl_subj023/wl_subj023_2015_07_03/Gray/Averages bars/';

% wl_subj030
%retLoc = '/Volumes/server/Projects/Retinotopy/wl_subj030/Gray/Averages_ROIs/';

% wl_subj031
retLoc = '/Volumes/server/Projects/Retinotopy/wl_subj031/Gray/Averages_ROIs/';


%% construct HRF for each ROI

t = [];
roi = {'V1', 'V2', 'V3', 'V3ab', 'hV4', 'VO', 'LO', 'TO', 'IPS'}; 

t = linspace(1, 30, 30);

for k = 1 : length(roi)
    fName = sprintf('rm_%s-fFit-fFit-fFit.mat', roi{k});
    a     = load(fullfile(retLoc, fName));
    hrfparams(k, :) = a.model{1}.hrf.params{2};
    hrf(k, :) = rmHrfTwogammas(t, hrfparams(k, :));
end
%% construct hrf

col = parula(length(roi));

figure (1), clf
for iroi = 1 %: length(roi)
    plot(t, hrf(iroi, :), 'color', col(iroi, :), 'linewidth', 3), hold on
end
legend(roi), xlabel('time (s)'), ylabel('arbitrary unit'), box off


