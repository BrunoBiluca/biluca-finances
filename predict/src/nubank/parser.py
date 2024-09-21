from datetime import datetime
from budget import headers
from budget.budget_date import to_str
from common.csv_file import read, write
from nubank.entry import to_date
from common.str_extensions import full_strip


def parse(pages):
    print("Início do parse do Nubank")

    entradas = []
    for p in pages[3:]:
        linhas = p.extract_text().split("\n")
        linhas_relevantes = linhas[3:len(linhas)-3]
        linhas_por_entrada = 4
        for i in range(0, len(linhas_relevantes), linhas_por_entrada):
            entrada = avaliar_linhas(
                linhas_relevantes[i: i+linhas_por_entrada])

            if "Pagamento" in entrada[1]:
                continue

            entradas.append(entrada)

    print(f"Recuperado  um total de {len(entradas)} entradas.")
    print("Parse do Nubank concluído")
    return entradas


def avaliar_linhas(l):
    data_criação = full_strip(l[0]) + " " + str(datetime.now().year)
    descrição = full_strip(l[2])
    preço = full_strip(l[3]).replace(".", "").replace(",", ".")

    descrição = descrição.replace('"', "")

    return (
        to_date(data_criação),
        descrição,
        float(preço) * -1.0
    )
