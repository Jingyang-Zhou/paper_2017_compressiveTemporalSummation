function trf_fmri_downloadData()
% Download and unzip the data from the Open Science Framework project page
% associated with this paper:
%
% Compressive Temporal Summation in Human Visual Cortex
% Jingyang Zhou, Noah C. Benson, Kendrick Kay, Jonathan Winawer
% Journal of Neuroscience 30 November 2017, 1724-17; DOI: 10.1523/JNEUROSCI.1724-17.2017
%
% Alternatively, the data can be downloaded manually from this site:
% https://osf.io/v843t/
%
% The code downloads a single zip file, places it in the root
% directory of the project, and unzips it into the folder named 'data'


url1  = 'https://osf.io/fgjp9/?action=download&version=1';
url2  = 'https://osf.io/wn2q9/?action=download&version=1';
url3  = 'https://osf.io/2ca3j/?action=download&version=1'; 

pth1 = fullfile(temporalfMRIRootPath, 'files' , 'trf_modelPrms.mat');
pth2 = fullfile(temporalfMRIRootPath, 'files' , 'trf_fmriData.mat');
pth3 = fullfile(temporalfMRIRootPath, 'files' , 'temporalExpImages.mat');

fname1 = websave(pth1, url1);
fname2 = websave(pth2, url2);
fname3 = websave(pth3, url3);

end