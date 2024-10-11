import pandas as pd
import numpy as np
from flask import Flask, request, jsonify
from process_receipt import process_receipt_logic
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

app = Flask(__name__)

cached_ingredients_list = None

def levenshtein_distance(s1, s2):
    if len(s1) < len(s2):
        return levenshtein_distance(s2, s1)

    if len(s2) == 0:
        return len(s1)

    previous_row = range(len(s2) + 1)
    for i, c1 in enumerate(s1):
        current_row = [i + 1]
        for j, c2 in enumerate(s2):
            insertions = previous_row[j + 1] + 1
            deletions = current_row[j] + 1
            substitutions = previous_row[j] + (c1 != c2)
            current_row.append(min(insertions, deletions, substitutions))
        previous_row = current_row
    
    return previous_row[-1]

def find_best_match_manual(item, ingredients):
    distances = [levenshtein_distance(item, ingredient) for ingredient in ingredients]
    min_distance_index = np.argmin(distances)
    return ingredients[min_distance_index]

def load_ingredients():
    global cached_ingredients_list
    if cached_ingredients_list is None:
        all_ingredients_df = pd.read_csv('data/all_ingredients.csv')
        cached_ingredients_list = all_ingredients_df['Ingrediente'].str.lower().tolist()
    return cached_ingredients_list

def clean_extracted_data(processed_items):
    df = pd.DataFrame(processed_items)
    df['item_name'] = df['item_name'].str.replace(r' \(Cód: \)', '', regex=True)
    return df['item_name'].str.lower().tolist()

def map_items_to_ingredients(items_list, ingredients_list):
    return [find_best_match_manual(item, ingredients_list) for item in items_list]

def calculate_similarity(mapped_items_manual):
    recipes_df = pd.read_csv('data/recipes_levenshtein.csv')
    receitas_ingredients = recipes_df['Ingredientes']

    # Preparar as strings de ingredientes para o cálculo de TF-IDF
    nota_ingredients_str = " ".join(mapped_items_manual)
    receitas_ingredients_str = receitas_ingredients.apply(lambda x: " ".join(eval(x)))

    # Criar o vetorizador TF-IDF e calcular a similaridade
    tfidf_vectorizer = TfidfVectorizer()
    tfidf_matrix = tfidf_vectorizer.fit_transform([nota_ingredients_str] + receitas_ingredients_str.tolist())
    
    # Calcular a similaridade coseno entre a nota fiscal e as receitas
    cosine_similarities = cosine_similarity(tfidf_matrix[0:1], tfidf_matrix[1:]).flatten()

    # Encontrar a receita com a maior similaridade e verificar a relevância
    best_match_index = cosine_similarities.argmax()
    best_match_score = cosine_similarities[best_match_index]
    
    if best_match_score < 0.1:
        return {'message': 'Nenhuma receita relevante encontrada', 'score': best_match_score}
    
    best_match_recipe = recipes_df.iloc[best_match_index]
    best_match_recipe['similarity_score'] = best_match_score
    return best_match_recipe

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

    ingredients_list = load_ingredients()
    cleaned_items = clean_extracted_data(processed_items)
    mapped_items_manual = map_items_to_ingredients(cleaned_items, ingredients_list)

    best_match_recipe = calculate_similarity(mapped_items_manual)
    print(best_match_recipe)
    
    return jsonify(result), 200

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000)