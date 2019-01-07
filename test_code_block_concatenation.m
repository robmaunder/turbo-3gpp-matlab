while true
    
    C = randi(10);
    
    E_r = zeros(1,C);
    for r = 0:C-1
        E_r(r+1) = randi(6144);
    end
    G = sum(E_r);
    
    E_r
    
    f = 0:G-1;
    
    e_r = code_block_deconcatenation(f,E_r);
    
    f2 = code_block_concatenation(e_r);
    
    
    if ~isequal(f,f2)
        error('Rob');
    end
end
        