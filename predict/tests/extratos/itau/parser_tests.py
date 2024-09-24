from pypdf import PdfReader
from src.extratos.itau import itau_parse


def test_deve_retornar_todas_as_entradas_do_extrato_itau():
    file_path = "resources/itau_sample.pdf"
    reader = PdfReader(file_path)
    result = itau_parse(reader.pages)
    
    assert result != None
    assert len(result) > 0
    assert len(result[0]) == 3

