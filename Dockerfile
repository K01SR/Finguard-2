# ==============================================================================
# Stage 1: Build React Frontend
# ==============================================================================
FROM node:20-alpine AS frontend-builder

WORKDIR /app/frontend

COPY frontend/package*.json ./
RUN npm ci || npm install

COPY frontend/ ./
ARG VITE_API_URL=""
ENV VITE_API_URL=$VITE_API_URL
RUN npm run build

# ==============================================================================
# Stage 2: All-in-One Python Backend + Integrated Frontend
# ==============================================================================
FROM python:3.10-slim

WORKDIR /app

# Install curl for healthchecks and DuckDNS updater
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Use Astral uv for fast, reliable parallel dependency installation with retry
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

COPY requirements.txt .
RUN uv pip install --system --no-cache -r requirements.txt

# Copy source code, generator and models
COPY data/ data/
COPY src/ src/
COPY api/ api/
COPY models/ models/
COPY docker-entrypoint.sh .
RUN chmod +x docker-entrypoint.sh

# Copy built frontend assets from builder stage
COPY --from=frontend-builder /app/frontend/dist /app/frontend/dist

# Pre-train anomaly detection models so first boot is instant
RUN python data/generator.py && python src/train.py

EXPOSE 8000

ENV HOST=0.0.0.0
ENV PORT=8000

ENTRYPOINT ["/app/docker-entrypoint.sh"]
