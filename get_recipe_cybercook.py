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

#não consegui identificar diretamente as porções, só recorrendo a img...
def extract_portions(soup):
    img_tag = soup.find('img', alt='Porção')
    if img_tag:
        portions_text = img_tag.find_next('p').get_text(strip=True)
        return portions_text
    else:
        raise ValueError("Não foi possível extrair as porções da receita.")
    
def extract_ingredients(soup):
    elements = soup.find_all('p', class_='font-normal')
    ingredients = [element.get_text() for element in elements]
    return ingredients

def extract_directions(soup):
    elements_li = soup.find_all('li', class_='flex items-center mb-3 text-gray-600')
    directions = []
    for element in elements_li:
        p_elements = element.find_all('p', class_='text-base')
        for p_element in p_elements:
            directions.append(p_element.get_text())
    return directions
    
def main():
    with open('links_receitas_cybercook.txt', 'r') as file:
        links = [line.strip() for line in file]

    with open('receitas_completas_cybercook.csv', 'w', newline='', encoding='utf-8') as csvfile:
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
