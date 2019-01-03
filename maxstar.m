function c = maxstar(a,b)

global approx_star;

if nargin == 2
    if approx_star
        c = max(a,b);
    else
        sub = a-b;
        sub(isnan(sub)) = 0;       
        c = max(a,b) + log(1+exp(-abs(sub)));
    end
else
    if approx_star
        c = max(a);
    else
        c = a(1,:);
        for index = 2:size(a,1)        
            sub = c-a(index,:);
            sub(isnan(sub)) = 0;       
            c = max(c,a(index,:)) + log(1+exp(-abs(sub)));
        end
    end
end