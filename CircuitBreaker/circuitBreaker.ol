include "time.iol"
from console import Console
from .target import TargetAPI

// Defines an interface extender for the circuit breaker
// This is a way to extend functionalities that might throw a custom error, CircuitOpenError
interface extender circuitBreakerExtender {
  requestResponse: *(void)(void) throws CircuitOpenError
}

service circuitBreaker {
  embed Console as console
  // Output port to communicate with the target service
  outputPort target {
    location: "auto:json:target.location:file:config.json"
    protocol: sodep
    interfaces: TargetAPI
  }
// Input port to receive requests and manage them via the circuit breaker
  inputPort input {
    location: "auto:json:circuit.location:file:config.json"
    protocol: sodep
    aggregates: target with circuitBreakerExtender
  }
 // Initialization block to set up circuit breaker parameters
    init{
        global.cooldown = 3000
        global.failureCount = 0
        global.failureThreshhold = 5
    }

  // Main courier logic for handling requests and circuit breaker functionality
  courier input {
    [ interface TargetAPI( request )( response ){ 
      // Scope block to wrap the circuit breaker logic
      scope ( circuitBreakerScope ) {
        // Error handler to catch specific errors such as ArithmeticException
        install ( 

          ArithmeticException => {
            global.failureCount = global.failureCount + 1

             // Checks if the failure count exceeds the threshold to open the circuit
            if(global.failureCount >= global.failureThreshhold){
              global.failureTimeStamp = getCurrentTimeMillis@Time()
              
            }
            throw(ArithmeticException)
          }
        )
        
        currentTime = getCurrentTimeMillis@Time()

        // Checks if the circuit should allow requests
        // - Allows if either no failure timestamp is set (circuit closed)
        // - Or if the cooldown period has passed since last failure
        if(!is_defined(global.failureTimeStamp) || global.cooldown < (currentTime - global.failureTimeStamp)){
            forward( request )( response ) 

            global.failureCount = 0

        }else{
          
          throw(CircuitOpenError) // Throws custom error if circuit is open and within cooldown period
        }
        
      }
    } ]

  }
    main { linkIn( l ) }
}