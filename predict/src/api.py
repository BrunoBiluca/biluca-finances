import argparse
from logging import basicConfig, error, info, warning
import traceback
from flask import Flask, request, g
import pandas
from pypdf import PdfReader
import bundle_resources

from classification.classification import categorize_identification
from extratos import AvaliadorExtrato


def predict_wrapper():
    try:
        return predict()
    except Exception as e:
        error(e)
        error(traceback.format_exc())
        return {"error": str(e)}, 500


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
        analisador = AvaliadorExtrato().avaliar_extrato(extrato_file.filename)

        if analisador is None:
            info("Não foi possivel identificar o extrato")
            return {"error": "Nao foi possivel identificar o extrato"}, 422

        reader = PdfReader(extrato_file)
        entradas = analisador(reader.pages)
        info("Foram encontrados {} entradas".format(len(entradas)))
        entradas = pandas.DataFrame(entradas, columns=["Criado em", "Descrição", "Valor"])

    result = categorize_identification(entradas)
    return {
        "cabeçalhos": [i for i in result.columns],
        "registros": result.values.tolist()
    }


def create_app():
    app = Flask(__name__)
    app.add_url_rule("/predict", view_func=predict_wrapper, methods=["POST"])
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
