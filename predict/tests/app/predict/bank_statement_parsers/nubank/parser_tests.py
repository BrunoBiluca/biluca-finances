
from src.app.predict.bank_statement_parsers.nubank.parser import NubankParser


def test_deve_averiguar_que_o_extrato_não_é_nubank():
    assert NubankParser().is_from_bank("2026_03_itau.pdf") == False


def test_deve_averiguar_que_o_extrato_é_nubank():
    assert NubankParser().is_from_bank("2026_03_nubank.pdf") == True


def test_deve_analisar_o_formato_de_entrada_de_duas_linhas():
    import argparse
    reader = argparse.Namespace()

    reader.pages = [argparse.Namespace()]

    linhas = [
        "",
        "",
        "TRANSAÇÕES",
        "14 DEZ",
        "Matozinhos R$ 30,00",
        "14 DEZ",
        "Matozinhos R$ 30,00",
        "14 DEZ",
        "Matozinhos R$ 30,00",
        "Como assegurado pela Resolução CMN n° 5.112 de 21/12/2023, o valor total c...",
        "5 de 8"
    ]

    reader.pages[0].extract_text = lambda: "\n".join(linhas)

    entradas = NubankParser().parse(reader.pages)

    assert len(entradas) == 3


def test_deve_analisar_o_formato_de_entrada_de_conversão():
    import argparse
    reader = argparse.Namespace()

    reader.pages = [argparse.Namespace()]

    linhas = [
        "",
        "",
        "TRANSAÇÕES",
        "14 DEZ",
        "Matozinhos R$ 30,00",
        "14 DEZ",
        " Steamgames.Com",
        "BRL 12.30 = USD 2.03",
        "Conversão: BRL 6.31 = USD 1 = R$ 6,31 R$12,82",
        "14 DEZ",
        "Matozinhos R$ 30,00",
        "Como assegurado pela Resolução CMN n° 5.112 de 21/12/2023, o valor total c...",
        "5 de 8"
    ]

    reader.pages[0].extract_text = lambda: "\n".join(linhas)

    entradas = NubankParser().parse(reader.pages)

    assert len(entradas) == 3
