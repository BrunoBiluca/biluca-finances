from datetime import datetime


def to_date(str):
    return datetime.strptime(str, "%d %b")
