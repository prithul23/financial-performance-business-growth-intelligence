-- public.vw_service_line_revenue_intelligence source

CREATE OR REPLACE VIEW public.vw_service_line_revenue_intelligence
AS SELECT standardized_service_line AS service_line,
    count(revenue_id) AS total_transactions,
    count(DISTINCT client_id) AS total_clients,
    sum(revenue_amount) AS total_revenue,
    round(sum(revenue_amount) * 100.0 / NULLIF(( SELECT sum(revenue_1.revenue_amount) AS sum
           FROM revenue revenue_1), 0::numeric), 2) AS revenue_contribution_percentage
   FROM revenue
  WHERE revenue_amount IS NOT NULL
  GROUP BY standardized_service_line;