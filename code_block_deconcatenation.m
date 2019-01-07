function e_r = code_block_deconcatenation(f, E_r)
% CODE_BLOCK_DECONCATENATION deconcatenates encoded codes blocks from an
% encoded transport block.
%   e_r = CODE_BLOCK_DECONCATENATION(f, E_r) deconcatenates encoded code
%   blocks having specified lengths from the specified encoded transport
%   block.
%
%   f should be a row vector comprising G encoded transport bits.
%
%   E_r should be a row vector, comprising C elements, each of which
%   specified an encoded block length, which should sum together to give G.
%
%   e_r will be a row cell array comprising C row vectors, each
%   representing an encoded code block having a length E_r.
%
% Copyright © 2018 Robert G. Maunder. This program is free software: you 
% can redistribute it and/or modify it under the terms of the GNU General 
% Public License as published by the Free Software Foundation, either 
% version 3 of the License, or (at your option) any later version. This 
% program is distributed in the hope that it will be useful, but WITHOUT 
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
% FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for 
% more details.

G = length(f);
if G ~= sum(E_r)
    error('E_r should sum together to give G.');
end

C = length(E_r);

e_r = cell(1,C);
for r = 0:C-1
    e_r{r+1} = zeros(1,E_r(r+1));
end

k=0;
r=0;
while r < C
    j=0;
    while j < E_r(r+1)
        e_r{r+1}(j+1) = f(k+1);
        k = k+1;
        j = j+1;
    end
    r = r+1;
end
        