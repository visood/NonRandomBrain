type NeuroNet
	time::Float64
	size::Int # number of neurons
	#Parameters
	threshold::Float64
	rest::Float64
	delta_weight::Float64
	delta_potential::Float64 #set this to 1
        decay_weight::Float64
        decay_potential::Float64
	t_stdp::Float64 #STDP time window
	dt::Float64 #time update between firing events

	#Network data
	potential::Array{Float64, 1}
	synapses::Array{Float64, 2}
	time_fired::Array{Float64, 1}

	#Constructor
	function NeuroNet(N::Int, v0::Float64, theta::Float64, dw::Float64, dv::Float64, dkw::Float64, dkv::Float64, ts::Float64, dt::Float64, psyn::Float64)
		new(	0.0,
			N,
			theta,
			0.0,
			dw,
			dv,
			dkw,
			dkv,
			ts,
			dt,
			[ v0*rand() for i=1:N],
			reshape( [ (rand() < psyn) ? 1.0 : 0.0 for i=1:(N*N)], N, N),
			[0.0 for i=1:N]
		)
	end

	function NeuroNet(nn::NeuroNet, v0::Float64, psyn::Float64)
		N = nn.size
		syns = reshape( [ (rand() < psyn) ? 1.0 : 0.0 for i=1:(N*N)], N, N)	
		for i=1:N
			syns[i, i] = 0.0
		end
		new(	nn.time, 
			nn.size,
			nn.threshold,
			nn.rest,
			nn.delta_weight,
			nn.delta_potential,
			nn.decay_weight,
			nn.decay_potential,
			nn.t_stdp,
			nn.dt,
			[2*v0*rand() for i=1:nn.size],
			syns,
			[0.0 for i=1:nn.size]
		)
	end

end


function no_plasticity(N::Int, v0::Float64, theta::Float64, dv::Float64, dkv::Float64, dt::Float64, psyn::Float64)
	NeuroNet( N, v0, theta, 0.0, dv, 0.0, dkv, 0.0, dt, psyn)
end

		

function network_state(nn::NeuroNet, i::Int)
	a = 1*[ nn.potential[i] > nn.threshold for i=1:nn.size]
	if i > 0
		a[i] = 2
	end
	transpose(a)
end

function number_active(nn::NeuroNet)
	sum( [ nn.potential[i] > nn.threshold for i=1:nn.size] )
end

function next_firing(nn::NeuroNet)
	can_fire = filter( (i)->(nn.potential[i] > nn.threshold), 1:nn.size)
	i = -1
	input = zeros(nn.size)
	if length(can_fire) > 0
		i = can_fire[ int(floor(length(can_fire)*rand())) + 1]
		input = [ (v > nn.rest) ? v : nn.rest for v = nn.synapses[:, i]*nn.delta_potential]
		nn.synapses[i, :] += transpose(([nn.time - t < nn.t_stdp for t in nn.time_fired] - nn.decay_weight)*nn.delta_weight)
		nn.synapses[i, i] = 0.0
		nn.time_fired[i] = nn.time
		nn.potential[i] = nn.rest
	end
	nn.potential = [ (v > nn.rest) ? v : nn.rest for v=(nn.potential + input - nn.decay_potential)]
	nn.time += nn.dt
	i
end


function evolve_till(nn::NeuroNet, time::Float64)
	while(nn.time < time)
		i = next_firing(nn)
		println( int(nn.time/nn.dt), ", ", number_active(nn), ":\t", transpose([int(100*x) for x=nn.potential]))
	end
end

#some statistics on the neural net, to characterize the parameters

function survival_activity(nn::NeuroNet, time::Float64, R::Int)
	active = 0
	for i=1:R
		nnn = NeuroNet(nn, 10.0, 0.5)
		while (nnn.time < time && number_active(nnn) > 0)
			next_firing(nnn)
		end
		active += (number_active(nnn) > 0)
	end
	active
end
	

nn = no_plasticity( 10, 2.0, 1.0, 0.1, 0.01, 0.01, 1.0)

		






