function c = maxstar(a,b)
% MAXSTAR    Jacobian logarithm.
%   c = MAXSTAR(a,b) outputs a matrix c, obtained as an element-wise
%   Jacobian logarithm of the elements of the matrices a and b, which are
%   required to have the same dimensions.
%
%   c = MAXSTAR(a) outputs a row vector c, where each element is obtained
%   as the Jacobian logarithm of the elements in the corresponding column
%   of the matrix a.
%
%   If the global variable approx_star is set to true, then MAXSTAR behaves
%   as MAX.
%
% Copyright © 2018 Robert G. Maunder. This program is free software: you 
% can redistribute it and/or modify it under the terms of the GNU General 
% Public License as published by the Free Software Foundation, either 
% version 3 of the License, or (at your option) any later version. This 
% program is distributed in the hope that it will be useful, but WITHOUT 
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
% FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for 
% more details.

global approx_star;

if nargin == 2
    if approx_star
        c = max(a,b);
    else
        sub = a-b;
        sub(isnan(sub)) = 0;       
        c = max(a,b) + log(1+exp(-abs(sub)));
    end
else
    if approx_star
        c = max(a);
    else
        c = a(1,:);
        for index = 2:size(a,1)        
            sub = c-a(index,:);
            sub(isnan(sub)) = 0;       
            c = max(c,a(index,:)) + log(1+exp(-abs(sub)));
        end
    end
end