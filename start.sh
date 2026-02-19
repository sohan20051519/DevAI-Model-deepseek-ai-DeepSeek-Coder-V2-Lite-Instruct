#!/usr/bin/env bash
set -e

PORT=${PORT:-8000}

# Required environment variables
if [ -z "$HF_TOKEN" ]; then
  echo "HF_TOKEN not set. Add it in Render/Railway environment variables."
  exit 1
fi

if [ -z "$VLLM_API_KEY" ]; then
  echo "VLLM_API_KEY not set. Add it in Render/Railway environment variables."
  exit 1
fi

export HUGGINGFACE_HUB_TOKEN=$HF_TOKEN

echo "Starting vLLM..."
echo "Model: Qwen/Qwen2.5-1.5B-Instruct"
echo "Port: $PORT"
echo "Host: 0.0.0.0"

exec vllm serve Qwen/Qwen2.5-1.5B-Instruct \
  --host 0.0.0.0 \
  --port $PORT \
  --api-key $VLLM_API_KEY \
  --device cpu \
  --max-model-len 2048
