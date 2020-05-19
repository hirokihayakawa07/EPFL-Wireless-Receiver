function [tx, parallel_symbols] = tx_flow(txbits, conf)
% bitstream to OFDM symbols in time domain

% modulate onto QPSK constellation
symbols = 1/ (sqrt(2)) * ((2 * txbits(1:2:end) - 1) + 1j * (2 * txbits(2:2:end) - 1));

% reshape symbols and insert train symbols at every train_interval symbols
parallel_symbols = reshape(symbols, conf.nsubc * conf.train_interval, []);
training_symbol = -2 * lfsr_framesync(conf.nsubc) + 1;
trained = vertcat(repmat(training_symbol, 1, size(parallel_symbols, 2)), parallel_symbols);
% parallelize
parallel_symbols = reshape(trained, conf.nsubc, []);

% perform IFFT and upsampling
symbol_intime = zeros(conf.nsubc * conf.os_factor, size(parallel_symbols, 2));
for i = 1:size(parallel_symbols, 2)
    symbol_intime(:, i) = osifft(parallel_symbols(:, i), conf.os_factor);
end

% add cyclic prefix
symbol_intime_CP = vertcat(symbol_intime(end-conf.lpfx * conf.os_factor + 1:end, :), symbol_intime);

% serialize ofdm symbols in time
serialized_ofdm = symbol_intime_CP(:);

% generate preamble and perform BPSK modulation
preamble = -2 .* (lfsr_framesync(conf.npreamble) - 0.5);
% adjust the scale of preamble so that its max power is same as the max of
% ofdm symbols
preamble = preamble ./ max(preamble) .* max(abs(serialized_ofdm));

% upsampling of Preamble
upsampled_ofdm = zeros(conf.npreamble*conf.os_factor, 1);
upsampled_ofdm(1:conf.os_factor:end) = preamble;

% pulse shaping of premble with root raised cosign filter
pulse = rrc(conf.os_factor, conf.rolloff, conf.filter_len);
filtered_preamble = conv(upsampled_ofdm, pulse, 'same');

% insert preamble at the begging of the ofdm symbols in time domain
symbols_intime = [filtered_preamble; serialized_ofdm];

% upconversion
time = (0:length(symbols_intime) - 1); 
time = time ./ conf.fsampling;
tx = real(symbols_intime.*exp(1j*2*pi*conf.f_c*time.'));

end
