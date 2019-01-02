function [K_r,F,L] = get_3gpp_code_block_segment_lengths(B)

if B <= 0
    error('Unsupported block length');
end

supported_values_of_K = [40:8:511,512:16:1023,1024:32:2047,2048:64:6144];

Z = 6144;

if B <= Z
    L = 0;
    C = 1;
    B_prime = B;
else
    L = 24;
    C = ceil(B/(Z-L));
    B_prime = B+C*L;
end

K_plus = min(supported_values_of_K(C*supported_values_of_K>=B_prime));

if C == 1
    C_plus = 1;
    K_minus = 0;
    C_minus = 0;
elseif C>1
    K_minus = max(supported_values_of_K(supported_values_of_K<K_plus));
    delta_K = K_plus - K_minus;
    C_minus = floor((C*K_plus-B_prime)/delta_K);
    C_plus = C-C_minus;
end

F = C_plus*K_plus+C_minus*K_minus-B_prime;

K_r = zeros(1,C);
for r = 0:C-1
    if r < C_minus
        K_r(r+1) = K_minus;
    else
        K_r(r+1) = K_plus;
    end
end