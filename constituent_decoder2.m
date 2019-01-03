% BCJR algorithm for a terminated unity-rate recursive convolutional code
% having 3 memory elements, a generator polynomial of [1,1,0,1] and a feedback
% polynomial of [1,0,1,1]. This is as used in the LTE turbo code, as specified in ETSI TS 136 212.
% Copyright (C) 2016  Robert G. Maunder


% apriori_uncoded_llrs is a 1x(N+3) vector of a priori uncoded LLRs
% apriori_encoded_llrs is a 1x(N+3) vector of a priori encoded LLRs
% extrinsic_uncoded_llrs is a 1x(N+3) vector of extrinsic encoded LLRs
function x_e = constituent_decoder2(x_a, z_a)

    if(length(x_a) ~= length(z_a))
        error('LLR sequences must have the same length');
    end

    % Matrix to describe the trellis
    % Each row describes one transition in the trellis
    % Each state is allocated an index 1,2,3,... Note that this list starts 
    % from 1 rather than 0.
    %               FromState,  ToState,    UncodedBit, EncodedBit
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
    gammas_uncoded = zeros(size(transitions,1),length(x_a));
    gammas_uncoded(transitions(:,3)==0,:) = repmat(x_a, sum(transitions(:,3)==0),1);
    
    gammas_encoded = zeros(size(transitions,1),length(x_a));
    gammas_encoded(transitions(:,4)==0,:) = repmat(z_a, sum(transitions(:,4)==0),1);
    
    gammas = gammas_uncoded + gammas_encoded;
    
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
    deltas = alphas(transitions(:,1),:) + betas(transitions(:,2),:) + gammas_encoded;
    
    % Calculate the uncoded extrinsic LLRs
    log_p0=maxstar(deltas(transitions(:,3) == 0,:));
    log_p1=maxstar(deltas(transitions(:,3) == 1,:));
    x_e = log_p0-log_p1;
   
 