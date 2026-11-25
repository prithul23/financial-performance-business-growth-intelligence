--Overall Client Performance

SELECT
    COUNT(DISTINCT c.client_id) AS total_clients,
    COUNT(DISTINCT r.client_id) AS clients_with_revenue,
    SUM(r.revenue_amount) AS total_revenue,
    ROUND(AVG(r.revenue_amount), 2) AS average_transaction_revenue
FROM public.clients c
LEFT JOIN public.revenue r
    ON c.client_id = r.client_id;


--Revenue by Client

SELECT
    c.client_id,
    c.client_name,
    COUNT(r.client_id) AS transaction_count,
    SUM(r.revenue_amount) AS total_revenue,
    ROUND(AVG(r.revenue_amount), 2) AS average_revenue
FROM public.clients c
JOIN public.revenue r
    ON c.client_id = r.client_id
GROUP BY c.client_id, c.client_name
ORDER BY total_revenue DESC;


--Top 10 Revenue-Generating Clients

SELECT
    c.client_id,
    c.client_name,
    SUM(r.revenue_amount) AS total_revenue,
    COUNT(*) AS transaction_count
FROM public.clients c
JOIN public.revenue r
    ON c.client_id = r.client_id
GROUP BY c.client_id, c.client_name
ORDER BY total_revenue DESC
LIMIT 10;


-- Client Revenue Contribution Analysis

WITH client_revenue AS (
    SELECT
        c.client_id,
        c.client_name,
        SUM(r.revenue_amount) AS total_revenue
    FROM public.clients c
    JOIN public.revenue r
        ON c.client_id = r.client_id
    GROUP BY c.client_id, c.client_name
)
SELECT
    client_id,
    client_name,
    total_revenue,
    ROUND(
        total_revenue * 100.0 /
        NULLIF(SUM(total_revenue) OVER (), 0),
        2
    ) AS revenue_contribution_percentage
FROM client_revenue
ORDER BY total_revenue DESC;


--Client Outstanding Receivables Analysis

SELECT
    c.client_id,
    c.client_name,
    COUNT(DISTINCT i.invoice_id) AS total_invoices,
    SUM(i.invoice_amount) AS total_invoice_amount,
    SUM(i.invoice_amount) -
        COALESCE(SUM(p.total_paid), 0) AS outstanding_receivables
FROM public.clients c
JOIN public.invoices i
    ON c.client_id = i.client_id
LEFT JOIN (
    SELECT
        invoice_id,
        SUM(payment_amount) AS total_paid
    FROM public.payments
    GROUP BY invoice_id
) p
    ON i.invoice_id = p.invoice_id
GROUP BY c.client_id, c.client_name
ORDER BY outstanding_receivables DESC;