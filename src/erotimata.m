% Αρχικές παράμετροι
crc_poly = '1100001100100110011111011';
block_size = 20;
extra_bits = 24;
total_samples = 100000;
block_count = total_samples / block_size;

% Δημιουργία της πηγής με οκτώ μηνύματα
messages = {'000', '001', '010', '011', '100', '101', '110', '111'};
num_messages = length(messages);

% Υπολογισμός της πιθανότητας για κάθε μήνυμα
p = 1 / num_messages;

% Υπολογισμός της εντροπίας της πηγής
H = -num_messages * (p * log2(p));
fprintf('Η εντροπία της πηγής είναι: %.4f bits\n', H);

% Δημιουργία σειράς 100.000 μηνυμάτων
random_indices = randi([1 num_messages], 1, total_samples);
random_messages = messages(random_indices);

% Δημιουργία των νέων μηνυμάτων με τυχαιότητα
new_messages = cell(num_messages, 8);
for i = 1:num_messages
    prefix = messages{i};
    for j = 0:7
        suffix = dec2bin(j, 3);
        new_messages{i, j+1} = [prefix, suffix];
    end
end

new_random_indices = randi([1, 8], 1, total_samples);
new_random_messages = cell(1, total_samples);
for i = 1:total_samples
    original_msg = random_messages{i};
    msg_index = find(strcmp(messages, original_msg));
    new_random_messages{i} = new_messages{msg_index, new_random_indices(i)};
end

% Υπολογισμός των πιθανοτήτων εμφάνισης των νέων μηνυμάτων
new_message_counts = zeros(num_messages, 8);
for i = 1:total_samples
    new_msg = new_random_messages{i};
    original_msg = new_msg(1:3);
    suffix = new_msg(4:6);
    original_index = find(strcmp(messages, original_msg));
    suffix_index = bin2dec(suffix) + 1;
    new_message_counts(original_index, suffix_index) = new_message_counts(original_index, suffix_index) + 1;
end

new_message_probs = new_message_counts / total_samples;

% Εμφάνιση των πιθανοτήτων εμφάνισης των νέων μηνυμάτων
disp('Πιθανότητες εμφάνισης των νέων μηνυμάτων (M''):');
disp(new_message_probs);

% Διαδικασία CRC
crc_blocks = cell(1, block_count);
for i = 1:block_count
    % Συγκέντρωση μπλοκ 20 μηνυμάτων
    block_data = strcat(new_random_messages{(i-1)*block_size + 1:i*block_size});
    % Υπολογισμός CRC-24
    crc_bits = computeCRC24(block_data, crc_poly);
    % Δημιουργία νέου μπλοκ με τα CRC bits
    crc_blocks{i} = [block_data, crc_bits];
end

% Εμφάνιση των πρώτων 5 μπλοκ για έλεγχο
disp('Τα πρώτα 5 μπλοκ μηνυμάτων με CRC-24:');
disp(crc_blocks(1:5));

% Ομαδοποίηση σε 24άδες bit και κωδικοποίηση Hamming
hamming_blocks = cell(1, block_count);
for i = 1:block_count
    % Ομαδοποίηση μπλοκ των 24 bits
    for j = 1:2:length(crc_blocks{i})/12
        data_block = crc_blocks{i}(j:j+11);
        % Κωδικοποίηση Hamming
        hamming_code = computeHamming(data_block);
        hamming_blocks{i} = [hamming_blocks{i}, hamming_code];
    end
end

% Εμφάνιση των πρώτων 5 μπλοκ με Hamming κωδικοποίηση για έλεγχο
disp('Τα πρώτα 5 μπλοκ μηνυμάτων με Hamming κωδικοποίηση:');
disp(hamming_blocks(1:5));

% Υπολογισμός των πιθανοτήτων εμφάνισης των νέων μηνυμάτων
hamming_message_counts = zeros(1, 2^12);
for i = 1:block_count
    for j = 1:length(hamming_blocks{i})/12
        hamming_msg = hamming_blocks{i}((j-1)*12+1:j*12);
        index = bin2dec(hamming_msg) + 1;
        hamming_message_counts(index) = hamming_message_counts(index) + 1;
    end
end

hamming_message_probs = hamming_message_counts / (block_count * 2);

% Εμφάνιση των πιθανοτήτων εμφάνισης των νέων μηνυμάτων με Hamming
disp('Πιθανότητες εμφάνισης των νέων μηνυμάτων με Hamming:');
disp(hamming_message_probs);

