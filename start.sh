#!/usr/bin/env bash
set -euo pipefail

# Default port - Railway sets PORT automatically in the environment
PORT="${PORT:-8000}"
VLLM_MODEL="${VLLM_MODEL:-deepseek-ai/DeepSeek-Coder-V2-Lite-Instruct}"

# Ensure HF token present (vLLM uses huggingface_hub to download models)
if [ -z "${HF_TOKEN:-}" ]; then
  echo "ERROR: HF_TOKEN environment variable is not set. Create a Hugging Face token and set HF_TOKEN in Railway env vars."
  exit 1
fi

# If API key not pre-set, generate one and print it to logs (copy from logs)
if [ -z "${VLLM_API_KEY:-}" ]; then
  # generate 32 byte urlsafe token
  VLLM_API_KEY="$(python - <<'PY'
import secrets
print(secrets.token_urlsafe(32))
PY
)"
  echo "================================================================"
  echo "Generated VLLM API key (copy this from logs):"
  echo "$VLLM_API_KEY"
  echo "================================================================"
else
  echo "Using provided VLLM_API_KEY from env."
fi

# Export HF token for the huggingface hub
export HF_HOME=/root/.cache/huggingface
export HUGGINGFACE_HUB_TOKEN="${HF_TOKEN}"

# Print some debug info
echo "Starting vLLM serve"
echo "Model: $VLLM_MODEL"
echo "Port: $PORT"
echo "Host: 0.0.0.0"
echo "API key length: ${#VLLM_API_KEY}"

# Start vLLM serve bound to 0.0.0.0 and port; pass the api key
# If vllm CLI differs, consult vllm docs. This is the canonical command for vllm >=0.4
exec vllm serve "$VLLM_MODEL" --host 0.0.0.0 --port "$PORT" --api-key "$VLLM_API_KEY"
