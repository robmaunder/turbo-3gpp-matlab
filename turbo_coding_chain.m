%TURBO_CODING_CHAIN Base class for 3GPP LTE turbo coding chain objects
%   This base class cannot be used to perform the processing of any turbo
%   coding, but it can be used to setup all turbo coding parameters. This
%   may be inherited by derived classes that can perform the processing of
%   turbo coding.
%
%   Copyright © 2018 Robert G. Maunder. This program is free software: you
%   can redistribute it and/or modify it under the terms of the GNU General
%   Public License as published by the Free Software Foundation, either
%   version 3 of the License, or (at your option) any later version. This
%   program is distributed in the hope that it will be useful, but WITHOUT
%   ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
%   FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
%   for more details.
classdef turbo_coding_chain < matlab.System
    
    % Once the step function has been called, the values of nontunable
    % properties can only be changed if the release function is called
    % first.
    properties(Nontunable)
        
        %A Number of information bits in the transport block
        A = 16; % Default value
        
        %I_LBRM Enable limited buffer rate matching
        %   Specifies whether or not a limit is imposed upon the length of the
        %   circular buffer used for rate matching, as defined in Section 5.4.2.1
        %   of TS38.212. A full buffer is used if I_LBRM = 0 and a limited buffer
        %   is used otherwise.
        I_LBRM = 0; % Default value
        
        %N_IR Circular buffer limit
        %   Specifies limit imposed upon the lenghth of the circular buffer
        %   used for rate matching, when I_LBRM is non-zero. N_IR is
        %   ignored when I_LBRM is zero.
        N_IR = inf; % Default value
    end
    
    % Tunable properties can be changed anytime, even after the step
    % function has been called.
    properties
        
        %RV_IDX Redundancy version number
        %   Specifies the redundancy version number, as defined in Section
        %   5.1.4.2.2 of TS36.212. rv_idx is tunable so that it can be
        %   changed for successive retransmissions during HARQ.
        rv_idx = 0; % Default value
        
        %G Number of encoded bits for the transport block
        %   Specifies the number of encoded bits in the output bit sequence. G is tunable
        %   so that it can be changed for successive retransmissions during HARQ.
        G = 132; % Default value
        
        %N_L Number of layers
        %   For transmit diversity N_L is equal to 2, otherwise N_L is
        %   equal to the number of layers a transport block is mapped onto, as
        %   defined in Section 5.1.4.1.2 of TS36.212.
        N_L = 1; % Default value
        
        %Q_M Modulation order
        %   Q_M is equal to 1 for pi/2-BPSK, 2 for QPSK, 4 for 16QAM, 6 for
        %   64QAM, 8 for 256QAM, and 10 for 1024QAM, as
        %   defined in Section 5.1.4.1.2 of TS36.212.
        Q_m = 1; % Default value
    end
    
    % Protected dependent properties cannot be set manually. Instead, they
    % are calculated automatically as functions of the non-dependent
    % properties.
    properties(Dependent, SetAccess = protected)
        
        %CRC_POLYNOMIAL_TB Cyclic Redundancy Check (CRC) polynomial
        %   Specifies the polynomial used when appending a CRC to the
        %   transport block, as defined in Section 5.1.1 of TS36.212.
        CRC_polynomial_TB
        
        %CRC_POLYNOMIAL_CB Cyclic Redundancy Check (CRC) polynomial
        %   Specifies the polynomial used when appending a CRC to each
        %   code block, as defined in Section 5.1.2 of TS36.212.
        CRC_polynomial_CB
        
        L_TB
        L_CB
        
        %B Number of bits in the transport block when concatenated with the
        % transport block CRC.
        B
        
        %C Number of code block segments
        C
        
        %B_prime Number of bits in the transport block when concatenated with the
        % transport block CRC and any code block CRCs.
        B_prime
        
        %K_r Number of information and CRC bits in each of the C code block
        %segments
        K_r
        
        %F_r Number of filler bits in each of the C code block
        %segments
        F_r
        
        %D_r Number of encoded bits in each of the three turbo code outputs
        %in each of the C code block segments
        D_r
        
        %F_r Number of encoded bits in each of the C code block
        %segments
        E_r
        
        %N_REF Circular buffer limit
        %   Specifies limit imposed upon the lenghth of the circular buffer used
        %   for rate matching. N_ref is ignored when I_LBRM is zero.
        N_ref
        
    end
    
    properties(SetAccess = protected, Hidden)
        CRC_generator_matrix_TB
        CRC_generator_matrix_CB        
        internal_interleaver_patterns
        rate_matching_patterns
    end
       
    % Methods used to set and get the values of properties.
    methods
        
        % Constructor allowing properties to be set according to e.g.
        % a = NRLDPC('BG',1,'K_prime_minus_L',20,'E',132);
        function obj = turbo_coding_chain(varargin)
            setProperties(obj,nargin,varargin{:});
        end
        
        function set.A(obj, A)
            if A < 0
                error('A should not be negative.');
            end
            obj.A = A;
        end
        
        function set.N_IR(obj, N_IR)
            if N_IR < 0
                error('N_IR should not be negative.');
            end
            obj.N_IR = N_IR;
        end
        
        % Valid values of rv_idx are described in Section 5.4.2.1 of
        % TS38.212.
        function set.rv_idx(obj, rv_idx)
            if rv_idx < 0 || rv_idx > 3
                error('ldpc_3gpp_matlab:UnsupportedParameters','Valid values of rv_idx are 0, 1, 2 and 3.');
            end
            obj.rv_idx = rv_idx;
        end
        
        function set.G(obj, G)
            if G < 0
                error('G should not be negative.');
            end
            obj.G = G;
        end
        
        function set.N_L(obj, N_L)
            if N_L < 1
                error('N_L should be no less than 1.');
            end
            obj.N_L = N_L;
        end
        
        % Valid values of Q_m are defined in Section 5.1.4.1.2 of TS36.212.
        function set.Q_m(obj, Q_m)
            if isempty(find([1,2,4,6,8,10] == Q_m, 1))
                error('Q_m should be selected from the set {1, 2, 4, 6, 8, 10}.');
            end
            obj.Q_m = Q_m;
        end
        
        function CRC_polynomial_TB = get.CRC_polynomial_TB(obj)
            CRC_polynomial_TB = get_3gpp_crc_polynomial('CRC24A');
        end
        
        % Code block CRC is only used when there is more than one code
        % block, as specified in Section 5.1.2 of TS36.212.
        function CRC_polynomial_CB = get.CRC_polynomial_CB(obj)
            if obj.C > 1
                CRC_polynomial_CB = get_3gpp_crc_polynomial('CRC24B');
            else
                CRC_polynomial_CB = 1;
            end
        end
        
        function L_TB = get.L_TB(obj)
            L_TB = length(obj.CRC_polynomial_TB)-1;
        end
        
        function L_CB = get.L_CB(obj)
            L_CB = length(obj.CRC_polynomial_CB)-1;
        end
        
        % The calculation of B is specified in Section 5.1.1 of TS36.212.
        function B = get.B(obj)
            B = obj.A + obj.L_TB;
        end
        
        function C = get.C(obj)
            C = length(obj.K_r);
        end
        
        % The calculation of B_prime is specified in Section 5.1.2 of TS36.212.
        function B_prime = get.B_prime(obj)
            Z = 6144;           
            if obj.B <= Z
                B_prime = obj.B;
            else
                B_prime = obj.B+obj.C*obj.L_CB;
            end
        end
        
        function K_r = get.K_r(obj)
            K_r = get_3gpp_code_block_segment_lengths(obj.B);
        end

        % The calculation of F is specified in Section 5.1.2 of TS36.212.
        function F_r = get.F_r(obj)
            F_r = zeros(1,obj.C);            
            F_r(1) = sum(obj.K_r) - obj.B_prime;
        end        
        
        % The calculation of D can be inferred from Section 5.1.3.2.2 of TS36.212.        
        function D_r = get.D_r(obj)
            D_r = obj.K_r+4;
        end
        
        function E_r = get.E_r(obj)
            E_r = get_3gpp_encoded_code_block_segment_lengths(obj.G, obj.C, obj.N_L, obj.Q_m);
        end
        
        % The calculation of N_ref is specified in Section 5.1.4.1.2 of TS36.212.        
        function N_ref = get.N_ref(obj)
            N_ref = floor(obj.N_IR/obj.C);
        end
    end
    
    % Methods used to execute processing.
    methods(Access = protected)
        
        % Code executed on the first time that the step function is called,
        % or the first time after the release function is called. e.g.
        % a = turbo_coding_chain;
        % step(a); % <- setupImpl executed here
        % step(a); % <- setupImpl not executed here
        % reset(a);
        % step(a); % <- setupImpl not executed here
        % release(a);
        % step(a); % <- setupImpl executed here
        function setupImpl(obj)
            
            obj.CRC_generator_matrix_TB = get_crc_generator_matrix(obj.A, obj.CRC_polynomial_TB);
            
            if obj.C > 1
                obj.CRC_generator_matrix_CB = get_crc_generator_matrix(6144, obj.CRC_polynomial_CB);
            end
            
            obj.internal_interleaver_patterns = cell(1,obj.C);
            for r = 0:obj.C-1
                obj.internal_interleaver_patterns{r+1} = internal_interleaver(0:obj.K_r(r+1)-1);
            end
            
            obj.processTunedPropertiesImpl;
        end
        
        
        % Code executed when step function is called after changing the
        % value of a tunable property.
        function processTunedPropertiesImpl(obj)
            obj.rate_matching_patterns = cell(1,obj.C);
            for r = 0:obj.C-1
                d = reshape(0:3*obj.D_r(r+1)-1,3,obj.D_r(r+1));
                d(1:2,1:obj.F_r(r+1)) = NaN;
                obj.rate_matching_patterns{r+1} = rate_matching(d, obj.N_ref, obj.I_LBRM, obj.rv_idx, obj.E_r(r+1));
            end
        end
        
        % Code executed by the step function. e.g.
        % a = turbo_coding_chain;
        % step(a); % <- stepImpl executed here
        % step(a); % <- stepImpl executed here
        % reset(a);
        % step(a); % <- stepImpl executed here
        % release(a);
        % step(a); % <- stepImpl executed here
        function e = stepImpl(obj, a)
            e = a;
        end
       
        
        
    end
end
