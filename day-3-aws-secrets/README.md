# Secure E-Commerce Deployment Architecture ☁️🔒

This project demonstrates the industry best practice for handling production secrets without using `.env` files. It uses **Golang**, **AWS Secrets Manager**, **Terraform**, and **GitHub Actions**.

## How the Architecture Works

1. **AWS Secrets Manager:** We manually create a secret in AWS named `prod/ecommerce/api_key`. This is our secure vault.
2. **GitHub Actions (CI/CD):** When code is pushed to the `main` branch, GitHub Actions automatically compiles the Golang binary and triggers Terraform.
3. **Terraform (IaC):** Terraform connects to AWS, looks up the value of our secret inside Secrets Manager, and spins up a new EC2 instance.
4. **Environment Injection:** Using EC2 `user_data` (a script that runs once when the server boots), Terraform injects the secret directly into the server's operating system environment variables.
5. **The Application:** The Golang application boots up and simply reads `os.Getenv("APP_SECRET")`.

### Why this is the Best Practice:
* **No `dotenv` package needed** in production.
* **Code Portability:** The Go application requires no AWS SDKs. It doesn't care if the environment variable came from a local `.env` file or AWS Secrets Manager.
* **Security:** Secrets are never hardcoded in GitHub, and they never touch the actual application source code.

## Folder Structure
```text
/
├── .github/
│   └── workflows/
│       └── deploy.yml      <-- GitHub Actions Pipeline MUST be at root
├── src/
│   └── main.go             <-- Golang application code
├── terraform/
│   └── main.tf             <-- Terraform infrastructure code
└── README.md