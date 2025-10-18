from fastapi import FastAPI, UploadFile, Request
import subprocess, os, shutil, requests

app = FastAPI()

@app.get("/")
def root():
    return {"status": "running"}

def ensure_model():
    model_dir = "/workspace/models/HunyuanVideo"
    if os.path.exists(os.path.join(model_dir, "ckpts", "hunyuan_video_diffusion.safetensors")):
        print("✅ 模型已存在，略過下載。")
        return
    print("⬇️ 下載 HunyuanVideo 模型中...")
    os.makedirs(model_dir, exist_ok=True)
    os.system(f"git clone https://huggingface.co/tencent/HunyuanVideo {model_dir}")
    for sub in ["ckpts", "vae", "text_encoder"]:
        os.makedirs(os.path.join(model_dir, sub), exist_ok=True)
        for file in os.listdir(model_dir):
            if file.endswith(".safetensors") and "vae" not in file:
                shutil.move(os.path.join(model_dir, file), os.path.join(model_dir, "ckpts", file))
            elif "vae" in file:
                shutil.move(os.path.join(model_dir, file), os.path.join(model_dir, "vae", file))
            elif file.endswith(".pt"):
                shutil.move(os.path.join(model_dir, file), os.path.join(model_dir, "text_encoder", file))
    print("✅ 模型下載完成。")


@app.post("/generate")
async def generate_video(image: UploadFile, audio: UploadFile):
    ensure_model()
    os.makedirs("uploads", exist_ok=True)
    os.makedirs("results", exist_ok=True)

    image_path = f"uploads/{image.filename}"
    audio_path = f"uploads/{audio.filename}"

    with open(image_path, "wb") as f:
        f.write(await image.read())
    with open(audio_path, "wb") as f:
        f.write(await audio.read())

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


# ✅ 新增這個，讓 RunPod Serverless 能接到
@app.post("/run")
async def run(request: Request):
    """
    RunPod Serverless 會呼叫這個端點，內容是 JSON
    {
        "input": {
            "image_url": "...",
            "audio_url": "...",
            "prompt": "..."
        }
    }
    """
    data = await request.json()
    image_url = data["input"]["image_url"]
    audio_url = data["input"]["audio_url"]

    # 下載檔案
    os.makedirs("uploads", exist_ok=True)
    image_path = "uploads/input_image.png"
    audio_path = "uploads/input_audio.wav"
    with open(image_path, "wb") as f:
        f.write(requests.get(image_url).content)
    with open(audio_path, "wb") as f:
        f.write(requests.get(audio_url).content)

    # 呼叫原本的推理程式
    ensure_model()
    cmd = [
        "python", "inference.py",
        "--config", "configs/hunyuan_avatar.yaml",
        "--image_path", image_path,
        "--audio_path", audio_path,
        "--output_dir", "results"
    ]
    subprocess.run(cmd, check=True)

    output_file = "results/avatar_out.mp4"
    return {"status": "success", "output_video": output_file}
