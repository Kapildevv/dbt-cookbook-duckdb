{% docs order_grain %}
One row per **order line**. In this warehouse every order happens to have
exactly one line, so `order_id` is unique here and `count(*)` counts both
lines and orders. That is why the `unique` test on `order_id` passes -- and
it is the test that will break first on the day a source starts sending
multi-line orders, which is the warning you want.

Two things to know before you aggregate:

* `order_status` is `Delivered`, `InTransit` or `Cancelled`. Only
  `Delivered` counts as revenue -- `dim_customers` and `agg_daily_sales`
  both filter on it, and summing `total_amount` here without that filter
  counts orders that were never completed.
* `cashback_amount` and `cashback_status` come from a left join and are
  null for most rows. Use `coalesce(cashback_amount, 0)` when you sum.
{% enddocs %}
