import re

def full_strip(str):
    white_space_pattern = re.compile(r'\s+')
    return re.sub(white_space_pattern, " ", str.strip())
