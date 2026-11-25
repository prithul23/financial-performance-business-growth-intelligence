-- public.vw_monthly_expense_trend source

CREATE OR REPLACE VIEW public.vw_monthly_expense_trend
AS SELECT date_trunc('month'::text, expense_date::timestamp with time zone)::date AS month,
    sum(expense_amount) AS total_expenses,
    count(expense_id) AS total_transactions,
    count(DISTINCT department_id) AS active_departments,
    round(sum(expense_amount) * 100.0 / NULLIF(( SELECT sum(expenses_1.expense_amount) AS sum
           FROM expenses expenses_1), 0::numeric), 2) AS expense_contribution_percentage
   FROM expenses
  WHERE expense_amount IS NOT NULL
  GROUP BY (date_trunc('month'::text, expense_date::timestamp with time zone));