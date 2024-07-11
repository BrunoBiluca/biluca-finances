from datetime import datetime
import locale


def to_date(str):
    locale.setlocale(locale.LC_ALL, 'pt_BR')
    return datetime.strptime(str, "%d %b")
