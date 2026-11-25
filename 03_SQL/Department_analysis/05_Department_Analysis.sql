--Overall Department Performance

SELECT
    COUNT(*) AS total_departments
FROM public.department;



--Department-wise Revenue Analysis

SELECT
    d.department_id,
    d.department_name,
    COUNT(r.revenue_amount) AS transaction_count,
    SUM(r.revenue_amount) AS total_revenue,
    ROUND(AVG(r.revenue_amount), 2) AS average_revenue
FROM public.department d
LEFT JOIN public.revenue r
    ON d.department_id = r.department_id
GROUP BY d.department_id, d.department_name
ORDER BY total_revenue DESC;



---Department-wise Expense Analysis

SELECT
    d.department_id,
    d.department_name,
    COUNT(e.expense_amount) AS transaction_count,
    SUM(e.expense_amount) AS total_expenses,
    ROUND(AVG(e.expense_amount), 2) AS average_expense
FROM public.department d
LEFT JOIN public.expenses e
    ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY total_expenses DESC;


--Department-wise Profitability Analysis

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
    d.department_id,
    d.department_name,
    COALESCE(r.total_revenue, 0) AS total_revenue,
    COALESCE(e.total_expenses, 0) AS total_expenses,
    COALESCE(r.total_revenue, 0) -
        COALESCE(e.total_expenses, 0) AS operating_profit,
    ROUND(
        (COALESCE(r.total_revenue, 0) -
         COALESCE(e.total_expenses, 0)) * 100.0 /
        NULLIF(COALESCE(r.total_revenue, 0), 0),
        2
    ) AS profit_margin_percentage
FROM public.department d
LEFT JOIN department_revenue r
    ON d.department_id = r.department_id
LEFT JOIN department_expenses e
    ON d.department_id = e.department_id
ORDER BY operating_profit DESC;



--Department Budget Utilisation Analysis



WITH department_budget AS (
    SELECT
        department_id,
        SUM(budget_amount) AS total_budget
    FROM public.budgets
    GROUP BY department_id
),
department_expense AS (
    SELECT
        department_id,
        SUM(expense_amount) AS total_expenses
    FROM public.expenses
    GROUP BY department_id
)
SELECT
    d.department_id,
    d.department_name,
    COALESCE(b.total_budget, 0) AS total_budget,
    COALESCE(e.total_expenses, 0) AS total_expenses,
    ROUND(
        COALESCE(e.total_expenses, 0) * 100.0 /
        NULLIF(b.total_budget, 0),
        2
    ) AS budget_utilisation_percentage,
    COALESCE(b.total_budget, 0) -
        COALESCE(e.total_expenses, 0) AS remaining_budget
FROM public.department d
LEFT JOIN department_budget b
    ON d.department_id = b.department_id
LEFT JOIN department_expense e
    ON d.department_id = e.department_id
ORDER BY budget_utilisation_percentage DESC;