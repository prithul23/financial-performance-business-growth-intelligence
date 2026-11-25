-- public.vw_final_receivables_collection_summary source

CREATE OR REPLACE VIEW public.vw_final_receivables_collection_summary
AS SELECT count(invoice_id) AS total_invoices,
    round(sum(invoice_amount), 2) AS total_invoice_amount,
    round(sum(actual_amount_paid), 2) AS total_payments_received,
    round(sum(actual_outstanding_amount), 2) AS total_outstanding_receivables,
    round(sum(actual_amount_paid) * 100.0 / NULLIF(sum(invoice_amount), 0::numeric), 2) AS collection_rate_percentage,
    round(sum(actual_outstanding_amount) * 100.0 / NULLIF(sum(invoice_amount), 0::numeric), 2) AS outstanding_percentage,
    count(*) FILTER (WHERE due_date < '2026-11-21'::date AND actual_outstanding_amount > 0::numeric) AS overdue_invoice_count,
    round(sum(actual_outstanding_amount) FILTER (WHERE due_date < '2026-11-21'::date AND actual_outstanding_amount > 0::numeric), 2) AS overdue_receivables
   FROM vw_invoice_payment_reconciliation;