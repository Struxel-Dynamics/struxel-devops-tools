#!/bin/bash

# Script to add Dockerfiles to repositories that don't have them
# This version includes a fix for handling missing requirements.txt files

set -e

# Function to create a Python Dockerfile with conditional requirements.txt handling
create_python_dockerfile() {
    cat > Dockerfile << 'EOF'
FROM python:3.9-slim

WORKDIR /app

# Copy requirements.txt if it exists, otherwise create an empty one
COPY requirements.tx[t] ./ 2>/dev/null || true

# Install dependencies only if requirements.txt exists and is not empty
RUN if [ -f requirements.txt ] && [ -s requirements.txt ]; then \
        pip install --no-cache-dir -r requirements.txt; \
    fi

# Copy the rest of the application
COPY . .

# Default command (override as needed)
CMD ["python", "app.py"]
EOF
}

# Function to create a Node.js Dockerfile
create_node_dockerfile() {
    cat > Dockerfile << 'EOF'
FROM node:16-alpine

WORKDIR /app

# Copy package files if they exist
COPY package*.json ./ 2>/dev/null || true

# Install dependencies if package.json exists
RUN if [ -f package.json ]; then \
        npm install; \
    fi

# Copy the rest of the application
COPY . .

# Expose port
EXPOSE 3000

# Default command (override as needed)
CMD ["npm", "start"]
EOF
}

# Function to create a generic Dockerfile
create_generic_dockerfile() {
    cat > Dockerfile << 'EOF'
FROM ubuntu:20.04

WORKDIR /app

# Update and install basic dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Copy application files
COPY . .

# Default command
CMD ["/bin/bash"]
EOF
}

# Main function to detect project type and create appropriate Dockerfile
main() {
    if [ -f "requirements.txt" ] || [ -f "setup.py" ] || [ -f "*.py" ]; then
        echo "Python project detected. Creating Python Dockerfile..."
        create_python_dockerfile
    elif [ -f "package.json" ]; then
        echo "Node.js project detected. Creating Node.js Dockerfile..."
        create_node_dockerfile
    else
        echo "Generic project detected. Creating generic Dockerfile..."
        create_generic_dockerfile
    fi
    
    echo "Dockerfile created successfully!"
}

# Run main function
main
