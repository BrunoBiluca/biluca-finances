from datetime import datetime

date_pattern = "%d/%m/%Y"


def to_date(str):
    return datetime.strptime(str, date_pattern)


def to_str(date):
    return date.strftime(date_pattern)
