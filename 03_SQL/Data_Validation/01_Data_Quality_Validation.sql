-- =====================================================
-- PROJECT: Financial Performance & Business Growth
-- MODULE: Data Validation
-- PURPOSE: Check record counts and missing financial values
-- DATABASE: financial_bi_project
-- =====================================================



--- Revenue missing-value validation

SELECT
    COUNT(*) AS revenue_rows,
    COUNT(*) FILTER (
        WHERE revenue_amount IS NULL
    ) AS missing_revenue
FROM public.revenue;



--- Expense missing-value validation

SELECT
    COUNT(*) AS expense_rows,
    COUNT(*) FILTER (
        WHERE expense_amount IS NULL
    ) AS missing_expenses
FROM public.expenses;