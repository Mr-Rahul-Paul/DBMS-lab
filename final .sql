CREATE DATABASE IF NOT EXISTS MedicalShopDB_Lab7;
USE MedicalShopDB_Lab7;

-- 1. DDL: Customer
CREATE TABLE Customer (
	customer_id INT PRIMARY KEY AUTO_INCREMENT,
	name VARCHAR(100) NOT NULL,
	address VARCHAR(255),
	phone VARCHAR(15),
	payment_method VARCHAR(50),
	total_orders INT DEFAULT 0
);

-- 2. DDL: Medicine
CREATE TABLE Medicine (
	medicine_id INT PRIMARY KEY AUTO_INCREMENT,
	type VARCHAR(50),
	expiry DATE,
	content TEXT,
	price DECIMAL(10,2) CHECK (price >= 0)
);

-- 3. DDL: Shops
CREATE TABLE Shops (
	shop_id INT PRIMARY KEY AUTO_INCREMENT,
	owner VARCHAR(100) NOT NULL
);

-- 4. DDL: Wholesaler
CREATE TABLE Wholesaler (
	wholesaler_id INT PRIMARY KEY AUTO_INCREMENT,
	name VARCHAR(100) NOT NULL,
	location VARCHAR(100),
	phone VARCHAR(15)
);

-- 5. DDL: Wholesaler Inventory (stores)
CREATE TABLE Wholesaler_Inventory (
	inventory_id INT PRIMARY KEY AUTO_INCREMENT,
	wholesaler_id INT NOT NULL,
	name VARCHAR(100),
	quantity INT CHECK (quantity >= 0),
	cp DECIMAL(10,2) CHECK (cp >= 0),
	sp DECIMAL(10,2) CHECK (sp >= 0),
	FOREIGN KEY (wholesaler_id) REFERENCES Wholesaler(wholesaler_id) ON DELETE CASCADE
);

-- 6. DDL: Shop Inventory (stores)
CREATE TABLE Shop_Inventory (
	inventory_id INT PRIMARY KEY AUTO_INCREMENT,
	shop_id INT NOT NULL,
	medicine_id INT NOT NULL,
	name VARCHAR(100),
	quantity INT CHECK (quantity >= 0),
	cp DECIMAL(10,2) CHECK (cp >= 0),
	sp DECIMAL(10,2) CHECK (sp >= 0),
	FOREIGN KEY (shop_id) REFERENCES Shops(shop_id) ON DELETE CASCADE,
	FOREIGN KEY (medicine_id) REFERENCES Medicine(medicine_id) ON DELETE CASCADE
);

-- 7. DDL: Orders (customer places order, shop verifies)
CREATE TABLE Orders (
	order_id INT PRIMARY KEY AUTO_INCREMENT,
	customer_id INT NOT NULL,
	medicine_id INT NOT NULL,
	shop_id INT NOT NULL,
	amount DECIMAL(10,2) CHECK (amount >= 0),
	order_date DATE,
	status VARCHAR(20) DEFAULT 'Placed',
	FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE CASCADE,
	FOREIGN KEY (medicine_id) REFERENCES Medicine(medicine_id) ON DELETE RESTRICT,
	FOREIGN KEY (shop_id) REFERENCES Shops(shop_id) ON DELETE CASCADE
);

-- 8. DDL: Invoice (customer gets invoice)
CREATE TABLE Invoice (
	invoice_id INT PRIMARY KEY AUTO_INCREMENT,
	order_id INT NOT NULL UNIQUE,
	customer_id INT NOT NULL,
	amount DECIMAL(10,2) CHECK (amount >= 0),
	issued_on DATE,
	FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
	FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE CASCADE
);

-- 9. DDL: Transport
CREATE TABLE Transport (
	tracking_id INT PRIMARY KEY AUTO_INCREMENT,
	order_id INT NOT NULL UNIQUE,
	customer_id INT NOT NULL,
	shop_id INT NOT NULL,
	shipped_on DATE,
	delivery_status VARCHAR(20) DEFAULT 'In Transit',
	FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
	FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE CASCADE,
	FOREIGN KEY (shop_id) REFERENCES Shops(shop_id) ON DELETE CASCADE
);

