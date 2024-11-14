import Levenshtein
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
        match = re.match(r'^(\d+)\.', instrucao)
        return int(match.group(1)) if match else float('inf')

    instrucoes_ordenadas = sorted(instrucoes, key=extrair_numero)
    return instrucoes_ordenadas

def levenshtein_distance(s1, s2):
    distance = Levenshtein.distance(s1, s2)
    return distance

def find_best_match_manual(item, ingredients):
    distances = [levenshtein_distance(item, ingredient) for ingredient in ingredients]
    min_distance_index = np.argmin(distances)
    return ingredients[min_distance_index].split(" ")[0]

def load_ingredients():
    global cached_ingredients_list
    if cached_ingredients_list is None:
        all_ingredients_df = pd.read_csv('data/all_ingredients.csv')
        cached_ingredients_list = all_ingredients_df['Ingrediente'].str.lower().tolist()
    return cached_ingredients_list

def get_correct_ingredients(recipe_name):
    receitas_porcoes_df = pd.read_csv('data/todas_receitas_porcoeslimpas.csv')
    receita = receitas_porcoes_df[receitas_porcoes_df['Receita'].str.lower() == recipe_name.lower()]
    if not receita.empty:
        ingredientes_str = receita.iloc[0]['Ingredientes']
        return eval(ingredientes_str)
    else:
        return []

def clean_extracted_data(processed_items):
    df = pd.DataFrame(processed_items)
    df['item_name'] = df['item_name'].str.replace(r' \(Cód: \)', '', regex=True)
    return df['item_name'].str.lower().tolist()

def map_items_to_ingredients(items_list, ingredients_list):
    return [find_best_match_manual(item, ingredients_list) for item in items_list]

def calculate_similarity(mapped_items_manual):
    np.set_printoptions(precision=2, suppress=True, threshold=np.inf)  # Define 2 casas decimais e suprime notação científica
    # Carregar vocabulário de ingredientes a partir do arquivo
    all_ingredients_df = pd.read_csv('data/all_ingredients.csv')
    vocabulario_ingredientes = all_ingredients_df['Ingrediente'].str.lower().tolist()

    # Configurar o TfidfVectorizer com o vocabulário fixo
    tfidf_vectorizer = TfidfVectorizer(vocabulary=vocabulario_ingredientes, max_df=1.0, min_df=1, stop_words=None)


    # Preparar as strings de ingredientes das receitas
    recipes_df = pd.read_csv('data/recipes_levenshtein.csv')
    receitas_ingredients_str = recipes_df['Ingredientes'].apply(lambda x: " ".join(eval(x)))

    # Calcular o TF-IDF das receitas
    tfidf_receitas = tfidf_vectorizer.fit_transform(receitas_ingredients_str)

    # Calcular o TF-IDF da nota fiscal
    nota_ingredients_str = " ".join(mapped_items_manual)  # mapeie os ingredientes da nota fiscal
    tfidf_nota = tfidf_vectorizer.transform([nota_ingredients_str])

    # Calcular a similaridade entre o vetor da nota e os vetores das receitas
    cosine_similarities = cosine_similarity(tfidf_nota, tfidf_receitas).flatten()
    top_3_indices = cosine_similarities.argsort()[-3:][::-1]  # Seleciona os 3 melhores
    # Exibir ingredientes e valores TF-IDF diferentes de 0.0 para a nota fiscal
    feature_names = tfidf_vectorizer.get_feature_names_out()
    print("Ingredientes da Nota Fiscal com valores TF-IDF diferentes de 0.0:", flush=True)
    for i, value in enumerate(tfidf_nota.toarray()[0]):
        if value != 0.0:
            print(f"{feature_names[i]}: {value:.2f}", flush=True)

    # Exibir ingredientes e valores TF-IDF diferentes de 0.0 para as top 3 receitas
    for idx in top_3_indices:
        print(f"\nIngredientes da Receita {idx} com valores TF-IDF diferentes de 0.0:", flush=True)
        for i, value in enumerate(tfidf_receitas[idx].toarray()[0]):
            if value != 0.0:
                print(f"{feature_names[i]}: {value:.2f}")

    # Exibir scores de similaridade das top 3 receitas
    top_3_scores = cosine_similarities[top_3_indices]
    print("Scores de Similaridade das Top 3 Receitas:", top_3_scores, flush=True)

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
    print(f"Itens antes do TF-IDF: {mapped_items_manual}", flush= True)
    top_3_recipes = calculate_similarity(mapped_items_manual)
    if 'message' in top_3_recipes:
        return jsonify(top_3_recipes), 200

    recipes_response = []
    for _, row in top_3_recipes.iterrows():
        ingredientes_list = get_correct_ingredients(row['Receita'])
        instrucoes_list = eval(row['Instruções'])
        instrucoes_ordenadas = ordenar_instrucoes(instrucoes_list)
        recipes_response.append({
            'Receita': row['Receita'],
            'Porções': int(row['Porções']),
            'Ingredientes': list(ingredientes_list),
            'Instruções': instrucoes_ordenadas,
            'similarity_score': float(row['similarity_score']),
        })

    return jsonify(recipes_response), 200

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000, debug=True)