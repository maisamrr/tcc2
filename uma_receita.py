import requests
from bs4 import BeautifulSoup

import pandas as pd
import numpy as np


url = 'https://www.receiteria.com.br/receita/macarrao-com-carne-moida/'
headers = {"User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36 OPR/108.0.0.0"}
requisicao = requests.get(url, headers = headers)

# print("Requisicao: ", requisicao)

soup = BeautifulSoup(requisicao.text, "html.parser")

nome_receita = soup.find("title").text.strip()
lista_ingredientes = soup.find('div', class_='ingredientes').find_all('label')
ingredientes = [label.get_text() for label in lista_ingredientes]

data = {
    'receita': [],
    'ingredientes': []
}

data['receita'].append(nome_receita)
data['ingredientes'].append(lista_ingredientes)
df = pd.DataFrame(data)

print(df)
