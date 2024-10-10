from pypdf import PdfReader

from src.extratos.nubank import é_nubank_extrato


def test_deve_averiguar_que_o_extrato_não_é_nubank():
    import argparse
    reader = argparse.Namespace() 
    reader.pages = [argparse.Namespace()]
    reader.pages[0].extract_text = lambda: "qualquer coisa escrita e pelo menos uma palavra"

    assert é_nubank_extrato(reader.pages) == False


def test_deve_averiguar_que_o_extrato_é_nubank():
    import argparse
    reader = argparse.Namespace() 
    reader.pages = [argparse.Namespace()]
    reader.pages[0].extract_text = lambda: "qualquer coisa escrita e pelo menos uma palavra nubank"

    assert é_nubank_extrato(reader.pages) == True