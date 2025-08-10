DROP VIEW IF EXISTS employees_view, clients_view, listings_view, commissions_view, sales_view, appointments_view, expenses_view;

CREATE VIEW employees_view AS
SELECT
    e.employee_id,
    o.address AS office_address,
    p.position_title,
    d.department_name,
    e.employee_since,
    pr.base_salary
FROM employees AS e
	JOIN offices AS o ON e.office_id = o.office_id
	JOIN positions AS p ON e.position_id = p.position_id
	JOIN departments AS d ON e.department_id = d.department_id
    JOIN payrolls pr ON e.employee_id = pr.employee_id;


CREATE VIEW clients_view AS
SELECT
    c.client_id,
    c.family_size,
    c.income
FROM clients AS c;

CREATE VIEW listings_view AS
SELECT
    l.listing_id,
    p.building_number,
    p.street_name,
    p.apartment,
    p.city,
    p.state,
    p.zip_code,
    lf.bedrooms,
    lf.bathrooms,
    lf.square_feet,
    lf.in_unit_washer,
    lf.dishwasher,
    lf.outdoor_space,
    lf.elevator,
    lf.doorman,
    lf.laundry_room,
    lf.pool,
    lf.gym,
    lf.rec_room,
    lf.parking,
    l.active,
    l.listing_type,
    l.listing_price
FROM listings AS l
JOIN properties AS p ON l.property_id = p.property_id
JOIN listing_features AS lf ON l.listing_id = lf.listing_id;

CREATE VIEW commissions_view AS
SELECT *
FROM commissions;

CREATE VIEW sales_view AS
SELECT
    s.sale_id,
    s.client_id,
    l.listing_id,
    s.sale_price,
    s.sale_date
FROM sales AS s
JOIN listings AS l ON s.property_id = l.property_id;

CREATE VIEW appointments_view AS
SELECT *
FROM appointments;

CREATE VIEW expenses_view AS
SELECT
    e.expense_id,
    e.office_id,
    e.employee_id,
    e.expense_date,
    ec.expense_category_name,
    e.expense_amount
FROM expenses AS e
JOIN expense_categories AS ec ON e.expense_category_id = ec.expense_category_id;

