% test_stimulus_timing

% load one mat file that was saved after 1 run:

data = load('~/Desktop//20180707T190821.mat');

% compare inputting stimulus timing and executed stimulus timing

a = data.stimulus;
b = data.response;

%%
output_flip = b.flip-data.time0;
output_nextfliptime = b.nextFlipTime-data.time0;
input_flip = a.seqtiming;

figure (1)
subplot(1, 4, 1)
plot(input_flip, 'b-'), hold on,
plot(output_nextfliptime, 'r-'), axis tight
xlim([0, 100]), ylim([0,30]), legend('seqtiming(input)', 'nextFlipTime (output)'), 
ylabel('time(sec)'), xlabel('nth sample')

subplot(1, 4, 2)
plot(output_nextfliptime-input_flip), hold on, axis tight
title('Difference between seqtiming and nextFlipTime','FontSize', 14), 
ylabel('time (sec)'), xlabel('nth sample')

subplot(1, 4, [3,4])
stem(diff(input_flip), 'b-', 'LineWidth', 3),  hold on
stem(diff(output_nextfliptime),'r-'),
axis tight, xlim([0,40]), title('Sample by sample difference','FontSize', 14)
ylabel('time(sec)'), xlabel('nth sample')

set(gcf, 'Name', 'Compare seqtiming and nextFlipTime')

figure (2)
subplot(1, 4, 1)
plot(input_flip, 'b-'), hold on,
plot(output_flip, 'r-'), axis tight
xlim([0, 100]), ylim([0,30]), legend('seqtiming(input)', 'flip (output)'), 
ylabel('time(sec)'), xlabel('nth sample')

subplot(1, 4, 2)
plot(output_flip-input_flip, 'b-'), hold on, 
plot(output_flip - output_nextfliptime,'k-')
plot(output_nextfliptime - input_flip,'r-')
title('Difference between seqtiming and flip','FontSize', 14), axis tight
ylabel('time (sec)'), xlabel('nth sample'),
legend('difference: flip and seqtiming', 'difference: flip and nextFlipTime', 'difference: nextFlipTime and seqtiming')


subplot(1, 4, [3,4])
stem(diff(input_flip), 'b-','LineWidth', 3),  hold on
stem(diff(output_flip),'r-'),
axis tight, xlim([0,40]), title('Sample by sample difference','FontSize', 14)
ylabel('time (sec)'), xlabel('nth sample')

set(gcf, 'Name', 'Compare seqtiming and flip')