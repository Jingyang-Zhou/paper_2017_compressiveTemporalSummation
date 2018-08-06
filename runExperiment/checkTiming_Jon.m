
% alternative file to load: '20180716T085603.mat' and '20160203T113847.mat'
fileNm = fullfile('.','testMatFiles','20180716T085603.mat'); % Windows, HU (peter's test)
fileNm = fullfile('.','testMatFiles','20160203T113847.mat'); % Mac, NYU (for paper)
%fileNm = fullfile('.','testMatFiles','20180803T154200.mat'); % windows, NYU


load(fileNm);

%%

figure(1); clf
subplot(2,1,1)
plot(sort(diff(stimulus.seqtiming)), 'b')
hold on
plot(sort(diff(response.flip)), 'r')
legend('seqtiming (input)', 'flip (output)', 'location', 'best'), box off
ylabel('time (s)'), title('Compare time intervals between input and output timing'), set(gca, 'fontsize', 14)

subplot(2,1,2)
scatter(diff(stimulus.seqtiming), diff(response.flip), 'ko', 'linewidth', 2);
axis tight square;
hold on
plot([0 .6], [0 .6], '--', [0 .6], [0 .6]-.010)
xlabel('input timing'), ylabel('output timing'), set(gca, 'fontsize', 14)

%% Look at timing accuracy in different temporal profiles

blank = mode(stimulus.seq);
[C,ia,ic] = unique(stimulus.seq);

onsetIdx = ia(1:end-1);

figure(2)
for ii = 1:length(onsetIdx)
    subplot(6,8,ii)
    
    trialStart = onsetIdx(ii);
    trialEnd   = find(stimulus.seqtiming > stimulus.seqtiming(trialStart)+1, 1);
    theseIndices = trialStart:trialEnd;
    
    t0 = stimulus.seqtiming(theseIndices)-stimulus.seqtiming(theseIndices(1));
    t1 = response.flip(theseIndices)-response.flip(theseIndices(1));
    stims  = double(stimulus.seq(theseIndices)<blank);
    
    t = 0:.001:.8;
    stims0 = interp1(t0,stims,t, 'previous');
    stims1 = interp1(t1,stims,t, 'previous');
    
    
    plot(t,stims0, t, stims1)
    if ii == 1
        titleTxt = sprintf('Trial %d', ii); title(titleTxt),
        legend('input', 'output')
    else
        title(ii)
    end
    box off, set(gca, 'yticklabel', '')
end


%% cummulative error
figure(3); set(gcf, 'Color', 'w'); clf
set(gca, 'FontSize', 20); hold on;
expected = stimulus.seqtiming;
observed = response.flip - response.flip(1);
plot(stimulus.seqtiming, expected - observed, 'o-');
xlabel('Time (s)')
ylabel('Accumulated error (s)');

