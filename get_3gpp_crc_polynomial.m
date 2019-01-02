function crc_polynomial = get_3gpp_crc_polynomial(CRC)
% GET_3GPP_CRC_POLYNOMIAL Obtain a Cyclic Redudancy Check (CRC) generator 
% polynomial as a binary vector.
%   crc_polynomial = GET_3GPP_CRC_POLYNOMIAL(CRC) obtains a CRC
%   generator polynomial, as specified in Section 5.1.1 of TS36.212.
%
%   CRC should be a string selected from the set 'CRC24A', 'CRC24B',
%   'CRC16' and 'CRC8'.
%
%   crc_polynomial will be a binary row vector comprising P+1
%   number of bits, each having the value 0 or 1. These bits parameterise a
%   Cyclic Redundancy Check (CRC) comprising P bits. Each bit provides the
%   coefficient of the corresponding element in the CRC generator
%   polynomial. From left to right, the bits provide the coefficients for
%   the elements D^P, D^P-1, D^P-2, ..., D^2, D, 1.
%
% Copyright © 2018 Robert G. Maunder. This program is free software: you 
% can redistribute it and/or modify it under the terms of the GNU General 
% Public License as published by the Free Software Foundation, either 
% version 3 of the License, or (at your option) any later version. This 
% program is distributed in the hope that it will be useful, but WITHOUT 
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
% FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for 
% more details.

% CRC exponents, as specified in Section 5.1.1 of TS36.212
if strcmp(CRC, 'CRC24A')
    exponents = [24,23,18,17,14,11,10,7,6,5,4,3,1,0];
elseif strcmp(CRC, 'CRC24B')
    exponents = [24,23,6,5,1,0];
elseif strcmp(CRC, 'CRC16')
    exponents = [16,12,5,0];
elseif strcmp(CRC, 'CRC8')
    exponents = [8,7,4,3,1,0];
else
    error('CRC is unsupported');
end

crc_polynomial = zeros(1,max(exponents)+1);
crc_polynomial(exponents+1) = 1;
crc_polynomial = fliplr(crc_polynomial);