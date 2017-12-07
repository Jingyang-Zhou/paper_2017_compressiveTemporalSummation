function [originalNVoxels, restrictedNVoxels] = preAnalysis_extractRangedROI(subjID,  dataPth, roiList, roiListNoFace, expNum)


% DESCRIPTION ----------------------------------------------

% This file intends to extract ROIs of eccentricity from 2 to 10 degree in
% the Gray view and export it to the inplane view.


% ATTENTION ------------------------------------------------

% (1) Before running this file, all bilateral Gray ROIs defined from the file
%     makeBilateralROI need to be imported to the inplane folder.

% (2) This file might erase all the ROI folders in the Inplane view.

% (3) All ROIs in Gray and Inplane view are force-saved for now, be extra
%     careful. Also all the bilateral eccentricity ROIs would be deleted at
%     the beginning of the analysis.

% (4) Highly recommand runing individual Ecc first and inpect the ROIs on
%     Mesh before re-running the file for combined analyses. (Controlled by
%     "individualEccROIOn").


% EXAMPLE ON ----------------------------------------------------

exampleOn     = 0;
exampleOn     = checkExampleOn(exampleOn, mfilename);

if exampleOn
    projectPth ='/Volumes/server/Projects/Temporal integration/fMRI/data/';
    [subjID, dataPth, roiList, roiListNoFace, voxelR2Threshod, roiType, expNum] = ...
        preAnalysis_subjectVariables(2, 31, projectPth);
    
elseif ~ismember(exampleOn, [0, 1])
    error(sprintf('Unidentifiable exmapleOn value in file %s', mfilename));
end


% PRE-DEFINED VARIABLES ------------------------------------

eraseInplaneROIs   = 1;
lowEcc             = 2;               % degree of visual angle
midEcc             = 5;
highEcc            = 10;
individualEccROIOn = 0;
aperSize           = 12; % degree


% PATH AND DIRECTORIES -------------------------------------

retPth             = loadRetPth(subjID);
grayRoiPth         = fullfile(dataPth, 'Gray', 'ROIs');
inplaneRoiPth      = fullfile(dataPth, 'Inplane', 'ROIs');

if ~(exist(inplaneRoiPth) == 7)
    mkdir(inplaneRoiPth)
end

% HISTORY -------------------------------------------------

% This file is created on 11/16/2015 by JYZ.


% TO DO -----------------------------------------------------

% (1) Currently there is a possibility that the retinotopy fit used to define
%     ROI is not the same as the fit to define eccentricity ROI. Might want to
%     change this later.

% (2) The number of voxels are saved in the lodROIdata.m currently


%% delete previously computed eccentricity ROIs form the GREY view 

% Delete Gray ROIs
cd(grayRoiPth)

disp('[extractRangedROI] DELETING GRAY bilateral eccentricity ROIs.')
delete('bilateral*Ecc*.mat')

cd(dataPth)
disp(sprintf('[extractRangedROI] CURRENT LOCATION :\n                  %s', dataPth))
disp(sprintf('\n'));


%% restrict gray ROIs to certain eccentricities:

gray        = mrVista ('3');
gray        = viewSet(gray, 'current dt', 'Averages');

% All subjects but wl_subj031 are using the fFit instead of gFit:
if strcmp(subjID, 'wl_subj031')
    outFileName = 'prf_model_imported_gFit.mat';
else
    outFileName = 'prf_model_imported_fFit.mat';
end

gray        = importRetModelFit(gray, retPth, outFileName);
gray        = rmSelect(gray, true, outFileName);
model       = viewGet(gray, 'rm model');
gray        = viewSet(gray, 'hide gray ROIs', true);

scale       = aperSize/max(model{1}.sigma.major);

figure (601), clf
figure (602), clf

for k = 1 : length(roiListNoFace)
    
    currentROI     = sprintf('bilateral%s', roiListNoFace{k});
    currentROIFile = sprintf('%s.mat', currentROI);
    
    gray           = loadROI(gray, currentROIFile, 1, [], 0, 1);
    coords         = viewGet(gray, 'ROI coords');
    allCoords      = viewGet(gray, 'coords');
    coords         = intersectCols(allCoords, coords);
    
    eccentricity   = rmCoordsGet('gray', model{1}, 'ecc',coords);
    eccentricity   = eccentricity.*scale;
    
    polarAngle     = rmCoordsGet('gray', model{1}, 'polarangle',coords);
    
    % extract eccentricity ROIs:
    
    first          = lowEcc - 1 : highEcc - 1;
    last           = lowEcc : highEcc;
    colors         = flip(jet(length(first)), 1);
    
    if individualEccROIOn
        for k1 = 1 : length(first)
            keepInds    = eccentricity > first(k1) & eccentricity < last(k1);
            gray        = newROI(gray, sprintf('bilateral%sEcc%dto%d', roiListNoFace{k}, first(k1), last(k1)), ...
                1, colors(k1, :), coords(:, keepInds), sprintf('%s restricted to ecc. %d-%d', roiListNoFace{k}, first(k1), last(k1)));
        end
    end
    
    % roi from 2 to 10 degree:
    
    keepInds2to10  = eccentricity > lowEcc & eccentricity < highEcc;
    gray           = newROI(gray, sprintf('bilateral%sEcc2to10', roiListNoFace{k}), ...
        1, 'k', coords(:, keepInds2to10), sprintf('%s restricted to ecc. 2 to 10 degree', roiListNoFace{k}));
    
    
    % check distirbution of voxel eccentricity
    fg601 = figure (601);
    subplot_tight(5, 2, k, 0.05)
    hist(eccentricity, 0.5:20); hold on
    
    
    hist(eccentricity(keepInds2to10), 0.5:20),
    h = findobj(gca,'Type','patch');
    set(h(1), 'faceColor', 'b', 'facealpha', 0.5);
    set(h(2), 'faceColor', 'r', 'facealpha', 0.5);
    
    title(roiList{k}), axis tight,
    grid on
    
    set(fg601, 'Name', 'num.Voxels across eccentricities in each ROI')
    xlabel('eccentricity (dg.)')
    drawnow, axis tight
    set(fg601, 'Position', [100, 100, 1500, 1000])
    
    % distribution of polar angles, should expect each angle contains about
    % the same number of voxels
    fg602 = figure (602);
    subplot_tight(5, 2, k, 0.1)
    hist(polarAngle); hold on
    h = findobj(gca,'Type','patch');
    
    set(h, 'faceColor', 'b', 'facealpha', 0.5);
    title(roiList{k}), axis tight,
    grid on
    set(fg601, 'Name', 'num.Voxels across angles in each ROI')
    
    
    % roi from 2 to 5 degree:
    
    keepInds2to5   = eccentricity > lowEcc & eccentricity < midEcc;
    gray           = newROI(gray, sprintf('bilateral%sEcc2to5', roiListNoFace{k}), ...
        1, 'b', coords(:, keepInds2to5), sprintf('%s restricted to ecc. 2 to 5 degree', roiListNoFace{k}));
    
    % roi from 5 to 10 degree:
    
    keepInds5to10  = eccentricity > midEcc & eccentricity < highEcc;
    gray           = newROI(gray, sprintf('bilateral%sEcc5to10', roiListNoFace{k}), ...
        1, 'r', coords(:, keepInds5to10), sprintf('%s restricted to ecc. 5 to 10 degree', roiListNoFace{k}));
    
