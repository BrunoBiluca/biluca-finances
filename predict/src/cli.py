import sys

import pandas
from itau.parser import parse as itau_parse
from nubank.parser import parse as nubank_parse
from common.period import by_month
from common.csv_file import write
from classification.classification import categorize_identification
from budget import headers


parser = sys.argv[1]
if parser == "itau":
    prestacao_contas = itau_parse(sys.argv[2], by_month(sys.argv[3]))
    final = categorize_identification(pandas.read_csv(prestacao_contas))
    write("itau_final.csv", [headers(), *final.values.tolist()])
elif parser == "nubank":
    prestacao_contas = nubank_parse(sys.argv[2])
    final = categorize_identification(pandas.read_csv(prestacao_contas))
    write("nubank_final.csv", [headers(), *final.values.tolist()])