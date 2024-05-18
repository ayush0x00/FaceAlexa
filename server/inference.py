from diffusers import AutoPipelineForText2Image
import torch
from diffusers import DiffusionPipeline

#pipeline = DiffusionPipeline.from_pretrained("dataautogpt3/OpenDalleV1.1").to("cuda")
#prompt = "indian man with big round blue eyes"

#image = pipeline(prompt, num_inference_steps=25).images[0]
#image

import torch
from diffusers import StableDiffusionPipeline

pipe = StableDiffusionPipeline.from_pretrained(
    "runwayml/stable-diffusion-v1-5",
    torch_dtype=torch.float16,
    use_safetensors=True,
)

prompt = "a photo of an astronaut riding a horse on mars"
pipe.enable_sequential_cpu_offload()
image = pipe(prompt).images[0]
image
