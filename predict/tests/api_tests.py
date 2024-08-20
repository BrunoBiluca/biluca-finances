import pytest

from src.api import create_app

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
    response = client.post("/predict", json={
        "cabeçalhos": ["Descrição", "Valor"],
        "registros": [
            ("Descrição 1", 10),
            ("Descrição 2", 20),
            ("Descrição 3", 30),
        ]
    })
    
    assert response.status_code == 200
    assert response.json["cabeçalhos"] == ["Descrição", "Valor", "Identificação"]
    assert len(response.json["registros"]) == 3
    
    