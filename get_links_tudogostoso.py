from selenium.webdriver.support.wait import WebDriverWait
from selenium.common.exceptions import NoSuchElementException, TimeoutException, ElementClickInterceptedException
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from selenium import webdriver

import time

# o URL vai ter que ser de mais de um site
URL = f'https://www.tudogostoso.com.br/receitas'
FILE_NAME = 'links_receitas_tudogostoso.txt'
EMPTY_LINKS = 'recipe_empty.txt'
PATTERN = 'tudogostoso.com.br/receita/'

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
        recipe_elements = my_webpage.find_elements(By.CSS_SELECTOR, 'h2.card-title a')
        for element in recipe_elements:
            link_element = element.get_attribute('href')
            recipe_links.append(link_element)
    except NoSuchElementException:
        pass
    return recipe_links

def get_links_from_site(recipe_driver, num_pages=5):
    all_pages_links = []
    for i in range(num_pages):
        page = get_links_from_one_page(recipe_driver)
        all_pages_links.append(page)
        try:
            next_page_link_element = recipe_driver.find_element(By.XPATH, '//span[text()="Próximo"]/parent::a')
            # Clica no link para ir para a próxima página
            next_page_link_element.click()
            time.sleep(5)
            print(f'Página {i} dados coletados')
        except NoSuchElementException:
            print('Fim das receitas')
            continue
        except ElementClickInterceptedException:
            print('Banner de cookies está obscurecendo o botão "Próximo"')
            try:
                # Encontrar o botão OK para fechar o banner de cookies
                ok_button = recipe_driver.find_element(By.CLASS_NAME, 'cookie-banner-close')
                ok_button.click()
                time.sleep(2)
                print('Banner de cookies fechado')
            except NoSuchElementException:
                print('Não foi possível encontrar o botão "OK" para fechar o banner de cookies')
                break
    return all_pages_links

def extract_links_to_file(file_name):
    recipe_driver = connect()

    element = recipe_driver.find_element(By.CSS_SELECTOR, "a#batchsdk-ui-alert__buttons_negative")
    element.click()

    recipe_links = get_links_from_site(recipe_driver)

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