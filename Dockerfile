FROM pytorch/pytorch:2.1.0-cuda12.1-cudnn8-runtime

# ✅ 避免 tzdata 互動卡住 + 設定時區
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
# ⚡ 立即輸出 log，不延遲
ENV PYTHONUNBUFFERED=1

# 🧩 安裝必要套件（含 ffmpeg）
RUN apt-get update && apt-get install -y \
    git \
    ffmpeg \
    libsm6 \
    libxext6 \
    tzdata \
 && rm -rf /var/lib/apt/lists/*

# ⚙️ 設定工作目錄
WORKDIR /workspace
COPY . /workspace

# 🐍 安裝 Python 套件
RUN pip install --upgrade pip
RUN pip install -r requirements.txt
RUN pip install runpod
# ✅ 解決 Gradio 與 RunPod 的 tomlkit 衝突
RUN pip install "tomlkit==0.12.2" --force-reinstall

# ✅ 保險行，避免 pip 警告導致 build fail
RUN true

# 🚦 健康檢查：每 30 秒請求一次 /health，若失敗重啟
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
 CMD curl -f http://localhost:7860/health || exit 1

# 🌐 對外開放埠口（Hunyuan / Gradio / API）
EXPOSE 7860

# 🚀 啟動應用
CMD ["python", "handler.py"]
