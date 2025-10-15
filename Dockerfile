# 🚀 基於輕量 CUDA Runtime，而非整包 PyTorch image
FROM nvidia/cuda:12.1.0-runtime-ubuntu20.04

# ✅ 基本設定
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV PYTHONUNBUFFERED=1

# 🧩 安裝必要套件（包含 ffmpeg 與 curl）
RUN apt-get update && apt-get install -y \
    git \
    ffmpeg \
    curl \
    python3-pip \
    python3-dev \
    libsm6 \
    libxext6 \
    tzdata \
 && rm -rf /var/lib/apt/lists/*

# ⚙️ 設定工作目錄
WORKDIR /workspace
COPY . /workspace

# 🐍 安裝 PyTorch（指定 CUDA 版本）
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir torch==2.1.0 torchvision==0.16.0 --index-url https://download.pytorch.org/whl/cu121

# 🧠 安裝必要的 Python 套件（gradio, transformers, runpod 等）
RUN pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir runpod tomlkit==0.12.2

# 🚦 健康檢查（確保 curl 可用）
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
 CMD curl -f http://localhost:7860/health || exit 1

# 🌐 對外埠口
EXPOSE 7860

# 🧹 清理暫存，減少鏡像體積
RUN rm -rf /root/.cache /tmp/* /var/tmp/*

# 🚀 啟動應用
CMD ["python3", "handler.py"]
