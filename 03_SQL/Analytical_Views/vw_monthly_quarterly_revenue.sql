-- public.vw_monthly_quarterly_revenue source

CREATE OR REPLACE VIEW public.vw_monthly_quarterly_revenue
AS SELECT date_trunc('month'::text, transaction_date::timestamp with time zone)::date AS month,
    EXTRACT(quarter FROM transaction_date)::integer AS quarter,
    sum(revenue_amount) AS total_revenue,
    count(revenue_id) AS total_transactions,
    count(DISTINCT client_id) AS active_clients
   FROM revenue
  WHERE revenue_amount IS NOT NULL
  GROUP BY (date_trunc('month'::text, transaction_date::timestamp with time zone)), (EXTRACT(quarter FROM transaction_date));