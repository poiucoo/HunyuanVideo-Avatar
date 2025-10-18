FROM pytorch/pytorch:2.1.0-cuda12.1-cudnn8-runtime

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y \
    git \
    ffmpeg \
    curl \
    libsm6 \
    libxext6 \
    tzdata \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
COPY . /workspace

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir torch==2.1.0 torchvision==0.16.0 --index-url https://download.pytorch.org/whl/cu121

RUN pip install --no-cache-dir -r requirements.txt

# 🌐 RunPod Serverless 走 5000 port
EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
 CMD curl -f http://localhost:5000/ || exit 1

CMD ["uvicorn", "server:app", "--host", "0.0.0.0", "--port", "5000"]
