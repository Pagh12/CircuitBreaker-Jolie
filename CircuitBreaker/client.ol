from .target import TargetAPI
include "time.iol"
from console import Console

// ---------- Test service to check circuitBreaker-----------------
//      default settings for circuitbreaker : 
//             - 5 failures before CircuitBreaker Opens
//             - 3000 milliseconds cooldown before Target API can be accessed, after circuitbreaker opens
//             - failure counter resets whenever no error occurs - not included in this test - 
// 
// config.json should be reconfigured in case of usage - 

service Client {

        outputPort in {
        Location: "auto:json:circuit.location:file:config.json"
        Protocol: sodep
        Interfaces: TargetAPI
    }
    embed Console as console

    // Call to targetAPI - Whenever the API is receiving more failures than the breaker threshhold, the breaker will open
    // and requests will get an "CircuitOpenError"
    // TargetAPI will be able to receive requests when the breaker cooldown has gone
    main{
        // last call will receive a CircuitBreakerOpen error
        for(i = 0, i < 6, i++){
            scope( f ){
                install (
                ArithmeticException =>{
                    println@console("ArithmeticException")()
                }
            )
                install (
                CircuitOpenError => {
                    println@console("CircuitOpenError")()
                }
            )
            operation@in("test")(resp) 
            }
            sleep@Time(100)()
    }
}
}