from logging import warning
from flask import Flask, request
import pandas
import bundle_resources

from classification.classification import categorize_identification


def predict():
    data = request.get_json()
    df = pandas.DataFrame(data["registros"], columns=data["cabeçalhos"])
    result = categorize_identification(df)
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
    app.run()