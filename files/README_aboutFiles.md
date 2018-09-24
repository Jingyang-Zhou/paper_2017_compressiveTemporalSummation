# paper_2017_compressiveTemporalSummation
Code for the paper "Compressive Temporal Summation in Human Visual Cortex", J Neurosci. 2017.

FILE: trf_modelPrms.mat

There are 4 structures contained in this mat file, each correspond to a different experiment or a different set of analysis.

-----------------------------------------------------------------------------------------------------------
fmri1: corresponds to figure 5-6, 10-12. The struct has many fields, each corresponds to a set of parameters for a different model fit to the fMRI data.

lin:  the linear model. lin.param - the scale parameter for the linear model (9 ROIs x 100 bootstraps per ROI). lin.prd - linear model prediction to each set of bootstrapped beta weights. lin.xparam - cross-validated fit of the scale to each bootstrap. lin.xPrd - cross-validated linear model prediction. xr2 - cross valided r^2 for the linear model.

stn: the main model we used in the paper, "stn" stands for static temporal normalization. All the fields are very similar to the linear model, except the following: stn.seed - the seed we use for the stn model fit, there are columns, each corresponds to "tau1, " the time scale of summation, "sigma," the extent of the sub-additive sum, as well as the scale we use the scale the model fit to the same range as the data. stn.seedr2 - this was used to choose the best set of parameters from the grid fit, and to use this best set as the seed for the fine fit in the paper. stn.derivedParam - Summary metrics we used for each model, see Figure 6C.

stn_var1:  the model parameters (simplified from stn) we used for figure 12 (red). 

stn_var2: the model parameters (simplified from stn) we used for figure 12 (blue).

stn_hrfRoi: the model parameters we used for figure 9C (black). 

stn_hrfFix: the model parameters we used for figure 9C (red).

stn_ttc: the two temporal channel model. We used this for figure 10.

etc: stands for exponentiated temporal compression. 

hrf: hrf parameters we used for figure 9A and 9B.

-----------------------------------------------------------------------------------------------------------
fmri1ecc: model parameters we used for figure 7.

fmri1indi: model parameters we used for individual subject, i don't think this made it to any figure in the paper, but it is useful to look at. 

fmri2: model parameters correspond to figure 8.






