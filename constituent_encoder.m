function [z, x] = constituent_encoder(c)
% CONSTITUENT_ENCODER encodes a code block using a terminated unity-rate
% recursive convolutional code having 3 memory elements, a generator
% polynomial of [1,1,0,1] and a feedback polynomial of [1,0,1,1], as
% specified in Section 5.1.3.2.1 and 5.1.3.2.2 of TS36.212.
%   [z, x] = CONSTITUENT_ENCODER(c) encodes a code block, in order to
%   obtain a sequence of systematic and termination bits, as well as a
%   sequence of encoded bits.
%
%   c should be a row vector, comprising the K bits of a code block.
%
%   z will be a row vector, comprising K+3 encoded bits.
%
%   x will be a row vector, comprising K systematic bits, appended with 3
%   termination bits.
%
% Copyright © 2018 Robert G. Maunder. This program is free software: you
% can redistribute it and/or modify it under the terms of the GNU General
% Public License as published by the Free Software Foundation, either
% version 3 of the License, or (at your option) any later version. This
% program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
% more details.

K = length(c);

% Initialise our output bit vectors
z = zeros(1,K+3);
x = zeros(1,K+3);

% We start in the all-zeros state
s1 = 0;
s2 = 0;
s3 = 0;

% Encode the uncoded bit sequence
for k = 0:K-1
    
    % Determine the next state
    s1_plus = mod(c(k+1)+s2+s3, 2); % This uses the feedback polynomial
    s2_plus = s1;
    s3_plus = s2;
    
    % Determine the systematic bit
    x(k+1) = c(k+1);
    
    % Determine the encoded bit
    z(k+1) = mod(s1_plus+s1+s3, 2); % This uses the generator polynomial
    
    % Enter the next state
    s1 = s1_plus;
    s2 = s2_plus;
    s3 = s3_plus;
end

% Terminate the convolutional code
for k = K:K+2
    
    % Determine the next state
    s1_plus = 0; % During termination, zeros are clocked into the shift register
    s2_plus = s1;
    s3_plus = s2;
    
    % Determine the termination bit
    x(k+1) = mod(s2+s3, 2); % This uses the feedback polynomial
    % Determine the encoded bit
    z(k+1) = mod(s1_plus+s1+s3, 2); % This uses the generator polynomial
    
    % Enter the next state
    s1 = s1_plus;
    s2 = s2_plus;
    s3 = s3_plus;
end

end