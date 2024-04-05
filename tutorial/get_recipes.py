from selenium.common.exceptions import NoAlertPresentException
from selenium.webdriver.support.wait import WebDriverWait
from selenium.common.exceptions import NoSuchElementException, TimeoutException
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from selenium import webdriver
import time

URL = f"https://cybercook.com.br/receitas"
FILE_NAME = 'links_receitas.txt'
EMPTY_LINKS = 'recipe_empty.txt'
PATTERN = 'cybercook.com.br/receitas/'

def connect(url=URL):
    """
    create chrome driver
    :return: chrome driver:obj
    """
    driver = webdriver.Firefox()
    try:
        driver.get(url)
        time.sleep(5)
    except TimeoutException:
        print('new connection try')
        driver.get(url)
        time.sleep(5)

    return driver


def get_links_from_one_page(my_webpage):
    """
    To collect links for each recipe from one page
    :param my_webpage: link to page for scrapping: selenium obj
    :return: links from one page: list[str]
    """
    recipe_links = []
    try:
        # Encontra todos os elementos <a> que têm um atributo href começando com '/receitas/'
        recipe_elements = my_webpage.find_elements(By.CSS_SELECTOR, 'a[href^="/receitas/"]')
        for element in recipe_elements:
            # Extrai o valor do atributo href
            link = element.get_attribute('href')
            recipe_links.append(link)
    except NoSuchElementException:
        pass
    return recipe_links

def get_links_from_site(recipe_driver, num_pages=3):
    """
    To list pages on website and collect links into list
    :param recipe_driver: obj  chrome driver
    :param num_pages: int number of pages to scrap / default 132
    :return: list of links
    """
    all_pages_links = []
    for i in range(num_pages):

        # get links from one page
        page = get_links_from_one_page(recipe_driver)
        all_pages_links.append(page)

        try:
            # go to next page
            recipe_driver.find_element(By.CSS_SELECTOR,'a[rel="next"]').click()
            time.sleep(5)
            print(f'page {i + 1} is collected')
        except NoSuchElementException:
            print('I guess the page have no more recipes')
            continue
    return all_pages_links


def extract_links_to_file(file_name):
    """
    To write down links into .txt file
    :param file_name: output filename / FILE_NAME in the same dir
    :return: void
    """
    # create a driver
    recipe_driver = connect()

    # collect links
    recipe_links = get_links_from_site(recipe_driver)

    # write down links to the txt file
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

    print(f'links are in {file_name} file')

if __name__ == '__main__':
    pass
