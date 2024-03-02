from budget import headers
from budget.budget_date import to_date, to_str
from common.csv_file import read, write

from common.str_extensions import full_strip


def parse(path, period=None):
    print("Início do parse do Itaú")
    budget = []
    for e in read(path):
        properties = full_strip(e).split(" ", 1)

        try:
            date = to_date(properties[0])
            description, value = properties[1].rsplit(" ", 1)

            if description == "SALDO DO DIA":
                continue

            budget.append({
                "date": date,
                "description": description,
                "value": value
            })
        except ValueError:
            continue

    formated_budget = []
    start = period[0]
    end = period[1]
    print("Filtrando para o período", to_str(start), "-", to_str(end))
    filtered_budget = list(filter(lambda e: start <= e["date"] <= end, budget))
    print("Foram encontrados", len(filtered_budget), "registros")
    for e in filtered_budget:
        value = e["value"].replace(".", "").replace(",", ".")
        formated_budget.append([
            to_str(e["date"]),
            e["description"],
            value,
            "saída" if value[0] == '-' else "entrada",
            ""
        ])

    return write("itau.csv", [headers(), *formated_budget])
