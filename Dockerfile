FROM pytorch/pytorch:2.1.0-cuda12.1-cudnn8-runtime

# 🧩 新增兩行避免 tzdata 卡住
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    git \
    ffmpeg \
    libsm6 \
    libxext6 \
    tzdata \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
COPY . /workspace

RUN pip install --upgrade pip
RUN pip install -r requirements.txt
RUN pip install runpod

EXPOSE 7860
CMD ["python", "handler.py"]
