from get_recipes import FILE_NAME, extract_links_to_file

def main():
    """
    Função principal para coletar links das receitas e armazená-los em um arquivo de texto.
    """
    # Obter todos os links do site
    links_file = FILE_NAME
    extract_links_to_file(links_file)
    print('Links coletados, o programa foi concluído')


main()
