from get_links_cybercook import FILE_NAME, extract_links_to_file

def main():
    # Obter todos os links do site
    links_file = FILE_NAME
    extract_links_to_file(links_file)
    print('Programa concluído')

main()
