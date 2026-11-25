-- Overall Budget Performance

SELECT
    COUNT(*) AS total_budget_records,
    SUM(budget_amount) AS total_allocated_budget,
    ROUND(AVG(budget_amount), 2) AS average_budget,
    MIN(budget_amount) AS minimum_budget,
    MAX(budget_amount) AS maximum_budget
FROM public.budgets;


--Department-wise Budget Allocation

SELECT
    d.department_id,
    d.department_name,
    SUM(b.budget_amount) AS total_allocated_budget
FROM public.department d
JOIN public.budgets b
    ON d.department_id = b.department_id
GROUP BY d.department_id, d.department_name
ORDER BY total_allocated_budget DESC;



--- Department-wise Budget Utilisation

WITH department_budget AS (
    SELECT
        department_id,
        SUM(budget_amount) AS total_budget
    FROM public.budgets
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
LEFT JOIN department_expenses e
    ON d.department_id = e.department_id
ORDER BY budget_utilisation_percentage DESC;


--Budget vs Actual Expense Analysis

WITH budget_summary AS (
    SELECT
        department_id,
        SUM(budget_amount) AS total_budget
    FROM public.budgets
    GROUP BY department_id
),
expense_summary AS (
    SELECT
        department_id,
        SUM(expense_amount) AS actual_expenses
    FROM public.expenses
    GROUP BY department_id
)
SELECT
    d.department_name,
    COALESCE(b.total_budget, 0) AS total_budget,
    COALESCE(e.actual_expenses, 0) AS actual_expenses,
    COALESCE(b.total_budget, 0) -
        COALESCE(e.actual_expenses, 0) AS budget_variance,
    CASE
        WHEN COALESCE(e.actual_expenses, 0) >
             COALESCE(b.total_budget, 0)
        THEN 'Over Budget'
        WHEN COALESCE(e.actual_expenses, 0) <
             COALESCE(b.total_budget, 0)
        THEN 'Under Budget'
        ELSE 'On Budget'
    END AS budget_status
FROM public.department d
LEFT JOIN budget_summary b
    ON d.department_id = b.department_id
LEFT JOIN expense_summary e
    ON d.department_id = e.department_id
ORDER BY budget_variance ASC;



-- Monthly Budget Allocation Analysis

SELECT
    DATE_TRUNC('month', budget_month)::date AS budget_month,
    SUM(budget_amount) AS total_allocated_budget,
    COUNT(*) AS budget_records
FROM public.budgets
GROUP BY DATE_TRUNC('month', budget_month)
ORDER BY budget_month;