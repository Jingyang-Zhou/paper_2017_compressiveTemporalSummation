% Temporal PRF Pilot plan
%
%
% 12 pulse types (6 durations with same ISI, 6 ISIs with same duration)
% 2 image types (zebra and ??)
% 2 tasks (fixation; 1-back)
%
% if task switches between runs, then we have 24 trial types per run * 4 s
% * 2 repeats per ryn = 48*4 = 192 s per run

function [stim, count_t] = temporalProfiles(dur, isi, plot_not)

% count_t is the total length of a temporal stimulus
% stim contatins all temporal profiles

if ~exist('dur', 'var'), dur = [1 2 4 8 16 32]; end
if ~exist('isi', 'var'), isi = [1 2 4 8 16 32]; end
if ~exist('plot_not', 'var'), plot_not = 1; end

iter      = 0;
trial_len = 5 * 60;
stim      = zeros(trial_len, 12);
count_t   = zeros(1, 12);

for ii = 1:length(dur)
        iter = iter + 1;
        stim(2:dur(ii)+1 ,iter) = 1;
        count_t(ii) = dur(ii);
end

for ii = 1:length(isi)
        iter = iter + 1;
        stim([1+(1:dur(4)) 1+(1:dur(4))+isi(ii)+dur(4)] , iter) = 1;
        count_t(length(dur) + ii) = dur(4)*2+isi(ii) ;
end

size(stim)

if plot_not
figure, 
subplot(1, 2, 1)
plot((1:trial_len)*1000/60, bsxfun(@plus, stim, 1.5*(1:12)), 'k')

set(gca, 'XGrid', 'on')

subplot(1, 2, 2)
imagesc(stim'), colormap gray

set(gcf, 'Name', 'Temporal Profiles Visualization')
end

end

