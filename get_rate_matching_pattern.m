function pi = get_rate_matching_pattern(F, K, N_ref, I_LBRM, rv_idx, E)

D = K+4;

d = reshape(0:3*D-1,3,D);
d(1,1:F) = NaN;
d(2,1:F) = NaN;

pi = rate_matching(d, N_ref, I_LBRM, rv_idx, E);
