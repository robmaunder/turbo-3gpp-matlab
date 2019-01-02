function a = check_and_remove_crc_bits(b, G_max)
% CHECK_AND_REMOVE_CRC_BITS checks and removes Cyclic Redudancy Check
% (CRC) bits that have been appended to an information bit sequence.
%   a = CHECK_AND_REMOVE_CRC_BITS(b, G_max) uses a specified generator
%   matrix to check the CRC bits appended to an information bit sequence
%   and removes them if the check is successful.
%
%   b should be a row vector comprising B = A+L bits, where A is the number
%   of information bits and L is the number of appended CRC bits.
%
%   G_max should be a binary generator matrix for the CRC. The number of
%   rows in G_max should be at least A, while the number of columns in
%   G_max should equal the number of CRC bits to be generated.
%
%   If the CRC check is successful, then a will be a row vector comprising
%   the A information bits. If the CRC check is unsuccessful, then a will
%   be an empty vector.
%
% Copyright © 2018 Robert G. Maunder. This program is free software: you 
% can redistribute it and/or modify it under the terms of the GNU General 
% Public License as published by the Free Software Foundation, either 
% version 3 of the License, or (at your option) any later version. This 
% program is distributed in the hope that it will be useful, but WITHOUT 
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
% FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for 
% more details.

B = length(b);
L = size(G_max,2);
A = B-L;

% Extract the information and CRC bits
a = b(1:A);
p = b(A+1:A+L);

% Recalculate the CRC bits
p2 = calculate_crc_bits(a, G_max);

% Check the CRC bits and reset a if the check fails
if ~isequal(p,p2)
    a = [];
end

    