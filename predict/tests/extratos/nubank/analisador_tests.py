from pypdf import PdfReader

from src.extratos.nubank import nubank_parse


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
    
    entradas = nubank_parse(reader.pages)
    
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
    
    entradas = nubank_parse(reader.pages)
    
    assert len(entradas) == 3