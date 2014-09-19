import Base.show
using Base.Collections


##############################  Process  ###########################################

type Event
	time::Float64
	action::Function
end

type DelayedEvent
	deltaTime::Float64
	action::Function
end

type Process
	time::Float64
	events::PriorityQueue{Event, Float64}
	running::Bool

	function Process(t::Float64)
		Process(t, PriorityQueue{Event,Float64}(), false)
	end
	function Process()
		Process(0.0, PriorityQueue{Event, Float64}(), false)
	end
		
end

function insertEvent(p::Process, ev::Event)
	p[ev] = ev.time
end

function afterDelay(p::Process, dt::Float64)
	(f::Function) -> insertEvent(p, Event(p.time + dt))
end

function nextEvent(p::Process)
	if running 
		event = dequeue!(p)
		p.time = event.time
		event.action()
	end
end

function run(p::Process)
	p.running = true
	nextEvent(p)
end

#########################################################################

####################### Things with behavior ############################
abstract TimeDependent

type ExpDecaying <: TimeDependent
	value::Float64
	rate::Float64
	time::Float64
end

decayed(v::ExpDecaying, t::Float64) = ExpDecaying( v.value*exp(-v.rate*(t - v.time)), v.rate, t )
incremented(v::ExpDecaying, d::Float64) = ExpDecaying(v.value - d, v.rate, v.time)

type Signal
	value::Float64
	timeOrigin::Float64
	timeTravel::Float64
end

#######################################################################################################




abstract Transmitter
abstract Receptor

function receive(r::Receptor, s::Signal) 
end

function transmit(t::Transmitter, s::Signal)
end

type Cleft
	filled::Bool
	transmitter::Transmitter
	receptor::Receptor
end

filled(c::Cleft) = Cleft(true, c.transmitter, c.receptor)

across(c::Cleft, s::Signal) = receive(c.receptor, s)

type Terminal <: Transmitter
	location::Cleft
	loaded::Boolean
end

loaded(t::Terminal) = Terminal(t.location, true)

function transmit(t::Terminal, s::Signal) 
	if t.loaded 
		across(t.location, s)
	end
end

abstract AbstractNeuron

function excite(n::AbstractNeuron, s::Signal)
end
function propagate(s::Signal, n::AbstractNeuron)
end


type Dendrite <: Receptor
	#parameters
	thetaPoten::Float64
	propDelay::Float64

	#state
	location::Cleft
	density::ExpDecaying
	epsp::ExpDecaying
	nmdaOpen::Bool
	tree::AbstractNeuron
end

function receive(d::Dendrite, s::Signal)
	d.epsp = decayed(d.epsp, s.timeOrigin + s.timeTravel) + d.density
	propagate(Signal(d.epsp, s.timeOrigin + s.timeTravel, d.propDelay), d.tree)
end

function backReceive(d::Dendrite, s::Signal)
	d.epsp = decayed(d.epsp, s.time) + s.value
end

propagate(s::Signal, n::Neuron) = excite(n, s )

function potentiate(d::Dendrite, s::Signal)
	if d.epsp > d.thetaPoten
		d.density = decayed(d.density, s.timeOrigin + s.timeTravel) + s.value
	end
end


type Neuron <: AbstractNeuron
	#Parameters
	theta::Float64
	propDelay::Float64
	backPoten::Float64
	backDelay::Float64
	densityUpgrade::Float64
	upgradeDelay::Float64
	actionEPSP::Float64
	actionDelay::Float64

	#state
	time::Float64
	potential::ExpDecaying
	axonalTerminals::Array{Terminal, 1}
	dendrites::Array{Dendrite, 1}
	process::Process
end

willFire(n) = n.potential >= n.theta 

function excite(n::Neuron, s::Signal)
	potential = decayed(potential, s.timeOrigin + s.timeTravel) + s.value
	n.time = s.timeOrigin + s.timeTravel
	if willFire(n)
		fire(n)
	end
end

function backPropagate(n::Neuron)
	for d=n.dendrites
		backReceive(d, Signal(n.backPoten, n.time, backDelay))
	end
	for d=n.dendrites
		potentiate(d, Signal(n.densityUpgrade, n.time, upgradeDelay))
	end
end

function fire(n::Neuron)
	for t=n.axonalTerminals
		transmit(t, Signal( actionEPSP, n.time, n.actionDelay))
	end
	potential = 0.0
	backPropagate(n)
end






