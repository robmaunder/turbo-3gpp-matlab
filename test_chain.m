while 1
    
    
    R_min = 78/1024;
    R_max = 948/1024;
    
    R = R_min+(R_max-R_min)*rand;
    
    A = floor(10^(4.2656*rand));
    G = max(floor(A/R),132);
    
    R = R_min+(R_max-R_min)*rand;
    N_IR = max(floor(A/R),132);
    
    Q_ms = [1,2,4,6,8,10];
    
    Q_m = Q_ms(randi(6));
    
    N_L = randi(3);
    
    rv_idx = randi([0,3]);
    
        
    fprintf('%d\t%d\t%d\t%d\t',A,G, N_IR, rv_idx);
    
    encoder = turbo_encoding_chain('A',A,'G',G,'I_LBRM',1,'N_IR',N_IR,'Q_m',Q_m,'N_L',N_L,'rv_idx',rv_idx);
    decoder = turbo_decoding_chain('A',A,'G',G,'I_LBRM',1,'N_IR',N_IR,'Q_m',Q_m,'N_L',N_L,'rv_idx',rv_idx,'iterations',3);
    
    a = round(rand(1,A));
    f = encoder(a);
    
    f_tilde = 1000*(1-2*f);
    
    a_hat = decoder(f_tilde);
    
    if ~isequal(a,a_hat)
        fprintf('failed\n');
    else
        fprintf('\n');
    end
end
    