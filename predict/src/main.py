import sys
from itau.parser import parse as itau_parse
from nubank.parser import parse as nubank_parse
from common.period import by_month
from classification.classification import categorize_identification


parser = sys.argv[1]
if parser == "itau":
    prestacao_contas = itau_parse(sys.argv[2], by_month(sys.argv[3]))
    categorize_identification(prestacao_contas)
elif parser == "nubank":
    prestacao_contas = nubank_parse(sys.argv[2])
    categorize_identification(prestacao_contas)
