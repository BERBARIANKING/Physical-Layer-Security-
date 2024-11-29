function message = estimate_message(demodulated, M)
    % Δημιουργία του αστερισμού για το 64-QAM
    constellation = qammod(0:M-1, M);
    
    % Χάρτης superposition coding: Αντιστοίχιση συμβόλων σε μηνύματα
    bit_pairs = {'00', '01', '10', '11'};
    shapes = {'circle', 'triangle', 'diamond', 'star'};
    
    % Διευκρίνιση των συντεταγμένων στον αστερισμό
    circle_indices = [1 5 9 13 17 21 25 29 33 37 41 45 49 53 57 61];
    triangle_indices = [2 6 10 14 18 22 26 30 34 38 42 46 50 54 58 62];
    diamond_indices = [3 7 11 15 19 23 27 31 35 39 43 47 51 55 59 63];
    star_indices = [4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64];
    
    % Προσδιορισμός του μήνυματος βάσει του λαμβανόμενου σήματος
    message = cell(size(demodulated));
    for i = 1:length(demodulated)
        if ismember(demodulated(i), circle_indices - 1)
            message{i} = '00';
        elseif ismember(demodulated(i), triangle_indices - 1)
            message{i} = '01';
        elseif ismember(demodulated(i), diamond_indices - 1)
            message{i} = '10';
        elseif ismember(demodulated(i), star_indices - 1)
            message{i} = '11';
        end
    end
end
