-- public.vw_monthly_payment_collection_analysis source

CREATE OR REPLACE VIEW public.vw_monthly_payment_collection_analysis
AS SELECT date_trunc('month'::text, payment_date::timestamp with time zone)::date AS collection_month,
    count(payment_id) AS total_transactions,
    round(sum(payment_amount), 2) AS total_collections,
    round(sum(payment_amount) * 100.0 / NULLIF(sum(sum(payment_amount)) OVER (), 0::numeric), 2) AS collection_contribution_percentage
   FROM payments
  GROUP BY (date_trunc('month'::text, payment_date::timestamp with time zone));