def é_extrato(pages):
    if any(["nubank" in p.extract_text().lower() for p in pages[0:3]]):
        return True
    return False
