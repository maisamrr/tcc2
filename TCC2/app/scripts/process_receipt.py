import time
import firebase_admin
import pandas as pd
from selenium import webdriver
from twocaptcha import TwoCaptcha
from firebase_admin import credentials, db
from selenium.webdriver.chrome.service import Service

cred = credentials.Certificate('../secrets/serviceAccountKey.json')
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://tcc2-notasculinarias-default-rtdb.firebaseio.com'
})

# credenciais e URLs do CAPTCHA
API_KEY = "22fcaab83c2393cd133542b3b8e75838"
url = "https://ww1.receita.fazenda.df.gov.br/DecVisualizador/Nfce/Captcha?Chave=53240617457404002589653180000642659019629963"
siteKey = "0x4AAAAAAAaOvnbOLak1uio1"
solver = TwoCaptcha(API_KEY)

try:
    result = solver.turnstile(sitekey=siteKey, url=url)
    print("CAPTCHA resolvido: ", result['code'])
except Exception as e:
    print("Erro no CAPTCHA: ", str(e))
    result = None

if result:
    options = webdriver.ChromeOptions()
    service = Service()
    driver = webdriver.Chrome(options=options)

    driver.get(url)
    time.sleep(5)

    # CAPTCHA
    driver.execute_script(f'''
        var elements = document.querySelectorAll("[name='g-recaptcha-response']");
        for (var i = 0; i < elements.length; i++) {{
            elements[i].value = "{result['code']}";
        }}
    ''')
    
    time.sleep(2)

    button = driver.find_element(By.CLASS_NAME, "btn")
    button.get_attribute("value")
    button.click()

  # Pegando a lista com os produtos
    itens_str = driver.find_element(By.XPATH, "//ul").text
    itens_lista = itens_str.split('\n')
    itens_lista = list(filter(None, itens_lista))

    df_all_itens = pd.DataFrame(itens_lista, columns=['Itens'])
    df_just_itens_name = df_all_itens[df_all_itens['Itens'].str.contains(r'\(Cód: \w+\)')].reset_index(drop=True)

    # Limpeza dos nomes dos produtos
    df_just_itens_name['Itens'] = df_just_itens_name['Itens'].str.replace(r' \(Cód: S\d+\)', '', regex=True)
    df_just_itens_name['Itens'] = df_just_itens_name['Itens'].str.replace(r'\d+[Xx]\d+\w*|\d+\w*|\d+', '', regex=True)
    df_just_itens_name['Itens'] = df_just_itens_name['Itens'].str.strip()
    df_just_itens_name['Primeira Palavra'] = df_just_itens_name['Itens'].str.split().str[0]

    # salvar no firebase
    items = df_just_itens_name['Itens'].tolist()

    # nó onde as notas fiscais serão armazenadas
    ref = db.reference('receipts')
    new_receipt_ref = ref.push()

    # Dados da nota fiscal para armazenar no Firebase
    receipt_data = {
        "url": url,
        "items": items,
        "timestamp": int(time.time())
    }

    # Salvar os dados no Realtime Database
    new_receipt_ref.set(receipt_data)

    print("Nota fiscal armazenada com sucesso.")
    driver.quit()