-- 1. Which are the top 3 expense categories by total spending for each office?

WITH category_totals AS (
    SELECT
        office_id,
        expense_category_name,
        SUM(expense_amount) AS total_expense_amount
    FROM expenses_view
    GROUP BY office_id, expense_category_name
),
ranked_categories AS (
    SELECT
        office_id,
        expense_category_name,
        total_expense_amount,
        ROW_NUMBER() OVER (
            PARTITION BY office_id
            ORDER BY total_expense_amount DESC
        ) AS rn
    FROM category_totals
)
SELECT
    ranked_categories.office_id,
    expense_categories.expense_category_name,
    ranked_categories.total_expense_amount
FROM ranked_categories
JOIN expense_categories
    ON ranked_categories.expense_category_name = expense_categories.expense_category_name
WHERE ranked_categories.rn <= 3
ORDER BY ranked_categories.office_id, ranked_categories.rn;

-- 2. What are the average personnel expenses/personnel for each department ranked in descending order?

WITH dept_totals AS (
SELECT
	department_name,
	SUM(base_salary) AS total_base_salary,
	COUNT(employee_id) AS personnel_count
FROM employees_view
GROUP BY department_name
)
SELECT
	department_name,
	total_base_salary,
	personnel_count,
	ROUND(total_base_salary / personnel_count, 2) AS avg_personnel_expense_per_employee,
RANK() OVER (ORDER BY total_base_salary / personnel_count DESC) AS rank_desc
FROM dept_totals
ORDER BY avg_personnel_expense_per_employee DESC;

-- 3. Among employees with the position title "Real Estate Agent" or "Broker", 
-- what is the average commission rate each employee has earned across all their 
-- sales and how many distinct sales have they participated in? 

SELECT 
    employees.employee_id,
    employees.first_name,
    employees.last_name,
    positions.position_title,
    COUNT(DISTINCT sales.sale_id) AS num_sales,
    ROUND(SUM(commissions.commission_amount) * 1.0 / NULLIF(SUM(sales.sale_price), 0), 4) AS avg_commission_rate
FROM employees
JOIN positions ON employees.position_id = positions.position_id
JOIN commissions ON employees.employee_id = commissions.employee_id
JOIN sales ON commissions.sale_id = sales.sale_id
WHERE positions.position_title IN ('Real Estate Agent', 'Broker')
GROUP BY employees.employee_id, employees.first_name, employees.last_name, positions.position_title
ORDER BY avg_commission_rate DESC;

-- 4. To measure workload and productivity, how many and what kind of appointments 
-- have been completed by each employee?

SELECT 
    a.employee_id,
	e.employee_since,
    e.first_name,
    e.last_name,
	SUM(CASE WHEN a.appointment_type = 'Tour' THEN 1 ELSE 0 END) AS property_tour,
    SUM(CASE WHEN a.appointment_type = 'Signing Lease' THEN 1 ELSE 0 END) AS lease_signing
FROM appointments a
JOIN employees e
    ON a.employee_id = e.employee_id
GROUP BY 
    a.employee_id,
	e.employee_since,
    e.first_name,
    e.last_name
ORDER BY 
    e.first_name,
    e.last_name;

-- 5. To measure the effectiveness of each employee, what is the ratio of sales to 
-- appointments for each employee?

WITH sales_count AS (
SELECT
      		cv.employee_id,
        	COUNT(DISTINCT sv.sale_id) AS total_sales
	FROM commissions_view cv
    	JOIN sales_view sv ON cv.sale_id = sv.sale_id
    	GROUP BY cv.employee_id
),
appointment_count AS (
	SELECT
        	av.employee_id,
        	COUNT(*) AS total_appointments
FROM appointments_view av
    	GROUP BY av.employee_id
)
SELECT
e.employee_id,
    	e.first_name,
    	e.last_name,
    	p.position_title,
    	COALESCE(sc.total_sales, 0) AS total_sales,
    	COALESCE(ac.total_appointments, 0) AS total_appointments,
    	ROUND(
        	COALESCE(sc.total_sales, 0) * 1.0 /
        	NULLIF(ac.total_appointments, 0), 2
    	) AS sales_to_appointments_ratio
