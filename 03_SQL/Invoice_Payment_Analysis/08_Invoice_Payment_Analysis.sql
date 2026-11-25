-- Overall Invoice Performance

SELECT
    COUNT(*) AS total_invoices,
    SUM(invoice_amount) AS total_invoice_amount,
    ROUND(AVG(invoice_amount), 2) AS average_invoice_amount,
    COUNT(*) FILTER (
        WHERE LOWER(invoice_status) = 'paid'
    ) AS paid_invoices,
    COUNT(*) FILTER (
        WHERE LOWER(invoice_status) = 'unpaid'
    ) AS unpaid_invoices,
    COUNT(*) FILTER (
        WHERE LOWER(invoice_status) = 'overdue'
    ) AS overdue_invoices
FROM public.invoices;


-- Invoice Status Analysis

SELECT
    invoice_status,
    COUNT(*) AS invoice_count,
    SUM(invoice_amount) AS total_invoice_amount,
    ROUND(AVG(invoice_amount), 2) AS average_invoice_amount
FROM public.invoices
GROUP BY invoice_status
ORDER BY total_invoice_amount DESC;



-- Payment Collection Summary

SELECT
    COUNT(*) AS total_payment_transactions,
    SUM(payment_amount) AS total_payments_received,
    ROUND(AVG(payment_amount), 2) AS average_payment_amount,
    MIN(payment_amount) AS minimum_payment,
    MAX(payment_amount) AS maximum_payment
FROM public.payments;



--Invoice and Payment Reconciliation

WITH payment_summary AS (
    SELECT
        invoice_id,
        SUM(payment_amount) AS total_paid
    FROM public.payments
    GROUP BY invoice_id
)
SELECT
    i.invoice_id,
    i.client_id,
    i.invoice_amount,
    COALESCE(p.total_paid, 0) AS total_paid,
    i.invoice_amount - COALESCE(p.total_paid, 0) AS outstanding_amount,
    i.invoice_status
FROM public.invoices i
LEFT JOIN payment_summary p
    ON i.invoice_id = p.invoice_id
ORDER BY outstanding_amount DESC;


--Outstanding Receivables by Client

WITH payment_summary AS (
    SELECT
        invoice_id,
        SUM(payment_amount) AS total_paid
    FROM public.payments
    GROUP BY invoice_id
)
SELECT
    c.client_id,
    c.client_name,
    SUM(i.invoice_amount) AS total_invoice_amount,
    SUM(COALESCE(p.total_paid, 0)) AS total_payments_received,
    SUM(i.invoice_amount - COALESCE(p.total_paid, 0))
        AS outstanding_receivables
FROM public.clients c
JOIN public.invoices i
    ON c.client_id = i.client_id
LEFT JOIN payment_summary p
    ON i.invoice_id = p.invoice_id
GROUP BY c.client_id, c.client_name
ORDER BY outstanding_receivables DESC;


-- Payment Method Analysis

SELECT
    payment_method,
    COUNT(*) AS payment_transactions,
    SUM(payment_amount) AS total_collections,
    ROUND(AVG(payment_amount), 2) AS average_payment
FROM public.payments
GROUP BY payment_method
ORDER BY total_collections DESC;