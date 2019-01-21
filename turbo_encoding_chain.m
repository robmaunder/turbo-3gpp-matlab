%TURBO_ENCODING_CHAIN Encoder for 3GPP LTE turbo code
%   TURBOENC = TURBO_ENCODING_CHAIN creates a 3GPP LTE turbo encoder system
%   object, TURBOENC. Default values are assumed for all properties, which
%   are inherited from the TURBO_CODING_CHAIN base class.
%
%   TURBOENC = TURBO_ENCODING_CHAIN(Name,Value) creates a 3GPP LTE Turbo
%   encoder system object, TURBOENC, with the specified property Name set to
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
classdef turbo_encoding_chain < turbo_coding_chain
    
    methods
        % Constructor allowing properties to be set according to e.g.
        % a = turbo_encoding_chain('A',40,'G',132);
        function obj = turbo_encoding_chain(varargin)
            setProperties(obj,nargin,varargin{:});
        end
    end    
    
  
    % Methods used to execute processing.
    methods(Access = protected)
                
        % Code executed by the step function. e.g.
        % a = turbo_coding_chain;
        % step(a); % <- stepImpl executed here
        % step(a); % <- stepImpl executed here
        % reset(a);
        % step(a); % <- stepImpl executed here
        % release(a);
        % step(a); % <- stepImpl executed here
        function f = stepImpl(obj, a)
            e_r = cell(1,obj.C);

            
            b = generate_and_append_crc_bits(a,obj.CRC_generator_matrix_TB);
            c_r = code_block_segmentation(b,obj.K_r,obj.CRC_generator_matrix_CB);            
            for r=0:obj.C-1
                d = turbo_encoder(c_r{r+1}, obj.internal_interleaver_patterns{r+1});
                
                % Perform rate matching
                d_vec = reshape(d,1,numel(d));
                e_r{r+1} = d_vec(obj.rate_matching_patterns{r+1}+1);
            end
            f = code_block_concatenation(e_r);
        end
        
    end
    
    
end
