%%
%This code simulates Figs. 2a and 3a in the paper "Utility Maximization ... Diversified Recommedation"
%%
clear
clc
global M N K fnm fkm a_pref x R bar_C L_n bar_a beta uti CanBeRec

N = 15; % number of content
M = 10; % number of features (themes)
K = 20; % number of users
x = .9*ones(1,K); % Probability of accepting the recommendations

bar_a = rand(1,K)/100; % threshold of recommendation in Eq. (6)

beta = rand(1,K); %weight of each user in Eq. (9)
beta = beta/sum(beta)*2;
meansize_content = 10;
barC_all = 30:15:120;
rec_opt = zeros(1,length(barC_all));
rec_Hete = zeros(1,length(barC_all));
rec_Homo = zeros(1,length(barC_all));
rec_Hete_ND = zeros(1,length(barC_all));
rec_Homo_ND = zeros(1,length(barC_all));

NumberIter = 2000;
for fa = 1:length(barC_all)
    bar_C = barC_all(fa); % size of caching entity  
    for it = 1:NumberIter
        R = randi([3,5],1,K);% maximum recommendation size
        L_n = randi(meansize_content*2,[1,N]); % size of each content%meansize_content*ones(1,N);%
        % x = R.^-1;
        %=====zipf feature value=======
        zipf_fct = 2;
        zipf_dis = zipf(M,zipf_fct);
        fnm = zeros(M,N);
        for n = 1:N
            fnm(:,n) = zipf_dis(randperm(M))'; 
        end
        fnm = fnm./(ones(M,1)*sum(fnm,1)); %normalization

        %=====random user preference=======
        fkm = rand(M,K); % feature value of each user
        fkm = fkm./(ones(M,1)*sum(fkm,1)); %normalization

        a_pref = fkm'*fnm./(sqrt(sum(fkm.^2,1))'*sqrt(sum(fnm.^2,1))); % Eq. (2)

        a_pref = a_pref./(sum(a_pref,2)*ones(1,N)); %normalization, Eq. (3)

        uti = rand(1,N); %the utility of each content

        vn = (sum(a_pref,1))';%Top Cache strategy
        [~,cache] = knapsack(L_n, vn, bar_C);%at first, some contents are randomly selected for caching

        CanBeRec = ceil(a_pref-(bar_a'*ones(1,N))); % the indices of ones in each column is the indices of contents that can be recommended to user k
        
        for iter = 1:3    
            rec = ERA(cache);
            a_req = (x'*ones(1,N)).*rec.*a_pref./(sum(rec.*a_pref,2)*ones(1,N))+(1-x'*ones(1,N)).*(1-rec).*a_pref./(sum((1-rec).*a_pref,2)*ones(1,N));
            [~,cache] = knapsack(L_n, sum(a_req,1).*uti, bar_C);            
        end
        for k = 1:K
            rec_opt(fa) = rec_opt(fa)+Utility(rec(k,:),k,cache);
        end

        %========TopHomoRec TopHeteRec========
        pref_sum = sum(a_pref,1);
        for k = 1:K
            rec_k_homo = top_rec(pref_sum,R(k),bar_a(k));
            rec_k_hete = top_rec(a_pref(k,:),R(k),bar_a(k));
            rec_Homo(fa) = rec_Homo(fa)+Utility(rec_k_homo,k,cache);
            rec_Hete(fa) = rec_Hete(fa)+Utility(rec_k_hete,k,cache);
            rec_Homo_ND(fa) = rec_Homo_ND(fa)+Utility_ND(rec_k_homo,k,cache);
            rec_Hete_ND(fa) = rec_Hete_ND(fa)+Utility_ND(rec_k_hete,k,cache);
        end
        
        it
        fa
    end
    rec_opt(fa) = rec_opt(fa)/NumberIter;
    rec_Homo(fa) = rec_Homo(fa)/NumberIter;
    rec_Hete(fa) = rec_Hete(fa)/NumberIter;
    rec_Homo_ND(fa) = rec_Homo_ND(fa)/NumberIter;
    rec_Hete_ND(fa) = rec_Hete_ND(fa)/NumberIter;
end
save(sprintf('rec_Homo.mat'),'rec_Homo');
save(sprintf('rec_Hete.mat'),'rec_Hete');
save(sprintf('rec_Homo_ND.mat'),'rec_Homo_ND');
save(sprintf('rec_Hete_ND.mat'),'rec_Hete_ND');
save(sprintf('rec_opt.mat'),'rec_opt');
figure;plot(barC_all,rec_opt,'k-',barC_all,rec_Homo,'b--',barC_all,rec_Homo_ND,'r--',barC_all,rec_Hete,'b:',barC_all,rec_Hete_ND,'r:')