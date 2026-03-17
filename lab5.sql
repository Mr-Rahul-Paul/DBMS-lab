CREATE DATABASE IF NOT EXISTS MedicalShopDB;
USE MedicalShopDB;

-- 1. DDL: Create Customer Table
CREATE TABLE Customer (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(15),
    address VARCHAR(255),
    past_orders INT DEFAULT 0,
    payment_method VARCHAR(50)
);

-- 2. DDL: Create Company Table
CREATE TABLE Company (
    company_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100),
    phone VARCHAR(15)
);

-- 3. DDL: Create Medicine Table
CREATE TABLE Medicine (
    medicine_id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT,
    type VARCHAR(50),
    expiry DATE,
    content TEXT,
    FOREIGN KEY (company_id) REFERENCES Company(company_id) ON DELETE SET NULL
);

-- 4. DDL: Create Shop Inventory Table
CREATE TABLE Shop_Inventory (
    inventory_id INT PRIMARY KEY AUTO_INCREMENT,
    medicine_id INT,
    name VARCHAR(100),
    qty INT CHECK (qty >= 0),
    cp DECIMAL(10,2),
    sp DECIMAL(10,2),
    expiry DATE,
    FOREIGN KEY (medicine_id) REFERENCES Medicine(medicine_id) ON DELETE CASCADE
);

-- 5. DDL: Create Wholeseller Table
CREATE TABLE Wholeseller (
    wholeseller_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(255),
    phone VARCHAR(15)
);

-- 6. DDL: Create Wholeseller Inventory Table
CREATE TABLE Wholeseller_Inventory (
    inventory_id INT PRIMARY KEY AUTO_INCREMENT,
    medicine_id INT,
    name VARCHAR(100),
    qty INT CHECK (qty >= 0),
    cp DECIMAL(10,2),
    sp DECIMAL(10,2),
    expiry DATE,
    wholeseller_id INT,
    FOREIGN KEY (medicine_id) REFERENCES Medicine(medicine_id) ON DELETE CASCADE,
    FOREIGN KEY (wholeseller_id) REFERENCES Wholeseller(wholeseller_id) ON DELETE CASCADE
);

-- 7. DDL: Create Logistics Table
CREATE TABLE Logistics (
    logistics_id INT PRIMARY KEY AUTO_INCREMENT,
    company_name VARCHAR(100),
    vehicle_no VARCHAR(20),
    driver_name VARCHAR(50)
);

-- 8. DDL: Create Bills Table
CREATE TABLE Bills (
    bill_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    bill_date DATE,
    total_amount DECIMAL(10,2) DEFAULT 0,
    status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE CASCADE
);

-- 9. DML: Insert into Customer
INSERT INTO Customer (name, phone, address, past_orders, payment_method) VALUES
('Ravi Kumar', '9876543210', 'Mumbai', 5, 'Credit Card'),
('Meera Patel', '8765432109', 'Delhi', 2, 'Cash'),
('Aman Singh', '7654321098', 'Bangalore', 10, 'UPI');

-- 10. DML: Insert into Company
INSERT INTO Company (name, contact_person, phone) VALUES
('PharmaCorp', 'Rahul Sharma', '1122334455'),
('HealthMed', 'Sunil Joshi', '9988776655');

-- 11. DML: Insert into Medicine
INSERT INTO Medicine (company_id, type, expiry, content) VALUES
(1, 'Tablet', '2025-12-31', 'Paracetamol 500mg'),
(2, 'Syrup', '2026-06-30', 'Cough Suppressant'),
(1, 'Capsule', '2024-11-15', 'Amoxicillin 250mg');

-- 12. DML: Insert into Shop_Inventory
INSERT INTO Shop_Inventory (medicine_id, name, qty, cp, sp, expiry) VALUES
(1, 'Paracetamol', 100, 10.00, 15.00, '2025-12-31'),
(2, 'Cough Syrup', 50, 40.00, 60.00, '2026-06-30'),
(3, 'Amoxil', 200, 5.00, 10.00, '2024-11-15');

