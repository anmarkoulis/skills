from cart.cart import Cart


def test_no_code_returns_subtotal():
    cart = Cart()
    cart.add("book", 20, qty=2)
    assert cart.total() == 40


def test_save10_on_small_order():
    cart = Cart()
    cart.add("pen", 50)
    assert cart.total("SAVE10") == 45
