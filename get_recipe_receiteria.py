import csv
import requests
from bs4 import BeautifulSoup

def make_soup(url):
    response = requests.get(url)
    response.raise_for_status()
    return BeautifulSoup(response.content, 'html.parser')

def extract_title(soup):
    title_element = soup.find('h1')
    if title_element:
        return title_element.get_text().strip()
    else:
        raise ValueError("Não foi possível extrair o título da receita.")

def extract_portions(soup):
    portion_element = soup.find('span', class_='align-middle')
    if portion_element:
        portions_text = portion_element.get_text().strip()
        return portions_text
    else:
        print("Elemento de porções não encontrado.")
    
def extract_ingredients(soup):
    ingredient_elements = soup.find('div', class_='ingredientes').find_all('li')
    ingredient_list = []
    for ingredient_element in ingredient_elements:
        ingredient_text = ingredient_element.get_text(strip=True)
        ingredient_list.append(ingredient_text)
    if ingredient_list:
        return ingredient_list
    else:
        print("Elemento de ingredientes não encontrado.")

def extract_directions(soup):
    elements_ol = soup.find_all('ol', class_='lista-preparo-1')
    directions = []
    for element in elements_ol:
        span_elements = element.find_all('span')
        for span_element in span_elements:
            directions.append(span_element.get_text())
    if directions: 
        return directions
    else:
        elements_ol = soup.find_all('ol', class_='noimg')
        for element in elements_ol:
            span_elements = element.find_all('li')
            for span_element in span_elements:
                directions.append(span_element.get_text())
        return directions

def main():
    with open('links_receitas_receiteria.txt', 'r') as file:
        links = [line.strip() for line in file]

    with open('receitas_completas_receiteria.csv', 'w', newline='', encoding='utf-8') as csvfile:
        fieldnames = ['Receita', 'Porções', 'Ingredientes', 'Instruções']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
    
        for recipe in links:
            try:
                soup = make_soup(recipe)
                title = extract_title(soup)
                portions = extract_portions(soup)
                ingredients = extract_ingredients(soup)
                directions = extract_directions(soup)

                writer.writerow({'Receita': title, 'Porções': portions, 'Ingredientes': ingredients, 'Instruções': directions})
            except Exception as e:
                print(e)

main()
