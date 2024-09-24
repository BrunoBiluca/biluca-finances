from src.common.str_extensions import full_strip


def test_should_replace_multiple_white_spaces_to_single_ones():
    s = "    Hello      World!    "
    result = full_strip(s)
    assert result == "Hello World!"
