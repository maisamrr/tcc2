from flask import Flask, request, jsonify
from process_receipt import process_receipt_logic

app = Flask(__name__)

@app.route('/')
def home():
    return "Servidor Flask"

@app.route('/process_receipt', methods=['POST'])
def process_note():
    print("aaaaaaa")
    data = request.json
    print(f"********************************** Recebido: {data}")
    url = data.get('url')

    if not url:
        return jsonify({'error': 'URL não fornecida'}), 400

    # processamento da nota
    result = process_receipt_logic(url)
    
    if 'error' in result:
        return jsonify(result), 500

    return jsonify(result), 200

if __name__ == '__main__':
    app.run(debug=True)