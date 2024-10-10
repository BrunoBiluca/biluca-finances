from pypdf import PdfReader
from src.extratos.itau import itau_parse


def test_deve_retornar_todas_as_entradas_do_extrato_itau():
    import argparse
    reader = argparse.Namespace() 
    reader.pages = [argparse.Namespace()]
    reader.pages[0].extract_text = lambda: """02/10/2024 PIX TRANSF HELENA 02/10 -120,00
01/10/2024 PIX TRANSF MARCELO01/10 -340,00
01/10/2024 PIX TRANSF Pollyan01/10 -300,00
01/10/2024 PIX QRS Maria Rosel01/10 -14,00"""

    result = itau_parse(reader.pages)
    
    assert result != None
    assert len(result) > 0
    assert len(result[0]) == 3

