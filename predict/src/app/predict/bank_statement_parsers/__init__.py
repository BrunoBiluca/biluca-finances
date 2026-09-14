from logging import info
from .itau.parser import ItauParser
from .nubank.parser import NubankParser


def match_parser(filename):
    analisadores = [
        ItauParser(),
        NubankParser()
    ]

    for a in analisadores:
        avaliador = analisadores[a][0]
        if avaliador(filename):
            info("Avaliando um extrato de: {}".format(a))
            return analisadores[a][1]

    return None
