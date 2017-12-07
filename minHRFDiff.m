function [diff, betas] = minHRFDiff(hrfPrms, betas, dsMtrix, data, importHrf)

% inputs: hrf parameters, beta weights, design matrix, data, TR

% hrfPrms: a vector of length 5 if importHrf = 0, a full hrf funciton if
% importHrf = 1;
% betas : a vector of length 13
% dsMatrix: a cell array of length 6 (within each cell: 167 x 13)
% data : size 167 x 6 (6 runs)
% TR : 1.5
% importHrf: 0, use the default hrf function here, if 1, import a vector as
% the hrf function

%% example

% hrfPrms = [6, 16, 1, 1, 6];
% dsMtrix = dsMatrix;
% betas   = ones(13, 1);
% data    = mroiData{1};

%% compute the hrf function

TR = 1.5 : 1.5 : 45;

if importHrf == 0
    hrf = rmHrfTwogammas(TR, hrfPrms);
else
    hrf = hrfPrms;
end

runLength   = size(dsMtrix{1}, 1);
nruns       = size(data, 2);
nConditions = size(dsMtrix{1}, 2);

normMax = @(x) x./max(x);
hrf = normMax(hrf);

%% compute for 6 runs per roi

for irun = 1 : nruns
    
    % convolve the design matrix with the hrf function
    for k = 1 : nConditions
        hrfMatrix{irun}(:, k) = convCut(dsMtrix{irun}(:, k), hrf, runLength);
    end
    
    % hrfMatrix times the beta weights
    %prediction(:, irun) = hrfMatrix{irun} * betas;
end

catMatrix = hrfMatrix{1};
for irun = 2 : nruns
    catMatrix = cat(1, catMatrix, hrfMatrix{irun});
end

% solve for beta weights:
rsdata = reshape(data, [], 1);
%betas = rsdata\catMatrix;
betas = catMatrix\rsdata;

prediction = catMatrix * betas;

%% compute the difference of output

diff = sum((prediction(:) - data(:)).^2);

%% plot

% figure (100), clf
% plot(prediction(:), 'b-'), hold on
% plot(data(:), 'r-'), drawnow


