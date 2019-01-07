function E_r = get_3gpp_encoded_code_block_segment_lengths(G, C, N_L, Q_m)
% GET_3GPP_ENCODED_CODE_BLOCK_SEGMENT_LENGTHS determines how an encoded
% transport block is formed from concatenated encoded code blocks,
% according to Section 5.1.4.1.2 of TS36.212.
%   E_r = GET_3GPP_ENCODED_CODE_BLOCK_SEGMENT_LENGTHS(G, C, N_L, Q_m)
%   determines the encoded code block lengths that result from the
%   segmentation of a transport block having a specified length.
%
%   G specifies the encoded transport block length.
%
%   C specifies the number of code block segments.
%
%   N_L specifies the number of layers a transport block is mapped to, or
%   is equal to 2 for transmit diversity, as described in Section 5.1.4.1.2
%   of TS36.212.
%
%   Q_m should be set to 1 for ?/2-BPSK, 2 for QPSK, 4 for 16QAM, 6 for
%   64QAM, 8 for 256QAM, and 10 for 1024QAM,
%
%   E_r will be a row vector comprising C elements, each of which specifies
%   the encoded code block length for the corresponding segment.
%
% Copyright © 2018 Robert G. Maunder. This program is free software: you 
% can redistribute it and/or modify it under the terms of the GNU General 
% Public License as published by the Free Software Foundation, either 
% version 3 of the License, or (at your option) any later version. This 
% program is distributed in the hope that it will be useful, but WITHOUT 
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
% FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for 
% more details.


E_r = zeros(1,C);

G_prime = G/(N_L*Q_m);

gamma = mod(G',C);

for r = 0:C-1
    if r <= C - gamma - 1
        E_r(r+1) = N_L*Q_m*floor(G_prime/C);
    else
        E_r(r+1) = N_L*Q_m*ceil(G_prime/C);
    end
end