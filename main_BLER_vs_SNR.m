function main_BLER_vs_SNR(A, max_iterations, approx_maxstar, target_block_errors, target_BLER, EsN0_start, EsN0_delta, seed)
% MAIN_BLER_VS_SNR Plots Block Error Rate (BLER) versus Signal to Noise
% Ratio (SNR) for turbo codes.
%   main_BLER_vs_SNR(A, L, min_sum, target_block_errors, target_BLER, EsN0_start, EsN0_delta, seed)
%   generates the plots.
%
%   A should be an integer row vector. Each element specifies the number of
%   bits in each set of simulated information bit sequences, before CRC and
%   other redundant bits are included.
%
%   max_iterations should be a row vector. Each element specifies a
%   different maximum number of iterations to characterise the BLER for.
%   The elements should be multiples of 0.5, which allows an odd number of
%   half iterations to be performed.
%
%   approx_maxstar should be a scalar logical. If it is true, then the
%   Log-BCJR decoding process will be completed using the approximate
%   maxstar operation. Otherwise, the exact maxstar operation will be used.
%   The exact maxstar operation gives better error correction capability
%   than the approximate maxstar operation, but it has higher complexity.
%
%   target_block_errors should be an integer scalar. The simulation of each
%   SNR for each coding rate will continue until this number of block
%   errors have been observed. A value of 100 is sufficient to obtain
%   smooth BLER plots for most values of A. Higher values will give
%   smoother plots, at the cost of requiring longer simulations.
%
%   target_BLER should be a real scalar, in the range (0, 1). The
%   simulation of each coding rate will continue until the BLER plot
%   reaches this value.
%
%   EsN0_start should be a real row vector, having the same length as the
%   vector of coding rates. Each value specifies the Es/N0 SNR to begin at
%   for the simulation of the corresponding coding rate.
%
%   EsN0_delta should be a real scalar, having a value greater than 0.
%   The Es/N0 SNR is incremented by this amount whenever
%   target_block_errors number of block errors has been observed for the
%   previous SNR. This continues until the BLER reaches target_BLER.
%
%   seed should be an integer scalar. This value is used to seed the random
%   number generator, allowing identical results to be reproduced by using
%   the same seed. When running parallel instances of this simulation,
%   different seeds should be used for each instance, in order to collect
%   different results that can be aggregated together.
%
% Copyright © 2018 Robert G. Maunder. This program is free software: you
% can redistribute it and/or modify it under the terms of the GNU General
% Public License as published by the Free Software Foundation, either
% version 3 of the License, or (at your option) any later version. This
% program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
% more details.

% Default values
if nargin == 0
    A = [8, 16, 32, 64];
    max_iterations = 0:0.5:6;
    approx_maxstar = true;
    target_block_errors = 10;
    target_BLER = 1e-1;
    EsN0_start = -10;
    EsN0_delta = 0.5;
    seed = 0;
end

global approx_star;
approx_star = approx_maxstar;

max_iterations = sort(max_iterations);

% Seed the random number generator
rng(seed);

crc_polynomial = get_3gpp_crc_polynomial('CRC16');
G_max = get_crc_generator_matrix(6144, crc_polynomial);
L = size(G_max,2);


