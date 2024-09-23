from logging import warning
from flask import Flask, request
import pandas
from pypdf import PdfReader
import bundle_resources
from itau import é_itau_extrato, itau_parse
from nubank import é_nubank_extrato, nubank_parse

from classification.classification import categorize_identification


def predict():
    entradas = None
    if (request.content_type == "application/json"):
        data = request.get_json()
        entradas = pandas.DataFrame(
            data["registros"], columns=data["cabeçalhos"])
    elif (request.content_type.startswith("multipart/form-data")):
        reader = PdfReader(request.files["extrato"])
        analisadores = {
            "itau": [é_itau_extrato, itau_parse],
            "nubank": [é_nubank_extrato, nubank_parse]
        }

        for a in analisadores:
            avaliador = analisadores[a][0]
            if avaliador(reader.pages):
                print("Avaliando um extrato de:", a)
                parser = analisadores[a][1]
                entradas = parser(reader.pages)
                print("Foram encontrados", len(entradas), "entradas")
                entradas = pandas.DataFrame(
                    entradas, columns=["Criado em", "Descrição", "Valor"])

    result = categorize_identification(entradas)
    return {
        "cabeçalhos": [i for i in result.columns],
        "registros": result.values.tolist()
    }


def create_app():
    app = Flask(__name__)
    app.add_url_rule("/predict", view_func=predict, methods=["POST"])
    return app


if __name__ == "__main__":
    if bundle_resources.exists("resources/classification.csv"):
        warning("Arquivo de classificação não encontrado")

    app = create_app()
    app.run(debug=True)
