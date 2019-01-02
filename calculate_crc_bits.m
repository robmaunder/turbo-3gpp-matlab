function p = calculate_crc_bits(a,G_max)
% CALCULATE_CRC_BITS calculates Cyclic Redudancy Check (CRC) bits for a
% specified information bit sequence.
%   b = CALCULATE_CRC_BITS(a, G_max) uses a specified generator
%   matrix to calculate CRC bits for a specified information bit sequence.
%
%   a should be a row vector comprising A information bits.
%
%   G_max should be a binary generator matrix for the CRC. The number of
%   rows in G_max should be at least A, while the number of columns in
%   G_max should equal the number of CRC bits to be generated.
%
%   p will be a row vector comprising L CRC bits.
%
% Copyright © 2018 Robert G. Maunder. This program is free software: you 
% can redistribute it and/or modify it under the terms of the GNU General 
% Public License as published by the Free Software Foundation, either 
% version 3 of the License, or (at your option) any later version. This 
% program is distributed in the hope that it will be useful, but WITHOUT 
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
% FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for 
% more details.

G = G_max(end-length(a)+1:end,:);

p = mod(a*G,2);
