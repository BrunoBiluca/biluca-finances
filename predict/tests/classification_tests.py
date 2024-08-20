import pandas
import pytest

from src.classification.classification import categorize_identification

def test_deve_lançar_um_erro_quando_não_são_forncecidos_os_campos_obrigatórios():
    dataset = pandas.DataFrame({
        "A": [],
        "B": [],
    })

    with pytest.raises(AttributeError) as e_info:
        categorize_identification(dataset)


def test_deve_predizer():
    dataset = pandas.DataFrame({
        "Descrição": ["Um valor", "Outro valor"],
        "Valor": [10, 20],
    })
    
    dataset_preditect = categorize_identification(dataset)
    
    assert dataset_preditect.shape[0] == 2
    assert "Identificação" in dataset_preditect.columns
    
    
def test_deve_predizer_e_manter_campos_extras():
    dataset = pandas.DataFrame({
        "Descrição": ["Um valor", "Outro valor"],
        "Valor": [10, 20],
        "Outro campo": ["abc", "def"]
    })
    
    dataset_preditect = categorize_identification(dataset)
    
    assert "Identificação" in dataset_preditect.columns
    assert "Outro campo" in dataset_preditect.columns