end

if expNum == 1
    faceROI     = sprintf('bilateral%s', roiList{end});
    faceROIFile = sprintf('%s.mat', faceROI);
    gray        = loadROI(gray, faceROIFile, 1, [], 0, 1);
elseif ~ismember(expNum, [1, 2])
end

% save all ROIs in the Gray view:

saveAllROIs(gray, 1, 1);


%% clear up all the inplane ROIs

cd('./Inplane/ROIs')

disp(sprintf('[extractRangedROI] DELETING (or not) INPLANE ROIs at \n                   %s', inplaneRoiPth))

if eraseInplaneROIs
    assert(strcmp(pwd, inplaneRoiPth ), 'Inplane Path not correct, please check.')
    delete('*.mat')
    assert(isempty(ls), 'Inplane ROIs are not completely deleted, please check')
elseif eraseInplaneROIs == 0
    warning('There may be some existing non-bilateral inplane ROIs.')
else
    error('Unidentifiable variable eraseInplaneROIs in extractRangedROI.m')
end

cd(dataPth)

disp(sprintf('[extractRangedROI] CURRENT DIRECTORY: \n                   %s', dataPth))

%% Import 2-10 degree, transform lower and higher eccentricity ROIs from gray view to Inplane view:

% import all volume ROI then delete the ones that we don't use:

disp('[extractRangedROI] IMPORTING GRAY ROIs to INPLANE ROIs')

%volume  = checkSelectedVolume;
inplane = mrVista;
inplane = vol2ipAllROIs(gray, inplane);
saveAllROIs(inplane, 1, 1);


%% Plot number of voxels in each type of ROIs

% change to inplane folder
cd('./Inplane/ROIs')

disp(sprintf('[extractRangedROI] CURRENT DIRECTORY: \n                   %s', inplaneRoiPth))
disp('[extractRangedROI] Compare number of voxels before and after restricting ROI eccentricities.' )

% figure (603), clf
% 
% fg = figure (603);

numVox  = [];
numVox1 = [];

if expNum == 1
    whichList = roiList;
elseif expNum == 2
    whichList = roiListNoFace;
end

for whichROI = 1 : length(whichList)
    
    roiStr    = sprintf('*%s.*', roiList{whichROI});
    roi       = dir(roiStr);
    a         = load(roi.name);
    numVox    = size(a.ROI.coords, 2);
    
    if whichROI < length(roiList)
        roiStr1   = sprintf('*%sEcc2to10*', roiList{whichROI});
        roi1      = dir(roiStr1);
        a1        = load(roi1.name);
        numVox1   = size(a1.ROI.coords, 2);
    end
    
%     figure (603)
%     subplot_tight(5, 2, whichROI, 0.05)
%     plot(1, numVox, '.', 'markerSize', 45), hold on,
%     text(1+0.1, numVox, num2str(numVox))
%     
%     if whichROI < length(roiList)
%         plot(2, numVox1, '.', 'markerSize', 45), hold on
%         text(2+0.1, numVox1, num2str(numVox1))
%     end
%     
%     set(gca, 'xTick', [1 : 3], 'xTickLabel', {'n(bilateral ROI)', 'n(2-10 degree data)', 'n(thresholded ROI)'});
%     title(roiList{whichROI}), %grid on
%     xlim([0.5, 3.5])
%     set(fg, 'Name', 'number of voxels in each type of ROI');
%     set(fg, 'Position', [100, 100, 1500, 1000]);
%     ylim([0, numVox])
%     drawnow
    
    originalNVoxels(whichROI) = numVox;
    restrictedNVoxels(whichROI) = numVox1;
    
end


%%

cd(dataPth)
disp(sprintf('[extractRangedROI] CURRENT DIRECTORY: \n                   %s', dataPth))


%%

clear global INPLANE 
clear global VOLUME 
clear global dataTYPES 
clear global mrLoadRetVERSION
clear global mrSESSION


end

