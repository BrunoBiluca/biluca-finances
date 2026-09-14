import sys

import pandas
from pypdf import PdfReader
from src.app.predict.bank_statement_parsers.itau.parser import ItauParser
from src.app.predict.bank_statement_parsers.nubank.parser import NubankParser
from src.app.predict.classification.classification import categorize_identification


file_path = sys.argv[1]
print("Avaliando arquivo:", file_path)

reader = PdfReader(file_path)

analisadores = [
    ItauParser(),
    NubankParser()
]

for a in analisadores:
    avaliador = analisadores[a][0]
    if avaliador(reader.pages):
        print("Avaliando um extrato de:", a)
        with open(file_path.replace(".pdf", ".txt"), 'w', encoding="utf-8") as f:
            i = 0
            for p in reader.pages:
                i += 1
                f.write(f"<<<<PAGINA_{i}>>>>\n")
                f.write(p.extract_text())
                f.write("\n")

        parser = analisadores[a][1]
        entradas = parser(reader.pages)
        print("Foram encontrados", len(entradas), "entradas")

        df = pandas.DataFrame(
            entradas, columns=["Criação", "Descrição", "Valor"])
        result = categorize_identification(df)
        print("Foram predizidos", len(result), "registros")
        result.to_csv(file_path.replace(".pdf", ".csv"), index=False)
