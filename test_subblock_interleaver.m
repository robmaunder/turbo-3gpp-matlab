while 1
    
    D = randi(6148);
    
    d = 0:D-1;
    
    subblock_interleaver_index = randi([0,2]);
    
    fprintf('%d %d\n',D,subblock_interleaver_index);
    
    v1 = subblock_interleaver_old(d,subblock_interleaver_index);
   
    
    pi = subblock_interleaver(0:D-1, subblock_interleaver_index);
    
    v2 = zeros(size(pi));
    v2(~isnan(pi)) = d(pi(~isnan(pi))+1);
    v2(isnan(pi)) = nan;
    
    d2 = zeros(1,D);
    d2(pi(~isnan(pi))+1) = v2(~isnan(pi));
    
    if ~isequal(d,d2)
        [d;d2]
        error('Rob3');
    end
    
    
    
    
    
    if ~isequal(isnan(v1),isnan(v2))
        [v1;v2]
        error('Rob');
    end
    
    if ~isequal(v1(~isnan(v1)),v2(~isnan(v2)))
        [v1;v2]
        error('Rob2');
    end
    
    
end