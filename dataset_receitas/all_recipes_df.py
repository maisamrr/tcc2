import pandas as pd

file_cybercook = 'receitas_completas_cybercook.csv'
file_receiteria = 'receitas_completas_receiteria.csv'

df_cybercook = pd.read_csv(file_cybercook)
# print("Número de linhas Cybercook:", df_cybercook.shape[0])
df_receiteria = pd.read_csv(file_receiteria)
# print("Número de linhas Receiteria:", df_receiteria.shape[0])

df_cybercook.drop_duplicates(subset='Receita', keep='first', inplace=True)
df_receiteria.drop_duplicates(subset='Receita', keep='first', inplace=True)

df_combined = pd.concat([df_cybercook, df_receiteria], axis=0)
print("Número de linhas:", df_combined.shape[0])

if df_combined.isnull().values.any():
    print("Há pelo menos uma célula vazia no DataFrame.")
else:
    print("Não há células vazias no DataFrame.")

print(df_combined)