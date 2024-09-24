
from pypdf import PdfReader
from src.extratos.itau import é_itau_extrato


def test_deve_averiguar_que_o_extrato_não_é_nubank():
    file_path = "resources/nubank_sample.pdf"
    reader = PdfReader(file_path)
    assert é_itau_extrato(reader.pages) == False


def test_deve_averiguar_que_o_extrato_é_nubank():
    file_path = "resources/itau_sample.pdf"
    reader = PdfReader(file_path)
    assert é_itau_extrato(reader.pages) == True

