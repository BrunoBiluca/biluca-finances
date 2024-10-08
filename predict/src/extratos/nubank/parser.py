from datetime import datetime
from extratos.nubank.entry import to_date
from common.str_extensions import full_strip
from budget.budget_date import to_str


def parse(pages):
    entradas = []
    índice_página_transações = 0
    for p in pages:
        linhas = p.extract_text().split("\n")

        if "TRANSAÇÕES" in linhas[2]:
            índice_página_transações = pages.index(p)
            break

    for p in pages[índice_página_transações:]:
        linhas = p.extract_text().split("\n")
        linhas_relevantes = linhas[3:len(linhas)-1]
        linhas_por_entrada = 2
        for i in range(0, len(linhas_relevantes), linhas_por_entrada):
            try:
                entrada = avaliar_linhas(linhas_relevantes[i: i+linhas_por_entrada])
            except ValueError:
                continue

            if "Pagamento" in entrada[1]:
                continue

            if entrada[2] == 0:
                continue

            entradas.append(entrada)

    return entradas


def avaliar_linhas(l):
    primeira_linha = full_strip(l[0])
    data_criação = primeira_linha + " " + str(datetime.now().year)
    data_criação = to_str(to_date(data_criação))

    segunda_linha = full_strip(l[1])

    índice_final = segunda_linha.find("R$")
    índice_final -= 1 if segunda_linha[índice_final-1] == "-" else 0
    descrição = segunda_linha[0:índice_final]
    descrição = full_strip(descrição)
    descrição = descrição.replace('"', "")

    preço = segunda_linha.replace("R$ ", "")
    preço = preço.rsplit(" ", 1)[1].replace(".", "").replace(",", ".")
    preço = float(preço) * -1.0

    return (
        data_criação,
        descrição,
        preço
    )
