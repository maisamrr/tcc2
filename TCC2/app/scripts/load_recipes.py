import pandas as pd
import firebase_admin
from firebase_admin import credentials, db

cred = credentials.Certificate('../etc/secrets/serviceAccountKey.json')
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://tcc2-notasculinarias-default-rtdb.firebaseio.com'
})

df = pd.read_csv('/Users/maisamoreira/Desktop/CCO/TCC1/codigo/dataset_receitas/todas_receitas_porcoeslimpas.csv')
recipes_ref = db.reference('recipes')

for index, row in df.iterrows():
    new_recipe_ref = recipes_ref.push()
    new_recipe_ref.set({
        'title': row['Receita'],
        'portions': row['Porções'],
        'ingredients': row['Ingredientes'].split(','), 
        'instructions': row['Instruções'].split(','),
    })

print("Importação de receitas concluída com sucesso.")