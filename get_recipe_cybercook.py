import requests
from urllib.parse import urlparse
from bs4 import BeautifulSoup

site = 'https://cybercook.com.br/receitas/bolos/bolo-de-milho-1641'
rec = 'https://cybercook.com.br/receitas/lanches/receita-de-esfiha-aberta-de-carne-3285'
rec2 = 'https://cybercook.com.br/receitas/bolos/receita-de-bolo-de-cenoura-13975'

def extract_title(url):
    response = requests.get(url)
    if response.status_code == 200:
        soup = BeautifulSoup(response.content, 'html.parser')
        title_element = soup.select_one('h1.text-3xl.lg\\:text-4xl.sm\\:text-xlg.xs\\:text-lg.font-title.font-bold.text-gray-650.mt-4')
        if title_element:
            return title_element.get_text().strip()
        else:
            print("Não foi possível extrair o título da receita.")
    else:
        print("Erro.")

#não consegui identificar diretamente as porções, só recorrendo a img...
def extract_portions(url):
    response = requests.get(url)
    if response.status_code == 200:
        soup = BeautifulSoup(response.content, 'html.parser')
        img_tag = soup.find('img', alt='Porção')
        if img_tag:
            portions_text = img_tag.find_next('p').get_text(strip=True)
            return portions_text
        else:
            print("Não foi possível extrair as porções da receita.")
    else:
        print("Erro.")

def extract_ingredients(url):
    response = requests.get(url)
    soup = BeautifulSoup(response.content, 'html.parser')
    elements = soup.find_all('p', class_='font-normal')
    for element in elements:
        print(element.get_text())

def extract_directions(url):
    response = requests.get(url)
    soup = BeautifulSoup(response.content, 'html.parser')
    elements_li = soup.find_all('li', class_='flex items-center mb-3 text-gray-600')
    for element in elements_li:
        p_elements = element.find_all('p', class_='text-base')
        for p_element in p_elements:
            print(p_element.get_text())
    
def main():
    title_recipe = extract_title(site)
    portions_recipe =  extract_portions(site)
    print(title_recipe)
    print(portions_recipe)
    extract_ingredients(site)
    extract_directions(site)

    # title_recipe1 = extract_title(rec)
    # portions_recipe1 =  extract_portions(rec)
    # print(title_recipe1)
    # print(portions_recipe1)

    # title_recipe2 = extract_title(rec2)
    # portions_recipe2 =  extract_portions(rec2)
    # print(title_recipe2)
    # print(portions_recipe2)

main()
