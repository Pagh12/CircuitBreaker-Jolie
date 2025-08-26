# Circuit Breaker in Jolie

This project demonstrates the **Circuit Breaker pattern** implemented in [Jolie](http://www.jolie-lang.org/).  
The Circuit Breaker is a resilience pattern commonly used in microservice architectures to handle failures gracefully.  
It prevents cascading failures by temporarily cutting off calls to an unresponsive service and optionally providing fallback behavior.

---

## 📂 Project Structure
- `circuitBreaker.ol` – The Circuit Breaker service that manages requests to the target.  
- `client.ol` – A client that sends requests through the Circuit Breaker.  
- `target.ol` – The target service (simulates a working or failing endpoint by dividing by zero).  
- `config.json` – Configuration file specifying service locations.  

---

## ▶️ How it Works

- At first, the **target service** throws an `ArithmeticException` (`/ by zero`).  
- The **client** receives these raw errors until the **Circuit Breaker** failure counter reaches **6**.  
- Once the threshold is reached, the Circuit Breaker **opens** and stops forwarding requests.  
- From then on, the **client** receives `CircuitOpenError` instead of the original `ArithmeticException`.  

This shows how the Circuit Breaker prevents repeated failures from overwhelming a failing service.

---

## ▶️ How to Run with Docker

1. Make sure you have **Docker Desktop** running (Linux containers mode).
2. From the project folder, start everything with:
   ```bash
   docker compose up
