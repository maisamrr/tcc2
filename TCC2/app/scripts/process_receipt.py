import json
import pandas as pd
import firebase_admin
from firebase_admin import credentials, db

cred = credentials.Certificate('../secrets/serviceAccountKey.json')
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://tcc2-notasculinarias-default-rtdb.firebaseio.com'
})

def process_receipt_logic(processed_items):
    try:
        print("Itens processados recebidos")
        df_just_itens_name = pd.DataFrame(processed_items)
        
        # Store in Firebase
        print("Salvando no Firebase")
        ref = db.reference('processed_notes')
        for _, row in df_just_itens_name.iterrows():
            ref.push({
                'item_name': row['item_name'],
                'first_word': row['first_word']
            })
        
        return {'message': 'Nota processada com sucesso.', 'items': df_just_itens_name.to_dict(orient='records')}

    except Exception as e:
        print("Erro ao processar nota: ", str(e))
        return {'error': 'Falha ao processar a nota.', 'Detalhes': str(e)}