# 使用支援 GPU 的官方 PyTorch 映像
FROM pytorch/pytorch:2.1.0-cuda12.1-cudnn8-runtime

# 安裝必要系統套件（包含 ffmpeg 以便處理音訊與影片）
RUN apt-get update && apt-get install -y \
    git \
    ffmpeg \
    libsm6 \
    libxext6 \
 && rm -rf /var/lib/apt/lists/*

# 設定工作目錄
WORKDIR /workspace

# 複製專案內容
COPY . /workspace

# 安裝 Python 套件
RUN pip install --upgrade pip
RUN pip install -r requirements.txt
RUN pip install runpod  # ⚠️ RunPod Serverless 必需！

# 預設開啟 port（非必需，但建議保留）
EXPOSE 7860

# ⚡ 關鍵：改成呼叫 handler.py，而不是 app.py
CMD ["python", "handler.py"]
