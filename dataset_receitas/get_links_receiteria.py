import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import NoSuchElementException, TimeoutException

URL = f'https://www.receiteria.com.br/especiais/'
FILE_NAME = 'links_receitas_receiteria.txt'
EMPTY_LINKS = 'recipe_empty.txt'
PATTERN = 'receiteria.com.br/receita/'

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
        recipe_elements = my_webpage.find_elements(By.CSS_SELECTOR, 'div.media.hover-zoom a')
        for element in recipe_elements:
            link_element = element.get_attribute('href')
            recipe_links.append(link_element)
    except NoSuchElementException:
        pass
    return recipe_links

def save_links_to_file(links, file_name):
    with open(file_name, 'w') as file:
        for link in links:
            file.write(link + '\n')

def main():
    mydriver = connect()

    all_pages_links = get_links_from_one_page(mydriver)

    qt_recipes = 1000
    while len(all_pages_links) < qt_recipes:
        mydriver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
        time.sleep(10)
        time.sleep(10)

        load_more_button = WebDriverWait(mydriver, 10).until(EC.presence_of_element_located((By.CSS_SELECTOR, 'button.alm-load-more-btn')))

        try:
            mydriver.execute_script("arguments[0].scrollIntoView(true);", load_more_button)
            time.sleep(10)
            load_more_button.click()
        except Exception as e:
            print(f'Erro ao clicar no botão "Carregar Mais": {e}')
            break
        len(all_pages_links)
        all_pages_links = get_links_from_one_page(mydriver)

    save_links_to_file(all_pages_links, FILE_NAME)
    print('Qtd total de receitas coletadas: ', len(all_pages_links))
    print(f'Links salvos em "{FILE_NAME}"')
    print('Programa concluído')

if __name__ == '__main__':
    main()
