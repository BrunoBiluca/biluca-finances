
from pypdf import PdfReader
from src.extratos.itau import é_itau_extrato


def test_deve_averiguar_que_o_extrato_não_é_nubank():
    import argparse
    reader = argparse.Namespace() 
    reader.pages = [argparse.Namespace()]
    reader.pages[0].extract_text = lambda: "qualquer coisa escrita mas não tem nenhuma palavra que define o extrato"
    assert é_itau_extrato(reader.pages) == False


def test_deve_averiguar_que_o_extrato_é_nubank():
    import argparse
    reader = argparse.Namespace() 
    reader.pages = [argparse.Namespace()]
    reader.pages[0].extract_text = lambda: "qualquer coisa escrita e pelo menos uma palavra itau"
    assert é_itau_extrato(reader.pages) == True

