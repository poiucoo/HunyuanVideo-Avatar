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

# 🐍 安裝 CUDA 12.1 對應的 PyTorch（GPU 版）
# ✅ 已內建 PyTorch 2.1.0，這行確保 torch/cu121 完整性（可重複安裝一次無礙）
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir torch==2.1.0 torchvision==0.16.0 --index-url https://download.pytorch.org/whl/cu121

# 🧠 安裝其餘依賴（requirements.txt）
RUN pip install --no-cache-dir -r requirements.txt

# 🚦 健康檢查（確保伺服器啟動後可被 RunPod ping）
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
 CMD curl -f http://localhost:7860/health || exit 1

# 🌐 對外埠口
EXPOSE 7860

# 🧹 清理暫存，進一步減少鏡像體積
RUN pip cache purge && \
    apt-get clean && \
    rm -rf /root/.cache /tmp/* /var/tmp/* /var/lib/apt/lists/*

# 🚀 啟動應用
CMD ["python3", "handler.py"]
