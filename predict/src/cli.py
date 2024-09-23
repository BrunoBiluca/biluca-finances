import sys

import pandas
from pypdf import PdfReader
from itau import é_itau_extrato, itau_parse
from nubank import é_nubank_extrato, nubank_parse
from classification.classification import categorize_identification


file_path = sys.argv[1]
print("Avaliando arquivo:", file_path)

reader = PdfReader(file_path)

analisadores = {
    "itau": [é_itau_extrato, itau_parse],
    "nubank": [é_nubank_extrato, nubank_parse]
}

for a in analisadores:
    avaliador = analisadores[a][0]
    if avaliador(reader.pages):
        print("Avaliando um extrato de:", a)
        parser = analisadores[a][1]
        entradas = parser(reader.pages)
        print("Foram encontrados", len(entradas), "entradas")

        df = pandas.DataFrame(
            entradas, columns=["Criação", "Descrição", "Valor"])
        result = categorize_identification(df)
        print("Foram predizidos", len(result), "registros")
