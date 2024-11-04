import pandas as pd
import numpy as np
import re
from flask import Flask, request, jsonify
from process_receipt import process_receipt_logic
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

app = Flask(__name__)

cached_ingredients_list = None
def ordenar_instrucoes(instrucoes):
    def extrair_numero(instrucao):
        match = re.match(r'^(\d+)\.', instrucao)  # Procura por um número seguido de ponto
        return int(match.group(1)) if match else float('inf')  # Retorna o número ou um valor alto se não encontrar

    # Ordenar as instruções com base no número extraído
    instrucoes_ordenadas = sorted(instrucoes, key=extrair_numero)
    return instrucoes_ordenadas

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

def get_correct_ingredients(recipe_name):
    # Carregar o CSV que contém os ingredientes corretos
    receitas_porcoes_df = pd.read_csv('data/todas_receitas_porcoeslimpas.csv')

    # Procurar a receita pelo nome e pegar os ingredientes corretos
    receita = receitas_porcoes_df[receitas_porcoes_df['Receita'].str.lower() == recipe_name.lower()]
    
    if not receita.empty:
        ingredientes_str = receita.iloc[0]['Ingredientes']
        # Retornar a lista de ingredientes
        return eval(ingredientes_str)  # Transformar string de volta em lista
    else:
        return []


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

    # Pegar os índices das 3 receitas com maior similaridade
    top_3_indices = cosine_similarities.argsort()[-3:][::-1]
    top_3_scores = cosine_similarities[top_3_indices]

    if top_3_scores[0] < 0.1:
        return {'message': 'Nenhuma receita relevante encontrada', 'scores': top_3_scores.tolist()}

    top_3_recipes = recipes_df.iloc[top_3_indices].copy()
    top_3_recipes.loc[:, 'similarity_score'] = top_3_scores

    return top_3_recipes


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

    top_3_recipes = calculate_similarity(mapped_items_manual)

    if 'message' in top_3_recipes:
        return jsonify(top_3_recipes), 200

    # Construir a resposta com as 3 melhores receitas
    recipes_response = []
    for _, row in top_3_recipes.iterrows():
        # Obter os ingredientes corretos da receita usando o nome da receita
        ingredientes_list = get_correct_ingredients(row['Receita'])

        instrucoes_list = eval(row['Instruções'])

        # Ordenar as instruções
        instrucoes_ordenadas = ordenar_instrucoes(instrucoes_list)

        # Adicionar cada receita ao resultado
        recipes_response.append({
            'Receita': row['Receita'],
            'Porções': int(row['Porções']),
            'Ingredientes': list(ingredientes_list),
            'Instruções': instrucoes_ordenadas,  # Instruções ordenadas
            'similarity_score': float(row['similarity_score']),
        })
    
    return jsonify(recipes_response), 200

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000)