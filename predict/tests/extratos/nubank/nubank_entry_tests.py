from pypdf import PdfReader
from src.extratos.nubank.entry import to_date
from src.extratos.nubank.parser import avaliar_linhas


def test_deve_converter_data_encontrada_no_extrato():
    date = to_date("14 JAN 2024")
    assert date is not None
    assert date.day == 14
    assert date.month == 1
    assert date.year == 2024



class TestNubank_102024:

    def test_deve_analisar_um_conjunto_de_linhas(self):
        result = avaliar_linhas(["21 SET", " Ladeiras Coxinha Mania R$ 15,00"])

        assert result is not None
        assert result[0] == "21/09/2024"
        assert result[1] == "Ladeiras Coxinha Mania"
        assert result[2] == -15


    def test_deve_analisar_un_conjunto_de_linhas_com_entrada_positiva(self):
        result = avaliar_linhas(["19 SET", "Estorno de 'Aliexpress' -R$ 308,46"])

        assert result is not None
        assert result[0] == "19/09/2024"
        assert result[1] == "Estorno de 'Aliexpress'"
        assert result[2] == 308.46