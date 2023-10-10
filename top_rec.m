function b = top_rec(pref,R,bar_a)
%this function return the recommendation decision
%b is a 1XN vector with binary elements

b = zeros(1,length(pref));% is 1 only if the bundle is to be recommended.
%====top recommendation strategy======
[~,idx] = sort(pref,'descend');
To_be_rec = idx(1:R); % index of bundles that have the largest revenue
b(To_be_rec) = 1;
for i = 1:R
    if pref(To_be_rec(i)) < bar_a % Take Eq. (10) into account
        b(To_be_rec(i)) = 0;
    end
end