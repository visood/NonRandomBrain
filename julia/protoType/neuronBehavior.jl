

type Dendrite
	#parameters

	#state
	location::Cleft

	#processes
	events::Process
	
end

function receive(d::Dendrite, s::Signal)
	d.epsp = decayed(d.epsp, s.timeOrigin + s.timeTravel) + d.density
	d.time = s.timeOrigin + s.timeTravel
	afterDelay(d.events, d.propDelay) ( () -> propagate(d.epsp, d.tree) )
end


