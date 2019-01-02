function c_r = code_block_segmentation(b,K_r,F,G_P)
B = length(b);
C = length(K_r);

L = size(G_P,2);
if sum(K_r) ~= C*L+F+B
    error('Block lengths do not match.');
end



c_r = cell(1,C);
for r = 0:C-1
    c_r{r+1} = zeros(1,K_r(r+1));
end


for k = 0:F-1
    c_r{1}(k+1) = NaN;
end

k = F;
s = 0;
for r = 0:C-1
    while k < K_r(r+1)-L
        c_r{r+1}(k+1) = b(s+1);
        k = k+1;
        s = s+1;
    end
    
    if C>1
        a_r = c_r{r+1}(1:K_r(r+1)-L);
        
        a_r(isnan(a_r)) = 0;
        A_r = length(a);
        p = mod(a_r*G_P(end-A_r+1,end,:),2);

        
    
    





end
