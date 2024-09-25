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
            except (ValueError, TypeError, IndexError):
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
