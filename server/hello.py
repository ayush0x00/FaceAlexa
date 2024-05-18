from flask import Flask, request, send_file, jsonify
from lcm_lora_2 import inference, load_pipeline
import random, time
from flask_cors import CORS
import time

app = Flask(__name__)

CORS(app)

is_sdxl = False
    
pipeline = load_pipeline(is_sdxl)

@app.route('/generate', methods=['POST'])
def generate_image():
    if request.method == 'POST':
        data = request.json
        prompt = data['prompt']
        print(f"Generating image with... {prompt}")
        random_int = str(random.randint(1,1000))
        output_path = '{}.png'.format(random_int)
        # result = {"error":False,"image_path":""}
        start = time.time()
        result = inference(pipeline,standard_sdxl=is_sdxl,prompt=prompt,output_path=output_path)
        stop = time.time()
        if not result["error"]:
            result["image_path"]=output_path
        response = jsonify(result)
        response.headers['Content-Type'] = 'application/json'
        response.headers["Access-Control-Allow-Origin"]="*"
        print(f"Generated image in {stop-start} time")
        return response
    else:
        return "Only POST methods allowed"
    
@app.route('/get_image', methods=['GET'])
def get_image():
    if request.method == 'GET':
        image_path = request.args.get('image_path')
        return send_file(image_path,mimetype='image/png')
        

if __name__ == "__main__":
    app.run(debug=True,host='0.0.0.0',port=5000)
