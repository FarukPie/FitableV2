FROM mcr.microsoft.com/playwright/python:v1.49.0-jammy

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
# Ensure python finds the app module
ENV PYTHONPATH=/app

WORKDIR /app

# Upgrade pip to ensure latest resolving logic
RUN pip install --upgrade pip

# Copy requirements file
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Explicitly install Playwright browsers (Chromium only for smaller image)
RUN playwright install chromium
RUN playwright install-deps chromium

# DEBUG: List installed packages to verify beautifulsoup4 is present
RUN pip list

# DEBUG: Fail build immediately if bs4 is not importable
RUN python -c "import bs4; print('SUCCESS: bs4 is importable')"

# Copy the application code
COPY . .

# Expose the port
EXPOSE 10000

# Run the application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "10000"]
