package learn.neuroscience


/**
  * This starts with code from the Reactive class
  */

abstract class Simulation {
  type Process = () => Unit
  case class Event(time: Int, process: Process)
  private type Agenda = List[Event] //use a priority queue for efficiency
  private var agenda: Agenda = List()
  private var curtime: Double = 0.0
  def currentTime: Double = curtime
  def afterDelay(delay: Double)(block: => Unit): Unit = {
    val item = Event(currentTime + delay, () => block)
    agenda = insert(agenda, item)
  }

  private def insert(ag: List[Event], item: Event): List[Event] = ag match {
    case first :: rest if first.time <= item.time => first :: insert(rest, item)
    case _ => item :: ag
  }
  private def loop(): Unit = agenda match {
    case first :: rest => {
      agenda = rest
      curtime = first.time
      first.action()
      loop()
    }
    case Nil =>
  }

  def run(): Unit = {
    afterDelay(0) {
      println(" *** The Simulation has started, time = " + currentTime + " ***")
    }
    loop()
  }
}


