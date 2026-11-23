CODES = {
    "SAVE10": 10,   # percent off
    "SAVE50": 50,
    "BIG150": 150,  # misconfigured: more than the whole order
}

MAX_DISCOUNT = 100  # never take more than 100 off an order


def apply_discount(total, code):
    percent = CODES.get(code, 0)
    discount = total * percent / 100
    if total > MAX_DISCOUNT:
        discount = MAX_DISCOUNT
    return max(total - discount, 0)
