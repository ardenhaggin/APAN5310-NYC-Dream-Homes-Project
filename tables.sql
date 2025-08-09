CREATE TABLE addresses (
    address_id SERIAL PRIMARY KEY,
    building_number VARCHAR(50) NOT NULL,
    street_name VARCHAR(50) NOT NULL,
    apartment VARCHAR(5) NOT NULL,
    city VARCHAR(20) NOT NULL,
    state CHAR(2) NOT NULL,
    zip_code CHAR(5) NOT NULL
);

CREATE TABLE clients (
    client_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    family_size INT,
    income NUMERIC(10,2)
);

CREATE TABLE sales (
    sale_id SERIAL PRIMARY KEY,
    client_id INT NOT NULL REFERENCES clients(client_id),
    address_id INT NOT NULL REFERENCES addresses(address_id),
    sale_price NUMERIC(11,2) NOT NULL,
    sale_date DATE NOT NULL
);

CREATE TABLE listings (
    listing_id SERIAL PRIMARY KEY,
    address_id INT NOT NULL REFERENCES addresses(address_id) ON DELETE CASCADE,
    listing_type VARCHAR(20) NOT NULL,
    listing_price NUMERIC(11,2) NOT NULL,
    sale_id INT REFERENCES sales(sale_id),
    active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE parks (
    p_id SERIAL PRIMARY KEY,
    address_id INT NOT NULL REFERENCES addresses(address_id) ON DELETE CASCADE,
    park_name VARCHAR(50) NOT NULL,
    zip_code CHAR(5) NOT NULL
);

CREATE TABLE parks_addresses (
    p_id INT NOT NULL REFERENCES parks(p_id) ON DELETE CASCADE,
    address_id INT NOT NULL REFERENCES addresses(address_id) ON DELETE CASCADE,
    PRIMARY KEY (p_id, address_id)
);

CREATE TABLE schools (
    s_id SERIAL PRIMARY KEY,
    address_id INT NOT NULL REFERENCES addresses(address_id) ON DELETE CASCADE,
    school_name VARCHAR(50) NOT NULL,
    zip_code CHAR(5) NOT NULL
);

CREATE TABLE schools_addresses (
    s_id INT NOT NULL REFERENCES schools(s_id) ON DELETE CASCADE,
    address_id INT NOT NULL REFERENCES addresses(address_id) ON DELETE CASCADE,
    PRIMARY KEY (s_id, address_id)
);

CREATE TABLE service_requests (
    sr_id SERIAL PRIMARY KEY,
    address_id INT NOT NULL REFERENCES addresses(address_id) ON DELETE CASCADE,
    complaint_type VARCHAR(30) NOT NULL
);

CREATE TABLE violations (
    v_id SERIAL PRIMARY KEY,
    address_id INT NOT NULL REFERENCES addresses(address_id) ON DELETE CASCADE,
    class CHAR(1) NOT NULL
);

CREATE TABLE offices (
    office_id SERIAL PRIMARY KEY,
    address VARCHAR(50) NOT NULL,
    city VARCHAR(20) NOT NULL,
    state CHAR(2) NOT NULL,
    phone_number VARCHAR(15) NOT NULL
);

CREATE TABLE positions (
    position_id SERIAL PRIMARY KEY,
    position_title VARCHAR(20) NOT NULL
);

CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(20) NOT NULL
);

CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    office_id INT NOT NULL REFERENCES offices(office_id) ON DELETE CASCADE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    position_id INT NOT NULL REFERENCES positions(position_id),
    department_id INT NOT NULL REFERENCES departments(department_id),
    employee_since DATE NOT NULL,
    email VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE payrolls (
    payroll_id SERIAL PRIMARY KEY,
    employee_id INT NOT NULL REFERENCES employees(employee_id) ON DELETE CASCADE,
    base_salary NUMERIC(10,2) NOT NULL
);

CREATE TABLE commissions (
    commission_id SERIAL PRIMARY KEY,
    employee_id INT NOT NULL REFERENCES employees(employee_id),
    sale_id INT NOT NULL REFERENCES sales(sale_id) ON DELETE CASCADE,
    commission_amount NUMERIC(12,2) NOT NULL
);

CREATE TABLE expense_categories (
    expense_category_id SERIAL PRIMARY KEY,
    expense_category_name VARCHAR(20) NOT NULL
);

CREATE TABLE expenses (
    expense_id SERIAL PRIMARY KEY,
    office_id INT NOT NULL REFERENCES offices(office_id),
    employee_id INT NOT NULL REFERENCES employees(employee_id),
    expense_date DATE NOT NULL,
    expense_category_id INT NOT NULL REFERENCES expense_categories(expense_category_id),
    expense_amount NUMERIC(8,2) NOT NULL
);

CREATE TABLE equipment_types (
    equipment_type_id SERIAL PRIMARY KEY,
    equipment_type_name VARCHAR(15) NOT NULL
);

CREATE TABLE equipment (
    equipment_id SERIAL PRIMARY KEY,
    office_id INT NOT NULL REFERENCES offices(office_id) ON DELETE CASCADE,
    employee_id INT NOT NULL REFERENCES employees(employee_id) ON DELETE CASCADE,
    equipment_type_id INT NOT NULL REFERENCES equipment_types(equipment_type_id) ON DELETE CASCADE
);

CREATE TABLE appointments (
    appointment_id SERIAL PRIMARY KEY,
    appointment_type VARCHAR(20) NOT NULL,
    employee_id INT NOT NULL REFERENCES employees(employee_id) ON DELETE CASCADE,
    client_id INT NOT NULL REFERENCES clients(client_id) ON DELETE CASCADE,
    listing_id INT NOT NULL REFERENCES listings(listing_id) ON DELETE CASCADE
);

CREATE TABLE listing_features (
    l_features_id SERIAL PRIMARY KEY,
    listing_id INT NOT NULL REFERENCES listings(listing_id) ON DELETE CASCADE,
    bedrooms INT NOT NULL,
    bathrooms INT NOT NULL,
    square_feet INT NOT NULL,
    in_unit_washer BOOLEAN NOT NULL,
    dishwasher BOOLEAN NOT NULL,
    outdoor_space BOOLEAN NOT NULL,
    elevator BOOLEAN NOT NULL,
    doorman BOOLEAN NOT NULL,
    laundry_room BOOLEAN NOT NULL,
    pool BOOLEAN NOT NULL,
    gym BOOLEAN NOT NULL,
    rec_room BOOLEAN NOT NULL,
    parking BOOLEAN NOT NULL
);

CREATE OR REPLACE FUNCTION deactivate_listing_on_sale()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE listings
    SET active = FALSE
    WHERE address_id = NEW.address_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_deactivate_listing
AFTER INSERT ON sales
FOR EACH ROW
EXECUTE FUNCTION deactivate_listing_on_sale();







