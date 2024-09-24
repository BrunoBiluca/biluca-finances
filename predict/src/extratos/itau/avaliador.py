def é_extrato(pages):
    if "itau" in pages[-1].extract_text().lower():
        return True
    return False
