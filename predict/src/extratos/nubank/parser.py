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
        
        linhas_da_entrada = []
        for i in range(len(linhas_relevantes)):
            linha = linhas_relevantes[i]
            linhas_da_entrada.append(linha)

            if i + 1 < len(linhas_relevantes):
                próxima_linha = linhas_relevantes[i + 1]
            

            if é_data(próxima_linha):
                avaliar_linhas(entradas, linhas_da_entrada)
                linhas_da_entrada = []
        else:
            avaliar_linhas(entradas, linhas_da_entrada)


    return entradas


def avaliar_linhas(entradas, l):
    entrada = None
    try:
        if 2 <= len(l) < 4:
            entrada = avaliar_linhas_formato_padrão(l[0:2])
        elif len(l) == 4:
            if l[3].startswith("Conversão:"):
                entrada = avaliar_linhas_formato_conversão(l)
            else:
                entrada = avaliar_linhas_formato_padrão(l[0:2])
    except ValueError:
        return
    
    if entrada is None:
        return

    if "IOF" in entrada[1]:
        return

    if "Pagamento" in entrada[1]:
        return

    if entrada[2] == 0:
        return

    entradas.append(entrada)


def avaliar_linhas_formato_padrão(l):
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


def avaliar_linhas_formato_conversão(l):
    primeira_linha = full_strip(l[0])
    data_criação = primeira_linha + " " + str(datetime.now().year)
    data_criação = to_str(to_date(data_criação))

    descrição = full_strip(l[1])

    preço = full_strip(l[3])
    preço = preço.rsplit(" ", 1)[1].replace(".", "").replace(",", ".").replace("R$", "")
    preço = float(preço) * -1.0

    return (
        data_criação,
        descrição,
        preço
    )


def é_data(linha):
    primeira_linha = full_strip(linha)
    data_criação = primeira_linha + " " + str(datetime.now().year)

    try:
        to_date(data_criação)
        return True
    except ValueError:
        return False
