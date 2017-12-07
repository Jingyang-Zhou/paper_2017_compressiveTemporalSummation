% roi_estimate hrf in the temporal experiment



for ii = 3 : 4


%% file locations
subj =  {'wl_subj001', 'wl_subj023', 'wl_subj030', 'wl_subj031'};
projLoc = fullfile(temporalRootPath, 'fMRI', 'experiment2');
subjId  = subj{ii};

cd(fullfile(projLoc, subjId))

%% load the denoised data

denoisedLoc = fullfile(projLoc, subjId, 'GLMdenoised13_usableData');
defName = 'denoiseddata.mat';
a = load(fullfile(denoisedLoc, defName));

% load denoised results
defName1 = 'denoisedresults.mat';
b = load(fullfile(denoisedLoc, defName1));
glmhrf = b.results.models{1};

% load original data
floc = fullfile(temporalRootPath, 'data', 'fMRI', 'trf_fmridata.mat');
c = load(floc);
tmp = squeeze((mean(c.data.fmri1.data, 3)));
origData = squeeze(tmp(2, :, :));

%% GLM denoised data
if ~exist('results', 'var'), load('GLMdenoised13/denoiseddata.mat'); end

% How to re-orient Kendrick's nifti output to match mrVista?
%   Get an example raw time series
vw       = initHiddenInplane;
dtNum    = viewGet(vw,'Current Data Type');
fileName = fullfile(projLoc, subjId, 'Raw', 'run01.nii');
nii      = niftiRead(fileName);
xform    = niftiCreateXform(nii,'inplane');

glm2vista = @(x) reorientForMrVista(x, xform);

for k = 1 : length(a.denoiseddata)
    data{k} = glm2vista(a.denoiseddata{k});
end

%% load rois

rois = {'V1', 'V2', 'V3', 'hV4', 'V3ab', 'VO', 'LO', 'TO', 'IPS'};

biRoiLabels = {};
indices = [];

for iroi = 1 : length(rois)
    % create bilateral roi labels
    biRoiLabels{iroi} = sprintf('bilateral%sEcc2to10', rois{iroi});
    % load bilateral rois
    vw = loadROI(vw, biRoiLabels(iroi), [], 'k', 0, 1);
end

for ii = 1:length(viewGet(vw, 'ROIs'))
    coords      = viewGet(vw, 'ROI coords', ii);
    rsFactor    = upSampleFactor(vw,1);
    coords(1,:) = round(coords(1,:)/rsFactor(1));
    coords(2,:) = round(coords(2,:)/rsFactor(2));
    indices{ii} = coords2Indices(coords,dataSize(vw,1));
end

%% make design matrix for each run

numScans      = 6;
numConditions = 13;
TR            = 1.5;

nFrames        = 167;
nTrials        = 54;
nFramePerTrial = 3;

stimfiles = matchfiles('Stimulus/20160*.mat');
assert(isequal(numel(stimfiles), numScans ));

dsMatrix = cell(1, numScans);

for k = 1 : numScans
    dm     = zeros(nFrames, numConditions);
    a      = load(stimfiles{k});
    cBlank = 0;
    for k1 = 1 : nTrials
        
        startPoint = (k1 - 1) * nFramePerTrial + 1;
        if a.stimulus.temporalOrder(k1) ~= 13
            dm(startPoint, a.stimulus.temporalOrder(k1)) = 1;
            
        elseif cBlank < 4
            dm(startPoint, a.stimulus.temporalOrder(k1)) = 1;
            cBlank = cBlank + 1;
        end
    end
    dsMatrix{k} = dm;
end

%figure (1), clf, imagesc(dsMatrix{1})

%% exclude bad voxels and make median time series per roi

betas = glm2vista(b.results.models{2});
badvoxels1 = find(glm2vista(b.results.R2) <= 2);

models = mean(mean(b.results.models{2}(:, :, :, 1 : 12, :), 4), 5);
badvoxels2 = find(models < 0);

badvoxels = union(badvoxels1, badvoxels2);

roiData  = {};
mroiData = {};

normSum = @(x) x./norm(x);

% viewing the time series (from the first scan) for each roi
for irun = 1 : length(data)
    rsdata{irun} = reshape(data{irun}, [], size(data{1}, 4));
    % normalize each time series to the sum
    for k = 1 : size(rsdata{irun}, 1)
        rsdata{irun}(k, :) = normSum(rsdata{irun}(k, :));
    end
    rsdata{irun}(badvoxels, :) = NaN;
    
    for iroi = 1 : length(rois)
        roiData{iroi}(irun, :,  :) = rsdata{irun}(indices{iroi}, :);
        mroiData{iroi}(:, irun) = nanmedian(roiData{iroi}(irun, :, :), 2);
    end
