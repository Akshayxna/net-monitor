# 1. Use a Python base (This "computer" has Python 3 installed)
FROM python:3.9-slim

# 2. Set the working directory
WORKDIR /app

# 3. Copy your app files (if you have any index.html or script.py)
COPY . .

# 4. Tell the container to start the Python server on port 8000
CMD ["python", "-m", "http.server", "8000"]# Triggering build
# Force Trigger 1
