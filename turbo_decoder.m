function [c, iterations_performed] = turbo_decoder(d_a, pi, max_iterations, G_max) 
% TURBO_DECODER decodes a code block using a turbo code, as
% specified in Section 5.1.3.2 of TS36.212.
%   c = TURBO_DECODER(d_a, pi, max_iterations) decodes a code block, using a specified
%   interleaver pattern and a fixed number of decoding iterations.
%
%   [c, iterations_performed] = TURBO_DECODER(d_a, pi, max_iterations,
%   G_max) decodes a code block, using a specified interleaver pattern and
%   a CRC-aided early termination.
%
%   d should be a matrix of encoded Logarithmic Likelihood Ratios (LLRs),
%   comprising 3 rows and K+4 columns. LLRs should be expressed in the form
%   LLR = ln[Pr(bit = 0)/Pr(bit = 1)].
%
%   pi should be a row vector of length K, containing unique indices in the range
%   0 to K-1, arranged according to the turbo code interleaver pattern,
%   such that interleaving can be achieved according to c_prime = c(pi+1);
%
%   max_iterations specifies the number of iterations to peform when early
%   termination is disabled, or specifies the maximum number of iterations
%   to perform when early termination is enabled.
%
%   c will be a row vector, comprising the K decoded bits of a code block.
%   Note that even when employing early termination, c is not guaranteed to
%   have a passing CRC.
%
%   iterations_performed specifies the number of iterations performed,
%   which may be lower than max_iterations when early termination is
%   enabled.
%
% Copyright © 2018 Robert G. Maunder. This program is free software: you
% can redistribute it and/or modify it under the terms of the GNU General
% Public License as published by the Free Software Foundation, either
% version 3 of the License, or (at your option) any later version. This
% program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
% more details.


K = size(d_a,2)-4;
if size(d_a,1) ~= 3
    error('d_a should have 3 rows');
end
if length(pi) ~= K
    error('length of pi does not match K');
end
if max_iterations ~= round(2*max_iterations)/2
    error('iterations must be a multiple of 0.5');
end


filler_bits = find(isnan(d_a(1,:)));

d_a(isnan(d_a)) = inf;

c_a = zeros(1,K);
x_a = zeros(1,K+3);
z_a = zeros(1,K+3);
x_prime_a = zeros(1,K+3);
z_prime_a = zeros(1,K+3);


z_a(1:K) = d_a(2,1:K);
z_prime_a(1:K) = d_a(3,1:K);

x_a(K+1) = d_a(1,K+1);
z_a(K+1) = d_a(2,K+1);
x_a(K+2) = d_a(3,K+1);
z_a(K+2) = d_a(1,K+2);
x_a(K+3) = d_a(2,K+2);
z_a(K+3) = d_a(3,K+2);
x_prime_a(K+1) = d_a(1,K+3);
z_prime_a(K+1) = d_a(2,K+3);
x_prime_a(K+2) = d_a(3,K+3);
z_prime_a(K+2) = d_a(1,K+4);
x_prime_a(K+3) = d_a(2,K+4);
z_prime_a(K+3) = d_a(3,K+4);

c = d_a(1:K) < 0; % a posteriori hard decision
if nargin == 4
    p = calculate_crc_bits(c,G_max);
    if sum(p) == 0
        iterations_performed = 0;
        c(filler_bits) = NaN;
        return;
    end
end
    

for iteration_index = 1:ceil(max_iterations)
    
    x_a(1:K) = c_a + d_a(1,1:K); % Systematic a priori
    x_e = constituent_decoder(x_a, z_a); % Upper decoder
    c_e = x_e(1:K) + d_a(1,1:K); % Systematic a priori
    c = (c_a + c_e) < 0; % a posteriori hard decision

    if nargin == 4
        p = calculate_crc_bits(c,G_max);
        if sum(p) == 0
            iterations_performed = iteration_index-0.5;
            c(filler_bits) = NaN;
            return;
        end
    end
       
    if iteration_index <= floor(max_iterations) % Disable last half-iteration when 2*iterations is odd   
        x_prime_a(1:K) = c_e(pi+1); % Interleaver
        x_prime_e = constituent_decoder(x_prime_a, z_prime_a); % Lower decoder
        c_a(pi+1) = x_prime_e(1:K); % Deinterleaver        
        c = (c_a + c_e) < 0; % a posteriori hard decision
        
        if nargin == 4
            p = calculate_crc_bits(c,G_max);
            if sum(p) == 0
                iterations_performed = iteration_index;
                c(filler_bits) = NaN;
                return;
            end
        end
    end  
end

iterations_performed = max_iterations;
c(filler_bits) = NaN;