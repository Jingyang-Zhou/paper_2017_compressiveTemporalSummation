t   = 0:0.001:1;

tau = 0.100;

h   = t .* exp(-t/tau);

h   = double(h/sum(h));

 

s1  = double(t<1/60);

s2  = double(t<2/60);

 

r1.linear = conv(s1, h, 'full');

r2.linear = conv(s2, h, 'full');

r1.linear = r1.linear(1:length(t));

r2.linear = r2.linear(1:length(t));

 

cts = @(x,s) x.^2./(s^2+x.^2);

 
figure
set(gcf, 'Color', 'w');

subplot(1,3,1)

plot(t, r1.linear, t, r2.linear)

title('Linear')

ylabel('Predicted Response')

legend('17 ms stimulus', '33 ms stimulus'), box off

 

subplot(1,3,2)

plot(t, cts(r1.linear,1), t, cts(r2.linear,1))

title('CTS Sigma=1')

xlabel('Time (s)')

legend('17 ms stimulus', '33 ms stimulus'), box off

 

subplot(1,3,3)

plot(t, cts(r1.linear,.01), t, cts(r2.linear,.01))

title('CTS Sigma=.01')

legend('17 ms stimulus', '33 ms stimulus'), box off