end

%% bootstrap mroiData

nBoots    = 100;
bsRoiData = [];
nRuns     = 6;

idx = randi(nRuns, [nRuns, nBoots]);


% create index

for iroi = 1 : length(rois)
    for k = 1 : nBoots
        bsRoiData{iroi}(:, :, k) = mroiData{iroi}(:, idx(:, k));
    end
end

%% make HRF

% default parameters
hrfDefault = [5.4 5.2 10.8 7.35 0.35];

lb = [0, 0, 5, 0, 0];
ub = [10, 10, 20, 10, 2];

%% only fit the beta weights using the original hrfs

for k = 1 : nBoots
    for iroi = 1 : length(rois)
        [~, betaRoisFixHrf(iroi, :, k)] = minHRFDiff(glmhrf(:, k)', [], dsMatrix(idx(:, k)), bsRoiData{iroi}(:, :, k), 1);
    end
end

%% visualize

m = mean(betaRoisFixHrf, 3);
order = [13, 1 : 6, 5, 7 : 12];
% 
figure, 
for k = 1 : 9
   subplot(3, 3, k)
   plot(m(k, order), 'o')
end

%% iterative fit

disp('Start iterative fit')

fValSum(1) = 0;
betaRois = [];
hrfPrm   = [];


for k = 1 : nBoots
    for iroi = 1 : length(rois)
        % fminsearch for beta weights using default hrf function
        [fHVal, betaRois(iroi, :, k)] = minHRFDiff(hrfDefault, [], dsMatrix(idx(:, k)), bsRoiData{iroi}(:, :, k), 0);
        [hrfPrm(iroi, :, k), fBVal] = fminsearchbnd(@(x) minHRFDiff(x, squeeze(betaRois(iroi, :, k))',...
            dsMatrix, bsRoiData{iroi}(:, :, k), 0), hrfDefault, lb, ub);
        iter = 1;
        
        % iterative fit
        
        while ((abs(fHVal - fBVal)>0.1) & iter < 10)
            [fHVal, betaRois(iroi, :, k)] = minHRFDiff(hrfPrm(iroi, :, k), [], dsMatrix(idx(:, k)), bsRoiData{iroi}(:, :, k), 0);
            [hrfPrm(iroi, :, k), fBVal] = fminsearchbnd(@(x) minHRFDiff(x, squeeze(betaRois(iroi, :, k))', ...
                dsMatrix, bsRoiData{iroi}(:, :, k), 0), hrfPrm(iroi, :, k), lb, ub);
            
            iter = iter + 1;
        end
        iroi
    end
    k
end

disp('Finished iterative fit')

%% quick visualization

% order = [13, 1 : 6, 5, 7 : 12];
% figure (1), clf
% for iroi = 1 : length(rois)
%     subplot(3, 3, iroi)
%     plot(mean(betaRoisFixHrf(iroi, order, :), 3).*25, 'ro:'), hold on
%     plot(origData(iroi, order), 'bo')
% end
% 
% % compare fitted hrf and the GLM denoise HRF
% for iroi = 1 : length(rois)
%     fittedHrfs(iroi, :) = rmHrfTwogammas(0 : 1.5 : 40, hrfPrm(iroi, :, k));
% end
% 
% figure,
% subplot(1, 2, 1)
% plot(glmhrf, 'k-'), hold on, plot(0 : 1.5 : 40, rmHrfTwogammas(0 : 1.5 : 40, hrfDefault), 'r-')
% subplot(1, 2, 2)
% plot(glmhrf, 'k-', 'linewidth', 3), hold on
% plot(0 : 1.5 : 40, fittedHrfs)

%% visualize

% hrfs = [];
% 
% col   = parula(length(rois));
% order = [13, 1 : 6, 5, 7 : 12];
% 
% figure (2), clf
% for iroi = 1 : length(rois)
%     subplot(3, 3, iroi)
%     plot(betaRois(iroi, order), 'o-')
%     title(rois{iroi})
% end
% 
% figure (3), clf
% for iroi = 1 : length(rois)
%     % make hrfs
%     hrfs(iroi, :) = rmHrfTwogammas(0 : 1.5 : 40, hrfPrm(iroi, :));
%     % subplot(3, 3, iroi)
%     plot(hrfs(iroi, :), '-', 'color', col(iroi, :), 'linewidth', 2) , hold on
% end
% legend(rois)

%% save data
save('hrf_betaWeights.mat', 'betaRois', 'hrfPrm', 'betaRoisFixHrf', 'glmhrf')
 end


