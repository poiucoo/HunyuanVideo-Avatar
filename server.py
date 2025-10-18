from fastapi import FastAPI, Request
import os, subprocess, requests

app = FastAPI()

# ✅ 健康檢查（讓 RunPod 可以確認容器存活）
@app.get("/health")
def health():
    return {"status": "ok"}

# ✅ 主推理路由（RunPod Serverless 預設呼叫 /run）
@app.post("/run")
async def run(request: Request):
    data = await request.json()
    image_url = data["input"]["image_url"]
    audio_url = data["input"]["audio_url"]

    os.makedirs("uploads", exist_ok=True)
    image_path = "uploads/input_image.png"
    audio_path = "uploads/input_audio.wav"

    # 下載圖片與音訊
    with open(image_path, "wb") as f:
        f.write(requests.get(image_url).content)
    with open(audio_path, "wb") as f:
        f.write(requests.get(audio_url).content)

    # 執行推理（這裡改成你模型的實際命令）
    cmd = [
        "python", "inference.py",
        "--config", "configs/hunyuan_avatar.yaml",
        "--image_path", image_path,
        "--audio_path", audio_path,
        "--output_dir", "results"
    ]
    subprocess.run(cmd, check=True)

    return {"status": "success", "video_path": "results/avatar_out.mp4"}
