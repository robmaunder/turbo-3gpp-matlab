global approx_star
approx_star = false;



while 1
    
    N = randi(6144);
    
    infs_x = randi(N);
    infs_z = randi(N);
    
    fprintf('%d %d %d\n',N,infs_x,infs_z);
    
    x_a = randn(1,N);
    z_a = randn(1,N);
    
    inf_x_indices = randperm(N);    
    x_a(inf_x_indices(1:infs_x)) = inf;
    x_a2 = x_a;
    x_a2(inf_x_indices(1:infs_x)) = 99999;
    
    inf_z_indices = randperm(N);    
    z_a(inf_z_indices(1:infs_z)) = inf;
    z_a2 = z_a;
    z_a2(inf_z_indices(1:infs_z)) = 99999;
    
    
    x_e1 = constituent_decoder(x_a2,z_a2);
    x_e2 = constituent_decoder2(x_a,z_a);
    
    x_e1(x_e1 > 50000) = inf;
    
    if sum(isnan(x_e2))>0
        error('Rob4');
    end
    
    if sum(isnan(x_e1))>0
        error('Rob5');
    end
    
    if ~isequal(isinf(x_e1), isinf(x_e2))
        [x_e1;x_e2]
        error('Rob3');
    end
    
    if ~isequal(x_e1(isinf(x_e1)), x_e2(isinf(x_e2)))
        [x_e1;x_e2]
        error('Rob2');
    end
    
    if mean((x_e1(~isinf(x_e1))-x_e2(~isinf(x_e2))).^2) > 1e-10
        [x_e1;x_e2]
        
        error('Rob');
    end
end
    
    
    