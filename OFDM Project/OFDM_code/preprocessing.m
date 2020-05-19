function [txbits, conf] = preprocessing(txdata, conf)
% Randomize data and add random padding to avoid high PAPR

% Randomize txdata in order to reduce peaks in time domain
pseudo_randomized = xor(txdata(:), lfsr_framesync(conf.ndata));

% Insert random padding so that the length of bits are equal to the ofdm
% symbol length
txbits = randi([0, 1], conf.nofdm * conf.nsubc * 2, 1);
txbits(1:conf.ndata) = pseudo_randomized;

end
