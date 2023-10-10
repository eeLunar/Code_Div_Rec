function rec = ERA(cache)
global K N CanBeRec R
rec = zeros(K,N);
for k = 1:K
    idx = find(CanBeRec(k,:)==1);
    if length(idx) > R(k)
        idx_remain = idx;
        idx_select = [];
        while length(idx_select) < R(k)
            U_rec = zeros(1,length(idx_remain));
            for i = 1:length(idx_remain)
                R_temp = zeros(1,N);
                idx_temp = union(idx_select,idx_remain(i));
                R_temp(idx_temp) = 1;
                U_rec(i) = Utility(R_temp,k,cache);
            end
            [~,idx_max] = max(U_rec);
            idx_select = union(idx_select,idx_remain(idx_max));
            idx_remain = setdiff(idx_remain,idx_remain(idx_max));
        end
        U_flag = max(U_rec);
        i_rec = [];
        j_rec = [];
        for i = 1:length(idx_remain)
            for j = 1:length(idx_select)
                idx_temp = union(setdiff(idx_select,idx_select(j)),idx_remain(i));
                R_temp = zeros(1,N);
                R_temp(idx_temp) = 1;
                U_temp = Utility(R_temp,k,cache);
                if U_temp > U_flag
                    U_flag = U_temp;
                    i_rec = i;
                    j_rec = j;
                end
            end
        end
        idx_select= union(setdiff(idx_select,idx_select(j_rec)),idx_remain(i_rec));
        rec(k,idx_select) = 1;
    else
        rec(k,idx) = 1;
    end
end