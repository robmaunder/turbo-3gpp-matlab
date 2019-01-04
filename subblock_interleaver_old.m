function v = subblock_interleaver_old(d,superscript)

D = length(d);

C_TC_subblock = 32;

R_TC_subblock = ceil(D/C_TC_subblock);

N_D = R_TC_subblock*C_TC_subblock-D;

y = [nan(1,N_D),d];

matrix = reshape(y,C_TC_subblock,R_TC_subblock)';

P = [0 16 8 24 4 20 12 28 2 18 10 26 6 22 14 30 1 17 9 25 5 21 13 29 3 19 11 27 7 23 15 31];

K_PI = R_TC_subblock*C_TC_subblock;

if superscript < 2
    
    matrix = matrix(:,P+1);
    
    v = reshape(matrix, 1, K_PI);
    
else
    pi = mod(P(floor((0:K_PI-1)/R_TC_subblock)+1) + C_TC_subblock*mod(0:K_PI-1,R_TC_subblock)+1, K_PI);
    
    v = y(pi+1);
end

end