-- 10. DDL: Shops buys from Wholesaler (relationship table)
CREATE TABLE Shop_Wholesaler_Purchase (
	purchase_id INT PRIMARY KEY AUTO_INCREMENT,
	shop_id INT NOT NULL,
	wholesaler_id INT NOT NULL,
	inventory_id INT,
	quantity INT CHECK (quantity > 0),
	cost DECIMAL(10,2) CHECK (cost >= 0),
	purchase_date DATE,
	FOREIGN KEY (shop_id) REFERENCES Shops(shop_id) ON DELETE CASCADE,
	FOREIGN KEY (wholesaler_id) REFERENCES Wholesaler(wholesaler_id) ON DELETE CASCADE,
	FOREIGN KEY (inventory_id) REFERENCES Wholesaler_Inventory(inventory_id) ON DELETE SET NULL
);

-- 11. Trigger: prevent negative quantity in shop inventory
DELIMITER //
CREATE TRIGGER before_shop_inventory_insert
BEFORE INSERT ON Shop_Inventory
FOR EACH ROW
BEGIN
	IF NEW.quantity < 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Quantity cannot be negative';
	END IF;
END //
DELIMITER ;

-- 12. Trigger: update customer total_orders when invoice is created
DELIMITER //
CREATE TRIGGER after_invoice_insert
AFTER INSERT ON Invoice
FOR EACH ROW
BEGIN
	UPDATE Customer
	SET total_orders = total_orders + 1
	WHERE customer_id = NEW.customer_id;
END //
DELIMITER ;

-- 13. DML: Insert Customers
INSERT INTO Customer (name, address, phone, payment_method) VALUES
('Ravi Kumar', 'Mumbai', '9876543210', 'Credit Card'),
('Meera Patel', 'Delhi', '8765432109', 'Cash'),
('Aman Singh', 'Bangalore', '7654321098', 'UPI');

-- 14. DML: Insert Medicines
INSERT INTO Medicine (type, expiry, content, price) VALUES
('Tablet', '2026-12-31', 'Paracetamol 500mg', 15.00),
('Syrup', '2027-06-30', 'Cough Suppressant', 60.00),
('Capsule', '2026-11-15', 'Amoxicillin 250mg', 10.00),
('Ointment', '2027-03-10', 'Skin Relief Gel', 95.00);

-- 15. DML: Insert Shops
INSERT INTO Shops (owner) VALUES
('Arjun Pharma Store'),
('Health First Medical');

-- 16. DML: Insert Wholesaler
INSERT INTO Wholesaler (name, location, phone) VALUES
('ABC Wholesales', 'Gujarat', '5566778899'),
('MediBulk Traders', 'Mumbai', '9988771122');

-- 17. DML: Insert Wholesaler Inventory
INSERT INTO Wholesaler_Inventory (wholesaler_id, name, quantity, cp, sp) VALUES
(1, 'Paracetamol Bulk', 8000, 8.00, 10.00),
(1, 'Cough Syrup Bulk', 3000, 35.00, 45.00),
(2, 'Amoxicillin Bulk', 5000, 4.50, 6.00),
(2, 'Skin Relief Gel Bulk', 1500, 70.00, 82.00);

-- 18. DML: Insert Shop Inventory
INSERT INTO Shop_Inventory (shop_id, medicine_id, name, quantity, cp, sp) VALUES
(1, 1, 'Paracetamol', 120, 10.00, 15.00),
(1, 2, 'Cough Syrup', 50, 40.00, 60.00),
(2, 3, 'Amoxil', 200, 5.00, 10.00),
(2, 4, 'Skin Relief Gel', 35, 78.00, 95.00);

-- 19. DML: Insert Orders
INSERT INTO Orders (customer_id, medicine_id, shop_id, amount, order_date, status) VALUES
(1, 1, 1, 150.00, '2026-03-01', 'Placed'),
(2, 2, 1, 120.00, '2026-03-02', 'Placed'),
(3, 3, 2, 100.00, '2026-03-03', 'Placed');

-- 20. DML: Insert Invoice (trigger updates total_orders)
INSERT INTO Invoice (order_id, customer_id, amount, issued_on) VALUES
(1, 1, 150.00, '2026-03-01'),
(2, 2, 120.00, '2026-03-02'),
(3, 3, 100.00, '2026-03-03');

-- 21. DML: Insert Transport
INSERT INTO Transport (order_id, customer_id, shop_id, shipped_on, delivery_status) VALUES
(1, 1, 1, '2026-03-01', 'Delivered'),
(2, 2, 1, '2026-03-02', 'In Transit'),
(3, 3, 2, '2026-03-03', 'In Transit');

-- 22. DML: Insert purchases (shops buys from wholesaler)
INSERT INTO Shop_Wholesaler_Purchase (shop_id, wholesaler_id, inventory_id, quantity, cost, purchase_date) VALUES
(1, 1, 1, 1000, 8000.00, '2026-02-20'),
(1, 1, 2, 400, 14000.00, '2026-02-22'),
(2, 2, 3, 600, 2700.00, '2026-02-25');

