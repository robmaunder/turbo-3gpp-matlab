
crc_polynomial = get_3gpp_crc_polynomial('CRC24B');
G_max = get_crc_generator_matrix(6144, crc_polynomial);

while 1
    
    B = floor(10^(rand*5));
    
    erroneous = round(rand);
    
    fprintf('%d %d\n',B,erroneous);
    
    K_r = get_3gpp_code_block_segment_lengths(B);
    
    b = round(rand(1,B));
    
    c_r = code_block_segmentation(b,K_r,G_max);
    
    C = length(c_r);
    
    if erroneous
        bit = NaN;        
        while isnan(bit)
            code_block_index = randi(length(c_r));
            bit_index = randi(length(c_r{code_block_index}));
            bit = c_r{code_block_index}(bit_index);
        end
        
        c_r{code_block_index}(bit_index) = ~c_r{code_block_index}(bit_index);
    end
    
    b2 = code_block_desegmentation(c_r,B,G_max);
    
    if ~isequal(b,b2) && erroneous == 0
        error('Something has gone wrong.');
    end
    
    if C>1 && ~isempty(b2) && erroneous == 1
        error('Something has gone wrong 2.');
    end
    
    if C == 1 && isequal(b,b2) && erroneous == 1
        error('Something has gone wrong 3.');
    end

end
    
    
    
    
    
    