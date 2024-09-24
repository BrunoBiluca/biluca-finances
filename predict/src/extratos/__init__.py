from extratos.itau import é_itau_extrato, itau_parse
from extratos.nubank import é_nubank_extrato, nubank_parse


analisadores = {
    "itau": [é_itau_extrato, itau_parse],
    "nubank": [é_nubank_extrato, nubank_parse]
}
