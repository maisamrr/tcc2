import time
import json
import pandas as pd
import firebase_admin
from firebase_admin import credentials, db, firestore
from selenium import webdriver
from twocaptcha import TwoCaptcha
from selenium.webdriver.common.by import By
from firebase_admin import credentials, firestore
from selenium.webdriver.chrome.service import Service

cred = credentials.Certificate('../secrets/serviceAccountKey.json')
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://tcc2-notasculinarias-default-rtdb.firebaseio.com'
})

with open('../secrets/api_key.json') as config_file:
    config = json.load(config_file)
API_KEY = config['API_KEY']
solver = TwoCaptcha(API_KEY)

def process_receipt_logic(url):
    try:
        print(f"Recebido URL: {url}")  
        # Start Selenium driver and perform actions
        options = webdriver.ChromeOptions()
        service = Service()
        driver = webdriver.Chrome(options=options)
        driver.get(url)
         
        time.sleep(5)

        print("Scraping items...")
        itens_str = driver.find_element(By.XPATH, "//ul").text
        
        # Process scraped items
        print("Processing scraped items")
        itens_lista = itens_str.split('\n')
        itens_lista = list(filter(None, itens_lista))

        df_all_itens = pd.DataFrame(itens_lista, columns=['Itens'])
        df_just_itens_name = df_all_itens[df_all_itens['Itens'].str.contains(r'\(Cód: \w+\)')].reset_index(drop=True)
        df_just_itens_name['Itens'] = df_just_itens_name['Itens'].str.replace(r' \(Cód: S\d+\)', '', regex=True)
        df_just_itens_name['Itens'] = df_just_itens_name['Itens'].str.replace(r'\d+[Xx]\d+\w*|\d+\w*|\d+', '', regex=True)
        df_just_itens_name['Itens'] = df_just_itens_name['Itens'].str.strip()
        df_just_itens_name['Primeira Palavra'] = df_just_itens_name['Itens'].str.split().str[0]

        # Store in Firebase
        print("Storing data in Firebase")
        ref = db.reference('processed_notes')
        for _, row in df_just_itens_name.iterrows():
            ref.push({
                'item_name': row['Itens'],
                'first_word': row['Primeira Palavra']
            })

        return {'message': 'Nota processada com sucesso.', 'items': df_just_itens_name.to_dict(orient='records')}

    except Exception as e:
        print("Error processing receipt: ", str(e))
        return {'error': 'Failed to process receipt', 'details': str(e)}

    finally:
        driver.quit()