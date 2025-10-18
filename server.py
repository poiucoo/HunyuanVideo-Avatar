from fastapi import FastAPI, UploadFile
import subprocess, os

app = FastAPI()

@app.get("/")
def root():
    return {"status": "running"}

@app.post("/generate")
async def generate_video(image: UploadFile, audio: UploadFile):
    os.makedirs("uploads", exist_ok=True)
    os.makedirs("results", exist_ok=True)

    image_path = f"uploads/{image.filename}"
    audio_path = f"uploads/{audio.filename}"

    # 儲存上傳的檔案
    with open(image_path, "wb") as f:
        f.write(await image.read())
    with open(audio_path, "wb") as f:
        f.write(await audio.read())

    # 呼叫官方 Hunyuan 推理程式
    cmd = [
        "python", "inference.py",
        "--config", "configs/hunyuan_avatar.yaml",
        "--image_path", image_path,
        "--audio_path", audio_path,
        "--output_dir", "results"
    ]
    subprocess.run(cmd, check=True)

    output_file = "results/avatar_out.mp4"
    return {"status": "ok", "output": output_file}