% Υπολογισμός εντροπίας των νέων μηνυμάτων M'' με Hamming
H_hamming = -sum(hamming_message_probs .* log2(hamming_message_probs + eps));
fprintf('Η εντροπία των νέων μηνυμάτων με Hamming είναι: %.4f bits\n', H_hamming);

% Υπολογισμός υπό συνθήκη εντροπίας και αμοιβαίας πληροφορίας
H_conditional = H_hamming - H;
I_mutual = H_hamming - H_conditional;
fprintf('Η υπό συνθήκη εντροπία είναι: %.4f bits\n', H_conditional);
fprintf('Η αμοιβαία πληροφορία είναι: %.4f bits\n', I_mutual);

% Superposition coding με 64-QAM
% Αντιστοίχιση ζευγών bits σε σχήματα
bit_pairs = {'00', '01', '10', '11'};
shapes = {'circle', 'triangle', 'diamond', 'star'};

% Προσδιορισμός σημείων του αστερισμού για κάθε σχήμα
circle_indices = [1 5 9 13 17 21 25 29 33 37 41 45 49 53 57 61]; % Παράδειγμα για τους κύκλους
triangle_indices = [2 6 10 14 18 22 26 30 34 38 42 46 50 54 58 62]; % Παράδειγμα για τα τρίγωνα
diamond_indices = [3 7 11 15 19 23 27 31 35 39 43 47 51 55 59 63]; % Παράδειγμα για τους ρόμβους
star_indices = [4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64]; % Παράδειγμα για τα αστέρια

% Δημιουργία συμβόλων 64-QAM
qam_symbols = zeros(total_samples, 1);
for i = 1:total_samples
    % Επιλογή ζεύγους bits
    bit_pair = bit_pairs{randi(4)};
    
    % Επιλογή τυχαίου σημείου από το αντίστοιχο σύνολο
    switch bit_pair
        case '00'
            symbol_index = circle_indices(randi(length(circle_indices)));
        case '01'
            symbol_index = triangle_indices(randi(length(triangle_indices)));
        case '10'
            symbol_index = diamond_indices(randi(length(diamond_indices)));
        case '11'
            symbol_index = star_indices(randi(length(star_indices)));
    end
    
    % Προσθήκη του συμβόλου στη λίστα
    qam_symbols(i) = qammod(symbol_index-1, 64);
end

% Εμφάνιση των πρώτων 10 συμβόλων της 64-QAM για έλεγχο
disp('Τα πρώτα 10 σύμβολα της 64-QAM διαμόρφωσης:');
disp(qam_symbols(1:10));


% Δημιουργία ενός παραδείγματος 64-QAM σήματος
M = 64; % Αριθμός συμβόλων στο 64-QAM
data = randi([0 M-1], 1000, 1); % Τυχαία δεδομένα
qam_modulated = qammod(data, M); % 64-QAM διαμόρφωση

% SNR σε dB
SNR_dB = 20;

% Πέρασμα του σήματος από το AWGN κανάλι
y = awgn_channel(qam_modulated, SNR_dB);

% Εμφάνιση του διαμορφωμένου και του ληφθέντος σήματος
scatterplot(qam_modulated);
title('64-QAM Διαμορφωμένο Σήμα');
scatterplot(y);
title('Ληφθέν Σήμα μέσω AWGN Καναλιού');

%--------------8-------------------
% SNR σε dB για τον Bob και την Eve
SNR_Bob_dB = 12; % Παράδειγμα SNR για τον Bob
SNR_Eve_dB = SNR_Bob_dB - 4; % SNR για την Eve είναι 4 dB χαμηλότερο

% Πέρασμα του σήματος από το AWGN κανάλι για τον Bob
y_bob = awgn_channel(qam_modulated, SNR_Bob_dB);

% Πέρασμα του σήματος από το AWGN κανάλι για την Eve
y_eve = awgn_channel(qam_modulated, SNR_Eve_dB);

% Εμφάνιση του διαμορφωμένου και των ληφθέντων σημάτων
scatterplot(qam_modulated);
title('64-QAM Διαμορφωμένο Σήμα');
scatterplot(y_bob);
title('Ληφθέν Σήμα μέσω AWGN Καναλιού (Bob)');
scatterplot(y_eve);
title('Ληφθέν Σήμα μέσω AWGN Καναλιού (Eve)');


%=======================================

% Αποδιαμόρφωση του σήματος του Bob χρησιμοποιώντας την custom συνάρτηση
demodulated_bob = custom_qamdemod(y_bob, M);

% Αποδιαμόρφωση του σήματος της Eve χρησιμοποιώντας την custom συνάρτηση
demodulated_eve = custom_qamdemod(y_eve, M);

