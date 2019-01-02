function c_r = code_block_segmentation(b,K_r,G_max)
% CODE_BLOCK_SEGMENTATION segments a transport block into code blocks,
% prepends filler bits when necessary and generates and appends Cyclic
% Redudancy Check (CRC) bits to each code block when there is more than one
% of them.
%   c_r = CODE_BLOCK_SEGMENTATION(b,K_r,G_max) segments a transport block
%   into code blocks having specified lengths, prepends filler bits when
%   necessary and uses a specified generator matrix to generate CRC bits
%   for each code block when there is more than one of them.
%
%   b should be a row vector comprising B transport block bits. It is
%   assumed that b is sufficiently long so that all filler bits are
%   contained in the first code block segment.
%
%   K_r should be a row vector comprising a desired length for each of the
%   C code blocks. 
%
%   G_max should be a binary generator matrix for the CRC. The number of
%   rows in G_max should be at least max(K_r), while the number of columns
%   in G_max should equal the number of CRC bits to be generated for each
%   code block when there is more than one of them.
%
%   c_r will be a row cell array comprising C row vectors, each
%   representing a code block having a length specified by the
%   corresponding element of K_r. The bits of b will be distributed among
%   the code blocks according to Section 5.1.2 of TS36.212. More
%   specifically, the first code block may be prepended with filler bits,
%   which will be represented by NaN. If there is more than one code block,
%   then the final L bits in each will be provided by CRC bits generated
%   using the specifed generator matrix G_max.
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
C = length(K_r);

if C==1
    L = 0;
    B_prime = B;
else
    L = size(G_max,2);
    B_prime = B+C*L;
end

F = sum(K_r) - B_prime;

c_r = cell(1,C);
for r = 0:C-1
    c_r{r+1} = zeros(1,K_r(r+1));
end

for k = 0:F-1
    c_r{1}(k+1) = NaN;
end

k = F;
s = 0;
for r = 0:C-1
    while k < K_r(r+1)-L
        c_r{r+1}(k+1) = b(s+1);
        k = k+1;
        s = s+1;
    end
    
    if C>1
        a_r = c_r{r+1}(1:K_r(r+1)-L);        
        a_r(isnan(a_r)) = 0;
        
        p_r = calculate_crc_bits(a_r,G_max);
        
        while k < K_r(r+1)
            c_r{r+1}(k+1) = p_r(k+L-K_r(r+1)+1);
            k = k+1;
        end
    end
    k=0;
end

end
