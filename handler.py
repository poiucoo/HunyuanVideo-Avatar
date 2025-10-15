import runpod
from gradio_server import main

def handler(event):
    return main(event)

runpod.serverless.start({"handler": handler})
