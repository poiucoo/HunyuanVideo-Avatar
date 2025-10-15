import runpod
from hymm_gradio import app
from fastapi import FastAPI
from threading import Thread

# ✅ 建立 FastAPI 健康檢查端點
health_app = FastAPI()

@health_app.get("/health")
def health():
    return {"status": "ok"}

# ✅ 啟動 Gradio 應用於背景
def start_gradio():
    app.demo.launch(share=False, server_name="0.0.0.0", server_port=7860)

# ✅ RunPod handler
def handler(event):
    input_data = event.get("input", {})
    image_url = input_data.get("image")
    audio_url = input_data.get("audio")

    print(f"🎬 Starting avatar generation:\n Image: {image_url}\n Audio: {audio_url}")

    # 🧠 使用背景執行緒啟動 Gradio（避免阻塞）
    thread = Thread(target=start_gradio)
    thread.start()

    return {
        "status": "Avatar service started",
        "health": "http://localhost:7860/health",
        "image": image_url,
        "audio": audio_url
    }

# ✅ 啟動 RunPod Serverless handler
runpod.serverless.start({"handler": handler})
