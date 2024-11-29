function y = awgn_channel(x, SNR_dB)
    % awgn_channel Προσθέτει θόρυβο AWGN στο σήμα x με δοθέν SNR σε dB
    %   y = awgn_channel(x, SNR_dB) επιστρέφει το σήμα y που είναι το σήμα x
    %   προστιθέμενο με AWGN θόρυβο για το δοθέν SNR σε dB.

    % Μετατροπή του SNR από dB σε γραμμική κλίμακα
    SNR_linear = 10^(SNR_dB / 10);

    % Υπολογισμός της διασποράς του θορύβου
    sigma2 = 1 / SNR_linear;

    % Δημιουργία του μιγαδικού θορύβου w
    noise_real = sqrt(sigma2 / 2) * randn(size(x));
    noise_imag = sqrt(sigma2 / 2) * randn(size(x));
    w = noise_real + 1i * noise_imag;

    % Έξοδος του καναλιού y
    y = x + w;
end