-- 23. DQL: Customers who pay by Cash
SELECT * FROM Customer WHERE payment_method = 'Cash';

-- 24. DQL: Count total medicines in shop inventory
SELECT COUNT(*) AS total_medicines FROM Shop_Inventory;

-- 25. DQL: Most expensive medicine
SELECT medicine_id, type, price FROM Medicine ORDER BY price DESC LIMIT 1;

-- 26. DQL: Average cost price in shop inventory
SELECT ROUND(AVG(cp), 2) AS avg_cost_price FROM Shop_Inventory;

-- 27. DQL: Customer + Invoice details (INNER JOIN)
SELECT c.name, i.invoice_id, i.amount, i.issued_on
FROM Customer c
JOIN Invoice i ON c.customer_id = i.customer_id;

-- 28. DQL: Orders with medicine and shop details
SELECT o.order_id, c.name AS customer_name, m.type AS medicine_type, s.owner AS shop_owner, o.amount, o.status
FROM Orders o
JOIN Customer c ON o.customer_id = c.customer_id
JOIN Medicine m ON o.medicine_id = m.medicine_id
JOIN Shops s ON o.shop_id = s.shop_id;

-- 29. DQL: Count invoices per customer (GROUP BY)
SELECT c.name, COUNT(i.invoice_id) AS total_invoices
FROM Customer c
LEFT JOIN Invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.name;

-- 30. DQL: Total billed amount per customer (GROUP BY + SUM)
SELECT c.name, SUM(i.amount) AS total_billed
FROM Customer c
JOIN Invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.name;

-- 31. DQL: Customers with total_orders > 0 (HAVING)
SELECT c.name, c.total_orders
FROM Customer c
GROUP BY c.customer_id, c.name, c.total_orders
HAVING c.total_orders > 0;

-- 32. DQL: Shop inventory items with SP between 10 and 80 and name starts with 'C'
SELECT name, cp, sp
FROM Shop_Inventory
WHERE sp BETWEEN 10 AND 80
  AND name LIKE 'C%';

-- 33. DQL: Medicines sold in shops that bought stock from wholesaler 1 (subquery)
SELECT si.name, si.quantity
FROM Shop_Inventory si
WHERE si.shop_id IN (
	SELECT shop_id
	FROM Shop_Wholesaler_Purchase
	WHERE wholesaler_id = 1
);

-- 34. DQL: Show all shops and transport details if any (LEFT JOIN)
SELECT s.owner, t.tracking_id, t.delivery_status
FROM Shops s
LEFT JOIN Transport t ON s.shop_id = t.shop_id;

-- 35. DQL: Total quantity per shop
SELECT s.owner, SUM(si.quantity) AS total_stock
FROM Shops s
JOIN Shop_Inventory si ON s.shop_id = si.shop_id
GROUP BY s.shop_id, s.owner;

-- 36. DQL: Top 3 most stocked shop items
SELECT name, quantity FROM Shop_Inventory ORDER BY quantity DESC LIMIT 3;

-- 37. DQL: Medicines expiring before 2027
SELECT medicine_id, type, expiry FROM Medicine WHERE expiry < '2027-01-01';

-- 38. DQL: Pending or in-transit deliveries
SELECT tracking_id, order_id, delivery_status
FROM Transport
WHERE delivery_status IN ('In Transit', 'Pending');

-- 39. DQL: Profit per inventory item
SELECT name, cp, sp, ROUND(sp - cp, 2) AS profit_per_unit
FROM Shop_Inventory;

-- 40. DML: Update order status
UPDATE Orders SET status = 'Verified' WHERE order_id = 2;

-- 41. DML: Increase SP by 5% for low-margin items
UPDATE Shop_Inventory
SET sp = ROUND(sp * 1.05, 2)
WHERE (sp - cp) / cp < 0.30;

-- 42. DDL: View for shop profit overview
CREATE OR REPLACE VIEW Shop_Profit_View AS
SELECT
	si.inventory_id,
	si.name,
	si.quantity,
	si.cp,
	si.sp,
	ROUND(si.sp - si.cp, 2) AS unit_profit,
	ROUND((si.sp - si.cp) * si.quantity, 2) AS total_profit
FROM Shop_Inventory si;

-- 43. DQL: Read from view
SELECT * FROM Shop_Profit_View ORDER BY total_profit DESC;

-- 44. DQL: Count transports by delivery status
SELECT delivery_status, COUNT(*) AS total_shipments
FROM Transport
GROUP BY delivery_status;

