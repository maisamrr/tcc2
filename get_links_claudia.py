from selenium.common.exceptions import NoAlertPresentException
from selenium.webdriver.support.wait import WebDriverWait
from selenium.common.exceptions import NoSuchElementException, TimeoutException
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from selenium import webdriver
import time

# o URL vai ter que ser de mais de um site
URL = f'https://claudia.abril.com.br/receitas'
FILE_NAME = 'links_receitas_claudia.txt'
EMPTY_LINKS = 'recipe_empty.txt'
PATTERN = 'claudia.abril.com.br/receitas'

def connect(url=URL):
    driver = webdriver.Firefox()
    try:
        driver.get(url)
        time.sleep(5)
    except TimeoutException:
        print('Estabelecendo nova conexão')
        driver.get(url)
        time.sleep(5)

    return driver

def get_links_from_one_page(my_webpage):
    recipe_links = []
    try:
        # Encontra todos os elementos <a> dentro dos elementos com a classe 'receita card not-loaded list-item'
        recipe_elements = my_webpage.find_elements(By.CSS_SELECTOR, '.receita.card.not-loaded.list-item a')
        for element in recipe_elements:
            # Extrai o valor do atributo href
            link = element.get_attribute('href')
            recipe_links.append(link)
    except NoSuchElementException:
        pass
    return recipe_links

def get_links_from_site(recipe_driver, num_clicks):
    all_pages_links = []
    for _ in range(num_clicks):
        page = get_links_from_one_page(recipe_driver)
        all_pages_links.append(page)
        try:
            recipe_driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
            load_more_button = recipe_driver.find_element(By.XPATH, '//button[contains(text(), "Carregar mais")]')
            load_more_button.click()
            time.sleep(5)
            recipe_driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
            print(f'Mais receitas carregadas')
        except NoSuchElementException:
            print('Fim das receitas')
            break
    return all_pages_links

def extract_links_to_file(file_name):
    recipe_driver = connect()

    recipe_links = get_links_from_site(recipe_driver, 1)

    output_recipe_links = open(file_name, 'w')
    empty_links = open(EMPTY_LINKS, 'w')
    for link_list in recipe_links:
        for url in link_list:
            if url.__contains__(PATTERN):
                output_recipe_links.write(url + '\n')
            else:
                empty_links.write(url + '\n')
    output_recipe_links.close()
    empty_links.close()

    print(f'Links salvos em {file_name}')

if __name__ == '__main__':
    pass

def main():
    # Obter todos os links do site
    links_file = FILE_NAME
    extract_links_to_file(links_file)
    print('Programa concluído')

main()