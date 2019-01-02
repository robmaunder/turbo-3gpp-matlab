function b = generate_and_append_crc_bits(a, G_P)
% GENERATE_AND_APPEND_CRC_BITS generates and appends Cyclic Redudancy Check
% (CRC) bits to an information bit sequence.
%   b = GENERATE_AND_APPEND_CRC_BITS(a, G_P) uses a specified generator
%   matrix to generate CRC bits for an information bit sequence and appends
%   them.
%
%   a should be a row vector comprising A information bits.
%
%   G_P should be an A by L binary generator matrix for the CRC, where L is
%   the number of CRC bits to be generated.
%
%   b will be a row vector comprising B=A+L bits, formed by appending the
%   sequence of L CRC bits onto the end of the sequence of A information
%   bits.
%
% Copyright © 2018 Robert G. Maunder. This program is free software: you 
% can redistribute it and/or modify it under the terms of the GNU General 
% Public License as published by the Free Software Foundation, either 
% version 3 of the License, or (at your option) any later version. This 
% program is distributed in the hope that it will be useful, but WITHOUT 
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
% FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for 
% more details.

A = length(a);
L = size(G_P,2);
B = A+L;

% Calculate the CRC bits
p = mod(a*G_P,2);

% Implemented according to Section 5.1.1 of TS36.212
b = zeros(1,B);
for k = 0:A-1
    b(k+1) = a(k+1);
end
for k=A:A+L-1
    b(k+1) = p(k-A+1);
end
    