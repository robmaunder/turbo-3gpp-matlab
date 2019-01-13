%NRLDPC Base class for 3GPP New Radio LDPC objects
%   This base class cannot be used to perform the processing of any LDPC
%   coding, but it can be used to setup all LDPC coding parameters. This
%   may be inherited by derived classes that can perform the processing of
%   LDPC coding.
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
        
        %K_PRIME_MINUS_L Number of information bits
        %   If we are considering the LDPC coding of a transport block that is not
        %   long enough to be decomposed into two or more code blocks, then the
        %   number of information bits in the transport block is given by A, as
        %   defined in Sections 6.2.1 and 6.3.1 of TS38.212. If we are considering
        %   one of the code blocks within a transport block that is long enough to
        %   be decomposed into two or more code blocks, then the number of
        %   information bits in the code block is given by K'-L, as defined in
        %   Section 5.2.2 of TS38.212.
        A = 16; % Default value
        
        %I_LBRM Enable limited buffer rate matching
        %   Specifies whether or not a limit is imposed upon the lenghth of the
        %   circular buffer used for rate matching, as defined in Section 5.4.2.1
        %   of TS38.212. A full buffer is used if I_LBRM = 0 and a limited buffer
        %   is used otherwise.
        I_LBRM = 0; % Default value
        
        N_IR = inf; % Default value
    end
    
    % Tunable properties can be changed anytime, even after the step
    % function has been called.
    properties
        
        %RV_ID Redundancy version number
        %   Specifies the redundancy version number, as defined in Section 5.4.2.1
        %   of TS38.212. rv_idx is tunable so that it can be changed for successive
        %   retransmissions during HARQ.
        rv_idx = 0; % Default value
        
        %E Number of encoded bits
        %   Specifies the number of encoded bits in the output bit sequence after
        %   rate matching, as defined in Section 5.4.2.1 of TS38.212. E is tunable
        %   so that it can be changed for successive retransmissions during HARQ.
        G = 132; % Default value
        
        N_L = 1; % Default value
        
        Q_m = 1; % Default value
    end
    
    % Protected dependent properties cannot be set manually. Instead, they
    % are calculated automatically as functions of the non-dependent
    % properties.
    properties(Dependent, SetAccess = protected)
        
        %CRCPOLYNOMIAL Cyclic Redundancy Check (CRC) polynomial
        %   Specifies the polynomial used when appending a CRC to the information
        %   bits, as defined in Section 5.1 of TS38.212.
        CRC_polynomial_TB
        CRC_polynomial_CB
        
        L_TB
        L_CB
        
        B
        
        C
        
        B_prime
        
        K_r
        
        F_r
        
        D_r
        
        E_r
        
        %N_REF Circular buffer limit
        %   Specifies limit imposed upon the lenghth of the circular buffer used
        %   for rate matching, when I_LBRM is non-zero, as defined in Section
        %   5.4.2.1 of TS38.212. N_ref is ignored when I_LBRM is zero.
        N_ref = 132; % Default value
        
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
        
        function set.Q_m(obj, Q_m)
            if isempty(find([1,2,4,6,8,10] == Q_m, 1))
                error('Q_m should be selected from the set {1, 2, 4, 6, 8, 10}.');
            end
            obj.Q_m = Q_m;
        end
        
        function CRC_polynomial_TB = get.CRC_polynomial_TB(obj)
            CRC_polynomial_TB = get_3gpp_crc_polynomial('CRC24A');
        end
        
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
        
        function B = get.B(obj)
            B = obj.A + obj.L_TB;
        end
        
        function C = get.C(obj)
            C = length(obj.K_r);
        end
        
        function B_prime = get.B_prime(obj)
            B_prime = obj.B+obj.C*obj.L_CB;
        end
        
        function K_r = get.K_r(obj)
            K_r = get_3gpp_code_block_segment_lengths(obj.B);
        end

        function F_r = get.F_r(obj)
            F_r = zeros(1,obj.C);            
            F_r(1) = sum(obj.K_r) - obj.B_prime;
        end        
        
        function D_r = get.D_r(obj)
            D_r = obj.K_r+4;
        end
        
        function E_r = get.E_r(obj)
            E_r = get_3gpp_encoded_code_block_segment_lengths(obj.G, obj.C, obj.N_L, obj.Q_m);
        end
        
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
