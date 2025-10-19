# 🚀 基於輕量 CUDA 12.1 Runtime（官方 PyTorch with Python 3.10）
FROM pytorch/pytorch:2.1.0-cuda12.1-cudnn8-runtime

# ✅ 基本設定
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV PYTHONUNBUFFERED=1

# 🧩 安裝必要系統套件（包含 git、ffmpeg、build-essential、curl）
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

# 🐍 安裝 PyTorch GPU 對應版本
RUN pip install --upgrade pip setuptools wheel
RUN pip install torch==2.1.0 torchvision==0.16.0 --index-url https://download.pytorch.org/whl/cu121

# 📦 分層安裝主要依賴（使用 --prefer-binary 加快速度）
RUN pip install --prefer-binary -r requirements.txt

# ⚡ 安裝 flash-attn 預編譯版（避免重新編譯）
RUN pip install flash-attn --extra-index-url https://flash-attn-builds.s3.amazonaws.com/whl/cu121/torch2.1/

# 🌐 安裝 RunPod 與其他網路依賴
RUN pip install runpod requests

# 🌍 對外服務埠（RunPod Serverless 預設使用 5000）
EXPOSE 5000

# 🚦 健康檢查
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
 CMD curl -f http://localhost:5000/ || exit 1

# ▶️ 啟動 RunPod Serverless handler
CMD ["python", "handler.py"]
