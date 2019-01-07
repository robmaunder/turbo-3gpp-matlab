function f = code_block_concatenation(e_r)
% CODE_BLOCK_CONCATENATION concatenates encoded codes blocks to obtain an
% encoded transport block, as described in Section 5.1.5 of TS36.212.
%   f = CODE_BLOCK_CONCATENATION(e_r) concatenates the specified encoded
%   code blocks to obtain an encoded transport block.
%
%   e_r should be a row cell array comprising C row vectors, each
%   representing an encoded code block having a length E_r.
%
%   f will be a row vector comprising G encoded transport bits, where G is
%   the sum of E_r.
%
% Copyright © 2018 Robert G. Maunder. This program is free software: you 
% can redistribute it and/or modify it under the terms of the GNU General 
% Public License as published by the Free Software Foundation, either 
% version 3 of the License, or (at your option) any later version. This 
% program is distributed in the hope that it will be useful, but WITHOUT 
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
% FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for 
% more details.


C = length(e_r);
E_r = zeros(1,C);
for r = 0:C-1
    E_r(r+1) = length(e_r{r+1});
end
G = sum(E_r);

f = zeros(1,G);

k=0;
r=0;
while r < C
    j=0;
    while j < E_r(r+1)
        f(k+1) = e_r{r+1}(j+1);
        k = k+1;
        j = j+1;
    end
    r = r+1;
end
        