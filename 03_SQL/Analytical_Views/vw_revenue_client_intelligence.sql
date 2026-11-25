-- public.vw_revenue_client_intelligence source

CREATE OR REPLACE VIEW public.vw_revenue_client_intelligence
AS SELECT c.client_id,
    c.client_name,
    c.industry,
    c.client_tier,
    count(r.revenue_id) AS total_transactions,
    sum(r.revenue_amount) AS total_revenue,
    round(sum(r.revenue_amount) * 100.0 / NULLIF(( SELECT sum(revenue.revenue_amount) AS sum
           FROM revenue), 0::numeric), 2) AS revenue_contribution_percentage
   FROM clients c
     JOIN revenue r ON c.client_id::text = r.client_id::text
  WHERE r.revenue_amount IS NOT NULL
  GROUP BY c.client_id, c.client_name, c.industry, c.client_tier;