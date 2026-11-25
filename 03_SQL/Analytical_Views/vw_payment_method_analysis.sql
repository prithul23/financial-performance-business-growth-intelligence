-- public.vw_payment_method_analysis source

CREATE OR REPLACE VIEW public.vw_payment_method_analysis
AS SELECT payment_method,
    count(payment_id) AS total_transactions,
    round(sum(payment_amount), 2) AS total_collections,
    round(avg(payment_amount), 2) AS average_payment,
    round(sum(payment_amount) * 100.0 / NULLIF(sum(sum(payment_amount)) OVER (), 0::numeric), 2) AS collection_contribution_percentage
   FROM payments
  GROUP BY payment_method;