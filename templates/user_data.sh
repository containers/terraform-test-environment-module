#!/usr/bin/env bash

set -x

ulimit -l unlimited

dnf install -y git podman wget awscli
dnf clean all

git clone https://github.com/redhat-et/locallm.git

# Build Model Service
podman build -t playground:image -f locallm/playground/Containerfile locallm/playground
# Download Model
# wget -P locallm/models https://huggingface.co/TheBloke/Llama-2-7B-Chat-GGUF/resolve/main/llama-2-7b-chat.Q5_K_S.gguf
aws s3 cp s3://${aws_cache_bucket}/llama-2-7b-chat.Q5_K_S.gguf locallm/models/llama-2-7b-chat.Q5_K_S.gguf
# Deploy Model Service
podman run -it -d \
        -p 8001:8001 \
        -v ./locallm/models:/locallm/models:ro,Z \
        -e MODEL_PATH=models/llama-2-7b-chat.Q5_K_S.gguf \
        -e HOST=0.0.0.0 \
        -e PORT=8001 \
        playground:image
# Build image
podman build -t stchat -f locallm/chatbot-langchain/builds/Containerfile locallm/chatbot-langchain
# Run image locally
podman run -it -p 8501:8501 -e MODEL_SERVICE_ENDPOINT=http://10.88.0.1:8001/v1 stchat
