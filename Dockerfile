# 🚀 基於官方 PyTorch CUDA 11.8 runtime，內建 torch==2.0.1 / torchvision==0.15.2
FROM pytorch/pytorch:2.0.1-cuda11.8-cudnn8-runtime

# ✅ 基本設定
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV PYTHONUNBUFFERED=1

# 🧩 安裝必要套件（包含 ffmpeg 與 curl）
RUN apt-get update && apt-get install -y \
    git \
    ffmpeg \
    curl \
    libsm6 \
    libxext6 \
    tzdata \
 && rm -rf /var/lib/apt/lists/*

# ⚙️ 設定工作目錄
WORKDIR /workspace
COPY . /workspace

# 🧠 安裝必要 Python 套件
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# 🚦 健康檢查
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
 CMD curl -f http://localhost:7860/health || exit 1

# 🌐 對外埠口
EXPOSE 7860

# 🧹 清理暫存，減少鏡像體積
RUN pip cache purge && rm -rf /root/.cache /tmp/* /var/tmp/*

# 🚀 啟動應用
CMD ["python3", "handler.py"]
