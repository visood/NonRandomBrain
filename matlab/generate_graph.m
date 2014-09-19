function [w] = generate_graph(N)
w=zeros(N,N);
for i=1:N
    for j=1:N
	if(i ~= j)
	w(i,j) = 20*randn+100.0;
        end
    end
end
