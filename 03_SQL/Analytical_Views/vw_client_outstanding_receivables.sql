-- public.vw_client_outstanding_receivables source

CREATE OR REPLACE VIEW public.vw_client_outstanding_receivables
AS SELECT c.client_id,
    c.client_name,
    count(r.invoice_id) AS total_invoices,
    round(sum(r.invoice_amount), 2) AS total_invoice_amount,
    round(sum(r.actual_amount_paid), 2) AS total_paid,
    round(sum(r.actual_outstanding_amount), 2) AS outstanding_receivables,
    round(sum(r.actual_outstanding_amount) * 100.0 / NULLIF(( SELECT sum(vw_invoice_payment_reconciliation.actual_outstanding_amount) AS sum
           FROM vw_invoice_payment_reconciliation), 0::numeric), 2) AS outstanding_contribution_percentage
   FROM clients c
     JOIN vw_invoice_payment_reconciliation r ON c.client_id::text = r.client_id::text
  GROUP BY c.client_id, c.client_name;