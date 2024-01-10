from flask import Flask, request

app = Flask(__name__)

@app.route('/generate', methods=['POST'])
def generate_image():
    if request.method == 'POST':
        data = request.json
        prompt = data['prompt']
        return f"Received prompt {prompt}\n"
    else:
        return "Only POST methods allowed"

@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"

if __name__ == "__main__":
    app.run(debug=True)