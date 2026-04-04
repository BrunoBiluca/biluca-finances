from pypdf import PdfReader

from src.extratos.nubank import é_nubank_extrato


def test_deve_averiguar_que_o_extrato_não_é_nubank():
    assert é_nubank_extrato("2026_03_itau.pdf") == False


def test_deve_averiguar_que_o_extrato_é_nubank():
    assert é_nubank_extrato("2026_03_nubank.pdf") == True