FROM pytorch/pytorch:2.1.0-cuda12.1-cudnn8-runtime

# ✅ 避免 tzdata 互動卡住 + 設定時區
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV PYTHONUNBUFFERED=1

# 🧩 安裝必要系統套件
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

# 🐍 安裝 Python 與 PyTorch 套件
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir torch==2.1.0 torchvision==0.16.0 --index-url https://download.pytorch.org/whl/cu121

# 📦 安裝 requirements.txt + FastAPI 相關依賴
RUN pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir runpod python-multipart

# 🌐 RunPod Serverless 走 5000 port
EXPOSE 5000

# 🚦 健康檢查（可留）
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
 CMD curl -f http://localhost:5000/ || exit 1

# ▶️ 啟動 FastAPI 服務
CMD ["uvicorn", "server:app", "--host", "0.0.0.0", "--port", "5000"]
