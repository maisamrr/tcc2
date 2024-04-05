import csv
from recipe_scrapers import scrape_me, SCRAPERS
from urllib.parse import urlparse

site = ['https://cybercook.com.br/receitas/doces/pudim-de-leite-condensado-8595',
        'https://cybercook.com.br/receitas/aves/receita-de-fricasse-de-frango-14641']

# Create a list to store the scraped data
scraped_data = []

for url in site:
    domain = urlparse(url).netloc.replace("www.", "")
    if domain in SCRAPERS:
        scraper = scrape_me(url)
        title = scraper.title()
        yields = scraper.yields()
        ingredients = scraper.ingredients()
        instructions = scraper.instructions()

        # Append the scraped data to the list
        scraped_data.append([title, yields, ingredients, instructions])

    else:
        print(f'\nSorry, {url} is not currently supported.')

# Write the scraped data to a CSV file
with open('test.csv', "w", encoding="utf-8") as recipes_file:
    recipe_writer = csv.writer(recipes_file, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
    recipe_writer.writerow(['Title', 'Servings', 'Ingredients', 'Instructions'])
    for data in scraped_data:
        recipe_writer.writerow(data)
