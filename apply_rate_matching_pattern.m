function e = apply_rate_matching_pattern(d, pi)

if size(d,1) ~= 3
    error('d should have 3 rows.');
end

d_vec = reshape(d,1,numel(d));
e = zeros(size(pi));
e = d_vec(pi+1);