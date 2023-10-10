function U = Utility(R_k,k,cache)
global a_pref x beta uti
a_req = x(k)*R_k.*a_pref(k,:)/sum(R_k.*a_pref(k,:))+(1-x(k))*(1-R_k).*a_pref(k,:)/sum((1-R_k).*a_pref(k,:));
U = sum(a_req.*cache.*uti)+beta(k)*diversity(R_k);