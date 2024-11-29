function decoded = hamming_decode(received, n, k)
    % received: 1xN binary vector representing the received Hamming code
    % n: length of the codeword (including parity bits)
    % k: length of the original data (without parity bits)

    % Create the parity-check matrix H
    H = create_parity_check_matrix(n, k);

    % Ensure the length of received matches the expected length
    if length(received) ~= n
        error('The length of received does not match the expected length of the Hamming code.');
    end

    % Syndrome calculation
    syndrome = mod(received * H', 2);

    % Error detection and correction
    if any(syndrome) % If syndrome is not all zeros
        % Find the error position
        error_position = bi2de(syndrome, 'left-msb');
        % Correct the error
        if error_position > 0 && error_position <= length(received)
            received(error_position) = mod(received(error_position) + 1, 2);
        end
    end

    % Extract the original data
    decoded = received(1:k);
end

function H = create_parity_check_matrix(n, k)
    % Create a parity-check matrix for a (n, k) Hamming code
    m = n - k;
    H = zeros(m, n);
    
    % Populate H with identity matrix and parity matrix
    for i = 1:m
        binary_vector = de2bi(2^(i-1), m, 'left-msb');
        H(i, 1:m) = binary_vector;
        H(i, m+i) = 1;
    end
    H = mod(H, 2);
end
