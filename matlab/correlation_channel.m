function [corr,eig_values,largest,large_vec] = correlation_channel()
load 'sample_MEG_data'
N=length(MEG_from_fif(1,1).data)
NC = 303;
corr = zeros(NC,NC);
d = zeros(N,NC);
ave = zeros(1,NC);
var = zeros(1,NC);
for i=1:NC d(:,i) = MEG_from_fif(:,i).data; end;
d = d*1e12;
for i=1:NC ave(i) = sum(d(:,i))/N;end;

for i=1:NC
for j=1:NC
corr(i,j) = (d(:,i)-ave(i))'*(d(:,j)-ave(j));
end;
end;
corr = corr/N;
eig_values = eig(corr);
[large_vec,largest] = eigs(corr);


