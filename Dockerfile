# Use a lightweight Linux version of Python
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Install the monitoring tool
RUN pip install psutil

# Copy our code
COPY monitor.py .

# Run the monitor
CMD ["python", "monitor.py"]