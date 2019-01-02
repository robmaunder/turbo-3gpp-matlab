function d = turbo_encoder(c, pi) 
% TURBO_ENCODER encodes a code block using a turbo code, as
% specified in Section 5.1.3.2 of TS36.212.
%   d = TURBO_ENCODER(c, pi) encodes a code block, using a specified
%   interleaver pattern.
%
%   c should be a row vector, comprising the K bits of a code block.
%
%   pi should be a row vector of length K, containing unique indices in the range
%   0 to K-1, arranged according to the turbo code interleaver pattern,
%   such that interleaving can be achieved according to c_prime = c(pi+1);
%
%   d will be a matrix of encoded bits, comprising 3 rows and K+4 columns.
%
% Copyright © 2018 Robert G. Maunder. This program is free software: you
% can redistribute it and/or modify it under the terms of the GNU General
% Public License as published by the Free Software Foundation, either
% version 3 of the License, or (at your option) any later version. This
% program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
% more details.

K = length(c);

if length(pi) ~= K
    error('pi has a different length to c');
end

filler_bits = find(isnan(c));

c(filler_bits) = 0;
c_prime = c(pi+1);

[z, x] = constituent_encoder(c);
[z_prime, x_prime] = constituent_encoder(c_prime);

d = zeros(3,K+4);

for k=0:K-1
    d(1,k+1) = x(k+1);
    d(2,k+1) = z(k+1);
    d(3,k+1) = z_prime(k+1);
end
d(1,filler_bits) = NaN;
d(2,filler_bits) = NaN;

d(1,K+1) = x(K+1);
d(2,K+1) = z(K+1);
d(3,K+1) = x(K+2);
d(1,K+2) = z(K+2);
d(2,K+2) = x(K+3);
d(3,K+2) = z(K+3);
d(1,K+3) = x_prime(K+1);
d(2,K+3) = z_prime(K+1);
d(3,K+3) = x_prime(K+2);
d(1,K+4) = z_prime(K+2);
d(2,K+4) = x_prime(K+3);
d(3,K+4) = z_prime(K+3);







