function crc_bits = computeCRC24(data, poly)
    % data: binary string (1xN char array) representing the data bits
    % poly: binary string (1x24 char array) representing the CRC polynomial
    % crc_bits: binary string (1x24 char array) representing the CRC bits
    
    % Convert binary strings to numerical arrays for polynomial division
    data = [data, repmat('0', 1, 24)]; % Append 24 zero bits for CRC calculation
    data = data - '0';
    poly = poly - '0';
    
    % Polynomial division
    for i = 1:(length(data) - 24)
        if data(i) == 1
            data(i:i+24) = bitxor(data(i:i+24), poly);
        end
    end
    
    % The remainder is the CRC
    crc_bits = data(end-23:end) + '0';

      data = [data, zeros(1, length(poly) - 1)]; % Προσθήκη μηδενικών για το CRC
    for i = 1:length(data) - length(poly) + 1
        if data(i) == 1
            data(i:i+length(poly)-1) = bitxor(data(i:i+length(poly)-1), poly);
        end
    end
    crc = data(end-length(poly)+2:end); % Τα τελευταία bits είναι το CRC
    crc = char(crc + '0'); % Μετατροπή πίσω σε συμβολοσειρ
end
%_--------------function crc = computeCRC24(data, poly)
    % computeCRC24 Υπολογισμός του CRC-24 για τα δεδομένα
    % data: Συμβολοσειρά bit
    % poly: Πολυώνυμο CRC
   % data = data - '0'; % Μετατροπή της συμβολοσειράς σε αριθμητικό πίνακα
   % poly = poly - '0'; % Μετατροπή του πολυωνύμου σε αριθμητικό πίνακα
 %   data = [data, zeros(1, length(poly) - 1)]; % Προσθήκη μηδενικών για το CRC
  %  for i = 1:length(data) - length(poly) + 1
      %  if data(i) == 1
    %        data(i:i+length(poly)-1) = bitxor(data(i:i+length(poly)-1), poly);
     %   end
   % end
  %  crc = data(end-length(poly)+2:end); % Τα τελευταία bits είναι το CRC
  %  crc = char(crc + '0'); % Μετατροπή πίσω σε συμβολοσειρά
%end
