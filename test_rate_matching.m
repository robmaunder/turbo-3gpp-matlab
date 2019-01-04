while true
    K = randi([1,6144]);
    E = randi([1,2*K]);
    rv_idx = randi([0,3]);
    
    fprintf('%d %d %d\n',K,E,rv_idx);

    pi1 = get_LTE_puncturer(K, E, rv_idx);
    
    F = 0;
    N_ref = inf;
    I_LBRM = 0;
    
    pi2 = get_rate_matching_pattern(F, K, N_ref, I_LBRM, rv_idx, E);

    if ~isequal(pi1, pi2)
        error('Rob');
    end
end
