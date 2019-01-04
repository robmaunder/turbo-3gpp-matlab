function e = rate_matching(d, N_ref, I_LBRM, rv_idx, E)

v = [subblock_interleaver(d(1,:), 0); subblock_interleaver(d(2,:), 1); subblock_interleaver(d(3,:), 2)];
e = circular_buffer(v, N_ref, I_LBRM, rv_idx, E);


