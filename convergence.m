%%
%This code simulates the schemes in the paper "Utility Maximization ... Diversified Recommedation"
%%
clear
clc
global M N K fnm fkm a_pref x R bar_C L_n bar_a beta uti CanBeRec

N = 15; % number of content
M = 10; % number of features (themes)
K = 20; % number of users
x = .3*ones(1,K); % Probability of accepting the recommendations
R = randi([3,5],1,K); % maximum recommendation size ones(1,K)*5;%

meansize_content = 10;

bar_C = round(meansize_content*N*.5); % size of caching entity
L_n = randi(meansize_content*2,[1,N]); % size of each content%ones(1,N);%
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

bar_a = ones(1,K)*0.01; % threshold of recommendation in Eq. (6)

beta = rand(1,K); %weight of each user in Eq. (9)
beta = beta/sum(beta)*2;

uti = rand(1,N); %the utility of each content

%=========random initialization===========
content_set = 1:N;
content_capacity = 0;
cache = zeros(1,N);
while content_capacity < bar_C
    idx = randi(length(content_set),1);
    cache(content_set(idx)) = 1;
    content_capacity = content_capacity+L_n(content_set(idx));
    content_set = setdiff(content_set,content_set(idx));
end

CanBeRec = ceil(a_pref-(bar_a'*ones(1,N))); % the indices of ones in each column is the indices of contents that can be recommended to user k

iterMax = 10;
U_record = zeros(1,2*iterMax);
for iter = 1:iterMax    
    rec = ERA(cache);
    for k = 1:K
        U_record(2*iter-1) = U_record(2*iter-1)+Utility(rec(k,:),k,cache);
    end
    a_req = (x'*ones(1,N)).*rec.*a_pref./(sum(rec.*a_pref,2)*ones(1,N))+(1-x'*ones(1,N)).*(1-rec).*a_pref./(sum((1-rec).*a_pref,2)*ones(1,N));
    [~,cache] = knapsack(L_n, sum(a_req,1).*uti, bar_C);
    for k = 1:K
        U_record(2*iter) = U_record(2*iter)+Utility(rec(k,:),k,cache);
    end
    iter
end
hold on;plot(1:2*iterMax,U_record,'-')