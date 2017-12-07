%function [] = loadROIdata(subjID, expNum, dataPth, roiList, roiListNoFace)


% EXAMPLE ---------------------------------------------------

exampleOn     = 1;
exampleOn     = checkExampleOn(exampleOn, mfilename);

if exampleOn
    acc
    projectPth ='/Volumes/server/Projects/Temporal integration/fMRI/data/';
    [subjID, dataPth, roiList, roiListNoFace, voxelR2Thresh, roiType, expNum] = ...
        preAnalysis_subjectVariables(2, 1, projectPth);
    saveData = 0;
elseif ~ismember(exampleOn, [0, 1])
    error(sprintf('Unidentifiable exmapleOn value in file %s', mfilename));
end

voxelR2Thresh = 0.02;

% PRE-DEFINED VARIABLES ----------------------------------------

numberOfConditions = [50, 13];
nCondition         = numberOfConditions(expNum);


denoiseFolder   = sprintf('GLMdenoised%d', nCondition);
roiType         = '2to10'; % other possible roiType : '2to5' or '5to10
roiName         = {};
indices         = [];
roiMeanOrMedian = 'median';


% PATHS AND DIRECTORIES ---------------------------------------

inplaneRoiPth   = fullfile(dataPth, 'Inplane', 'ROIs');


%% load ROI names

% go to Inplane ROI folder:

cd(inplaneRoiPth),
disp(sprintf('\n[loadROIdata] CURRENT DIRECTORY \n              %s', inplaneRoiPth))


for k = 1 : length(roiListNoFace)
    a = dir(sprintf('bilateral%sEcc%s.mat', roiListNoFace{k}, roiType));
    roiName{k} = a(1).name(1 : end - 4) ;
end
if expNum == 1
    assert(exist('bilateralFA.mat') == 2, 'ROI FA does not exist.');
    roiName{length(roiList)} = 'bilateralFA';
elseif ~ismember(expNum, [1, 2])
    error('Unidentifiable variable number expNum. ')
end


