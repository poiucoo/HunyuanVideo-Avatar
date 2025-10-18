import runpod
import os
import subprocess
import requests

def handler(event):
    """RunPod Serverless 主入口"""
    data = event.get("input", {})
    image_url = data.get("image_url")
    audio_url = data.get("audio_url")

    # 🧩 驗證輸入
    if not image_url or not audio_url:
        return {"error": "Missing image_url or audio_url"}

    # 📁 建立資料夾
    os.makedirs("uploads", exist_ok=True)
    os.makedirs("results", exist_ok=True)

    image_path = "uploads/input_image.png"
    audio_path = "uploads/input_audio.wav"

    # 🌐 下載圖片與音訊
    try:
        with open(image_path, "wb") as f:
            f.write(requests.get(image_url, timeout=20).content)
        with open(audio_path, "wb") as f:
            f.write(requests.get(audio_url, timeout=20).content)
    except Exception as e:
        return {"error": f"Failed to download media: {e}"}

    # ✅ 關鍵修正：確保 Python 子程序能找到 hymm_sp 模組
    env = os.environ.copy()
    env["PYTHONPATH"] = "/workspace"

    # ▶️ 執行推理命令
    cmd = [
        "python", "hymm_sp/inference.py",
        "--config", "configs/hunyuan_avatar.yaml",
        "--image_path", image_path,
        "--audio_path", audio_path,
        "--output_dir", "results"
    ]

    try:
        result = subprocess.run(
            cmd,
            check=True,
            capture_output=True,
            text=True,
            cwd="/workspace",       # ⬅️ 確保在正確目錄執行
            env=env                 # ⬅️ 子進程能 import hymm_sp
        )

        video_path = "results/avatar_out.mp4"
        if os.path.exists(video_path):
            return {
                "status": "success",
                "video_path": video_path,
                "stdout": result.stdout[-500:]
            }
        else:
            return {
                "status": "failed",
                "message": "No video generated",
                "stdout": result.stdout[-500:],
                "stderr": result.stderr[-500:]
            }

    except subprocess.CalledProcessError as e:
        return {
            "error": f"Inference failed: {e}",
            "stderr": e.stderr[-500:] if e.stderr else None
        }

# ✅ RunPod Serverless 啟動點
runpod.serverless.start({"handler": handler})
