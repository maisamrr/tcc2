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
    receipt_id = data.get('receipt_id')
    if not extracted_data or not receipt_id:
        return jsonify({'error': 'Nota fiscal sem conteúdo ou identificação.'}), 400

    processed_items = extracted_data

    result = process_receipt_logic(processed_items, receipt_id)

    if 'error' in result:
        return jsonify(result), 500

    return jsonify(result), 200

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000)