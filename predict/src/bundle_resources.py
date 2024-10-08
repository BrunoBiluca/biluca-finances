from logging import info
import os
import sys


def resource_path(relative_path):
    # determine if application is a script file or frozen exe
    if getattr(sys, 'frozen', False):
        application_path = os.path.dirname(sys.executable)
    elif __file__:
        application_path = ""

    return os.path.join(application_path, relative_path)


def open_file(file_name):
    return open(resource_path(file_name), encoding="utf8")


def exists(file_name):
    file_path = resource_path(file_name)
    info("Verificando se o arquivo existe no caminho: " + file_path)
    return os.path.exists(file_path)
