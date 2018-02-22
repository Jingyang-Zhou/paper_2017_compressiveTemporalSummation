
Code for the paper "Compressive Temporal Summation in Human Visual Cortex", J Neurosci. 2017.

Note: Both the code and documentation are still under construction.

HOW TO USE IT? Download "trf_fmriData.mat" and "trf_modelPrms.mat" from our OSF page (https://osf.io/v843t) into the "files" folder. Run code in folder "mkFigures" to make figures form the published paper. Run "trf_tutorial.mlx" to see example model predictions.

In the code, the naming convention is a little different from the paper, mainly, “STN” stands for “static temporal normalization,” which refers to the main implementation of the CTS (compressive temporal summation) model. “STN_var1” and “STN_var2” stand for the two additional variation of the STN model (by relaxing more parameters, see figure 12). “ETC” stands for “exponentiated temporal compression,” and it refers to the second implementation of the CTS model (see figure 11).

Additionally, “lin” is for the linear model, and “ttc” for the 2-temporal channels model. 

An example model parameters structure in “trf_modelPrms.mat” may contain the following fields:

seed: parameter seed used for fitting (trf_gridFit.m) the model, computed using a grid search (trf_fineFit.m).

seedr2: corresponding r^2 for the seeding parameter set. 

param: model parameter computed using fine fit (trf_fineFit.m). (900 (9 ROIs x 100 bootstraps per ROI) x 3 model parameters)

prd: model predictions for all bootstrapped data (900 (9 ROIs x 100 bootstraps per ROI) x 13 temporal conditions) using param. 

xparam : parameters estimated from the cross-validation fit

xPrd : cross-validation prediction.

xr2 : corss-validated r^2.

derivedParam: summary metrics. derivedParam.r_double: r_double computed for each bootstrap. derivedParam.t_isi: t_isi computed for each bootstrap.


For the data file trf_fmriData.mat:

The data contained, for example, for the main (the first) fMRI experiment is denoted as firm.data. It has four dimensions: number of subjects x 9 ROIs x 100 bootstraps per ROI x 13 temporal conditions.