% Εκτίμηση του μηνύματος για τον Bob
message_bob = estimate_message(demodulated_bob, M);

% Εκτίμηση του μηνύματος για την Eve
message_eve = estimate_message(demodulated_eve, M);

% Εμφάνιση των πρώτων 10 αποδιαμορφωμένων συμβόλων για έλεγχο
disp('Τα πρώτα 10 αποδιαμορφωμένα σύμβολα για τον Bob (custom):');
disp(demodulated_bob_custom(1:10));

disp('Τα πρώτα 10 αποδιαμορφωμένα σύμβολα για την Eve (custom):');
disp(demodulated_eve_custom(1:10));

%------------------------11--------------
% Εμφάνιση των πιθανοτήτων εμφάνισης των νέων μηνυμάτων με Hamming
disp('Πιθανότητες εμφάνισης των νέων μηνυμάτων με Hamming:');
disp(hamming_message_probs);

% Υπολογισμός εντροπίας των νέων μηνυμάτων M'' με Hamming
H_hamming = -sum(hamming_message_probs .* log2(hamming_message_probs + eps));
fprintf('Η εντροπία των νέων μηνυμάτων με Hamming είναι: %.4f bits\n', H_hamming);

% Καλεί την συνάρτηση decodeQAM που έχει δημιουργηθεί σε άλλο αρχείο
decodeQAM;
%-------------------------14------------------
% Αρχικές παράμετροι
M = 64; % 64-QAM
total_samples = 100000;
sigma_squared = 0.005;
block_size = 20;
block_count = total_samples / block_size;

% Ορισμός του πίνακα καναλιού Hm για τον Bob
Hm = [1.6330, 0.4082 - 0.7071i, 0.4082 + 0.7071i;
      1.1547, -0.5774 + 1i, -0.5774 - 1i;
      0, 0.7071 - 1.2247i, -0.7071 - 1.2247i];

% Ορισμός του πίνακα καναλιού He για την Eve
He = [5 -1+1i 3+3i;
      -3 -1-1i -1+4i;
      -1 0 -1-7i];

% Δημιουργία τυχαίων δεδομένων για 64-QAM διαμόρφωση
data = randi([0 M-1], total_samples, 3);

% Διαμόρφωση 64-QAM
qam_modulated = qammod(data, M, 'UnitAveragePower', true);
qam_modulated = transpose(qam_modulated); % [3xN]

