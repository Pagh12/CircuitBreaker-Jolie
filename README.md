# Circuit Breaker in Jolie

This project demonstrates the **Circuit Breaker pattern** implemented in [Jolie](http://www.jolie-lang.org/).  
The Circuit Breaker is a resilience pattern commonly used in microservice architectures to handle failures gracefully.  
It prevents cascading failures by temporarily cutting off calls to an unresponsive service and optionally providing fallback behavior.

---

## Project Structure
- `circuitBreaker.ol` – The Circuit Breaker service that manages requests to the target.  
- `client.ol` – A client that sends requests through the Circuit Breaker.  
- `target.ol` – The target service (simulates a working or failing endpoint).  
- `config.json` – Configuration file specifying service locations.  

Example config:
```json
{
  "target": {
    "location":"socket://localhost:8080"
  },
  "circuit": {
    "location":"socket://localhost:8081"
  }
}


## How to run - inside the folder run##
  1. paste 'jolie target.ol' into terminal
  2. paste 'jolie circuitBreaker.ol' into terminal
  3. paste 'jolie client.ol' into terminal
