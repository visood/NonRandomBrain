package learn.neuroscience
import scala.util.{Random => rand}
import scala.math._


/**
  * Lets first describe the elements and processes,
  * while going into too much detail,
  * to understand deeply the elements and the processes interlinking them 
  * One thing we have to understand is if the element is stateful
  */

  /**
    * What two elements can effect each other is determined
    * by where they are
    * Location can be a physical location, or an abstract 
    * And it can contain signals
    */

  def michaelisMenton(vmax: Double, Km: Double, h: Double = 1.0) ( s: Double): Double = {
    val x = pow(s/Km, h)
    vmax*x/(1 + x)
  }
  def logistic(theta: Double, scale: Double)(x: Double): Double = {
    val y = (x - theta)/scale
    1/(1 + exp(-x))
  }

  trait Location {
    private var signals: Map[Signal, Double]

    def input(ss: (Signal, Double) *): (Signal, Double) = {
      ss.groupBy(_._1).mapValues(_.map(_._2).sum)
    }

    def add(s: (Signal, Double)): Unit = {
      signals = signals.updated(s._1, signals.getOrElse(s._1, 0.0) + s._2)
    }
  }

  /**
    * a neuron receives signals at its axon,
    * but what are these signals?
    */
  trait Signal

  /**
    * An axon is not a unit element
    * It releases transmitters at its terminals
    * These transmitters are contained in vesicles
    * which are modeled as non-stateful values
    * a Vesicle should burst to release a Signal
    */

  trait Vesicle {
    def contents: Signal
    def intensity: Double
    def burst: (Signal, Double) = (contents, intensity)
  }
  /**
    * Each axon terminal is defined by its location,
    * and contains vesicles
    */

  trait Terminal extends Simulation {
    val location: Location
    private var vesicles: List[Vesicle]

    def release: Unit =  {
      vesicles foreach( location.add(_.burst) )
      //location.pool( vesicles.map(_.burst) )
      vesicles = Nil
    }

    /**
      * process of replenishment of terminals should be under the Neuron's  or Axon's control
    def replenish(v: Vesicle): Unit = replenishRates foreach{ 
      case (signal, rate) =>  afterDelay( timeDelay(rate) ) { newVesicle( signal )(this) } 
    }
    */

    def add(v: Vesicle): Unit = {
      vesicles = v :: vesicles
    }
  }

  /**
    * Now we can define an axon
    * Again stateful, an axon can have a variable list of terminals
    */

  trait Axon {
    private var terminals: List[Terminal]

    val rateVesicleReplenish: Map[Signal, Double]

    val sizeVesicle: Map[Signal, Double]

    def newVesicle(s: Signal, x: Double): Vesicle

    val rateTransport: Map[Terminal, Double]

    def terminalForVesicle(v: Vesicle): Terminal

    def replenish: Unit = {
      rateVesicleReplenish foreach { 
        case (s, r) => {
          val v = newVesicle(s, sizeVesicle(s))
          afterDelay( timeDelay(r) ) { terminalForVesicle(v).add(v) }
        }
      }
    }


  }

/**
  * A dendrite should be a leaf on a tree, that receives excitations from 
  * outside the tree, propagating them up
  */
  trait Dendtree {
    val down: List[Dendtree]
    val up: Dendtree
    val propDelay: Double
    private var timeUpdated: Double
    private var potential: Double


    def backProp(v: Double): Unit = {
      down.foreach{ afterDelay(propDelay) { _.backProp(v) } }
    }

    def propagate: Unit {
      up.polarize(potential)
      potential = 0.0
    }

    def polarize(v: Double): Unit {
      potential += v
      //timeUpdated = time
      afterDelay( -propDelay*log(rand.nextDouble)){ propagate }
    }


  }

  trait Soma extends Dendtree {
    val up = this
    val propDelay = 0.0

    override def propagate: Unit {}

    override def polarize(v: Double): Unit = {
      potential += v
      timeUpdated = time
    }

  }


  trait Dendrite extends Dendtree {
    val down: List[Dendtree] = List()
    val location: Location
    val nmdaMax: Double
    val timeDecay: Double
    val timePoten: Double
    val timeOpenNMDA: Double
    val timeCloseNMDA: Double
    val unitAMPA: Double
    val unitNMDA: Double
    val thetaNMDA: Double
    val scaleNMDA: Double
    private var ampa: Double
    private var nmda: Double

    /*
    override def polarize(v: Double): Unit {
      super.polarize(v)
      nmda += logistic(thetaNMDA, scaleNMDA)(potential)
      afterDelay( -timePoten*log(rand.nextDouble)){ potentiate }
    }
    */
    def update: Unit = {
      ampa -= unitAmpa*(time - timeUpdated)/timeDecay
      nmda -= unitNMDA*(time - timeUpdated)/timeCloseNMDA
      timeUpdate = time
    }


    def potentiate: Unit = {
      update
      ampa += unitAMPA*nmda 
    }

    def receive(s: Signal, i: Intensity): Unit = {
      //carry out the decays since last reception of signal
      update
      //instantaneous linear response of ampa channels to the incoming signal
      polarize(i*ampa) 
      //time-lagged response of nmda channels, to allow backpropagating signal to reach here
      afterDelay( -timeOpenNMDA*log(rand.nextDouble) ){ openNMDA }
    }

    def openNMDA: Unit = {
      update
      nmda += logistic(thetaNMDA, scaleNMDA)(potential)
      afterDelay( -timePoten*log( rand.nextDouble ) ) { potentiate }
    }

    
     
  }


  trait Neuron extends Soma with Axon {
    val threshold: Double

    def critical: Boolean = potential >= threshold

    override def propagate: Unit = { if critical fire }

    def fire: Unit = {
      terminals foreach _.release
    }



  }




    




