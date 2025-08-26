
interface TargetAPI {
  requestResponse: 
    operation(string)(int) throws ArithmeticException 
}

// Dummy Target service - which returns a arithmetric error
service targetService {
  execution: concurrent

  inputPort in {
    location: "auto:json:target.location:file:config.json"
    protocol: sodep
    interfaces: TargetAPI
  }

  // gives an ArithmeticException error
  main {
    [ operation( request )( response ){
      response = 1 / 0
      
    } ]
  }
}