% Υπολογισμός beamforming weights χρησιμοποιώντας τον πίνακα καναλιού του Bob
[V, ~] = eig(Hm' * Hm);
w = V(:, 1); % Beamforming weight vector

% Μετάδοση σημάτων μέσω του καναλιού
ym = Hm * (qam_modulated .* repmat(w, 1, total_samples)) + sqrt(sigma_squared) * randn(size(Hm * qam_modulated)); % Σήμα στο Bob
ye = He * (qam_modulated .* repmat(w, 1, total_samples)) + sqrt(sigma_squared) * randn(size(He * qam_modulated)); % Σήμα στην Eve

% Προσθήκη AWGN θορύβου
SNR_Bob_dB = 20;
SNR_Eve_dB = 16;
ym = awgn(ym, SNR_Bob_dB, 'measured');
ye = awgn(ye, SNR_Eve_dB, 'measured');

% Εξισορρόπηση του καναλιού για τον Bob
H_inv_bob = pinv(Hm);
ym_equalized = H_inv_bob * ym;

% Εξισορρόπηση του καναλιού για την Eve
H_inv_eve = pinv(He);
ye_equalized = H_inv_eve * ye;

% Αποδιαμόρφωση QAM για τον Bob
qam_demodulated_bob = qamdemod(ym_equalized(:), M, 'UnitAveragePower', true);
qam_demodulated_eve = qamdemod(ye_equalized(:), M, 'UnitAveragePower', true);

% Υπολογισμός της πιθανότητας σφάλματος για τον Bob και την Eve
bits_per_symbol = log2(M); % Αριθμός bits ανά σύμβολο
qam_bits_bob = de2bi(qam_demodulated_bob, bits_per_symbol, 'left-msb');
qam_bits_eve = de2bi(qam_demodulated_eve, bits_per_symbol, 'left-msb');

% Μετατροπή των bits σε μονοδιάστατους πίνακες
qam_bits_bob = reshape(qam_bits_bob.', 1, []);
qam_bits_eve = reshape(qam_bits_eve.', 1, []);

% Υπολογισμός των σφαλμάτων
original_bits = de2bi(data(:), bits_per_symbol, 'left-msb');
original_bits = reshape(original_bits.', 1, []);

num_errors_bob = sum(qam_bits_bob ~= original_bits);
num_errors_eve = sum(qam_bits_eve ~= original_bits);

% Εμφάνιση των αποτελεσμάτων
fprintf('Αριθμός σφαλμάτων για τον Bob: %d\n', num_errors_bob);
fprintf('Αριθμός σφαλμάτων για την Eve: %d\n', num_errors_eve);


% Εμφάνιση των πιθανοτήτων εμφάνισης των νέων μηνυμάτων με Hamming
disp('Πιθανότητες εμφάνισης των νέων μηνυμάτων με Hamming:');
disp(hamming_message_probs);

% Υπολογισμός εντροπίας των νέων μηνυμάτων M'' με Hamming
H_hamming = -sum(hamming_message_probs .* log2(hamming_message_probs + eps));
fprintf('Η εντροπία των νέων μηνυμάτων με Hamming είναι: %.4f bits\n', H_hamming);

% Καλεί την συνάρτηση snr_analysis_beamforming που έχει δημιουργηθεί σε άλλο αρχείο
fprintf('Εκτελείται ο έλεγχος του SNR για το κανάλι μεταξύ του Bob και της Eve...\n');
%snr_analysis;
%snr_analysis_beamforming;

%-----------16---------------------
beamforming_technique;
%_______________17_________________

% Ορισμός του πίνακα καναλιού He
He = [5 -1+1i 3+3i; -3 -1-1i -1+4i; -1 0 -1-7i];

% Υπολογισμός της Singular Value Decomposition (SVD)
[U, S, V] = svd(He);

% Εμφάνιση των αποτελεσμάτων της SVD
disp('U =');
disp(U);
disp('S =');
disp(S);
disp('V =');
disp(V);

% Ορισμός του λευκού Gaussian θορύβου με σ^2 = 0.005
sigma_squared = 0.005;

% Υπολογισμός της χωρητικότητας του καναλιού
capacity = sum(log2(1 + (diag(S).^2) / sigma_squared));

% Εμφάνιση της χωρητικότητας
fprintf('Η χωρητικότητα του καναλιού είναι: %.4f bits/channel use\n', capacity);


%--------------------18-----------------
% Ορισμός του πίνακα καναλιού Hm για τον Bob
Hm = [1.6330, 0.4082 - 0.7071i, 0.4082 + 0.7071i;
      1.1547, -0.5774 + 1i, -0.5774 - 1i;
      0, 0.7071 - 1.2247i, -0.7071 - 1.2247i];

% Ορισμός του πίνακα καναλιού He για την Eve
He = [5 -1+1i 3+3i;
      -3 -1-1i -1+4i;
      -1 0 -1-7i];

% Ορισμός των παραμέτρων
M = 64; % 64-QAM
total_samples = 100000;
sigma_squared = 0.005;
SNR_Bob_dB = 20;
SNR_Eve_dB = 16;

% Δημιουργία τυχαίων δεδομένων για 64-QAM διαμόρφωση
data = randi([0 M-1], total_samples, 3);

% Διαμόρφωση 64-QAM
qam_modulated = qammod(data, M, 'UnitAveragePower', true);
qam_modulated = transpose(qam_modulated); % [3xN]

% Υπολογισμός beamforming weights χρησιμοποιώντας τον πίνακα καναλιού του Bob
[V, ~] = eig(Hm' * Hm);
w = V(:, 1); % Beamforming weight vector

% Μετάδοση σημάτων μέσω του καναλιού
ym = Hm * (qam_modulated .* w) + sqrt(sigma_squared) * randn(size(Hm * qam_modulated)); % Σήμα στο Bob
ye = He * (qam_modulated .* w) + sqrt(sigma_squared) * randn(size(He * qam_modulated)); % Σήμα στην Eve

% Προσθήκη AWGN θορύβου
ym = awgn(ym, SNR_Bob_dB, 'measured');
ye = awgn(ye, SNR_Eve_dB, 'measured');

% Αποδιαμόρφωση QAM
qam_demodulated_bob = qamdemod(ym(:), M, 'UnitAveragePower', true);
qam_demodulated_eve = qamdemod(ye(:), M, 'UnitAveragePower', true);

% Υπολογισμός της πιθανότητας σφάλματος για τον Bob και την Eve
bits_per_symbol = log2(M); % Αριθμός bits ανά σύμβολο
qam_bits_bob = de2bi(qam_demodulated_bob, bits_per_symbol, 'left-msb');
qam_bits_eve = de2bi(qam_demodulated_eve, bits_per_symbol, 'left-msb');

% Υπολογισμός της χωρητικότητας
capacity_bob = sum(log2(1 + (diag(V).^2) / sigma_squared));
capacity_eve = sum(log2(1 + (diag(V).^2) / sigma_squared));

% Εμφάνιση των αποτελεσμάτων
fprintf('Η χωρητικότητα του καναλιού για τον Bob είναι: %.4f bits/channel use\n', capacity_bob);
fprintf('Η χωρητικότητα του καναλιού για την Eve είναι: %.4f bits/channel use\n', capacity_eve);

% Υπολογισμός της χωρητικότητας μυστικότητας
capacity_secrecy = capacity_bob - capacity_eve;
fprintf('Η χωρητικότητα μυστικότητας είναι: %.4f bits/channel use\n', capacity_secrecy);


%----------------19---------------------

% Ορισμός των παραμέτρων
M = 64; % 64-QAM
total_samples = 100000;
sigma_squared = 0.005;
block_size = 20;
block_count = total_samples / block_size;

% Ορισμός του πίνακα καναλιού Hm για τον Bob
Hm = [1.6330, 0.4082 - 0.7071i, 0.4082 + 0.7071i;
      1.1547, -0.5774 + 1i, -0.5774 - 1i;
      0, 0.7071 - 1.2247i, -0.7071 - 1.2247i];

% Ορισμός του πίνακα καναλιού He για την Eve
He = [5 -1+1i 3+3i;
      -3 -1-1i -1+4i;
      -1 0 -1-7i];

% Δημιουργία τυχαίων δεδομένων για 64-QAM διαμόρφωση
data = randi([0 M-1], total_samples, 3);

% Διαμόρφωση 64-QAM
qam_modulated = qammod(data, M, 'UnitAveragePower', true);
qam_modulated = transpose(qam_modulated); % [3xN]

% Υπολογισμός beamforming weights χρησιμοποιώντας τον πίνακα καναλιού του Bob
[V, ~] = eig(Hm' * Hm);
w = V(:, 1); % Beamforming weight vector

% Μετάδοση σημάτων μέσω του καναλιού
ym = Hm * (qam_modulated .* w) + sqrt(sigma_squared) * randn(size(Hm * qam_modulated)); % Σήμα στο Bob
ye = He * (qam_modulated .* w) + sqrt(sigma_squared) * randn(size(He * qam_modulated)); % Σήμα στην Eve

% Προσθήκη AWGN θορύβου
SNR_Bob_dB = 20;
SNR_Eve_dB = 16;
ym = awgn(ym, SNR_Bob_dB, 'measured');
ye = awgn(ye, SNR_Eve_dB, 'measured');

% Εξισορρόπηση του καναλιού για τον Bob
H_inv_bob = pinv(Hm);
ym_equalized = H_inv_bob * ym;

% Εξισορρόπηση του καναλιού για την Eve
H_inv_eve = pinv(He);
ye_equalized = H_inv_eve * ye;

% Αποδιαμόρφωση QAM για τον Bob
qam_demodulated_bob = qamdemod(ym_equalized(:), M, 'UnitAveragePower', true);
qam_demodulated_eve = qamdemod(ye_equalized(:), M, 'UnitAveragePower', true);

% Υπολογισμός της πιθανότητας σφάλματος για τον Bob και την Eve
bits_per_symbol = log2(M); % Αριθμός bits ανά σύμβολο
qam_bits_bob = de2bi(qam_demodulated_bob, bits_per_symbol, 'left-msb');
qam_bits_eve = de2bi(qam_demodulated_eve, bits_per_symbol, 'left-msb');

% Μετατροπή των bits σε μονοδιάστατους πίνακες
qam_bits_bob = reshape(qam_bits_bob.', 1, []);
qam_bits_eve = reshape(qam_bits_eve.', 1, []);

% Υπολογισμός των σφαλμάτων
original_bits = de2bi(data(:), bits_per_symbol, 'left-msb');
original_bits = reshape(original_bits.', 1, []);

num_errors_bob = sum(qam_bits_bob ~= original_bits);
num_errors_eve = sum(qam_bits_eve ~= original_bits);

% Εμφάνιση των αποτελεσμάτων
fprintf('Αριθμός σφαλμάτων για τον Bob: %d\n', num_errors_bob);
fprintf('Αριθμός σφαλμάτων για την Eve: %d\n', num_errors_eve);

