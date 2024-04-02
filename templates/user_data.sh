#!/usr/bin/env bash

set -x

dnf install -y podman wget
dnf clean all

wget -P locallm/models https://huggingface.co/TheBloke/Llama-2-7B-Chat-GGUF/resolve/main/llama-2-7b-chat.Q5_K_S.gguf
podman run -it -d \
        -p 8001:8001 \
        -v ./locallm/models:/locallm/models:ro,Z \
        -e MODEL_PATH=models/llama-2-7b-chat.Q5_K_S.gguf \
        -e HOST=0.0.0.0 \
        -e PORT=8001 \
        registry.gitlab.com/bootc-org/platform-engineering/testing-framework/playground:0cd8060ff89f0101a24a39f0c7a880456be1c3ec
podman run -it \
        -p 8501:8501 \
        -e MODEL_SERVICE_ENDPOINT=http://10.88.0.1:8001/v1 \
        registry.gitlab.com/bootc-org/platform-engineering/testing-framework/chatbot-langchain:1ea797a0c84673dd67e1be0d5d15fc2f58ed17eb
