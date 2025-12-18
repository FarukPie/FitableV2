# Use an official Python runtime as a parent image
FROM python:3.10-slim

# Set environment variables
# PYTHONDONTWRITEBYTECODE: Prevents Python from writing pyc files to disc
# PYTHONUNBUFFERED: Prevents Python from buffering stdout and stderr
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set work directory
WORKDIR /app

# Install system dependencies required for Playwright
# We install these before python deps to cache them
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements file
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Install Playwright browsers and dependencies
# --with-deps installs system dependencies for the browsers
RUN playwright install --with-deps chromium

# Copy the application code
COPY . .

# Expose the port that uvicorn will run on
# Render sets the PORT environment variable, but defaults to 10000 usually
EXPOSE 10000

# Run the application
# Use 0.0.0.0 to bind to all interfaces acting as a web server
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "10000"]