FROM employees e
JOIN positions p ON e.position_id = p.position_id
LEFT JOIN sales_count sc ON e.employee_id = sc.employee_id
LEFT JOIN appointment_count ac ON e.employee_id = ac.employee_id
WHERE p.position_title IN ('Real Estate Agent', 'Broker')
ORDER BY sales_to_appointments_ratio DESC;

-- 6. What is the average property sale value for each of our offices?

SELECT 
	ev.office_address, 
	ROUND(AVG(sv.sale_price),2) as avg_sale
FROM employees_view ev
JOIN commissions_view cv
ON ev.employee_id = cv.employee_id
JOIN sales_view sv
ON cv.sale_id = sv.sale_id
GROUP BY ev.office_address;

-- 7. How has total sales grown quarter-over-quarter?

WITH quarterly_sales AS (
    SELECT 
        DATE_TRUNC('quarter', sale_date) AS quarter,
        SUM(sale_price) AS total_sales
    FROM sales_view
    GROUP BY DATE_TRUNC('quarter', sale_date)
)
SELECT 
    current_quarter.quarter,
    current_quarter.total_sales,
    previous_quarter.total_sales AS prev_quarter_sales,
    ROUND(
        (current_quarter.total_sales - previous_quarter.total_sales) / 
        NULLIF(previous_quarter.total_sales, 0),
        2
    ) AS sales_growth_rate
FROM quarterly_sales AS current_quarter
LEFT JOIN quarterly_sales AS previous_quarter
    ON current_quarter.quarter = previous_quarter.quarter + INTERVAL '3 months'
ORDER BY current_quarter.quarter;

-- 8. What are the Top 10 Zip Codes with the highest revenue potential 
-- (sum of sale price per zip code)?

WITH zip_potential AS (
	SELECT
	    zip_code,
	    SUM(listing_price) AS total_potential_revenue
  	FROM listings_view
  	WHERE active = TRUE
  	GROUP BY zip_code
),
ranked AS (
 	SELECT
	    zip_code,
	    total_potential_revenue,
		RANK() OVER (ORDER BY total_potential_revenue DESC) AS rank_desc
  	FROM zip_potential
)
SELECT
	zip_code,
  	total_potential_revenue,
  	rank_desc
FROM ranked
WHERE rank_desc <= 10
ORDER BY rank_desc, zip_code;

-- 9. To measure seasonality, what is the average number of sales that are completed 
-- during each month since we began collecting data?

SELECT 
    month,
    month_name,
    ROUND(AVG(sale_count), 2) AS avg_monthly_sale_count
FROM (
    SELECT 
        EXTRACT(MONTH FROM sale_date) AS month,
        TO_CHAR(sale_date, 'Month') AS month_name,
        EXTRACT(YEAR FROM sale_date) AS year,
        COUNT(*) AS sale_count
    FROM sales_view
    GROUP BY 
        month,
        month_name,
        year
) monthly_sales
GROUP BY 
	month, 
	month_name
ORDER BY 
	month;

-- 10. What are the demographics of our existing customers

SELECT 
    family_size,
    COUNT(CASE WHEN income < 50000 THEN 1 END) AS "$0 - 49,999",
    COUNT(CASE WHEN income >= 50000 AND income < 100000 THEN 1 END) AS "$50,000 - 99,999",
    COUNT(CASE WHEN income >= 100000 AND income < 150000 THEN 1 END) AS "$100,000 - 149,999",
	COUNT(CASE WHEN income >= 150000 AND income < 200000 THEN 1 END) AS "$150,000 - 199,999",
    COUNT(CASE WHEN income >= 200000 THEN 1 END) AS "$200,000+"
FROM 
clients_view
GROUP BY 
family_size
ORDER BY 
family_size;

