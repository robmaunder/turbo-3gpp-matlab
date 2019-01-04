clear all

while true
    K = randi([1,6144]);
    E = randi([1,2*K]);
    rv_idx = randi([0,3]);
    
    fprintf('%d %d %d\n',K,E,rv_idx);
    
    pi1 = get_LTE_puncturer(K, E, rv_idx);
    
    F = 0;
    N_ref = inf;
    I_LBRM = 0;
    
    D = K+4;
    
    d = reshape(0:3*D-1,3,D);
    d(1:2,1:F) = NaN;
    pi2 = rate_matching(d, N_ref, I_LBRM, rv_idx, E);
    
    if ~isequal(pi1, pi2)
        error('Rob');
    end
end
