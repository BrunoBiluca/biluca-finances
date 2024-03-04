from sklearn.preprocessing import MinMaxScaler
import pandas as pd
import numpy as np
from scipy.sparse import hstack
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.naive_bayes import MultinomialNB


def categorize_identification(csv_path):
    print("Categorizando...")
    column_to_predict = "Identificação"
    value_fn = "Descrição"
    value_feat_name = "Valor"

    prestacao_contas = pd.read_csv(csv_path)

    train = pd.read_csv("resources/classification_train.csv")
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
    prestacao_contas.to_csv(csv_path, index=False)
