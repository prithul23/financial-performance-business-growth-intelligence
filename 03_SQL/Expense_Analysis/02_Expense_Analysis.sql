-- Overall Expense Performance


SELECT
    COUNT(*) AS total_transactions,
    SUM(expense_amount) AS total_expenses,
    ROUND(AVG(expense_amount), 2) AS average_expense,
    MIN(expense_amount) AS minimum_expense,
    MAX(expense_amount) AS maximum_expense
FROM public.expenses;



-- Expense Category Analysis

SELECT
    standardized_expense_category ,
    COUNT(*) AS transaction_count,
    SUM(expense_amount) AS total_expenses,
    ROUND(AVG(expense_amount), 2) AS average_expense
FROM public.expenses
GROUP BY standardized_expense_category
ORDER BY total_expenses DESC;



-- Monthly Expense Trend

SELECT
    DATE_TRUNC('month', expense_date)::date AS expense_month,
    COUNT(*) AS transaction_count,
    SUM(expense_amount) AS total_expenses
FROM public.expenses
GROUP BY DATE_TRUNC('month', expense_date)
ORDER BY expense_month;




-- Department-wise Expense Analysis


SELECT
    d.department_name,
    COUNT(*) AS transaction_count,
    SUM(e.expense_amount) AS total_expenses,
    ROUND(AVG(e.expense_amount), 2) AS average_expense
FROM public.expenses e
JOIN public.department d
    ON e.department_id = d.department_id
GROUP BY d.department_name
ORDER BY total_expenses DESC;



--Vendor-wise Expense Analysis

SELECT
    standardized_vendor,
    COUNT(*) AS transaction_count,
    SUM(expense_amount) AS total_expenses,
    ROUND(AVG(expense_amount), 2) AS average_expense
FROM public.expenses
GROUP BY standardized_vendor
ORDER BY total_expenses DESC
LIMIT 10;



--Paid vs Pending Expense Analysis

SELECT
    payment_status,
    COUNT(*) AS transaction_count,
    SUM(expense_amount) AS total_expenses
FROM public.expenses
GROUP BY payment_status
ORDER BY total_expenses DESC;