-- 13. DML: Insert into Wholeseller and Wholeseller_Inventory
INSERT INTO Wholeseller (name, location, phone) VALUES ('ABC Wholesales', 'Gujarat', '5566778899');
INSERT INTO Wholeseller_Inventory (medicine_id, name, qty, cp, sp, expiry, wholeseller_id) VALUES
(1, 'Paracetamol Bulk', 10000, 8.00, 10.00, '2025-12-31', 1);

-- 14. DML: Insert into Logistics
INSERT INTO Logistics (company_name, vehicle_no, driver_name) VALUES
('Speedy Transport', 'MH-01-AB-1234', 'Ramesh');

-- 15. DML: Insert into Bills
INSERT INTO Bills (customer_id, bill_date, total_amount, status) VALUES
(1, '2023-10-01', 150.00, 'Paid'),
(2, '2023-10-05', 300.00, 'Pending');

-- 16. DQL: Select all medicines with their company name (INNER JOIN)
SELECT m.medicine_id, m.type, c.name AS company_name 
FROM Medicine m 
JOIN Company c ON m.company_id = c.company_id;

-- 17. DQL: Find shop inventory items expiring before 2025 (WHERE)
SELECT * FROM Shop_Inventory WHERE expiry < '2025-01-01';

-- 18. DQL: Count the number of past orders per payment method (GROUP BY)
SELECT payment_method, SUM(past_orders) AS total_past_orders 
FROM Customer 
GROUP BY payment_method;

-- 19. DQL: Find customers having more than 3 past orders (HAVING)
SELECT name, past_orders 
FROM Customer 
GROUP BY customer_id 
HAVING past_orders > 3;

-- 20. DQL: Subquery to find bills for customers who pay via UPI
SELECT * FROM Bills 
WHERE customer_id IN (SELECT customer_id FROM Customer WHERE payment_method = 'UPI');

-- 21. DML: Update operation
UPDATE Customer SET address = 'Pune' WHERE name = 'Ravi Kumar';

-- 22. DML: Delete operation
DELETE FROM Medicine WHERE medicine_id = 3; 
-- Note: ON DELETE CASCADE will trigger and delete inventory records as well.

-- 23. View: Create a view for Shop Inventory overview
CREATE VIEW Shop_Inventory_View AS
SELECT name, qty, sp, (qty * sp) AS total_potential_revenue
FROM Shop_Inventory;

-- 24. DQL: Select from View
SELECT * FROM Shop_Inventory_View;

-- 25. Trigger: Prevent insertion into Shop_Inventory with negative quantity
DELIMITER //
CREATE TRIGGER before_shop_inventory_insert
BEFORE INSERT ON Shop_Inventory
FOR EACH ROW
BEGIN
    IF NEW.qty < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Quantity cannot be negative';
    END IF;
END //
DELIMITER ;

-- 26. Trigger: Automatically update past_orders when a new bill is created and status is 'Paid'
DELIMITER //
CREATE TRIGGER after_bill_insert
AFTER INSERT ON Bills
FOR EACH ROW
BEGIN
    IF NEW.status = 'Paid' THEN
        UPDATE Customer SET past_orders = past_orders + 1 WHERE customer_id = NEW.customer_id;
    END IF;
END //
DELIMITER ;

-- 27. DQL: Use LEFT JOIN to show all customers and their bills if any
SELECT c.name, b.bill_id, b.total_amount
FROM Customer c
LEFT JOIN Bills b ON c.customer_id = b.customer_id;

-- 28. DDL: Add Column using ALTER
ALTER TABLE Logistics ADD contact_number VARCHAR(15);

-- 29. DML: Update newly added column
UPDATE Logistics SET contact_number = '9998887776' WHERE logistics_id = 1;

-- 30. DQL: Order by query to get top sellers from Shop Inventory
SELECT name, sp FROM Shop_Inventory ORDER BY sp DESC LIMIT 3;

