import csv
import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.common.exceptions import NoSuchElementException, TimeoutException

site = 'https://www.tbca.net.br/base-dados/composicao_alimentos.php'

def connect(url):
    driver = webdriver.Firefox()
    try:
        driver.get(url)
        time.sleep(5)
    except TimeoutException:
        print('Estabelecendo nova conexão')
        driver.get(url)
        time.sleep(5)

    return driver

def get_items_from_one_page(my_webpage):
    ingredients = []
    try:
        ingredients_elements = my_webpage.find_elements(By.CSS_SELECTOR, 'table tr td:nth-child(2) a') 
        for element in ingredients_elements:
            item = element.text.strip()
            ingredients.append(item)
    except NoSuchElementException:
        pass
    return ingredients

def get_all_items_from_site(my_driver, num_pages=56): 
    all_ingredients = []
    for i in range(num_pages):
        all_items_from_one_page = get_items_from_one_page(my_driver)
        all_ingredients.extend(all_items_from_one_page)  
        try:
            next_page_link = my_driver.find_element(By.XPATH, "//a[contains(text(),'próxima')]")
            next_page_link.click()
            time.sleep(10)
            print(f'Página {i + 1} dados coletados')
        except NoSuchElementException:
            print('Fim das receitas')
            break
    return all_ingredients

def main():
    ingredients_driver = connect(site)
    ingredients = get_all_items_from_site(ingredients_driver)

    with open('ingredientes.csv', 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(['Ingredientes'])
        for ingredient in ingredients:
            writer.writerow([ingredient])

    print('Ingredientes salvos com sucesso.')

main()
