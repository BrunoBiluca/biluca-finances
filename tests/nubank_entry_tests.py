from src.nubank.entry import to_date


def test_should_create_date_from_nubank_date_str():
    date = to_date("14 JAN")
    assert date is not None
    assert date.day == 14
    assert date.month == 1
