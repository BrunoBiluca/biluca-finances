# Predição

O serviço de predição é responsável por receber dados e fazer a predição de algumas informações relecionadas a contabilidade desses dados.

Predições disponíveis:

- Identificação

# API

### POST /predict

Body

```python
{
    "cabeçalhos": ["Descrição", "Valor"],
    "registros": [
        ("Descrição 1", 10),
        ("Descrição 2", 20),
        ("Descrição 3", 30),
    ]
}
```

Responsta

```python
{
    "cabeçalhos": ["Descrição", "Valor", "Identificação"],
    "registros": [
        ("Descrição 1", 10, "supermercado"),
        ("Descrição 2", 20, "supermercado"),
        ("Descrição 3", 30, "supermercado"),
    ]
}
```