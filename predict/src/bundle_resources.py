import os
import sys


def base_path():
    if getattr(sys, 'frozen', False) and hasattr(sys, '_MEIPASS'):
        print('running in a PyInstaller bundle')
        return os.path.abspath(os.path.dirname(__file__)) + "/"

    print('running in a normal Python process')
    return ""


def open_file(file_name):
    return open(base_path() + file_name, encoding="utf8")


def exists(file_name):
    return os.path.isfile(base_path() + file_name)