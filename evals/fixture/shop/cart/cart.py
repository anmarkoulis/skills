from cart.discount import apply_discount


class Cart:
    def __init__(self):
        self.items = []

    def add(self, name, price, qty=1):
        self.items.append({"name": name, "price": price, "qty": qty})

    def subtotal(self):
        return sum(item["price"] * item["qty"] for item in self.items)

    def total(self, code=None):
        subtotal = self.subtotal()
        if code is None:
            return subtotal
        return apply_discount(subtotal, code)
