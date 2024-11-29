function snr_analysis
    % Initial parameters
    M = 64; % Number of symbols in 64-QAM
    total_samples = 100000; % Total samples
    block_size = 20; % Block size
    block_count = total_samples / block_size;
    crc_poly = '1100001100100110011111011'; % CRC-24 polynomial
    n = 12; % Total number of bits in the encoded message (for (12, 8) Hamming)
    k = 8; % Number of information bits in the original message
    SNR_Eve_threshold = 0.98; % PER threshold for Eve
    SNR_values = 35:-1:15; % SNR values from 35dB to 15dB (decreasing)

    % Define the MIMO channel matrix H_m
    H_m = [1.6330, 0.4082 - 0.7071i, 0.4082 + 0.7071i;
           1.1547, -0.5774 + 1i, -0.5774 - 1i;
           0, 0.7071 - 1.2247i, -0.7071 - 1.2247i];

    % Calculate beamforming weights (example using eigenvector)
    [V, ~] = eig(H_m' * H_m);
    w = V(:, 1); % Beamforming weight vector

    % Create random data for QAM modulation (each column is for a transmit antenna)
    qam_modulated = randi([0 M-1], total_samples, 3); % 3 transmit antennas
    qam_modulated_signal = qammod(qam_modulated, M); % 64-QAM modulation

    for SNR_Bob_dB = SNR_values
        SNR_Eve_dB = SNR_Bob_dB - 4; % SNR for Eve is 4 dB lower

        % Pass the signal through the MIMO channel with beamforming for Bob and Eve
        qam_received_bob = mimo_channel(qam_modulated_signal, H_m, w);
        qam_received_eve = mimo_channel(qam_modulated_signal, H_m, w);

        % Add AWGN noise
        qam_received_bob = awgn(qam_received_bob, SNR_Bob_dB, 'measured');
        qam_received_eve = awgn(qam_received_eve, SNR_Eve_dB, 'measured');

        % QAM demodulation using the custom function
        qam_demodulated_bob = custom_qamdemod(qam_received_bob(:), M);
        qam_demodulated_eve = custom_qamdemod(qam_received_eve(:), M);

        % Convert the demodulated data to bits
        bits_per_symbol = log2(M); % Number of bits per symbol
        qam_bits_bob = de2bi(qam_demodulated_bob, bits_per_symbol, 'left-msb');
        qam_bits_eve = de2bi(qam_demodulated_eve, bits_per_symbol, 'left-msb');

        % Convert the bit arrays to one-dimensional arrays
        qam_bits_bob = reshape(qam_bits_bob.', 1, []);
        qam_bits_eve = reshape(qam_bits_eve.', 1, []);

        blocks_bob = cell(1, block_count);
        blocks_eve = cell(1, block_count);

        for i = 1:block_count
            block_start = (i-1) * block_size * bits_per_symbol + 1;
            block_end = i * block_size * bits_per_symbol;

            if block_end <= length(qam_bits_bob)
                blocks_bob{i} = qam_bits_bob(block_start:block_end);
            end

            if block_end <= length(qam_bits_eve)
                blocks_eve{i} = qam_bits_eve(block_start:block_end);
            end
        end

        % Hamming Decoding
        decoded_blocks_bob = cell(1, block_count);
        decoded_blocks_eve = cell(1, block_count);

        for i = 1:block_count
            decoded_blocks_bob{i} = '';
            decoded_blocks_eve{i} = '';

            if ~isempty(blocks_bob{i})
                for j = 1:n:length(blocks_bob{i})
                    if j+n-1 <= length(blocks_bob{i})
                        hamming_code_bob = blocks_bob{i}(j:j+n-1);
                        
                        % Check the length of the received data
                        if length(hamming_code_bob) == n
                            decoded_data_bob = hamming_decode(hamming_code_bob, n, k);
                            decoded_blocks_bob{i} = [decoded_blocks_bob{i}, decoded_data_bob];
                        else
                            error('Length of received data does not match the expected length of the Hamming code.');
                        end
                    end
                end
            end

            if ~isempty(blocks_eve{i})
                for j = 1:n:length(blocks_eve{i})
                    if j+n-1 <= length(blocks_eve{i})
                        hamming_code_eve = blocks_eve{i}(j:j+n-1);
                        
                        % Check the length of the received data
                        if length(hamming_code_eve) == n
                            decoded_data_eve = hamming_decode(hamming_code_eve, n, k);
                            decoded_blocks_eve{i} = [decoded_blocks_eve{i}, decoded_data_eve];
                        else
                            error('Length of received data does not match the expected length of the Hamming code.');
                        end
                    end
                end
            end
        end

        % Error correction and removing redundant bits
        corrected_blocks_bob = cell(1, block_count);
        corrected_blocks_eve = cell(1, block_count);

        for i = 1:block_count
            if ~isempty(decoded_blocks_bob{i})
                corrected_data_bob = decoded_blocks_bob{i}; % Assuming correction in hamming_decode
                corrected_blocks_bob{i} = corrected_data_bob(1:end-8); % Removing last 8 bits
            end

            if ~isempty(decoded_blocks_eve{i})
                corrected_data_eve = decoded_blocks_eve{i};
                corrected_blocks_eve{i} = corrected_data_eve(1:end-8);
            end
        end

        % Calculate and compare CRC
        PER_Bob = 0;
        PER_Eve = 0;

        for i = 1:block_count
            if ~isempty(corrected_blocks_bob{i})
                if length(corrected_blocks_bob{i}) >= 40*6 % Ensure there are enough bits
                    block_data_bob = corrected_blocks_bob{i}(1:40*6); % 40 messages, each 6 bits
                    computed_crc_bob = computeCRC24(block_data_bob, crc_poly);
                    received_crc_bob = corrected_blocks_bob{i}(40*6+1:end);

                    if ~strcmp(computed_crc_bob, received_crc_bob)
                        PER_Bob = PER_Bob + 1;
                    end
                else
                    PER_Bob = PER_Bob + 1;
                end
            end

            if ~isempty(corrected_blocks_eve{i})
                if length(corrected_blocks_eve{i}) >= 40*6 % Ensure there are enough bits
                    block_data_eve = corrected_blocks_eve{i}(1:40*6);
                    computed_crc_eve = computeCRC24(block_data_eve, crc_poly);
                    received_crc_eve = corrected_blocks_eve{i}(40*6+1:end);

                    if ~strcmp(computed_crc_eve, received_crc_eve)
                        PER_Eve = PER_Eve + 1;
                    end
                else
                    PER_Eve = PER_Eve + 1;
                end
            end
        end

        PER_Bob = PER_Bob / block_count;
        PER_Eve = PER_Eve / block_count;

        % Check if PER for Eve exceeds 98%
        if PER_Eve > SNR_Eve_threshold
            fprintf('SNR for Bob: %d dB\n', SNR_Bob_dB);
            fprintf('SNR for Eve: %d dB\n', SNR_Eve_dB);
            fprintf('PER for Bob: %.4f\n', PER_Bob);
            fprintf('PER for Eve: %.4f\n', PER_Eve);
            break;
        end
    end
end