% Consider each information block length in turn
for A_index = 1:length(A)
    
    B = A(A_index)+L;
    
    K_r = get_3gpp_code_block_segment_lengths(B);
    
    pi = get_3gpp_lte_interleaver(K_r);
    
    % Create a figure to plot the results.
    figure
    axes1 = axes('YScale','log');
    title(['LTE turbo code, A = ',num2str(A(A_index)),', Approx maxstar = ',num2str(approx_maxstar),', errors = ',num2str(target_block_errors),', QPSK, AWGN']);
    ylabel('BLER');
    xlabel('E_s/N_0 [dB]');
    ylim([target_BLER,1]);
    hold on
    
    plots = zeros(size(max_iterations));
    % Consider each encoded block length in turn
    for max_iterations_index = 1:length(max_iterations)
        % Create the plot
        plots(max_iterations_index) = plot(nan,'Parent',axes1);
    end
    legend(cellstr(num2str(max_iterations', '%0.1f its')),'Location','southwest');
    drawnow
    
    % Counters to store the number of bits and errors simulated so far
    block_counts=[];
    block_error_counts=[];
    EsN0s = [];
    
    % Initialise the BLER and SNR
    BLER = 1;
    EsN0 = EsN0_start;
    
    found_start = false;
    
    % Loop over the SNRs
    while BLER > target_BLER
        
        % Convert from SNR (in dB) to noise power spectral density
        N0 = 1/(10^(EsN0/10));
        
        % Start new counters
        block_counts(end+1) = 0;
        block_error_counts(:,end+1) = zeros(length(max_iterations),1);
        EsN0s(end+1) = EsN0;
        
        keep_going = true;
        
        % Continue the simulation until enough block errors have been simulated
        while keep_going && block_error_counts(end,end) < target_block_errors
            
            % Generate a random block of bits
            a = round(rand(1,A(A_index)));
            
            b = generate_and_append_crc_bits(a, G_max);
            
            c = code_block_segmentation(b, K_r);
            
            % Perform polar encoding
            d = turbo_encoder(c{1},pi);
            
            e = reshape(d,[1,numel(d)]);
            f = e(~isnan(e));
            
            % QPSK modulation
            f2 = [f,zeros(1,mod(-length(f),2))];
            tx = sqrt(1/2)*(2*f2(1:2:end)-1)+1i*sqrt(1/2)*(2*f2(2:2:end)-1);
            
            % Simulate transmission
            rx = tx + sqrt(N0/2)*(randn(size(tx))+1i*randn(size(tx)));
            
            % QPSK demodulation
            f2_tilde = zeros(size(f2));
            f2_tilde(1:2:end) = -4*sqrt(1/2)*real(rx)/N0;
            f2_tilde(2:2:end) = -4*sqrt(1/2)*imag(rx)/N0;
            f_tilde = f2_tilde(1:length(f));
            
            e_tilde = NaN(size(e));
            e_tilde(~isnan(e)) = f_tilde;
            d_tilde = reshape(e_tilde,size(d));
            
            
            
            % Perform polar decoding
            [c{1}, iterations_performed] = turbo_decoder(d_tilde, pi, max(max_iterations),G_max);
            
            b = code_block_desegmentation(c, B);
            
            a_hat = check_and_remove_crc_bits(b, G_max);
            
            if found_start == false && ~isequal(a,a_hat)
                keep_going = false;
                BLER = 1;
            else
                found_start = true;
                
                % Determine if we have a block error
                if ~isequal(a,a_hat)
                    block_error_counts(:,end) = block_error_counts(:,end) + 1;
                else
                    block_error_counts(max_iterations < iterations_performed,end) = block_error_counts(max_iterations < iterations_performed,end) + 1;
                end
                
                % Accumulate the number of blocks that have been simulated
                % so far
                block_counts(end) = block_counts(end) + 1;
                
                % Calculate the BLER and save it in the file
                BLER = block_error_counts(end,end)/block_counts(end);
                
                % Plot the BLER vs SNR results
                for max_iterations_index = 1:length(max_iterations)
                    set(plots(max_iterations_index),'XData',EsN0s);
                    set(plots(max_iterations_index),'YData',block_error_counts(max_iterations_index,:)./block_counts);
                end
                drawnow
            end
        end
        
%         if BLER < 1
%             fprintf(fid,'%f\t%e\n',EsN0,BLER);
%         end
%         
        % Update the SNR, ready for the next loop
        EsN0 = EsN0 + EsN0_delta;
        
    end
    
    
    
    
%     % Open a file to save the results into.
%     filename = ['results/BLER_vs_SNR_',code,'_',num2str(A(A_index)),'_',num2str(E(E_index)),'_',num2str(L),'_',num2str(min_sum),'_',num2str(target_block_errors),'_',num2str(seed)];
%     fid = fopen([filename,'.txt'],'w');
%     if fid == -1
%         error('Could not open %s.txt',filename);
%     end
%     
%     
%     % Close the file
%     fclose(fid);
end
end




