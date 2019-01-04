function d = apply_derate_matching_pattern(e, pi)

if length(e) ~= length(pi)
    error('pi and e should have the same length.');
end

d_vec = NaN(1,max(pi)+1);

for k = 0:length(pi)-1
    if isnan(d_vec(pi(k+1)+1))
        d_vec(pi(k+1)+1) = e(k+1);
    else
        d_vec(pi(k+1)+1) = d_vec(pi(k+1)+1) + e(k+1);
    end
end
        
d = reshape(d_vec,3,length(d_vec)/3);
