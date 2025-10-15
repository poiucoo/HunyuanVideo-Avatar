import runpod
from hymm_gradio import app

def handler(event):
    app.demo.launch()
    return {"status": "Avatar service started."}

runpod.serverless.start({"handler": handler})
