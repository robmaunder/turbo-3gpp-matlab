function interleaver_pattern = get_3gpp_subblock_interleaver(D, subblock_interleaver_index)
% GET_3GPP_SUBBLOCK_INTERLEAVER obtains the subblock interleaver pattern, as
% specified in Section 5.1.4.1.1 of TS36.212.
%   interleaver_pattern = GET_3GPP_SUBBLOCK_INTERLEAVER(D,
%   subblock_interleaver_index) obtains the interleaver pattern for a
%   specified block length and a specified subblock interleaver index.
%
%   D specifies the block length.
%
%   subblock_interleaver_index specifies the subblock interleaver index
%   from the set 0, 1 or 2.
%
%   interleaver_pattern will be a row vector of length K_Pi, containing
%   unique indices in the range 0 to D-1, as well as K_Pi-D NaNs, arranged
%   according to the subblock interleaver pattern. Interleaving can be
%   achieved according to
%       v = zeros(size(interleaver_pattern));
%       v(~isnan(interleaver_pattern)) = d(interleaver_pattern(~isnan(interleaver_pattern))+1);
%       v(isnan(interleaver_pattern)) = NaN;
%   Deinterleaving can be achieved according to
%       d = zeros(1,D);
%       d(interleaver_pattern(~isnan(interleaver_pattern))+1) = v(~isnan(interleaver_pattern));
%
% Copyright © 2018 Robert G. Maunder. This program is free software: you
% can redistribute it and/or modify it under the terms of the GNU General
% Public License as published by the Free Software Foundation, either
% version 3 of the License, or (at your option) any later version. This
% program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
% more details.

d = 0:D-1;

P = [0, 16, 8, 24, 4, 20, 12, 28, 2, 18, 10, 26, 6, 22, 14, 30, 1, 17, 9, 25, 5, 21, 13, 29, 3, 19, 11, 27, 7, 23, 15, 31];

C_TC_subblock=32;
R_TC_subblock = 0;

while ~(D <= (R_TC_subblock*C_TC_subblock))
    R_TC_subblock = R_TC_subblock+1;
end

K_Pi = R_TC_subblock*C_TC_subblock;

y = zeros(1, K_Pi);

N_D = (R_TC_subblock*C_TC_subblock - D);

for k = 0:N_D-1
    y(k+1) = NaN;
end

for k = 0:D-1
    y(N_D+k+1) = d(k+1);
end

matrix = reshape(y,C_TC_subblock, R_TC_subblock)';

if subblock_interleaver_index == 0 || subblock_interleaver_index == 1
    matrix = matrix(:,P+1);
    interleaver_pattern = reshape(matrix, 1, K_Pi);
elseif subblock_interleaver_index == 2
    pi = zeros(1,K_Pi);
    for k = 0:K_Pi-1    
        pi(k+1) = mod(P(floor(k/R_TC_subblock)+1)+C_TC_subblock*mod(k,R_TC_subblock)+1,K_Pi);
    end
     interleaver_pattern = y(pi+1);
else
    error('Unsupported subblock_interleaver_index');
end
    
