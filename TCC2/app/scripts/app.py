import json
from flask import Flask, request, jsonify
from process_receipt import process_receipt_logic

app = Flask(__name__)

@app.route('/')
def home():
    return "Servidor Flask"

@app.route('/process_receipt', methods=['POST'])
def process_note():
    data = request.json
    extracted_data = data.get('data')

    if not extracted_data:
        return jsonify({'error': 'Data not provided'}), 400

    try:
        processed_items = json.loads(extracted_data)
    except json.JSONDecodeError as e:
        print(f"JSON decode error: {e}")
        return jsonify({'error': 'Invalid data format'}), 400

    result = process_receipt_logic(processed_items)

    if 'error' in result:
        return jsonify(result), 500

    return jsonify(result), 200

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000)