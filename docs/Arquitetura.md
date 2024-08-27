Organização do projeto

- app: aplicação
- docs: documentação
- predict: serviço de predição

# App

A aplicação principal do Biluca Finanças. Desenvolvido em [Flutter](https://github.com/BrunoBiluca/biluca-knowledge/tree/main/Frontend/Flutter).

```mermaid
flowchart TB

subgraph Legenda
direction LR
A -- usa --> B
C .- implementa .-> D
end

```

```mermaid
flowchart BT

acc("Accountability")
common
components
predict
reports("Relatórios")
sqlite
app
cd("Container de dependências")

acc --> common
acc --> components
reports --> acc
sqlite --> predict

predict -..-> acc
sqlite -..-> acc
sqlite -..-> reports

app --> acc
app --> reports
app --> cd

```

Módulos

accountability
common
components
predict
reports
sqlite
app
cd