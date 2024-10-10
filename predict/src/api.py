import argparse
from logging import basicConfig, info, warning
from flask import Flask, request
import pandas
from pypdf import PdfReader
import bundle_resources
from extratos import analisadores

from classification.classification import categorize_identification


def predict():
    info('Request de {} {} {}'.format(request.remote_addr, request.method, request.content_type))
    entradas = None
    if ("application/json" in request.content_type):
        data = request.get_json()
        info(f"Fazendo predição para os registros: {data["registros"]}")
        entradas = pandas.DataFrame(
            data["registros"], columns=data["cabeçalhos"])
    elif (request.content_type.startswith("multipart/form-data")):
        reader = PdfReader(request.files["extrato"])
        for a in analisadores:
            avaliador = analisadores[a][0]
            if avaliador(reader.pages):
                info("Avaliando um extrato de:", a)
                parser = analisadores[a][1]
                entradas = parser(reader.pages)
                info("Foram encontrados", len(entradas), "entradas")
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
    basicConfig(level="INFO")
    if not bundle_resources.exists("resources/classification_train.csv"):
        warning("Arquivo de classificação não encontrado")

    app = create_app()
    parser = argparse.ArgumentParser()
    parser.add_argument("-d", "--debug", action="store_true", help="Habilita o modo debug")
    args = parser.parse_args()
    app.run(debug=args.debug, port=5666)