display('[loadROIdata] ROIs to be analyzed:')
display(roiName')

% go back to subject directory:

cd(dataPth)
disp(sprintf('\n[loadROIdata] CURRENT DIRECTORY \n              %s', dataPth))


%% load denoised data

% load denoised results:
disp('[loadROIdata] Load denoise folder.')

if ~exist('results', 'var'),
    load(sprintf('%s/denoisedresults.mat', denoiseFolder));
end


%% Re-orient Kendrick's nifti output to match mrVista:

disp('[loadROIdata] Re-orient Kendircks nifti output to match mrVista.')
% load inplane :

vw           = mrVista('inplane');%initHiddenInplane;
dtNum        = viewGet(vw, 'Current Data Type');
inplaneName  = dtGet(dataTYPES(dtNum), 'Inplane Path', 1);
nii          = niftiRead(inplaneName);
xform        = niftiCreateXform(nii,'inplane');
glm2vista    = @(x) reorientForMrVista(x, xform);


coefficients = glm2vista(results.modelmd{2});
sem          = glm2vista(results.modelse{2});
t            = coefficients ./ sem;
R2           = results.R2/100;
R2           = glm2vista(R2);


%% vista ROIs

mrGlobals;

vw           = mrVista('inplane');
vw           = viewSet(vw, 'current data TYPE', 'Original');
vw           = loadMeanMap(vw);
vw           = refreshScreen(vw);


%% load ROIs:

for k1 = 1 : length(roiName)
    vw = loadROI(vw, roiName{k1}, [], 'k', 0, 1);
end


%% load desnoised results:

betas        = glm2vista(results.models{2});
nboot        = size(betas, 5);              % 100 boots
badVoxel     = find(R2 <= voxelR2Thresh);

% exclude voxels that have lower stimulus-present mean activity than that in
% stimulus-absent.
betasSize        = size(betas);
betasReshape     = reshape(betas, [betasSize(1) * betasSize(2) * betasSize(3), betasSize(4), betasSize(5)]);
meanBetasReshape = mean(betasReshape, 3);
excludeIndex     = [];

for k0 = 1 : size(betasReshape, 1)
    if expNum == 1
        temporalVect = 25 : 48;
    elseif expNum == 2
        temporalVect = 1 : 12;
    else
        error('Unidentifiable expNum.')
    end
    if mean(meanBetasReshape(k0, temporalVect)) < 0 %meanBetasReshape(k0, 50)
        excludeIndex = [excludeIndex, k0];
    end
end

%% transform coordinates and get indices for each ROI:

for k2 = 1 : length(viewGet(vw, 'ROIs'))
    
    coords      = viewGet(vw, 'ROI coords', k2);
    rsFactor    = upSampleFactor(vw,1);
    coords(1,:) = round(coords(1,:)/rsFactor(1));
    coords(2,:) = round(coords(2,:)/rsFactor(2));
    indices{k2} = coords2Indices(coords,dataSize(vw,1));
    
end


%% overlay data:

bootsPerVoxel = cell(1, length(indices));
bootsPerROI   = cell(size(bootsPerVoxel));

for whichCond = 1 : nCondition
    
    condData                  = betas(:, :, :, whichCond, :);
    condData                  = reshape(condData, [], 100);
    condData(badVoxel, :)     = NaN;
    condData(excludeIndex, :) = NaN;
    
    % compute bootsPerVoxel and bootsPerROI:
    
    for roi = 1 : length(indices)
        
        bootsPerVoxel{roi}(:, whichCond, :)     = condData(indices{roi}, :);
        
        if strcmp(roiMeanOrMedian, 'median')
            bootsPerRoi{roi}(whichCond, :)      = nanmedian(condData(indices{roi}, :));
        elseif strcmp(roiMeanOrMedian, 'mean')
            bootsPerRoi{roi}(whichCond, :)      = nanmean(condData(indices{roi}, :));
        end
    end
end


%% check eccentricity of the remaining voxels

% project inplane voxels to the gray space and compare to retinotopy
% parameters:



%% normalize data to L2 norm

l2           = @(x) (x./norm(x));
nVoxelPerRoi = zeros(1, length(roiList));

% normalize bootstrap in each voxel:


for k = 1 : length(bootsPerVoxel)
    countNotNan  = 0;
    for k1 = 1 :  size(bootsPerVoxel{k}, 1) % number of voxels
        tmp = bootsPerVoxel{k}(k1, :, :);
        if sum(isnan(tmp(:)))== 0
            countNotNan = countNotNan + 1;
        end
        for k2 = 1 : size(bootsPerVoxel{k}, 3) % number of bootstraps
            bootsPerVoxel{k}(k1, :, k2) = l2(bootsPerVoxel{k}(k1, :, k2));
        end
    end
    nVoxelPerRoi(k) = countNotNan;
end

% normalize bootstrap in averaged ROI :

for k3 = 1 : length(bootsPerRoi)
    for k4 = 1 : size(bootsPerRoi{k3}, 2)
        bootsPerRoi{k3}(:, k4) = l2(bootsPerRoi{k3}(:, k4));
    end
end


%% display number of voxels per remaining ROI:

for kk = 1 : length(roiList)
    figure (603)
    subplot_tight(5, 2, kk, 0.08)
    plot(3, nVoxelPerRoi(kk), '.', 'markerSize', 45), hold on
    text(3 + 0.1,  nVoxelPerRoi(kk), num2str( nVoxelPerRoi(kk)))
    grid on,
    title(roiList{kk}),
end


%% data quality inspection

% plot mean or median ROI beta

medianBootsPerRoi = zeros(nCondition, length(indices));
lower25           = zeros(size(medianBootsPerRoi));
upper75           = zeros(size(medianBootsPerRoi));

for k3 = 1 : length(indices)
    medianBootsPerRoi(:, k3) = median(bootsPerRoi{k3}, 2);
    lower25(:, k3)           = medianBootsPerRoi(:, k3) - quantile(bootsPerRoi{k3}, 0.25, 2);
    upper75(:, k3)           = quantile(bootsPerRoi{k3}, 0.75, 2) - medianBootsPerRoi(:, k3);
end


fg = figure (604); clf


if expNum == 1
    
    displayOrder      = conditionDisplayOrder('long');
    
    for k4 = 1 : length(indices)
        subplot_tight(5, 2, k4, 0.05)
        
        bar(29 : 35,  medianBootsPerRoi(displayOrder(29:35), k4),'faceColor', 0.22 * ones(1, 3)), hold on
        bar(36 : 42,  medianBootsPerRoi(displayOrder(36:42), k4),'faceColor', 0.6 * ones(1, 3)),
        bar(43 : 49,  medianBootsPerRoi(displayOrder(43:49), k4),'faceColor', 0.37 * ones(1, 3)),
        bar(50 : 56,  medianBootsPerRoi(displayOrder(50:56), k4),'faceColor', 0.75 * ones(1, 3)),
        
        errorbar(29:56, medianBootsPerRoi(displayOrder(29:56), k4), lower25(displayOrder(29:56), k4), ...
            upper75(displayOrder(29:56), k4), '.', 'color', 0 * ones(1, 3), 'lineWidth', 2);
        
        title(roiList{k4}), axis tight
        ylim([-0.1, max(medianBootsPerRoi(:))])
        set(gca, 'xTick', [0.5: 7: 56], 'xTickLabel', ...
            {'', 'task.face', '','task.noise', '', 'fix.face', '', 'fix.noise'}),
        grid on
    end
    
elseif expNum == 2
    
    for k4 = 1 : length(indices)
        subplot_tight(5, 2, k4, 0.05)
        
        bar(1:7, medianBootsPerRoi([13, 1:6], k4), 'faceColor', 0.22 * ones(1, 3)), hold on
        bar(8 : 14, medianBootsPerRoi([5, 7:12], k4), 'faceColor',  0.6 * ones(1, 3))
        
        errorbar(1:14, medianBootsPerRoi([13, 1:6, 5, 7:12], k4), lower25([13, 1:6, 5, 7:12], k4), upper75([13, 1:6, 5, 7:12], k4), '.', ...
            'color', 0*ones(1, 3), 'lineWidth', 2)
        
        title(roiList{k4}), axis tight
        set(gca, 'xtick', 0.5:7:14.5, 'xticklabel', '')
        ylim([-0.1, max(medianBootsPerRoi(:))+0.05])
        grid on
    end
    
else
    error('Unidentifiable expNum.')
    
end


set(fg, 'Position', [100, 100, 1600, 1200])

hgexport(fg, 'Images/dataInspection.eps')
if ~exist('Images/figs', 'dir'), mkdir('Images/figs'); end
saveas(fg, 'Images/figs/dataInspection.fig')


%% saving data
%

% disp('[loadROIdata] done.')
% 
% if saveData
%     saveTxt = sprintf('%sRoiData', subjID);
%     save(saveTxt, 'bootsPerRoi', 'bootsPerVoxel', 'medianBootsPerRoi', 'nVoxelPerRoi', 'originalNVoxels', 'restrictedNVoxels')
% else
%     disp('[loadROIdata] Data is not saved.')
% end
