function output = trf_2chansModel(params, stimulus, t)

% INPUTS : 
% params have fields for two beta weights, b1 and b2, and a constant
% epsilon for scaling

%% pre-set options

%% useful functions

makeIRF = @(A, B, C, t)(t/A).^8 .* exp(-t/A) - 1 / B .* (t/C).^9 .* exp(-t/C);
normSum = @(x) x./sum(x);
normMax = @(x) x./max(x);

normMin = @(x) x - mean(x(4000 : end));

%% default parameters

A = 3.29;
B = 14;
C = 3.85;

a = 2.75;
b = 11;
c = 3.18;

%% make impulse response function

% make time step
dt = 0.001;

% make sustained channel impulse response
t1   = t *(1./dt);
firf = normMax(makeIRF(A, B, C, t1));

% make transient channel impulse response
pirf = normMax(makeIRF(a, b, c, t1));

%% compute neuronal and broadband response

for k = 1 : size(stimulus, 1)
    if any(stimulus(k, :))
        fcomp(k, :)  = convCut(firf, stimulus(k, :), length(stimulus));
        pcomp(k, :)  = convCut(pirf, stimulus(k, :), length(stimulus)).^2;
        output(k, :) = (params(1) *fcomp(k, :) + params(2) * pcomp(k, :));
    else
        output(k, :) = zeros(1, length(pirf));
    end
end

%% plot

% figure (100), clf
% plot(sum(output, 2)),drawnow

end