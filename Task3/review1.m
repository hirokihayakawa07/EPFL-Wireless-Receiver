clear all

load task3
SNR                 = 10;
rx_filterlen        = 20;
os_factor           = 4;
alpha = 0.22;
data_length = prod(image_size) * 8 / 2;

SNRlin = 10^(SNR/10);
rx_signal = signal + sqrt(1/(2*SNRlin)) * (randn(size(signal)) + 1i*randn(size(signal)));
g_rrc = rrc(os_factor, alpha, rx_filterlen);


z_len = length(rx_signal) - 2*rx_filterlen;
z = zeros(1, z_len);
for i=1:length(z)
    z(i) = rx_signal(i:i+2*rx_filterlen).' * g_rrc;
end

% find start of data frame
beginning_of_data = frame_sync(z.', os_factor); % Index of the first data symbol

% decode image
d = demapper(z(beginning_of_data : os_factor : beginning_of_data + os_factor * (data_length - 1)));
image_decoder(d, image_size);