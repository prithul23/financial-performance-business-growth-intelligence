-- Client Revenue Ranking (RANK)

SELECT
    c.client_id,
    c.client_name,
    SUM(r.revenue_amount) AS total_revenue,
    RANK() OVER (
        ORDER BY SUM(r.revenue_amount) DESC
    ) AS revenue_rank
FROM public.clients c
JOIN public.revenue r
    ON c.client_id = r.client_id
GROUP BY c.client_id, c.client_name
ORDER BY revenue_rank;


-- Monthly Revenue Running Total

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', transaction_date)::date AS revenue_month,
        SUM(revenue_amount) AS total_revenue
    FROM public.revenue
    GROUP BY DATE_TRUNC('month', transaction_date)
)
SELECT
    revenue_month,
    total_revenue,
    SUM(total_revenue) OVER (
        ORDER BY revenue_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_revenue
FROM monthly_revenue
ORDER BY revenue_month;


-- Month-over-Month Revenue Growth (LAG)

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', transaction_date)::date AS revenue_month,
        SUM(revenue_amount) AS total_revenue
    FROM public.revenue
    GROUP BY DATE_TRUNC('month', transaction_date)
)
SELECT
    revenue_month,
    total_revenue,
    LAG(total_revenue) OVER (
        ORDER BY revenue_month
    ) AS previous_month_revenue,
    ROUND(
        (total_revenue - LAG(total_revenue) OVER (
            ORDER BY revenue_month
        )) * 100.0 /
        NULLIF(LAG(total_revenue) OVER (
            ORDER BY revenue_month
        ), 0),
        2
    ) AS growth_percentage
FROM monthly_revenue
ORDER BY revenue_month;



-- Top 3 Clients Within Each Department (PARTITION BY)


WITH client_department_revenue AS (
    SELECT
        d.department_name,
        c.client_id,
        c.client_name,
        SUM(r.revenue_amount) AS total_revenue
    FROM public.revenue r
    JOIN public.clients c
        ON r.client_id = c.client_id
    JOIN public.department d
        ON r.department_id = d.department_id
    GROUP BY
        d.department_name,
        c.client_id,
        c.client_name
),
ranked_clients AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY department_name
            ORDER BY total_revenue DESC
        ) AS department_rank
    FROM client_department_revenue
)
SELECT *
FROM ranked_clients
WHERE department_rank <= 3
ORDER BY department_name, department_rank;



-- Invoice Collection Risk Ranking

WITH payment_summary AS (
    SELECT
        invoice_id,
        SUM(payment_amount) AS total_paid
    FROM public.payments
    GROUP BY invoice_id
),
invoice_balances AS (
    SELECT
        i.invoice_id,
        i.client_id,
        i.invoice_amount,
        i.invoice_date,
        i.due_date,
        i.invoice_status,
        COALESCE(p.total_paid, 0) AS total_paid,
        i.invoice_amount - COALESCE(p.total_paid, 0)
            AS outstanding_amount
    FROM public.invoices i
    LEFT JOIN payment_summary p
        ON i.invoice_id = p.invoice_id
)
SELECT
    *,
    RANK() OVER (
        ORDER BY outstanding_amount DESC
    ) AS collection_risk_rank
FROM invoice_balances
WHERE outstanding_amount > 0
ORDER BY collection_risk_rank;