% trf_fitSCTSModel

function diff = trf_fitSCTSModel(params, data, stim, t)
   
% compute model prediction
model = trf_sCTSmodel(params, stim, t);
diff  = sum((model - data).^2);
end