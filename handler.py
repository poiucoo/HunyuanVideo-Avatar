import runpod
from hymm_gradio import app

def handler(event):
    input_data = event.get("input", {})
    image_url = input_data.get("image")
    audio_url = input_data.get("audio")

    print(f"🎬 Starting avatar generation:\n Image: {image_url}\n Audio: {audio_url}")

    # 啟動 Gradio 應用
    app.demo.launch(share=False, server_name="0.0.0.0", server_port=7860)

    return {
        "status": "Avatar service started",
        "image": image_url,
        "audio": audio_url
    }

runpod.serverless.start({"handler": handler})
