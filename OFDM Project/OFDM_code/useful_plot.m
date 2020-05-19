function useful_plot(channel_training, channel_others, theta_hat, conf)
%% normalize channel estimations
channel_training = channel_training ./ repmat(max(abs(channel_training(:))), size(channel_training, 1), size(channel_training, 2));
channel_others = channel_others ./ repmat(max(abs(channel_others(:))), size(channel_others, 1), size(channel_others, 2));


%% (task3) plot the performance of the phase tracking function 
tracked_subcarrier = conf.nsubc; % plot an high frequency
num_symbols = (1:size(channel_others, 2));
fig1 = figure;
hold on;
plot(num_symbols, mod(angle(channel_others(tracked_subcarrier, :)), 2*pi)/pi);
plot(num_symbols(1:conf.train_interval+1:end), mod(angle(channel_training(tracked_subcarrier, :)), 2*pi)/pi, 'o');
plot(num_symbols, theta_hat(tracked_subcarrier, :)/pi, '.-');
title('Phase Estimation Performances')
xlabel('OFDM Symbol');
legend('Real', 'Estimated', 'Tracked');
saveas(fig1, 'Phase estimation.png');


%% (task2) channel spectrum over frequency
frequency = conf.f_c - (conf.nsubc - 1) / 2 * conf.fspacing:conf.fspacing:conf.f_c + (conf.nsubc - 1) / 2 * conf.fspacing;
fig2 = figure;

subplot(2, 1, 1);
plot(frequency, abs(channel_training));
title('Channel Magnitude');
xlabel('Frequency [Hz]');

subplot(2, 1, 2);
plot(frequency, unwrap(angle(channel_training)));
title('Channel Phase');
xlabel('Frequency [Hz]')
saveas(fig2, 'Spectrum of channel.png');


%% (task2) channel spectrum for some subcarriers (1:400:end) over time
num_symbols = (1:size(channel_others, 2));
time = (num_symbols - 1) .* (conf.nofdm ./ (conf.fsampling / conf.os_factor)) * 1000;
fig4 = figure;

subplot(2, 1, 1);
magnitude = abs(channel_others(1:400:end, :))./repmat(max(abs(channel_others(1:400:end, :))), numel(1:400:size(channel_others, 1)), 1); 
plot(time, magnitude);
title('Magnitude of Real Channel on Single Subcarriers');
xlabel('Time [ms]');

subplot(2, 1, 2);
ang = unwrap(angle(channel_others(1:400:end, :)));
plot(time, ang);
title('Phase of Real Channel on Single Subcarriers')
xlabel('Time (ms)');
saveas(fig4, 'Spectrum of real channel.png');


%% (task2) delay spread to determine CP length
fig3 = figure;
time = (0:conf.nsubc - 1) ./ (conf.fsampling / conf.os_factor) * 1000;
hold on;
for i = 1:size(channel_training, 2)
    y = abs(ifft(channel_training(:, i), 'symmetric'));
%     plot(time(1:end-500), y(1:end-500)./max(y(:)), '.-');
    plot(time(1:end), y(1:end)./max(y(:)), '.-');
end
title('Delay Spread');
xlabel('Time (ms)')
saveas(fig3, 'Delay spread.png');

end
