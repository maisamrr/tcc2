import pandas as pd
import firebase_admin
from firebase_admin import credentials, db
from unidecode import unidecode
import re

# Inicializar o Firebase com as credenciais e URL do banco de dados
cred = credentials.Certificate('../secrets/serviceAccountKey.json')
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://tcc2-notasculinarias-default-rtdb.firebaseio.com'
})

# Referência ao nó de receitas
recipes_ref = db.reference('recipes')

# Apagar todas as receitas existentes
recipes_ref.delete()

# Carregar o dataset
df = pd.read_csv('./data/todas_receitas_porcoeslimpas.csv')

# Inserir as novas receitas com ID personalizado
for index, row in df.iterrows():
    # Remove acentos e caracteres especiais do nome da receita
    recipe_id = unidecode(row['Receita']).replace(" ", "_")  # Remove acentos e substitui espaços por underscores
    recipe_id = re.sub(r'\W+', '', recipe_id)  # Remove caracteres não alfanuméricos

    recipe_ref = recipes_ref.child(recipe_id)
    recipe_ref.set({
        'title': row['Receita'],
        'portions': row['Porções'],
        'ingredients': row['Ingredientes'].split(','), 
        'instructions': row['Instruções'].split(','),
    })

print("Importação de receitas concluída com sucesso.")
