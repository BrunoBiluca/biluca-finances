import argparse
import bundle_resources
import traceback
from logging import basicConfig, error, warning
from flask import Flask

from src.app.predict.entrypoint import predict


def wrapper(entry_point):
    try:
        return entry_point()
    except Exception as e:
        error(e)
        error(traceback.format_exc())
        return {"error": str(e)}, 500


def create_app():
    app = Flask(__name__)
    app.add_url_rule("/predict", view_func=lambda: wrapper(predict), methods=["POST"])
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
