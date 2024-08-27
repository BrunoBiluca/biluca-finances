from sklearn.preprocessing import MinMaxScaler
import pandas as pd
import numpy as np
from scipy.sparse import hstack
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.naive_bayes import MultinomialNB

import bundle_resources


def categorize_identification(prestacao_contas: pd.DataFrame) -> pd.DataFrame:
    print("Categorizando...")

    value_fn = "Descrição"
    value_feat_name = "Valor"

    colunas_obrigatórias = [value_fn, value_feat_name]
    colunas = map(lambda c: c[0], prestacao_contas.items())
    
    if not all([c in colunas for c in colunas_obrigatórias]):
        raise AttributeError(f"Os dados para categorização precisam prover os seguintes campos <{colunas_obrigatórias}>")

    column_to_predict = "Identificação"
    train_file = bundle_resources.open_file("resources/classification_train.csv")
    train = pd.read_csv(train_file)
    train = train[train[column_to_predict].notna()]
    train[value_fn] = train[value_fn].apply(lambda d: d.rsplit(" ", -1)[0])

    vectorizer = TfidfVectorizer()
    train_tfidf = vectorizer.fit_transform(train[value_fn])
    saidas_descricao = vectorizer.transform(prestacao_contas[value_fn])

    # Normalizando os valores numéricos
    scaler = MinMaxScaler()
    train_numeric_normalized = scaler.fit_transform(
        np.array(train[value_feat_name]).reshape(-1, 1)
    )
    saidas_valores = scaler.transform(np.array(prestacao_contas[value_feat_name]).reshape(-1, 1))

    # Concatenando as features numéricas normalizadas com as features de texto
    features = hstack([saidas_descricao, saidas_valores])
    train_combined = hstack([train_tfidf, train_numeric_normalized])

    # Inicializando e treinando o classificador Naive Bayes
    clf = MultinomialNB()
    clf.fit(train_combined, train[column_to_predict])

    prestacao_contas[column_to_predict] = clf.predict(features)
    return prestacao_contas
