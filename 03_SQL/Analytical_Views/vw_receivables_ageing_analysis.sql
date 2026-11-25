-- public.vw_receivables_ageing_analysis source

CREATE OR REPLACE VIEW public.vw_receivables_ageing_analysis
AS WITH ageing_data AS (
         SELECT vw_invoice_payment_reconciliation.invoice_id,
            vw_invoice_payment_reconciliation.actual_outstanding_amount,
                CASE
                    WHEN vw_invoice_payment_reconciliation.due_date >= '2026-11-21'::date THEN 'Current'::text
                    WHEN ('2026-11-21'::date - vw_invoice_payment_reconciliation.due_date) >= 1 AND ('2026-11-21'::date - vw_invoice_payment_reconciliation.due_date) <= 30 THEN '1-30 Days'::text
                    WHEN ('2026-11-21'::date - vw_invoice_payment_reconciliation.due_date) >= 31 AND ('2026-11-21'::date - vw_invoice_payment_reconciliation.due_date) <= 60 THEN '31-60 Days'::text
                    WHEN ('2026-11-21'::date - vw_invoice_payment_reconciliation.due_date) >= 61 AND ('2026-11-21'::date - vw_invoice_payment_reconciliation.due_date) <= 90 THEN '61-90 Days'::text
                    ELSE 'Above 90 Days'::text
                END AS ageing_bucket
           FROM vw_invoice_payment_reconciliation
          WHERE vw_invoice_payment_reconciliation.actual_outstanding_amount > 0::numeric
        )
 SELECT ageing_bucket,
    count(invoice_id) AS invoice_count,
    round(sum(actual_outstanding_amount), 2) AS outstanding_receivables,
    round(sum(actual_outstanding_amount) * 100.0 / NULLIF(sum(sum(actual_outstanding_amount)) OVER (), 0::numeric), 2) AS outstanding_contribution_percentage
   FROM ageing_data
  GROUP BY ageing_bucket;