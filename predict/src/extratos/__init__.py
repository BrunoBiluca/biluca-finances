from logging import info
from extratos.itau import é_itau_extrato, itau_parse
from extratos.nubank import é_nubank_extrato, nubank_parse


analisadores = {
    "itau": [é_itau_extrato, itau_parse],
    "nubank": [é_nubank_extrato, nubank_parse]
}


class AvaliadorExtrato():
    _instance = None

    def __new__(cls, *args, **kwargs):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
    
    def avaliar_extrato(self, reader):
        for a in analisadores:
            avaliador = analisadores[a][0]
            if avaliador(reader.pages):
                info("Avaliando um extrato de: {}".format(a))
                return analisadores[a][1]

        return None
