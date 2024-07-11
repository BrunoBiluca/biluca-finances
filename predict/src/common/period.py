from datetime import datetime


def by_month(input_month):
    start = datetime.strptime(input_month, "%m/%Y")

    days_of_month = 0
    if start.month in [1, 3, 5, 7, 8, 10, 12]:
        days_of_month = 31
    elif start.month == 2:
        days_of_month = 28 if start.year % 4 != 0 else 29
    else:
        days_of_month = 30

    end = datetime(day=days_of_month, month=start.month, year=start.year)

    return (start, end)
