from datetime import datetime
from budget import headers
from budget.budget_date import to_str
from common.csv_file import read, write
from nubank.entry import to_date
from common.str_extensions import full_strip


def parse(path):
    print("Início do parse do Nubank")
    invoice = []
    for e in read(path):
        properties = full_strip(e)

        try:
            date = to_date(properties[0:6])
            date = datetime(day=date.day, month=date.month, year=2024)
            description, value = properties[6:].rsplit(" ", 1)
            description = full_strip(description)

            if "Pagamento" in description:
                continue

            invoice.append({
                "date": date,
                "description": description,
                "value": value
            })
        except ValueError:
            continue

    formated_budget = []
    for e in invoice:
        value = e["value"].replace(".", "").replace(",", ".")
        formated_budget.append([
            to_str(e["date"]),
            e["description"],
            float(value) * -1.0,
            "saída",
            ""
        ])
    return write("nubank.csv", [headers(), *formated_budget])
