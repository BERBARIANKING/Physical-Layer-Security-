function demodulated = custom_qamdemod(y, M)
    % Δημιουργία του αστερισμού για το 64-QAM
    constellation = qammod(0:M-1, M);
    
    % Αρχικοποίηση του πίνακα αποδιαμορφωμένων συμβόλων
    demodulated = zeros(size(y));
    
    % Υπολογισμός των ευκλείδειων αποστάσεων και επιλογή του πλησιέστερου σημείου
    for i = 1:length(y)
        [~, idx] = min(abs(y(i) - constellation));
        demodulated(i) = idx - 1;
    end
end
