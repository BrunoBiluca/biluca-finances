import csv
from datetime import datetime
import os


def read(path):
    entries = []
    print("Lendo arquivo", path)
    with open(path, newline='', encoding="utf8") as csvfile:
        spamreader = csv.reader(csvfile, delimiter=',', quotechar='"')
        for row in spamreader:
            entries.append(', '.join(row))
    return entries


def write(name, budget):
    print("Escrevendo o arquivo", name)
    date = datetime.now().strftime("%Y-%m-%d")
    folder = "outputs/" + date

    if not os.path.exists(folder):
        os.mkdir(folder)

    file_path = folder + "/" + name
    with open(file_path, 'w', newline='', encoding="utf-8") as csvfile:
        spamwriter = csv.writer(csvfile, quoting=csv.QUOTE_NONE)
        spamwriter.writerows(budget)

    return file_path
