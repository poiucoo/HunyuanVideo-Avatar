# 🚀 基於輕量 CUDA 12.1 Runtime（官方 PyTorch with Python 3.10）
FROM pytorch/pytorch:2.1.0-cuda12.1-cudnn8-runtime

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

# 🧠 安裝 CUDA 12.1 對應的 PyTorch（GPU 版）
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir torch==2.1.0 torchvision==0.16.0 --index-url https://download.pytorch.org/whl/cu121

# 🧩 安裝依賴
RUN pip install --no-cache-dir -r requirements.txt

# 🚦 健康檢查
# ⚠️ Serverless 健康檢查預設會 ping 5000 port（不是 7860）
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
 CMD curl -f http://localhost:5000/ || exit 1

# 🌐 對外埠口（Serverless 固定用 5000）
EXPOSE 5000

# 🧹 清理暫存
RUN pip cache purge && \
    apt-get clean && \
    rm -rf /root/.cache /tmp/* /var/tmp/* /var/lib/apt/lists/*

# 🚀 啟動 FastAPI 應用
CMD ["uvicorn", "server:app", "--host", "0.0.0.0", "--port", "5000"]
