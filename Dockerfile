# Dockerfile - Intended for Railway (uses python slim)
FROM python:3.10-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install OS deps required for many ML packages and vLLM building
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential git wget curl ca-certificates cmake libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install vllm. Note: vllm may build native extensions and require tools.
RUN pip install --upgrade pip setuptools wheel
# Pinning isn't required but you can pin a known working vllm version if preferred
RUN pip install vllm

# Add start script
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8000

# Railway exposes $PORT; start.sh will use $PORT if provided
CMD ["/start.sh"]
