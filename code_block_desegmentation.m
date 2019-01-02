function b = code_block_desegmentation(c_r,B,G_max)
% CODE_BLOCK_DESEGMENTATION desegments a transport block from code blocks,
% removes filler bits when necessary and checks and removes Cyclic
% Redudancy Check (CRC) bits from each code block when there is more than
% one of them.
%   b = CODE_BLOCK_DESEGMENTATION(c_r,B,G_max) desegments a transport block
%   having a specified length from code blocks, removes filler bits when
%   necessary and uses a specified generator matrix to check CRC bits
%   for each code block when there is more than one of them.
%
%   c_r should be a row cell array comprising C row vectors, each
%   representing a code block, structured according to Section 5.1.2 of
%   TS36.212. More specifically, the first code block may be prepended with
%   filler bits, which should be represented by NaN. If there is more than
%   one code block, then the final L bits in each should be provided by CRC
%   bits generated using the specifed generator matrix G_max.
%
%   B specifies the transport block length. It is assumed that the
%   transport block is sufficiently long so that all filler bits are
%   contained in the first code block segment.
%
%   G_max should be a binary generator matrix for the CRC. The number of
%   rows in G_max should be at least max(K_r), while the number of columns
%   in G_max should equal the number of CRC bits to be generated for each
%   code block when there is more than one of them.
%
%   b will be a row vector comprising B transport block bits.
%
%
% Copyright © 2018 Robert G. Maunder. This program is free software: you 
% can redistribute it and/or modify it under the terms of the GNU General 
% Public License as published by the Free Software Foundation, either 
% version 3 of the License, or (at your option) any later version. This 
% program is distributed in the hope that it will be useful, but WITHOUT 
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
% FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for 
% more details.

C = length(c_r);

K_r = zeros(1,C);
for r = 0:C-1
    K_r(r+1) = length(c_r{r+1});
end

if C==1
    L = 0;
    B_prime = B;
else
    L = size(G_max,2);
    B_prime = B+C*L;
end

F = sum(K_r) - B_prime;

b = zeros(1,B);

k = F;
s = 0;
for r = 0:C-1
    while k < K_r(r+1)-L
        b(s+1) = c_r{r+1}(k+1);
        k = k+1;
        s = s+1;
    end
    
    if C>1
        a_r = c_r{r+1}(1:K_r(r+1)-L);        
        a_r(isnan(a_r)) = 0;
        
        p_r2 = calculate_crc_bits(a_r,G_max);
        
        p_r = zeros(1,L);
        while k < K_r(r+1)
            p_r(k+L-K_r(r+1)+1) = c_r{r+1}(k+1);
            k = k+1;
        end
        
        if ~isequal(p_r,p_r2)
            b = [];
            return;
        end
        
    end
    k=0;
end

end
