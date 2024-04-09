from recipe_scrapers import scrape_me

scraper = scrape_me('https://tudogostoso.com.br/', wild_mode=True)
# if no error is raised - there's schema available:
scraper.title()