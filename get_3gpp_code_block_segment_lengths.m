function K_r = get_3gpp_code_block_segment_lengths(B)
% GET_3GPP_CODE_BLOCK_SEGMENT_LENGTHS determines how to segment a transport
% block into code blocks, according to Section 5.1.2 of TS36.212.
%   K_r = GET_3GPP_CODE_BLOCK_SEGMENT_LENGTHS(B) determines the code block
%   lengths that result from the segmentation of a transport block having a
%   specified length.
%
%   B specifies the transport block length.
%
%   K_r will be a row vector comprising a code block length for each code
%   block.
%
% Copyright © 2018 Robert G. Maunder. This program is free software: you 
% can redistribute it and/or modify it under the terms of the GNU General 
% Public License as published by the Free Software Foundation, either 
% version 3 of the License, or (at your option) any later version. This 
% program is distributed in the hope that it will be useful, but WITHOUT 
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
% FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for 
% more details.

if B <= 0
    error('Unsupported block length');
end

supported_values_of_K = [40:8:511,512:16:1023,1024:32:2047,2048:64:6144];

Z = 6144;

if B <= Z
%    L = 0;
    C = 1;
    B_prime = B;
else
    L = 24;
    C = ceil(B/(Z-L));
    B_prime = B+C*L;
end

K_plus = min(supported_values_of_K(C*supported_values_of_K>=B_prime));

if C == 1
%    C_plus = 1;
    K_minus = 0;
    C_minus = 0;
elseif C>1
    K_minus = max(supported_values_of_K(supported_values_of_K<K_plus));
    delta_K = K_plus - K_minus;
    C_minus = floor((C*K_plus-B_prime)/delta_K);
%    C_plus = C-C_minus;
end

K_r = zeros(1,C);
for r = 0:C-1
    if r < C_minus
        K_r(r+1) = K_minus;
    else
        K_r(r+1) = K_plus;
    end
end