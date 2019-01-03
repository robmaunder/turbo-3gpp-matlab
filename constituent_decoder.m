function x_e = constituent_decoder(x_a, z_a)
% CONSTITUENT_DECODER Log-BCJR decodes a code block using a terminated unity-rate
% recursive convolutional code having 3 memory elements, a generator
% polynomial of [1,1,0,1] and a feedback polynomial of [1,0,1,1], as
% specified in Section 5.1.3.2.1 and 5.1.3.2.2 of TS36.212.
%   x_e = CONSTITUENT_DECODER(x_a, z_a) decodes a code block by combining a
%   sequence of a priori systematic Logarithmic Likelihood Ratios (LLRs)
%   with a sequence of a priori encoded LLRs, in order to obtain a sequence
%   of extrinsic systematic LLRs. LLRs should be expressed in the form
%   LLR = ln[Pr(bit = 0)/Pr(bit = 1)].
%
%   x_a should be a row vector, comprising K+3 a priori systematic and
%   termination LLRs.
%
%   z_a should be a row vector, comprising K+3 a priori encoded LLRs.
%
%   x_e will be a row vector, comprising K+3 extrinsic systematic and
%   termination LLRs.
%
% Copyright © 2018 Robert G. Maunder. This program is free software: you
% can redistribute it and/or modify it under the terms of the GNU General
% Public License as published by the Free Software Foundation, either
% version 3 of the License, or (at your option) any later version. This
% program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
% more details.

    if(length(x_a) ~= length(z_a))
        error('LLR sequences must have the same length');
    end

    % Matrix to describe the trellis
    % Each row describes one transition in the trellis
    % Each state is allocated an index 1,2,3,... Note that this list starts 
    % from 1 rather than 0.
    %               FromState,  ToState,    x,          z
    transitions =  [1,          1,          0,          0; 
                    2,          5,          0,          0; 
                    3,          6,          0,          1; 
                    4,          2,          0,          1; 
                    5,          3,          0,          1; 
                    6,          7,          0,          1; 
                    7,          8,          0,          0; 
                    8,          4,          0,          0; 
                    1,          5,          1,          1; 
                    2,          1,          1,          1; 
                    3,          2,          1,          0; 
                    4,          6,          1,          0; 
                    5,          7,          1,          0; 
                    6,          3,          1,          0; 
                    7,          4,          1,          1; 
                    8,          8,          1,          1];
               
    % Find the largest state index in the transitions matrix           
    % In this example, we have eight states since the code has three memory elements
    state_count = max(max(transitions(:,1)),max(transitions(:,2)));

    % Calculate the a priori transition log-probabilities
    gammas_x = zeros(size(transitions,1),length(x_a));
    gammas_x(transitions(:,3)==1,:) = repmat(-x_a, sum(transitions(:,3)==1),1);
    
    gammas_z = zeros(size(transitions,1),length(z_a));
    gammas_z(transitions(:,4)==1,:) = repmat(-z_a, sum(transitions(:,4)==1),1);
    
    gammas = gammas_x + gammas_z;
    
    % Recursion to calculate forward state log-probabilities
    alphas=zeros(state_count,length(x_a));
    alphas(2:end,1)=-inf; % We know that these are not the first state
    for bit_index = 2:length(x_a)        
        temp = alphas(transitions(:,1),bit_index-1)+gammas(:,bit_index-1);
        for state_index = 1:state_count
            alphas(state_index,bit_index) = maxstar(temp(transitions(:,2) == state_index));
        end
    end
    
    % Recursion to calculate backward state log-probabilities
    betas=zeros(state_count,length(x_a));
    betas(2:end,end)=-inf; % We know that these are not the final state
    for bit_index = length(x_a)-1:-1:1
        temp = betas(transitions(:,2),bit_index+1)+gammas(:,bit_index+1);
        for state_index = 1:state_count
            betas(state_index,bit_index) = maxstar(temp(transitions(:,1) == state_index));
        end
    end

    % Calculate a posteriori transition log-probabilities
    deltas = alphas(transitions(:,1),:) + betas(transitions(:,2),:) + gammas_z;
      
    % Calculate the uncoded extrinsic LLRs
    log_p0=maxstar(deltas(transitions(:,3) == 0,:));
    log_p1=maxstar(deltas(transitions(:,3) == 1,:));
    x_e = log_p0-log_p1;
   
 