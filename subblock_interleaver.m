function v = subblock_interleaver(d, subblock_interleaver_index)
% SUBBLOCK_INTERLEAVER performs subblock interleaving, as
% specified in Section 5.1.4.1.1 of TS36.212.
%   v = SUBBLOCK_INTERLEAVER(d, subblock_interleaver_index) subblock
%   interleaves a specified bit sequence, using a specified subblock
%   interleaver index.
%
%   d should be a row vector of length D, to be interleaved.
%
%   subblock_interleaver_index specifies the subblock interleaver index
%   from the set 0, 1 or 2.
%
%   v will be a row vector of length K_Pi, containing the D elements of d,
%   as well as K_Pi-D NaNs, arranged according to the subblock interleaver
%   pattern. 
%
%   A subblock interleaver pattern can be obtained according to
%       pi = subblock_interleaver(0:D-1, subblock_interleaver_index);
%   Using this, interleaving can be achieved according to
%       v = NaN(size(pi));
%       v(~isnan(pi)) = d(pi(~isnan(pi))+1);
%   Deinterleaving can be achieved according to
%       d = zeros(1,D);
%       d(pi(~isnan(pi))+1) = v(~isnan(pi));
%
% Copyright © 2018 Robert G. Maunder. This program is free software: you
% can redistribute it and/or modify it under the terms of the GNU General
% Public License as published by the Free Software Foundation, either
% version 3 of the License, or (at your option) any later version. This
% program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
% more details.

D = length(d);

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

if subblock_interleaver_index == 0 || subblock_interleaver_index == 1
    matrix = reshape(y,C_TC_subblock, R_TC_subblock)';
    matrix = matrix(:,P+1);
    v = reshape(matrix, 1, K_Pi);
elseif subblock_interleaver_index == 2
    pi = zeros(1,K_Pi);
    for k = 0:K_Pi-1    
        pi(k+1) = mod(P(floor(k/R_TC_subblock)+1)+C_TC_subblock*mod(k,R_TC_subblock)+1,K_Pi);
    end
     v = y(pi+1);
else
    error('Unsupported subblock_interleaver_index');
end
    
