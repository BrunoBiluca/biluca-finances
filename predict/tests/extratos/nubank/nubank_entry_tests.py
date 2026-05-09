from pypdf import PdfReader
from src.extratos.nubank.entry import to_date
from src.extratos.nubank.parser import avaliar_linhas


def test_deve_converter_data_encontrada_no_extrato():
    date = to_date("14 JAN 2024")
    assert date is not None
    assert date.day == 14
    assert date.month == 1
    assert date.year == 2024

