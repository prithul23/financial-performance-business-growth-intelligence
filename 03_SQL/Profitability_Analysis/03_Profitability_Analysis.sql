-- Overall Profitability Summary


SELECT
    SUM(r.revenue_amount) AS total_revenue,
    SUM(e.expense_amount) AS total_expenses,
    SUM(r.revenue_amount) - SUM(e.expense_amount) AS operating_profit,
    ROUND(
        (SUM(r.revenue_amount) - SUM(e.expense_amount)) * 100.0 /
        NULLIF(SUM(r.revenue_amount), 0),
        2
    ) AS profit_margin_percentage
FROM public.revenue r
CROSS JOIN (
    SELECT SUM(expense_amount) AS expense_amount
    FROM public.expenses
) e;



-- Monthly Profitability Analysis

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', transaction_date)::date AS month,
        SUM(revenue_amount) AS total_revenue
    FROM public.revenue
    GROUP BY DATE_TRUNC('month', transaction_date)
),
monthly_expenses AS (
    SELECT
        DATE_TRUNC('month', expense_date)::date AS month,
        SUM(expense_amount) AS total_expenses
    FROM public.expenses
    GROUP BY DATE_TRUNC('month', expense_date)
)
SELECT
    COALESCE(r.month, e.month) AS month,
    COALESCE(r.total_revenue, 0) AS total_revenue,
    COALESCE(e.total_expenses, 0) AS total_expenses,
    COALESCE(r.total_revenue, 0) -
        COALESCE(e.total_expenses, 0) AS operating_profit
FROM monthly_revenue r
FULL OUTER JOIN monthly_expenses e
    ON r.month = e.month
ORDER BY month;



-- Department-wise Profitability Analysis


WITH department_revenue AS (
    SELECT
        department_id,
        SUM(revenue_amount) AS total_revenue
    FROM public.revenue
    GROUP BY department_id
),
department_expenses AS (
    SELECT
        department_id,
        SUM(expense_amount) AS total_expenses
    FROM public.expenses
    GROUP BY department_id
)
SELECT
    d.department_name,
    COALESCE(r.total_revenue, 0) AS total_revenue,
    COALESCE(e.total_expenses, 0) AS total_expenses,
    COALESCE(r.total_revenue, 0) -
        COALESCE(e.total_expenses, 0) AS operating_profit
FROM public.department d
LEFT JOIN department_revenue r
    ON d.department_id = r.department_id
LEFT JOIN department_expenses e
    ON d.department_id = e.department_id
ORDER BY operating_profit DESC;



-- Service Line Profitability Analysis

SELECT
    standardized_service_line,
    COUNT(*) AS transaction_count,
    SUM(revenue_amount) AS total_revenue,
    ROUND(AVG(revenue_amount), 2) AS average_revenue
FROM public.revenue
GROUP BY standardized_service_line
ORDER BY total_revenue DESC;



-- Monthly Profit Margin Analysis

WITH monthly_data AS (
    SELECT
        DATE_TRUNC('month', transaction_date)::date AS month,
        SUM(revenue_amount) AS total_revenue
    FROM public.revenue
    GROUP BY DATE_TRUNC('month', transaction_date)
),
monthly_costs AS (
    SELECT
        DATE_TRUNC('month', expense_date)::date AS month,
        SUM(expense_amount) AS total_expenses
    FROM public.expenses
    GROUP BY DATE_TRUNC('month', expense_date)
)
SELECT
    r.month,
    r.total_revenue,
    COALESCE(e.total_expenses, 0) AS total_expenses,
    r.total_revenue - COALESCE(e.total_expenses, 0) AS operating_profit,
    ROUND(
        (r.total_revenue - COALESCE(e.total_expenses, 0)) * 100.0 /
        NULLIF(r.total_revenue, 0),
        2
    ) AS profit_margin_percentage
FROM monthly_data r
LEFT JOIN monthly_costs e
    ON r.month = e.month
ORDER BY r.month;