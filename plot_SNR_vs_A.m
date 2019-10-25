function plot_SNR_vs_A(A, R, rv_idx_sequence, max_iterations, approx_maxstar, target_block_errors, target_BLER, EsN0_start, EsN0_delta, seed)
% PLOT_SNR_VS_A Plots Block Error Rate (BLER) versus Signal to Noise
% Ratio (SNR) for turbo codes.
%   plot_BLER_vs_SNR(A, R, rv_idx_sequence, iterations, target_block_errors, target_BLER, EsN0_start, EsN0_delta, seed)
%   generates the plots.
%
%   A should be an integer row vector. Each element specifies the number of
%   bits in each set of simulated information bit sequences, before CRC and
%   other redundant bits are included.
%
%   R should be a real row vector. Each element specifies a coding rate to
%   simulate.
%
%   rv_idx_sequence should be an integer row vector. Each element should be
%   in the range 0 to 3. The length of the vector corresponds to the
%   maximum number of retransmissions to attempt. Each element specifies
%   the rv_idx to use for the corresponding retransmission.
%
%   max_iterations specifies how many decoding iterations to perform. It
%   should be a multiple of 0.5, which allows an odd number of half
%   iterations to be performed.
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
    A = [40,50];
    R = [1/2,1/3];
    rv_idx_sequence = [0];
    max_iterations = 8;
    approx_maxstar = true;
    target_block_errors = 10;
    target_BLER = 1e-1;
    EsN0_start = -10;
    EsN0_delta = 0.5;
    seed = 0;
end

% Seed the random number generator
rng(seed);

global approx_star;
approx_star = approx_maxstar;

% Create a figure to plot the results.
figure
axes1 = axes;
title(['3GPP LTE Turbo code, iterations = ',num2str(max_iterations),', RVs = ',num2str(length(rv_idx_sequence)),', approx = ',num2str(approx_maxstar),', QPSK, AWGN, errors = ',num2str(target_block_errors)]);
ylabel('Required E_s/N_0 [dB]');
xlabel('A');
grid on
hold on
drawnow


for R_index = 1:length(R)
    
    
    
    % Create the plot
    plots(R_index) = plot(nan,'Parent',axes1);
    set(plots(R_index),'XData',A);
    legend(cellstr(num2str(R(1:R_index)', 'R=%0.2f')),'Location','eastoutside');
    
    % Open a file to save the results into.
    filename = ['results/SNR_vs_A_',num2str(target_BLER),'_',num2str(R(R_index)),'_',num2str(max_iterations),'_',num2str(target_block_errors),'_',num2str(seed)];
    fid = fopen([filename,'.txt'],'w');
    if fid == -1
        error('Could not open %s.txt',filename);
    end
    
    EsN0s = nan(1,length(A));
    
    % Consider each information block length in turn
    for A_index = 1:length(A)
        
        % Skip any encoded block lengths that generate errors
        try
            
            G = round(A(A_index)/R(R_index));
            
            
            hEnc = turbo_encoding_chain('A',A(A_index),'G',G,'Q_m',2);
            hDec = turbo_decoding_chain('A',A(A_index),'G',G,'Q_m',2,'I_HARQ',1,'iterations',max_iterations);
            
            found_start = false;
            
            

                % Initialise the BLER and SNR
                BLER=1;
                prev_BLER = nan;
                EsN0 = EsN0_start-EsN0_delta;
                
                
                
                
                % Loop over the SNRs
                while BLER > target_BLER
                    prev_EsN0 = EsN0;
                    EsN0 = EsN0 + EsN0_delta;

                    % Convert from SNR (in dB) to noise power spectral density
                    N0 = 1/(10^(EsN0/10));
                    
                    % Start new counters
                    block_error_count = 0;
                    block_count = 0;
                    
                    keep_going = true;
                    
                    % Continue the simulation until enough block errors have been simulated
                    while keep_going && block_error_count < target_block_errors
                        
                        a = round(rand(1,A(A_index)));
                        
                        a_hat = [];
                        rv_idx_index = 1;
                        reset(hDec); % Reset the incremental redundancy buffer
                        
                        while isempty(a_hat) && rv_idx_index <= length(rv_idx_sequence)
                            
                            hEnc.rv_idx = rv_idx_sequence(rv_idx_index);
                            hDec.rv_idx = rv_idx_sequence(rv_idx_index);
                            
                            f = hEnc(a);
                            
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
                            
                            
                            [a_hat, iterations_performed] = hDec(f_tilde);
                            
                            rv_idx_index = rv_idx_index + 1;
                        end
                        
                        if found_start == false && ~isequal(a,a_hat)
                            keep_going = false;
                            
                            block_error_count = 1;
                            block_count = 1;
                        else
                            found_start = true;
                            
                            
                            % Determine if we have a block error
                            if ~isequal(a, a_hat)
                                block_error_count = block_error_count+1;
                            end
                            
                            % Accumulate the number of blocks that have been simulated
                            % so far
                            block_count = block_count+1;
                            
                            
                            
                            %                         % Determine if we have a block error
                            %                         if ~isequal(a,a_hat)
                            %                             block_error_counts(:,end) = block_error_counts(:,end) + 1;
                            %                         else
                            %                             block_error_counts(max_iterations < max(iterations_performed),end) = block_error_counts(max_iterations < max(iterations_performed),end) + 1;
                            %                         end
                            %
                            %                         % Accumulate the number of blocks that have been simulated
                            %                         % so far
                            %                         block_counts(end) = block_counts(end) + 1;
                            
                            %                         % Calculate the BLER and save it in the file
                            %                         BLER = block_error_counts(end,end)/block_counts(end);
                            %
                            %                         % Plot the BLER vs SNR results
                            %                         for max_iterations_index = 1:length(max_iterations)
                            %                             set(plots(max_iterations_index),'XData',EsN0s);
                            %                             set(plots(max_iterations_index),'YData',block_error_counts(max_iterations_index,:)./block_counts);
                            %                         end
                            %                         drawnow
                        end
                    end
                    
                    prev_BLER = BLER;
                    BLER = block_error_count/block_count;
                    
                    
                    %                 if BLER < 1
                    %                     fprintf(fid, '%f',EsN0);
                    %                     for max_iterations_index = 1:length(max_iterations)
                    %                         fprintf(fid,'\t%e',block_error_counts(max_iterations_index,end)/block_counts(end));
                    %                     end
                    %                     fprintf(fid,'\n');
                    %                 end
                    
                    
                end
                
                
                % Use interpolation to determine the SNR where the BLER equals the target
                EsN0s(A_index) = interp1(log10([prev_BLER, BLER]),[prev_EsN0,EsN0],log10(target_BLER));
                
                % Plot the SNR vs A results
                set(plots(R_index),'YData',EsN0s);
                
                xlim auto;
                xl = xlim;
                xlim([floor(xl(1)), ceil(xl(2))]);
                
                drawnow;
                
                fprintf(fid,'%d\t%f\n',A(A_index),EsN0s(A_index));
                
            
        catch ME
            if strcmp(ME.identifier, 'turbo_3gpp_matlab:UnsupportedParameters')
                warning('turbo_3gpp_matlab:UnsupportedParameters','The requested combination of parameters is not supported. %s', getReport(ME, 'basic', 'hyperlinks', 'on' ));
                continue
            else
                rethrow(ME);
            end
        end
        
        
        
        
    end
    %   Close the file
    fclose(fid);
end




