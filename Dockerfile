# Use the official Python image
FROM python:3.9-slim

# Set the working directory inside the container
WORKDIR /app

# Install Flask and psutil
# We install both because the web app needs them
RUN pip install flask psutil

# Copy the current folder contents (app.py AND templates folder) into the container
COPY . .

# Tell Docker this app listens on port 5000 (Documentation only, but good practice)
EXPOSE 5000

# Command to run the web app
CMD ["python", "app.py"]