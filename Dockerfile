# 🚀 CUDA 12.1 Runtime（官方 PyTorch with Python 3.10）
FROM pytorch/pytorch:2.2.0-cuda12.1-cudnn8-runtime

# ✅ 基本環境設定
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV PYTHONUNBUFFERED=1

# 🧩 安裝必要套件
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
    pip install --no-cache-dir torch==2.2.0 torchvision==0.17.0 torchaudio==2.2.0 --index-url https://download.pytorch.org/whl/cu121

# 📦 安裝模型依賴（分階段降低錯誤率）
RUN pip install --prefer-binary -r requirements.txt
RUN pip install --no-cache-dir runpod==1.4.0 requests==2.31.0

# ⚡ 加入 FlashAttention 的 Dummy Fallback
# （確保匯入 flash_attn 時不報錯）
RUN mkdir -p /workspace/flash_attn && \
    echo "def flash_attn_func(*args, **kwargs):\n    raise NotImplementedError('FlashAttention disabled. Using PyTorch native attention instead.')" > /workspace/flash_attn/__init__.py

# 🌐 RunPod Serverless 預設使用 port 5000
EXPOSE 5000

# 🚦 健康檢查
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
 CMD curl -f http://localhost:5000/ || exit 1

# ▶️ 啟動 RunPod Serverless handler
CMD ["python", "handler.py"]
