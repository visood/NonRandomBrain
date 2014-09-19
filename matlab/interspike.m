function [s] = interspike()
d = load('data.dat');
tmax=length(d);
y = d(:,4);
n=1;
flag=0;
for i=1000:tmax
if(y(i) == 1 & flag==0)
flag =1;
last_fire=i;
end;

if(y(i)== 0 & flag==1)
s(n) = i-last_fire;
n=n+1
flag=0;
end;
end;

