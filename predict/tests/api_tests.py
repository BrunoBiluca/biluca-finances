import pytest

from src.api import create_app


endpoint_predição = "/predict"
campos_obrigatórios = ["Descrição", "Valor"]


@pytest.fixture()
def app():
    app = create_app()
    app.config.update({
        "TESTING": True,
    })
    yield app


@pytest.fixture()
def client(app):
    return app.test_client()


@pytest.fixture()
def runner(app):
    return app.test_cli_runner()


def test_deve_receber_os_registros_para_fazer_a_previsão(client):
    response = client.post(endpoint_predição, json={
        "cabeçalhos": campos_obrigatórios,
        "registros": [
            ("Descrição 1", 10),
            ("Descrição 2", 20),
            ("Descrição 3", 30),
        ]
    })

    assert response.status_code == 200
    assert response.json["cabeçalhos"] == campos_obrigatórios + ["Identificação"]
    assert len(response.json["registros"]) == 3


def test_deve_receber_os_registros_com_todos_os_cabeçalhos_enviados(client):
    campos_extras = ["Outro campo", "Mais um campo"]
    response = client.post(endpoint_predição, json={
        "cabeçalhos": campos_obrigatórios + campos_extras,
        "registros": [
            ("Descrição 1", 10, "abc", "def"),
            ("Descrição 2", 20, "abc", "def"),
            ("Descrição 3", 30, "abc", "def"),
        ]
    })

    assert response.status_code == 200
    assert response.json["cabeçalhos"] == campos_obrigatórios + campos_extras + ["Identificação"]

