function [distribution]=zipf(N,alpha)


summation = sum(1./(1:N).^alpha);


distribution = [1/summation,1/summation./(2:N).^alpha];


