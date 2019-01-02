while 1
    CRC_index = randi(4);
    
    
    if CRC_index == 1
        CRC = 'CRC24A';
    elseif CRC_index == 2
        CRC = 'CRC24B';    
    elseif CRC_index == 3
        CRC = 'CRC16';
    elseif CRC_index == 4
        CRC = 'CRC8';
    else
        error('Something has gone wrong');
    end
    A = randi(6144);
    A2 = randi(A);
    
    erroneous = round(rand);
    
    fprintf('%s %d %d %d\n',CRC,A,A2,erroneous);
    
    
    crc_polynomial = get_3gpp_crc_polynomial(CRC);
    
    G_P = get_crc_generator_matrix(A, crc_polynomial);
    
    a = round(rand(1,A2));
    
    b = generate_and_append_crc_bits(a, G_P);
    
    if erroneous
        index = randi(length(b));
        
        b(index) = ~b(index);
    end
    
    a2 = check_and_remove_crc_bits(b, G_P);
    
    if ~isequal(a2,a) && erroneous == 0
        error('Check failed');
    end
    
     if ~isempty(a2) && erroneous == 1
        error('Check should have failed');
    end
    
end