-- public.vw_overdue_invoice_collection_risk source

CREATE OR REPLACE VIEW public.vw_overdue_invoice_collection_risk
AS SELECT r.invoice_id,
    r.client_id,
    c.client_name,
    r.invoice_date,
    r.due_date,
    r.invoice_status,
    r.invoice_amount,
    r.actual_amount_paid,
    r.actual_outstanding_amount,
    '2026-11-21'::date - r.due_date AS overdue_days,
        CASE
            WHEN ('2026-11-21'::date - r.due_date) >= 1 AND ('2026-11-21'::date - r.due_date) <= 30 THEN 'Moderate Risk'::text
            WHEN ('2026-11-21'::date - r.due_date) >= 31 AND ('2026-11-21'::date - r.due_date) <= 60 THEN 'High Risk'::text
            WHEN ('2026-11-21'::date - r.due_date) >= 61 AND ('2026-11-21'::date - r.due_date) <= 90 THEN 'Very High Risk'::text
            ELSE 'Critical Risk'::text
        END AS collection_risk
   FROM vw_invoice_payment_reconciliation r
     JOIN clients c ON r.client_id::text = c.client_id::text
  WHERE r.due_date < '2026-11-21'::date AND r.actual_outstanding_amount > 0::numeric;