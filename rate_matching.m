function e = rate_matching(d, N_ref, I_LBRM, rv_idx, E)
% RATE_MATCHING performs rate matching, as specified in Section
% 5.1.4.1 of TS36.212.
%   e = RATE_MATCHING(d, N_ref, I_LBRM, rv_idx, E) rate matches a specified
%   bit matrix, using various specified parameters.
%
%   d should be a matrix comprising 3 rows and D columns, filler bits to
%   be punctured should be indicated by NaN-valued elements.
%
%   N_ref should be set to floor(N_IR/C), as described in Section 5.1.4.1.2
%   of TS36.212.
%
%   I_LBRM should be set to 0 for UL-SCH, MCH, SL-SCH and SL-DCH transport
%   channels, as well as for UE category 0 for DL-SCH associated with
%   SI-RNTI and RA-RNTI and PCH transport channel. Otherwise, I_LBRM should
%   be set to a value other than 0 for DL-SCH and PCH transport channels,
%   as described in Section 5.1.4.1.2 of TS36.212.
%
%   rv_idx specifies the redundancy version, which should be selected from
%   the set 0, 1, 2 or 3, as described in Section 5.1.4.1.2 of TS36.212.
%
%   E specifies the encoded block length.
%   
%   e will be a row vector of length E.
%
%   A rate matching pattern can be obtained according to
%        d = reshape(0:3*D-1,3,D);
%        d(1:2,1:F) = NaN;
%        pi = rate_matching(d, N_ref, I_LBRM, rv_idx, E);
%   Using this, rate matching can be achieved according to
%        d_vec = reshape(d,1,numel(d));
%        e = d_vec(pi+1);
%   Derate matching can be achieved according to
%        d_vec = zeros(1,3*D);
%        for k = 0:length(pi)-1
%           d_vec(pi(k+1)+1) = d_vec(pi(k+1)+1) + e(k+1);
%        end
%        d = reshape(d_vec,3,D);
%        d(1:2,1:F) = NaN;
%
% Copyright © 2018 Robert G. Maunder. This program is free software: you
% can redistribute it and/or modify it under the terms of the GNU General
% Public License as published by the Free Software Foundation, either
% version 3 of the License, or (at your option) any later version. This
% program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
% more details.

v = [subblock_interleaver(d(1,:), 0); subblock_interleaver(d(2,:), 1); subblock_interleaver(d(3,:), 2)];
e = circular_buffer(v, N_ref, I_LBRM, rv_idx, E);


