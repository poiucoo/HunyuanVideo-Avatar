# 🚀 基於 CUDA 12.1 Runtime（官方 PyTorch with Python 3.10）
FROM pytorch/pytorch:2.3.0-cuda12.1-cudnn8-runtime

# ✅ 基本設定
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV PYTHONUNBUFFERED=1

# 🧩 安裝必要系統套件
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    ffmpeg \
    curl \
    libsm6 \
    libxext6 \
    tzdata \
 && rm -rf /var/lib/apt/lists/*

# ⚙️ 設定工作目錄
WORKDIR /workspace
COPY . /workspace

# 🐍 安裝 PyTorch GPU 對應版本（CUDA 12.1）
RUN pip install --upgrade pip setuptools wheel && \
    pip install --no-cache-dir torch==2.3.0 torchvision==0.18.0 torchaudio==2.3.0 --index-url https://download.pytorch.org/whl/cu121

# 📦 第一階段：主要依賴
RUN pip install --prefer-binary -r requirements.txt

# ⚡ 第二階段：安裝 FlashAttention（CUDA12.1 對應 torch 2.3）
RUN pip install "flash-attn>=2.5,<2.6" \
    --no-build-isolation --prefer-binary \
    --extra-index-url https://flash-attn-builds.s3.amazonaws.com/whl/cu121/torch2.3/

# 🧩 第三階段：補上 runpod 與 requests
RUN pip install --no-cache-dir runpod==1.4.0 requests==2.31.0

# 🌐 RunPod Serverless port
EXPOSE 5000

# 🚦 健康檢查
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
 CMD curl -f http://localhost:5000/ || exit 1

# ▶️ 啟動 RunPod Serverless handler
CMD ["python", "handler.py"]
