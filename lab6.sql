USE MedicalShopDB;

-- 1. Select all customers who pay by Cash
SELECT * FROM Customer WHERE payment_method = 'Cash';

-- 2. Count total number of medicines in shop inventory
SELECT COUNT(*) AS total_medicines FROM Shop_Inventory;

-- 3. Find the most expensive medicine in shop (MAX)
SELECT name, sp FROM Shop_Inventory ORDER BY sp DESC LIMIT 1;

-- 4. Find average cost price of all shop inventory items
SELECT ROUND(AVG(cp), 2) AS avg_cost_price FROM Shop_Inventory;

-- 5. Show customer name and their bill total using INNER JOIN
SELECT c.name, b.total_amount, b.status
FROM Customer c
JOIN Bills b ON c.customer_id = b.customer_id;

-- 6. Show all medicines along with their company name
SELECT m.medicine_id, m.type, m.content, c.name AS company_name
FROM Medicine m
JOIN Company c ON m.company_id = c.company_id;

-- 7. Find all shop items where selling price is greater than 20
SELECT name, sp FROM Shop_Inventory WHERE sp > 20;

-- 8. Count how many bills each customer has (GROUP BY)
SELECT c.name, COUNT(b.bill_id) AS total_bills
FROM Customer c
JOIN Bills b ON c.customer_id = b.customer_id
GROUP BY c.customer_id, c.name;

-- 9. Show all wholesellers sorted by name alphabetically
SELECT * FROM Wholeseller ORDER BY name ASC;

-- 10. Find total quantity of all items in shop inventory
SELECT SUM(qty) AS total_stock FROM Shop_Inventory;

-- 11. Find all medicines that expire before 2026-01-01
SELECT name, expiry FROM Shop_Inventory WHERE expiry < '2026-01-01';

-- 12. List customers who have made more than 3 past orders
SELECT name, past_orders FROM Customer WHERE past_orders > 3;

-- 13. Show wholeseller name and the medicines they stock (JOIN)
SELECT w.name AS wholeseller, wi.name AS medicine, wi.qty
FROM Wholeseller w
JOIN Wholeseller_Inventory wi ON w.wholeseller_id = wi.wholeseller_id;

-- 14. Find medicines where selling price is less than cost price (loss items)
SELECT name, cp, sp FROM Shop_Inventory WHERE sp < cp;

-- 15. Show total amount billed per customer (GROUP BY + SUM)
SELECT c.name, SUM(b.total_amount) AS total_billed
FROM Customer c
JOIN Bills b ON c.customer_id = b.customer_id
GROUP BY c.customer_id, c.name;

-- 16. Find all pending bills
SELECT * FROM Bills WHERE status = 'Pending';

-- 17. Show medicines with quantity less than 10 (low stock alert)
SELECT name, qty FROM Shop_Inventory WHERE qty < 10;

-- 18. Count medicines per company
SELECT c.name AS company, COUNT(m.medicine_id) AS medicine_count
FROM Company c
LEFT JOIN Medicine m ON c.company_id = m.company_id
GROUP BY c.company_id, c.name;

-- 19. Find customer who has spent the most (MAX subquery)
SELECT c.name, b.total_amount
FROM Customer c
JOIN Bills b ON c.customer_id = b.customer_id
WHERE b.total_amount = (SELECT MAX(total_amount) FROM Bills);

-- 20. List all UPI payment customers with their bill status
SELECT c.name, c.payment_method, b.status
FROM Customer c
JOIN Bills b ON c.customer_id = b.customer_id
WHERE c.payment_method = 'UPI';

-- 21. Show difference between selling price and cost price (profit per item)
SELECT name, cp, sp, ROUND(sp - cp, 2) AS profit_per_unit
FROM Shop_Inventory;

-- 22. Count how many bills have each status (Paid / Pending)
SELECT status, COUNT(*) AS count FROM Bills GROUP BY status;

-- 23. Find medicines from a specific company (e.g., PharmaCorp)
SELECT m.medicine_id, m.type, m.content, c.name
FROM Medicine m
JOIN Company c ON m.company_id = c.company_id
WHERE c.name = 'PharmaCorp';

-- 24. Show top 3 most stocked items in shop inventory
SELECT name, qty FROM Shop_Inventory ORDER BY qty DESC LIMIT 3;

-- 25. Find all wholesellers located in a specific city (e.g., Mumbai)
SELECT * FROM Wholeseller WHERE location = 'Mumbai';

-- 26. Show customers who have never placed a bill (LEFT JOIN + NULL check)
SELECT c.name
FROM Customer c
LEFT JOIN Bills b ON c.customer_id = b.customer_id
WHERE b.bill_id IS NULL;

-- 27. Find total inventory value in shop (qty * cp)
SELECT ROUND(SUM(qty * cp), 2) AS total_inventory_value FROM Shop_Inventory;

-- 28. List logistics entries with driver name sorted alphabetically
SELECT driver_name, vehicle_no, company_name
FROM Logistics
ORDER BY driver_name ASC;

-- 29. Show medicines expiring within the next 90 days from today
SELECT name, expiry FROM Shop_Inventory
WHERE expiry BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 90 DAY);

-- 30. Find average selling price grouped by medicine type
SELECT m.type, ROUND(AVG(si.sp), 2) AS avg_sp
FROM Shop_Inventory si
JOIN Medicine m ON si.medicine_id = m.medicine_id
GROUP BY m.type;
