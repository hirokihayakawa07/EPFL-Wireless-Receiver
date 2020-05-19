clear all;

% Oversampling factor
os_factor    = 4;

% SNR
SNR          = 6;
noAntenna    = 3;
receiverMode = 'MaximumRatioCombining'; % Possible values; singleAntenna / AntennaSelect / MaximumRatioCombining
noframes     = 1;
task         = 2;

if task == 1
    % transmitter
    load task6_1
    data_length = prod(image_size) * 8 / 2; % Number of QPSK data symbols
    noframes    = size(signal,1);
else
    load pn_sequence_fading
    load ber_pn_seq
    ber_pn_seq = repmat(ber_pn_seq,noframes,1);
    signal = repmat(signal,noframes,1);
    data_length = length(ber_pn_seq)/2;    
end

symbolsperframe = data_length/noframes;
rxsymbols = zeros(noframes,symbolsperframe);
    
% Loop through all frames
for k=1:noframes
   
    Frame = signal(k,:);
    
    % Apply Rayleigh Fading Channel
    h = randn(noAntenna,1)+1i*randn(noAntenna,1);
    chanFrame = h * Frame;
    
    % Add White Noise
    SNRlin = 10^(SNR/10);
    noiseFrame = chanFrame + 1/sqrt(2*SNRlin)*(randn(size(chanFrame)) + 1i*randn(size(chanFrame)));

    %
    % Receiver with Single Antenna
    %
    
    for i=1:noAntenna
        % Matched Filter
        filtered_rx_signal(i,:) = matched_filter(noiseFrame(i,:), os_factor, 6); % 6 is a good value for the one-sided RRC length (i.e. the filter has 13 taps in total)

        % Frame synchronization
        [data_idx(i) theta(i) magnitude(i)] = frame_sync(filtered_rx_signal(i,:).', os_factor); % Index of the first data symbol
    end
  
    switch receiverMode
            case 'singleAntenna',
                % Pick correct sampling points of the 1st antenna only
                correct_samples = filtered_rx_signal(1,data_idx(1):os_factor:data_idx(1)+(symbolsperframe*os_factor)-1);
    
                rxsymbols(k,:) = 1/magnitude(1)*exp(-1j*theta(1)) * correct_samples;                
            case 'AntennaSelect',
                [val idx] = max(magnitude);
                
                correct_samples = filtered_rx_signal(idx,data_idx(idx):os_factor:data_idx(idx)+(symbolsperframe*os_factor)-1);
                rxsymbols(k,:) = 1/magnitude(idx)*exp(-1j*theta(idx)) * correct_samples;                  
                
            case 'MaximumRatioCombining',
                h_conj = exp(-1j*theta).*magnitude;
                rxsymbols(k,:)  = h_conj/norm(h_conj)^2 * filtered_rx_signal(:,data_idx(1):os_factor:data_idx(1)+(symbolsperframe*os_factor)-1);
                
    end   
    

    
end

combined_rxsymbols = reshape(rxsymbols.',1,noframes*symbolsperframe);

rxbitstream = demapper(combined_rxsymbols); % Demap Symbols
if task == 1
    image_decoder(rxbitstream,image_size) % Decode Image
else
    BER = sum(rxbitstream ~= ber_pn_seq)/length(ber_pn_seq)
end