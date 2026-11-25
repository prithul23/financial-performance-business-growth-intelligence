-- public.vw_executive_financial_overview source

CREATE OR REPLACE VIEW public.vw_executive_financial_overview
AS WITH monthly_revenue AS (
         SELECT date_trunc('month'::text, revenue.transaction_date::timestamp with time zone)::date AS month,
            sum(revenue.revenue_amount) AS total_revenue
           FROM revenue
          WHERE revenue.revenue_amount IS NOT NULL
          GROUP BY (date_trunc('month'::text, revenue.transaction_date::timestamp with time zone))
        ), monthly_expenses AS (
         SELECT date_trunc('month'::text, expenses.expense_date::timestamp with time zone)::date AS month,
            sum(expenses.expense_amount) AS total_expenses
           FROM expenses
          WHERE expenses.expense_amount IS NOT NULL
          GROUP BY (date_trunc('month'::text, expenses.expense_date::timestamp with time zone))
        ), monthly_budgets AS (
         SELECT date_trunc('month'::text, budgets.budget_month::timestamp with time zone)::date AS month,
            sum(budgets.budget_amount) AS total_budget
           FROM budgets
          GROUP BY (date_trunc('month'::text, budgets.budget_month::timestamp with time zone))
        ), monthly_financials AS (
         SELECT COALESCE(r.month, e.month, b.month) AS month,
            COALESCE(r.total_revenue, 0::numeric) AS total_revenue,
            COALESCE(e.total_expenses, 0::numeric) AS total_expenses,
            b.total_budget
           FROM monthly_revenue r
             FULL JOIN monthly_expenses e ON r.month = e.month
             FULL JOIN monthly_budgets b ON COALESCE(r.month, e.month) = b.month
        )
 SELECT month,
    total_revenue,
    total_expenses,
    total_revenue - total_expenses AS operating_profit,
    round((total_revenue - total_expenses) / NULLIF(total_revenue, 0::numeric) * 100::numeric, 2) AS profit_margin,
    total_budget,
    round(total_expenses / NULLIF(total_budget, 0::numeric) * 100::numeric, 2) AS budget_utilisation_percentage,
    total_budget - total_expenses AS budget_variance
   FROM monthly_financials;