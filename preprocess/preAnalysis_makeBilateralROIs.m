function [] = preAnalysis_makeBilateralROIs(dataPth, roiList)

% This file requires MATLAB R2015a to display date time properly.

% DESCRIPTION ---------------------------------------------

% This file combines ROIs from left and right hemisphere.

% For face areas, don't capitalize "L" or "R"
% Be careful when importing shared ROI to gray.

% roiList    = importRoiList('withface');
% subject    = 'wl_subj024';

% INPUTS ---------------------------------------------------


% OUTPUTS -------------------------------------------------


% EXAMPLE -----------------------------------------------

exampleOn     = 0;
exampleOn     = checkExampleOn(exampleOn, mfilename);

if exampleOn
    projectPth ='/Volumes/server/Projects/Temporal integration/fMRI/data/';
    
    [subjID, dataPth, roiList, roiListNoFace, voxelR2Threshod, roiType, expNum] = ...
        preAnalysis_subjectVariables(2, 31, projectPth);
    
elseif ~ismember(exampleOn, [0, 1])
    error(sprintf('Unidentifiable exmapleOn value in file %s', mfilename));
end

% HISTORY -------------------------------------------------

% This file is created on 11/16/2015 by JYZ.
% Modified on 01/28/2016.

% TO DO --------------------------------------------------

% make the task more flexible, can choose from combining bilateral ROIs or
% unilateral ROIs etc.


%% PRE-DEFINED VARIABLES

% I compared doing this in inplane and in Gray view, and think the ROI
% combined from the gray view is cleaner (less spots), although i don't
% really know why at the moment.

whichView  = 'Gray';
roiPth     = fullfile(dataPth, whichView, 'ROIs');

cd(roiPth)
disp(sprintf('\n[make BilateralROIs] CURRENT DIRECTORY: \n                      %s', roiPth))


%% delete files with the name string "bilateral" :

disp(sprintf('[make BilateralROIs] DELETE EXISTING BILATERAL ROIs in the %s view.', whichView))

deleteFile     = dir('bilateral*');
deleteFileName = [];

for k = 1 : length(deleteFile)
    deleteFileName = [];
    deleteFileName = deleteFile(k).name;
    delete(deleteFileName)
end


%% delete pre-combiend files: for example, LV2 versus LV2d and LV2v.


disp(sprintf('[make BilateralROIs] DELETE PRE-COMBINED(e.g. LV2d, LV2v vs LV2) ROIs in the %s view.', whichView))

for k1 = 1 : length(roiList) * 2
    if k1 <= length(roiList),
        side  = 'L';
        index = k1;
    elseif k1 <= length(roiList) * 2
        side  = 'R';
        index = k1 - length(roiList);
    else
        error('The counter is greater than the number of combined ROIs on both sides.')
    end
    
    strToFind  = sprintf('%s%s', side, roiList{index});
    fileToFind = dir(sprintf('%s*', strToFind));
    
    % if findFile has more than 2 entries, it usually means there is a redundant ROIs
    % so we need to delete it, but in the future we need to check if this
    % is still true:
    if length(fileToFind) > 2
        if exist(sprintf('%s.mat', strToFind)) == 2
            delete(sprintf('%s.mat', strToFind))
        end
    end
end
disp(sprintf('[make BilateralROIs] CURRENT ROIs in the %s folder :', whichView))
disp(sprintf('\n'))
ls


%% combine bilateral ROIs:

disp(sprintf('[make BilateralROIs] Create new bilateral ROIs in the %s view', whichView))
disp(sprintf('\n'))


for k2 = 1 : length(roiList)
    
    % load all ROIs with the combined string name
    newRoiCoords = [];
    a = dir(sprintf('*%s*', roiList{k2}));
    
    % combine ROI:
    display(sprintf('Now combining %s. ROIs to be combined:', roiList{k2}))
    
    for k3 = 1 : length(a)
        
        if strcmp(roiList{k2}, 'V3') ~= 1
            b            = load(a(k3).name);
            newRoiCoords = [newRoiCoords, b.ROI.coords];
            display(sprintf('%s : %d x %d', a(k3).name, size(b.ROI.coords, 1),  size(b.ROI.coords, 2)))
            
        else
            if isempty(strfind(a(k3).name, 'V3a')) & isempty(strfind(a(k3).name, 'V3b')) & isempty(strfind(a(k3).name, 'V3ab'))
                
                b            = load(a(k3).name);
                newRoiCoords = [newRoiCoords, b.ROI.coords];
                display(sprintf('%s : %d x %d', a(k3).name, size(b.ROI.coords, 1),  size(b.ROI.coords, 2)));
            end
        end
        
    end
    
    display(sprintf('combined ROI size: %d x %d', size(newRoiCoords, 1), size(newRoiCoords, 2)));
    
    % save th new ROI:
    
    ROI          = [];
    ROI.name     = sprintf('bilateral%s', roiList{k2});
    ROI.color    = 'k';
    ROI.comments = '';
    ROI.coords   = newRoiCoords;
    ROI.created  = datetime('now')
    ROI.modified = datetime('now');
    ROI.viewType = whichView;
    
    saveName = ROI.name;
    save(saveName, 'ROI');
end

cd(dataPth)
disp(sprintf('[make BilateralROIs] CURRENT LOCATION : \n                     %s', dataPth))

disp('[make BilateralROIs] Done.')

%%

clear global INPLANE 
clear global VOLUME 
clear global dataTYPES 
clear global mrLoadRetVERSION
clear global mrSESSION



end