-- 45. DQL: Wholesaler with supplied inventory count
SELECT w.name AS wholesaler_name, COUNT(wi.inventory_id) AS items_supplied
FROM Wholesaler w
LEFT JOIN Wholesaler_Inventory wi ON w.wholesaler_id = wi.wholesaler_id
GROUP BY w.wholesaler_id, w.name;

-- 46. DQL: Customers and their latest invoice date
SELECT c.name, MAX(i.issued_on) AS latest_invoice_date
FROM Customer c
LEFT JOIN Invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.name;

-- 47. DML: Delete a transport entry (example)
DELETE FROM Transport WHERE tracking_id = 3;

-- 48. DQL: Final check of customers after invoice trigger updates
SELECT customer_id, name, total_orders FROM Customer ORDER BY customer_id;

-- 49. DQL: Orders that do not yet have an invoice
SELECT o.order_id, c.name AS customer_name, o.amount, o.status
FROM Orders o
JOIN Customer c ON o.customer_id = c.customer_id
LEFT JOIN Invoice i ON o.order_id = i.order_id
WHERE i.invoice_id IS NULL;

-- 50. DQL: Shop-wise total order revenue
SELECT s.owner AS shop_name, ROUND(SUM(o.amount), 2) AS total_revenue
FROM Shops s
JOIN Orders o ON s.shop_id = o.shop_id
GROUP BY s.shop_id, s.owner
ORDER BY total_revenue DESC;

-- 51. DQL: Customers whose total billed amount is above average billed amount
SELECT c.name, SUM(i.amount) AS billed_total
FROM Customer c
JOIN Invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.name
HAVING SUM(i.amount) > (
	SELECT AVG(amount) FROM Invoice
);

-- 52. DQL: Medicines priced above average medicine price
SELECT medicine_id, type, price
FROM Medicine
WHERE price > (
	SELECT AVG(price) FROM Medicine
)
ORDER BY price DESC;

-- 53. DQL: Shop inventory items with price rank (highest SP first)
SELECT
	name,
	sp,
	DENSE_RANK() OVER (ORDER BY sp DESC) AS price_rank
FROM Shop_Inventory;

-- 54. DQL: Running total of invoice amounts by issue date
SELECT
	invoice_id,
	issued_on,
	amount,
	SUM(amount) OVER (ORDER BY issued_on, invoice_id) AS running_total
FROM Invoice;

-- 55. DQL: Wholesaler purchase details with shop and wholesaler names
SELECT
	p.purchase_id,
	s.owner AS shop_name,
	w.name AS wholesaler_name,
	p.quantity,
	p.cost,
	p.purchase_date
FROM Shop_Wholesaler_Purchase p
JOIN Shops s ON p.shop_id = s.shop_id
JOIN Wholesaler w ON p.wholesaler_id = w.wholesaler_id
ORDER BY p.purchase_date;

-- 56. DQL: Medicines that are present in both wholesaler and shop inventory (EXISTS)
SELECT m.medicine_id, m.type
FROM Medicine m
WHERE EXISTS (
	SELECT 1
	FROM Shop_Inventory si
	WHERE si.medicine_id = m.medicine_id
)
AND EXISTS (
	SELECT 1
	FROM Wholesaler_Inventory wi
	WHERE wi.name LIKE CONCAT('%', m.type, '%')
	   OR wi.name LIKE CONCAT('%', m.content, '%')
);

-- 57. DQL: Delivery status summary with percentage
SELECT
	delivery_status,
	COUNT(*) AS status_count,
	ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM Transport), 2) AS status_percent
FROM Transport
GROUP BY delivery_status;

-- 58. DQL: Customer-wise order count and invoice count in one query
SELECT
	c.customer_id,
	c.name,
	COUNT(DISTINCT o.order_id) AS order_count,
	COUNT(DISTINCT i.invoice_id) AS invoice_count
FROM Customer c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
LEFT JOIN Invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.name;

-- 59. DQL: Detect invoice/order amount mismatches
SELECT
	i.invoice_id,
	i.order_id,
	i.amount AS invoice_amount,
	o.amount AS order_amount
FROM Invoice i
JOIN Orders o ON i.order_id = o.order_id
WHERE i.amount <> o.amount;

-- 60. DQL: Low stock alert with category label using CASE
SELECT
	inventory_id,
	name,
	quantity,
	CASE
		WHEN quantity < 20 THEN 'Critical'
		WHEN quantity BETWEEN 20 AND 50 THEN 'Low'
		ELSE 'Normal'
	END AS stock_level
FROM Shop_Inventory
ORDER BY quantity ASC;
