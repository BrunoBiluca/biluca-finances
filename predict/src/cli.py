import sys

import pandas
from pypdf import PdfReader
from itau.parser import parse as itau_parse
from nubank.parser import parse as nubank_parse
from common.period import by_month
from common.csv_file import write
from classification.classification import categorize_identification
from budget import headers


file_path = sys.argv[1]
print(file_path)

reader = PdfReader(file_path)

entradas = nubank_parse(reader.pages)
print(entradas)
df = pandas.DataFrame(entradas, columns=["Criação", "Descrição", "Valor"])
result = categorize_identification(df)
print(result)

# with open("./resources/nubank_sample.txt", "w", encoding="utf8") as f:
#     i = 0
#     for p in reader.pages:
#         i += 1
#         f.writelines(["\n", "Página " + str(i), "\n"])
#         f.writelines(p.extract_text())

