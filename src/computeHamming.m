function hamming_code = computeHamming(data)
    % data: binary string (1xN char array) representing the data bits
    % hamming_code: binary string (1xN+bit char array) representing the Hamming code bits

    % Convert binary strings to numerical arrays for Hamming code
    data = data - '0';
    
    % Determine the number of parity bits needed
    m = length(data);
    r = 1;
    while 2^r - 1 - r < m
        r = r + 1;
    end

    % Initialize Hamming code with parity bits
    hamming_code = zeros(1, m + r);
    j = 1;
    for i = 1:length(hamming_code)
        if ispowerof2(i)
            hamming_code(i) = 0; % Initialize parity bits to 0
        else
            hamming_code(i) = data(j);
            j = j + 1;
        end
    end

    % Calculate parity bits
    for i = 1:r
        parity_index = 2^(i-1);
        parity_value = 0;
        for j = parity_index:length(hamming_code)
            if bitget(j, i) == 1
                parity_value = xor(parity_value, hamming_code(j));
            end
        end
        hamming_code(parity_index) = parity_value;
    end
    
    hamming_code = char(hamming_code + '0');
end

function result = ispowerof2(n)
    result = n > 0 && bitand(n, n-1) == 0;
end
