-- public.clients definition

-- Drop table

-- DROP TABLE public.clients;

CREATE TABLE public.clients (
	client_id varchar(10) NOT NULL,
	client_name varchar(100) NOT NULL,
	industry varchar(100) NULL,
	client_tier varchar(30) NULL,
	region varchar(100) NULL,
	CONSTRAINT clients_client_id_not_null NOT NULL client_id,
	CONSTRAINT clients_client_name_not_null NOT NULL client_name,
	CONSTRAINT clients_pkey PRIMARY KEY (client_id)
);


-- public.department definition

-- Drop table

-- DROP TABLE public.department;

CREATE TABLE public.department (
	department_id varchar(10) NOT NULL,
	department_name varchar(100) NOT NULL,
	CONSTRAINT department_department_id_not_null NOT NULL department_id,
	CONSTRAINT department_department_name_not_null NOT NULL department_name,
	CONSTRAINT department_pkey PRIMARY KEY (department_id)
);


-- public.budgets definition

-- Drop table

-- DROP TABLE public.budgets;

CREATE TABLE public.budgets (
	budget_id varchar(20) NOT NULL,
	budget_month date NOT NULL,
	department_id varchar(10) NOT NULL,
	budget_category varchar(100) NULL,
	budget_amount numeric(14, 2) NOT NULL,
	CONSTRAINT budgets_budget_amount_not_null NOT NULL budget_amount,
	CONSTRAINT budgets_budget_id_not_null NOT NULL budget_id,
	CONSTRAINT budgets_budget_month_not_null NOT NULL budget_month,
	CONSTRAINT budgets_department_id_not_null NOT NULL department_id,
	CONSTRAINT budgets_pkey PRIMARY KEY (budget_id),
	CONSTRAINT fk_budgets_department FOREIGN KEY (department_id) REFERENCES public.department(department_id)
);


-- public.expenses definition

-- Drop table

-- DROP TABLE public.expenses;

CREATE TABLE public.expenses (
	expense_id varchar(20) NOT NULL,
	expense_date date NOT NULL,
	department_id varchar(10) NOT NULL,
	standardized_expense_category varchar(100) NULL,
	standardized_vendor varchar(100) NULL,
	expense_amount numeric(14, 2) NULL,
	payment_status varchar(30) NULL,
	CONSTRAINT expenses_department_id_not_null NOT NULL department_id,
	CONSTRAINT expenses_expense_date_not_null NOT NULL expense_date,
	CONSTRAINT expenses_expense_id_not_null NOT NULL expense_id,
	CONSTRAINT expenses_pkey PRIMARY KEY (expense_id),
	CONSTRAINT fk_expenses_department FOREIGN KEY (department_id) REFERENCES public.department(department_id)
);


-- public.invoices definition

-- Drop table

-- DROP TABLE public.invoices;

CREATE TABLE public.invoices (
	invoice_id varchar(20) NOT NULL,
	client_id varchar(10) NOT NULL,
	invoice_date date NOT NULL,
	due_date date NOT NULL,
	invoice_amount numeric(14, 2) NOT NULL,
	invoice_status varchar(30) NULL,
	CONSTRAINT invoices_client_id_not_null NOT NULL client_id,
	CONSTRAINT invoices_due_date_not_null NOT NULL due_date,
	CONSTRAINT invoices_invoice_amount_not_null NOT NULL invoice_amount,
	CONSTRAINT invoices_invoice_date_not_null NOT NULL invoice_date,
	CONSTRAINT invoices_invoice_id_not_null NOT NULL invoice_id,
	CONSTRAINT invoices_pkey PRIMARY KEY (invoice_id),
	CONSTRAINT fk_invoices_client FOREIGN KEY (client_id) REFERENCES public.clients(client_id)
);


-- public.payments definition

-- Drop table

-- DROP TABLE public.payments;

CREATE TABLE public.payments (
	payment_id varchar(20) NOT NULL,
	invoice_id varchar(20) NOT NULL,
	payment_date date NOT NULL,
	payment_amount numeric(14, 2) NOT NULL,
	payment_method varchar(50) NULL,
	CONSTRAINT payments_invoice_id_not_null NOT NULL invoice_id,
	CONSTRAINT payments_payment_amount_not_null NOT NULL payment_amount,
	CONSTRAINT payments_payment_date_not_null NOT NULL payment_date,
	CONSTRAINT payments_payment_id_not_null NOT NULL payment_id,
	CONSTRAINT payments_pkey PRIMARY KEY (payment_id),
	CONSTRAINT fk_payments_invoice FOREIGN KEY (invoice_id) REFERENCES public.invoices(invoice_id)
);


-- public.revenue definition

-- Drop table

-- DROP TABLE public.revenue;

CREATE TABLE public.revenue (
	revenue_id varchar(20) NOT NULL,
	transaction_date date NOT NULL,
	client_id varchar(10) NOT NULL,
	standardized_service_line varchar(100) NULL,
	revenue_amount numeric(14, 2) NULL,
	currency varchar(3) NULL,
	department_id varchar(50) NULL,
	CONSTRAINT revenue_client_id_not_null NOT NULL client_id,
	CONSTRAINT revenue_pkey PRIMARY KEY (revenue_id),
	CONSTRAINT revenue_revenue_id_not_null NOT NULL revenue_id,
	CONSTRAINT revenue_transaction_date_not_null NOT NULL transaction_date,
	CONSTRAINT fk_revenue_client FOREIGN KEY (client_id) REFERENCES public.clients(client_id),
	CONSTRAINT fk_revenue_department FOREIGN KEY (department_id) REFERENCES public.department(department_id)
);