-- public.vw_department_expense_budget_intelligence source

CREATE OR REPLACE VIEW public.vw_department_expense_budget_intelligence
AS WITH department_expenses AS (
         SELECT expenses.department_id,
            sum(expenses.expense_amount) AS total_expenses
           FROM expenses
          WHERE expenses.expense_amount IS NOT NULL
          GROUP BY expenses.department_id
        ), department_budgets AS (
         SELECT budgets.department_id,
            sum(budgets.budget_amount) AS total_budget
           FROM budgets
          GROUP BY budgets.department_id
        )
 SELECT d.department_id,
    d.department_name,
    COALESCE(e.total_expenses, 0::numeric) AS total_expenses,
    COALESCE(b.total_budget, 0::numeric) AS total_budget,
    round(COALESCE(e.total_expenses, 0::numeric) * 100.0 / NULLIF(b.total_budget, 0::numeric), 2) AS budget_utilisation_percentage,
    COALESCE(b.total_budget, 0::numeric) - COALESCE(e.total_expenses, 0::numeric) AS budget_variance
   FROM department d
     LEFT JOIN department_expenses e ON d.department_id::text = e.department_id::text
     LEFT JOIN department_budgets b ON d.department_id::text = b.department_id::text;