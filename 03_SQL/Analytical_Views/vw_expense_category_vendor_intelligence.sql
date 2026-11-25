-- public.vw_expense_category_vendor_intelligence source

CREATE OR REPLACE VIEW public.vw_expense_category_vendor_intelligence
AS SELECT standardized_expense_category AS expense_category,
    standardized_vendor AS vendor,
    count(expense_id) AS total_transactions,
    sum(expense_amount) AS total_expenses,
    round(sum(expense_amount) * 100.0 / NULLIF(( SELECT sum(expenses_1.expense_amount) AS sum
           FROM expenses expenses_1), 0::numeric), 2) AS expense_contribution_percentage
   FROM expenses
  WHERE expense_amount IS NOT NULL
  GROUP BY standardized_expense_category, standardized_vendor;