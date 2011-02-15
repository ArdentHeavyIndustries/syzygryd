/* 
 * EventDispatcher encapsulates the necessary functionality to fire and listen for events.
 */

public class EventDispatcher {
  
  LinkedList<String> eventQueue;
  LinkedList<String> deferredEventQueue;
  
  // Create event queues
  EventDispatcher() {
    eventQueue = new LinkedList();
    deferredEventQueue = new LinkedList();
  }
  
  
  /* 
   * On invocation, clears the current contents of the queue and adds any deferred events for the next pass. Should only be called 
   * once all potential event handlers have had their shot at the contents of the event queue. Must be called immediately before 
   * the end of the event polling loop (in this case, draw()).
   */
   
  void flushExpired(){
    eventQueue.clear();
    eventQueue.addAll(deferredEventQueue);
    deferredEventQueue.clear();
  }
  
  
  /* 
   * Adds an event to the queue. Asynchronous events (e.g., events triggered via OSCEvent) are added directly to the eventQueue 
   * for immediate handling. Synchronous events (generally those generated within functions called by the draw() loop, i.e. 
   * lighting programs) are added to a deferred queue, to be handled on the next pass of the draw() loop.
   */
   
  void fire(String eventMessage, boolean async){
    if (async){
      //print ("fired '" + eventMessage + "' (async) @ " + millis() + "\n");
      eventQueue.addLast(eventMessage);
    } 
    else {
      //print ("fired '" + eventMessage + "' (sync) @ " + millis() + "\n");
      deferredEventQueue.addLast(eventMessage);
    }
  }
  
  
  /*
   * Alternate form of fire(): defaults to async = false if called with no second argument, to simplify calls within, 
   * e.g., lighting programs.
   */
   
  void fire(String eventMessage){
    fire(eventMessage, false);
  }
  
  
  /*
   * Checks to see if a given event has been fired by looking for its message in the queue.
   */
   
  boolean fired(String eventMessage){
    return eventQueue.contains(eventMessage);
  }
}

/*
** Local Variables:
**   mode: java
**   c-basic-offset: 2
**   tab-width: 2
**   indent-tabs-mode: nil
** End:
**
** vim: softtabstop=2 tabstop=2 expandtab cindent shiftwidth=2
**
*/
