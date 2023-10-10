function V = diversity(R_k)
global fnm
idx = find(R_k==1);
V = 0;
if length(idx)>=2
    for i = 1:length(idx)-1
        for j = i+1:length(idx)
            V = V+(1-fnm(:,idx(i))'*fnm(:,idx(j))/(norm(fnm(:,idx(i)))*norm(fnm(:,idx(j)))));
        end
    end
end