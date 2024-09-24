from datetime import datetime
from budget import headers
from budget.budget_date import to_date, to_str
from common.csv_file import read, write

from common.str_extensions import full_strip


def parse(pages):
    entradas = []
    for p in pages:
        linhas = p.extract_text().split("\n")
        for l in linhas:
            if "SALDO DO DIA" in l:
                continue

            try:
                linha_avaliada = avaliar_linhas(l)
                entradas.append(linha_avaliada)
            except (ValueError, TypeError, IndexError) as e:
                continue

    return entradas


def avaliar_linhas(l):
    properties = full_strip(l).split(" ", 1)
    date = properties[0]

    descrição, value = properties[1].rsplit(" ", 1)
    descrição = descrição.replace('"', "")
    return (
        to_str(to_date(date)),
        descrição,
        float(value.replace(".", "").replace(",", "."))
    )

    # print("Início do parse do Itaú")
    # budget = []
    # for e in read(path):
    #     properties = full_strip(e).split(" ", 1)

    #     try:
    #         date = to_date(properties[0])
    #         description, value = properties[1].rsplit(" ", 1)

    #         if description == "SALDO DO DIA":
    #             continue

    #         budget.append({
    #             "date": date,
    #             "description": description,
    #             "value": value
    #         })
    #     except ValueError:
    #         continue

    # formated_budget = []
    # start = period[0]
    # end = period[1]
    # print("Filtrando para o período", to_str(start), "-", to_str(end))
    # filtered_budget = list(filter(lambda e: start <= e["date"] <= end, budget))
    # print("Foram encontrados", len(filtered_budget), "registros")
    # for e in filtered_budget:
    #     value = e["value"].replace(".", "").replace(",", ".")
    #     formated_budget.append([
    #         to_str(e["date"]),
    #         e["description"],
    #         value,
    #         ""
    #     ])

    # return write("itau.csv", [headers(), *formated_budget])
