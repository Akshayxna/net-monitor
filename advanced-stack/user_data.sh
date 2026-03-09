#!/bin/bash
# 1. Update the system
apt-get update -y
apt-get upgrade -y
sudo apt-get install -y docker.io docker-compose-v2

# 2. Add your user to the docker group so it can run without sudo later
sudo usermod -aG docker ubuntu


# Create Nginx config file

sudo cat <<'EOF' > /home/ubuntu/nginx.conf
events {
    worker_connections 1024;
}

http {
    # 1. Tell Nginx to use Docker's internal DNS (127.0.0.11)
    resolver 127.0.0.11 valid=30s;

    server {
        listen 80;
        server_name localhost;

        location / {
            # 2. Put the domain in a variable $upstream
            set $upstream http://web_app:8000;

            # 3. Use the variable in proxy_pass
            proxy_pass $upstream;

            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }
}
EOF


# Create Docker compose file

sudo cat <<'EOF' > /home/ubuntu/docker-compose.yml
version: "3.8"

services: 
  reverse-proxy:
    image: nginx:latest
    container_name: my_nginx_proxy
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on: 
      - web_app
    networks:
      - frontend

  web_app:
    image: ak009/net-monitor:v1
    command: python -m http.server 8000
    networks:
      - frontend
      - backend
    deploy:
      replicas: 3
    depends_on:
      mongodb:
        condition: service_healthy

  mongodb:
    image: mongo:latest
    container_name: my_mongodb
    ports:
      - "27017:27017"
    environment:
      # These variables create a root user for the 'admin' database
      MONGO_INITDB_ROOT_USERNAME: ${DB_USER}
      MONGO_INITDB_ROOT_PASSWORD: ${DB_PASSWORD}
      # Optional: create a default application database on startup
      MONGO_INITDB_DATABASE: myappdb
    volumes:
      # This named volume persists your data on the host machine
      - mongo-data:/data/db
    healthcheck:
      test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
      interval: 10s
      timeout: 10s
      retries: 3
      start_period: 20s
    networks:
      - backend
  
networks:
  frontend:
  backend:

volumes:
  mongo-data:
EOF


# Create the .env file for the database credentials
cat <<EOF > /home/ubuntu/.env
DB_USER=admin
DB_PASSWORD=password123
EOF

# Start the stack

cd /home/ubuntu
sudo docker compose up -d