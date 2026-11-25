-- public.vw_invoice_payment_reconciliation source

CREATE OR REPLACE VIEW public.vw_invoice_payment_reconciliation
AS WITH payment_summary AS (
         SELECT payments.invoice_id,
            sum(payments.payment_amount) AS total_paid,
            count(payments.payment_id) AS payment_count
           FROM payments
          GROUP BY payments.invoice_id
        )
 SELECT i.invoice_id,
    i.client_id,
    i.invoice_date,
    i.due_date,
    i.invoice_amount,
    i.invoice_status,
    COALESCE(p.total_paid, 0::numeric) AS actual_amount_paid,
    COALESCE(p.payment_count, 0::bigint) AS payment_count,
    i.invoice_amount - COALESCE(p.total_paid, 0::numeric) AS actual_outstanding_amount,
        CASE
            WHEN COALESCE(p.total_paid, 0::numeric) = 0::numeric THEN 'No Payment'::text
            WHEN COALESCE(p.total_paid, 0::numeric) >= i.invoice_amount THEN 'Fully Paid'::text
            ELSE 'Partially Paid'::text
        END AS actual_payment_status,
        CASE
            WHEN i.invoice_status::text = 'Paid'::text AND COALESCE(p.total_paid, 0::numeric) < i.invoice_amount THEN 'Status Mismatch'::text
            WHEN i.invoice_status::text = 'Unpaid'::text AND COALESCE(p.total_paid, 0::numeric) > 0::numeric THEN 'Status Mismatch'::text
            WHEN i.invoice_status::text = 'Partially Paid'::text AND (COALESCE(p.total_paid, 0::numeric) = 0::numeric OR COALESCE(p.total_paid, 0::numeric) >= i.invoice_amount) THEN 'Status Mismatch'::text
            ELSE 'Status Consistent'::text
        END AS reconciliation_result
   FROM invoices i
     LEFT JOIN payment_summary p ON i.invoice_id::text = p.invoice_id::text;