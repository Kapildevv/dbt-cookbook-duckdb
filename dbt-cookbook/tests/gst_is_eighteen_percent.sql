-- Singular test: one specific business rule, written as a query that
-- returns the offending rows. GST must be 18% of the order value, to the
-- rupee. Anything else means the macro or the source data has drifted.

select
    order_id,
    total_amount,
    gst_amount,
    round(total_amount * 0.18, 2) as expected_gst
from {{ ref('silver_transactions') }}
where abs(gst_amount - round(total_amount * 0.18, 2)) > 0.01
