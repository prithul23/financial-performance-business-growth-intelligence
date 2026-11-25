-- PROJECT: Financial Performance & Business Growth
-- MODULE: Revenue Analysis
-- DATABASE: financial_bi_project
-- PURPOSE: Analyse revenue by service line, department,
-- month and client




-- Revenue by service line

SELECT
    standardized_service_line AS service_line,
    COUNT(*) AS transaction_count,
    SUM(revenue_amount) AS total_revenue,
    AVG(revenue_amount) AS average_revenue
FROM public.revenue
GROUP BY standardized_service_line
ORDER BY total_revenue DESC;



-- Revenue by department

SELECT
    d.department_id,
    d.department_name,
    SUM(r.revenue_amount) AS total_revenue
FROM public.revenue r
JOIN public.department d
    ON r.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY total_revenue DESC;


-- Monthly revenue

SELECT
    DATE_TRUNC('month', transaction_date)::date AS revenue_month,
    SUM(revenue_amount) AS total_revenue
FROM public.revenue
GROUP BY DATE_TRUNC('month', transaction_date)
ORDER BY revenue_month;


-- Client revenue ranking

SELECT
    c.client_id,
    c.client_name,
    SUM(r.revenue_amount) AS total_revenue,
    RANK() OVER (
        ORDER BY SUM(r.revenue_amount) DESC
    ) AS revenue_rank
FROM public.revenue r
JOIN public.clients c
    ON r.client_id = c.client_id
GROUP BY c.client_id, c.client_name
ORDER BY revenue_rank;



