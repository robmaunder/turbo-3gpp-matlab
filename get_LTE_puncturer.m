% Generate the LTE puncturer as specified in ETSI TS 136 212 (search for it on Google if you like)
% Copyright (C) 2014  Robert G. Maunder

% This program is free software: you can redistribute it and/or modify it 
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your 
% option) any later version.

% This program is distributed in the hope that it will be useful, but 
% WITHOUT ANY WARRANTY; without even the implied warranty of 
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General 
% Public License for more details.

% The GNU General Public License can be seen at http://www.gnu.org/licenses/.

% K is an integer that specifies the length of the message, in the range 40 to 6144 
% E is an integer that specifies the length of the punctured turbo encoded bits, in the range 1 to 3* < 3K+12
% rv_idx is an integer that specifies the redundancy version number, in the range 0 to 3
% puncturer is a 1xE vector of unique integers in the range 1 to 3*K+12

% Suppose d = [c,z,x,z_prime,x_prime], where c is a 1xK vector of message
% bits, z is a 1xK+3 vector of upper encoded bits, x is a 1x3 vector of
% upper termination bits, z_prime is a 1xK+3 vector of lower encoded bits 
% and x_prime is a 1x3 vector of lower termination bits.

% Puncturing can be achieved according to 
% e = d(puncturer);

% Depuncturing can be achieved according to 
% d_tilde = zeros(size(d));
% d_tilde(puncturer) = e_tilde;

function puncturer = get_LTE_puncturer(K, E, rv_idx)

if nargin < 3
    rv_idx = 0;
end

if E > 3*K+12
    error('E value not supported for this value of K');
end

if isempty(find(0:3 == rv_idx,1))
    error('rv_idx value not supported');
end
    

D = K+4;

d = reshape(0:3*D-1,3,D);

d_0 = d(1,:);
d_1 = d(2,:);
d_2 = d(3,:);

% The subblock_interleaver function is defined below
v_0 = subblock_interleaver(d_0,0);
v_1 = subblock_interleaver(d_1,1);
v_2 = subblock_interleaver(d_2,2);

w = [v_0, reshape([v_1;v_2],1,2*length(v_1))];

K_w = length(w);

N_cb = K_w; % assume UL-SCH or MCH transport channels

D = length(d_0);

C_TC_subblock = 32;

R_TC_subblock = ceil(D/C_TC_subblock);

e = zeros(1,E);
k_0 = R_TC_subblock*(2*ceil(N_cb/(8*R_TC_subblock))*rv_idx+2);
k = 0;
j = 0;
while k < E
    if ~isnan(w(mod(k_0+j,N_cb)+1))
        e(k+1) = w(mod(k_0+j,N_cb)+1);
        k = k+1;
    end
    j = j+1;
end

puncturer = e;

end
    
    
    
function v = subblock_interleaver(d,superscript)

D = length(d);

C_TC_subblock = 32;

R_TC_subblock = ceil(D/C_TC_subblock);

N_D = R_TC_subblock*C_TC_subblock-D;

y = [nan(1,N_D),d];

matrix = reshape(y,C_TC_subblock,R_TC_subblock)';

P = [0 16 8 24 4 20 12 28 2 18 10 26 6 22 14 30 1 17 9 25 5 21 13 29 3 19 11 27 7 23 15 31];

K_PI = R_TC_subblock*C_TC_subblock;

if superscript < 2
    
    matrix = matrix(:,P+1);
    
    v = reshape(matrix, 1, K_PI);
    
else
    pi = mod(P(floor((0:K_PI-1)/R_TC_subblock)+1) + C_TC_subblock*mod(0:K_PI-1,R_TC_subblock)+1, K_PI);
    
    v = y(pi+1);
end

end
