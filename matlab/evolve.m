N=100;
tmax = 5000;
NDATA = 1000;
final_dat = zeros(3,NDATA);
s = rand(1,N);
data =zeros(4,tmax);
for i=1:N if( s(i) > 0.1 ) s(i) = 1.0; else s(i) =0; end; end; 
w = zeros(N,N);
g = zeros(N,N);
w = generate_graph(N);
%restart
norm = 0.0;
norm = sum(s);
n=1;
for j_th=10:10:10
for beta=0.05:0.05:0.05
s = rand(1,N);
[sfinal,wfinal,data,seq] = evolution_graph(s,w,N,tmax,norm,j_th,beta);
filename1 = sprintf('sfinal-jth%d-beta%4.3f',j_th,beta);
filename2 = sprintf('wfinal-jth%d-beta%4.3f',j_th,beta);
filename3 = sprintf('sinitial-jth%d-beta%4.3f',j_th,beta);
filename4 = sprintf('winitial-jth%d-beta%4.3f',j_th,beta);
filename5 = sprintf('data-jth%d-beta%4.3f.txt',j_th,beta);
filename6 = sprintf('final-data.dat');
sfinal = sfinal';
s = s';
save(filename1, 'sfinal', '-ASCII');
save(filename2, 'wfinal', '-ASCII');
save(filename3, 's', '-ASCII');
save(filename4, 'w', '-ASCII');
data=data';
final_dat(1,n) = j_th;
final_dat(2,n) = beta;
for i=1:tmax if(i>2000) final_dat(3,n) = final_dat(3,n) + data(i,4);end;end;
save(filename5, 'data', '-ASCII');
save(filename6, 'seq', '-ASCII');
n=n+1;
end
end
final_dat(3,:)=final_dat(3,:)/8000;
final_dat = final_dat';
save(filename6, 'final_dat', '-ASCII');

