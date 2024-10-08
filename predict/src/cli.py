import sys

import pandas
from pypdf import PdfReader
from extratos.itau import é_itau_extrato, itau_parse
from extratos.nubank import é_nubank_extrato, nubank_parse
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