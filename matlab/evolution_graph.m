function [s,w,data,seq] = evolution_graph(s,w,N,tmax,norm,j_th,beta)

%definition of the parameters
scaled_j=0.0;
seq = zeros(tmax,N);
data = zeros(4,tmax);
jth = zeros(1,N);
deltaW1 = 0.01;
deltaW2 = 0.05;
current = 0.2;
delta2=0;
overlap = 0;
p = 0;
scaleF=0.0;
for iter=1:1
s = rand(1,N);
p=rand;
for i=1:N if(s(i)>0.5) s(i) =1; else s(i) =0; end;end;
%norm = sum(w*s')/(N*N);
norm = j_th
for i=1:N jth(i) = 50; end
for t=1:tmax
snew = zeros(1,length(s));
jyt = w*s';
%sum(jyt)
%for i=1:N jth(i) = 1.0/sum(jyt); end

%update of the state

for n=1:N
rand_num = rand; 
prob = 1/(1+exp(-beta*(jyt(n)-jth(n))));
if(prob >= rand_num)
snew(n)=1;
else
snew(n)=0; 
end
end
 
%snew
%update of the weight
for i=1:N
for j=1:N
if(i ~= j)
delta1 = w(j,i)*deltaW1*snew(j)*s(i); 
delta2 = - w(j,i)*snew(i)*s(j)*deltaW2;
w(j,i) = w(j,i) + delta1+delta2;

if(w(j,i)<0)
w(j,i)=0;
end

end
end
end
overlap = snew*s';
s = snew;
scaled_j = sum(jyt)/N;
%I_0 = current*cos(2*3.14159*0.01*t);
I_0= current;
scaleF = (1.0+I_0/(scaled_j)+0.5*(norm-scaled_j)/scaled_j);
w = scaleF*w;

%print the time
seq(t,:) = s;
data(1,t) = t;
data(2,t) = sum(sum(w));
data(3,t) = sum(jyt);
data(4,t) = sum(s);
end
iter
end
