# from diffusers import AutoPipelineForText2Image
# import torch
from diffusers import DiffusionPipeline

pipeline = DiffusionPipeline.from_pretrained("dataautogpt3/OpenDalleV1.1")
prompt = "indian man with big round blue eyes"

image = pipeline(prompt, num_inference_steps=25).images[0]
image