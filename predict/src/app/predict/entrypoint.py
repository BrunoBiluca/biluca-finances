import pandas
from logging import info
from flask import request
from pypdf import PdfReader

from .classification.classification import categorize_identification
from .bank_statement_parsers import match_parser


def predict():
    info('Request de {} {} {}'.format(request.remote_addr, request.method, request.content_type))
    entradas = None

    if ("application/json" in request.content_type):
        data = request.get_json()
        info(f"Fazendo predição para os registros: {data["registros"]}")
        entradas = pandas.DataFrame(data["registros"], columns=data["cabeçalhos"])

    elif (request.content_type.startswith("multipart/form-data")):

        if "extrato" not in request.files:
            raise Exception("Nenhum arquivo de extrato foi enviado")

        extrato_file = request.files["extrato"]
        analisador = match_parser(extrato_file.filename)

        if analisador is None:
            info("Não foi possivel identificar o extrato")
            return {"error": f"Nao foi possivel identificar o extrato para o arquivo {extrato_file.filename}"}, 422

        reader = PdfReader(extrato_file)
        entradas = analisador(reader.pages)
        info("Foram encontrados {} entradas".format(len(entradas)))
        entradas = pandas.DataFrame(entradas, columns=["Criado em", "Descrição", "Valor"])

    result = categorize_identification(entradas)
    return {
        "cabeçalhos": [i for i in result.columns],
        "registros": result.values.tolist()
    }
