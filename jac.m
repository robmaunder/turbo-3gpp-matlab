% Jacobian logarithm
% If A = log(a) and B = log(b), then log(a+b) = max(A,B) + log(1+exp(-abs(A-B)))
% Copyright (C) 2010  Robert G. Maunder

% This program is free software: you can redistribute it and/or modify it 
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your 
% option) any later version.

% This program is distributed in the hope that it will be useful, but 
% WITHOUT ANY WARRANTY; without even the implied warranty of 
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General 
% Public License for more details.

% The GNU General Public License can be seen at http://www.gnu.org/licenses/.

% A, B and C are scalar LLRs
function C = jac(A,B)

    mode = 0; % Exact Jacobian logarithm (Log-MAP)
%	mode = 1; % Jacobian logarithm using a lookup table 
%   mode = 2; % Approximate Jacobian logarithm (Max-Log-MAP)

	if(A == -inf && B == -inf)
        C = -inf;
    else
        if mode == 0;
            C = max(A,B) + log(1+exp(-abs(A-B)));
        elseif mode == 1
        
            difference = abs(A-B);
            if     difference >= 4.5
                C = max(A,B);
            elseif difference >= 2.252
                C = max(A,B) + 0.05;
            elseif difference >= 1.508
                C = max(A,B) + 0.15;
            elseif difference >= 1.05
                C = max(A,B) + 0.25;
            elseif difference >= 0.71
                C = max(A,B) + 0.35;
            elseif difference >= 0.433
                C = max(A,B) + 0.45;
            elseif difference >= 0.196
                C = max(A,B) + 0.55;
            else % difference >= 0
                C = max(A,B) + 0.65;
            end
        
        elseif mode == 2
            C = max(A,B);
        else
            error('Invalid Jacobian mode');
        end
	end
end
	