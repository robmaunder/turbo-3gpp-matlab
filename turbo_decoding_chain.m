%TURBO_DECODING_CHAIN Decoder for 3GPP LTE turbo code
%   TURBODEC = TURBO_DECODING_CHAIN creates a 3GPP LTE turbo decoder system
%   object, TURBODEC. Default values are assumed for all properties, which
%   are inherited from the TURBO_CODING_CHAIN base class.
%
%   TURBODEC = TURBO_DECODING_CHAIN(Name,Value) creates a 3GPP LTE Turbo
%   decoder system object, TURBODEC, with the specified property Name set to
%   the specified Value. You can specify additional name-value pair
%   arguments in any order as (Name1,Value1,...,NameN,ValueN).
%
%   Copyright © 2018 Robert G. Maunder. This program is free software: you
%   can redistribute it and/or modify it under the terms of the GNU General
%   Public License as published by the Free Software Foundation, either
%   version 3 of the License, or (at your option) any later version. This
%   program is distributed in the hope that it will be useful, but WITHOUT
%   ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
%   FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
%   for more details.
classdef turbo_decoding_chain < turbo_coding_chain
    
    properties(Nontunable)
        %I_HARQ Enable Hybrid Automatic Repeat reQuest (HARQ)
        %   Specifies whether or not successive blocks of input LLRs are assumed to
        %   be retransmissions of the same information block. When I_HARQ = 0, it
        %   is assumed that successive blocks of input LLRs correspond to different
        %   information blocks. In this case, the blocks of input LLRs are decoded
        %   independently. When I_HARQ ~= 0, the successive blocks of input LLRs
        %   are assumed to be retransmissions of the same information block. In
        %   this case the successive blocks of input LLRs are accumulated in an
        %   internal buffer, before they are processed by the turbo decoder core.
        %   The internal buffer may be reset using the reset method, when the
        %   retransmission of a particular information block is completed, allowing
        %   the transmission of another information block.
        I_HARQ = 0; % Default value
    end
    
    properties
        %ITERATIONS Number of decoding iterations
        %   Specifies the number of decoding iterations performed during
        %   turbo decoding.
        iterations = 8; % Default value
    end
    
    properties(DiscreteState)
        %BUFFER Internal buffer used to accumulate input LLRs during HARQ
        %   When I_HARQ ~= 0, successive blocks of input LLRs are assumed to be
        %   retransmissions of the same information block. In this case the
        %   successive blocks of input LLRs are accumulated in this internal
        %   buffer, before they are processed by the turbo decoder core. The
        %   internal buffer may be reset using the reset method, when the
        %   retransmission of a particular information block is completed, allowing
        %   the transmission of another information block.
        buffers
    end
    
    methods
        % Constructor allowing properties to be set according to e.g.
        % a = turbo_decoding_chain('A',40,'G',132);
        function obj = NRLDPCDecoder(varargin)
            setProperties(obj,nargin,varargin{:});
        end
    end
    
    methods(Access = protected)
        
        function setupImpl(obj)
            setupImpl@turbo_coding_chain(obj);
            obj.buffers = cell(1,obj.C);
            for r=0:obj.C-1
                obj.buffers{r+1} = zeros(3,obj.D_r(r+1));
            end
        end
        
        function a = stepImpl(obj, f)
            
            e_r = code_block_deconcatenation(f, obj.E_r);
            
            c_r = cell(1, obj.C);
            for r = 0:obj.C-1
                
                % Perform rate dematching
                d_vec = zeros(1,3*obj.D_r(r+1));
                for k = 0:length(obj.rate_matching_patterns{r+1})-1
                    d_vec(obj.rate_matching_patterns{r+1}(k+1)+1) = d_vec(obj.rate_matching_patterns{r+1}(k+1)+1) + e_r{r+1}(k+1);
                end
                d = reshape(d_vec,3,obj.D_r(r+1));
                d(1:2,1:obj.F_r(r+1)) = NaN;
                
                % Perform turbo decoding
                if obj.I_HARQ == 0
                    if obj.C > 1
                        % Use the code block CRC for early termination
                        c_r{r+1} = turbo_decoder(d, obj.internal_interleaver_patterns{r+1}, obj.iterations, obj.CRC_generator_matrix_CB);
                    else
                        % Use the transport block CRC for early termination
                        c_r{r+1} = turbo_decoder(d, obj.internal_interleaver_patterns{r+1}, obj.iterations, obj.CRC_generator_matrix_TB);
                    end
                else
                    % Accumulate the HARQ buffer
                    obj.buffers{r+1} = obj.buffers{r+1} + d;
                                       
                    if obj.C > 1
                        % Use the code block CRC for early termination
                        c_r{r+1} = turbo_decoder(obj.buffers{r+1}, obj.internal_interleaver_patterns{r+1}, obj.iterations, obj.CRC_generator_matrix_CB);
                    else
                        % Use the transport block CRC for early termination
                        c_r{r+1} = turbo_decoder(obj.buffers{r+1}, obj.internal_interleaver_patterns{r+1}, obj.iterations, obj.CRC_generator_matrix_TB);
                    end
                end
            end
            
            b = code_block_desegmentation(c_r,obj.B,obj.CRC_generator_matrix_CB);
            
            if ~isempty(b)
                a = check_and_remove_crc_bits(b, obj.CRC_generator_matrix_TB);
            else
                a = [];
            end
            
        end
        
        function resetImpl(obj)
            for r=0:obj.C-1
                obj.buffers{r+1} = zeros(3,obj.D_r(r+1));
            end
        end
        
    end
end
