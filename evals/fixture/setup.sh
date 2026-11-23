#!/usr/bin/env bash
# Seeds the run workspace with the shop fixture as a git repo on main.
# setup.sh         clean repo, one commit (has the discount cap bug)
# setup.sh change  plus an uncommitted fix of the cap bug with its test
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp -R "$here/shop/." .
g() { git -c user.name=eval -c user.email=eval@example.com -c init.defaultBranch=main "$@"; }
g init -q
g add -A
g commit -qm "feat: cart with discount codes"
if [ "${1:-}" = change ]; then
  sed -i.bak 's/if total > MAX_DISCOUNT:/if discount > MAX_DISCOUNT:/' cart/discount.py && rm cart/discount.py.bak
  cat >> tests/test_cart.py <<'PY'


def test_save10_on_large_order_is_not_capped():
    cart = Cart()
    cart.add("tv", 200)
    assert cart.total("SAVE10") == 180
PY
fi
