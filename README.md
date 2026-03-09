🚀 Net-Monitor Cloud Architecture

A scalable, network-isolated 3-tier web application stack built with Docker Compose and validated through GitHub Actions. This project demonstrates core SRE (Site Reliability Engineering) principles including load balancing, horizontal scaling, and secure network segmentation.

🛠️ Tech Stack Proxy/Load Balancer: Nginx

Application: Python 3.9 (Scaled Replicas)

Database: MongoDB (with Persistent Volumes)

CI/CD: GitHub Actions

Infrastructure: Docker Compose v3.8

🏗️ Architecture Highlights

High Availability & Scaling The application tier is configured for horizontal scaling using Docker Compose deploy replicas. The Nginx reverse proxy uses proxy_pass to distribute incoming traffic across all healthy application containers.

Network Isolation (Security) To follow security best practices, the stack is divided into two isolated bridge networks:

Frontend Network: Accessible by the Nginx proxy and the Web App.

Backend Network: Accessible ONLY by the Web App and MongoDB.

Note: This prevents the database from being exposed to the public internet, mitigating direct attack vectors.

Automated CI/CD Pipeline Every push to the repository triggers a GitHub Actions workflow that:
Checks out the latest code.

Validates the docker-compose.yml syntax using docker compose config.

Ensures the infrastructure is "clean" before deployment.

🚦 Getting Started

Prerequisites Docker and Docker Compose (V2)

A .env file for database credentials (see .env.example)

Installation Clone the repository: git clone https://github.com/Akshayxna/net-monitor.git cd net-monitor Create your environment variables:

echo "DB_USER=admin\nDB_PASSWORD=yourpassword" > .env Spin up the 3-tier stack:

docker compose up -d 📊 Verification Check the running services and replicas:

docker compose ps

You should see one proxy, one mongodb, and three web_app instances running.
