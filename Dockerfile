# Use Python 3.11 slim image for smaller size
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Create non-root user for security
RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app

# Copy requirements file
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY verify-dockerhub-secrets.py .

# Switch to non-root user
USER appuser

# Set the entrypoint to run the Python script
ENTRYPOINT ["python3", "verify-dockerhub-secrets.py"]

# Default command (can be overridden)
CMD ["--help"]
