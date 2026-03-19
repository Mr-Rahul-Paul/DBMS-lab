USE MedicalShopDB;

-- 41. Select all customers who pay by Cash
SELECT * FROM Customer WHERE payment_method = 'Cash';

-- 42. Count total number of medicines in shop inventory
SELECT COUNT(*) AS total_medicines FROM Shop_Inventory;

-- 43. Find the most expensive medicine in shop (MAX)
SELECT name, sp FROM Shop_Inventory ORDER BY sp DESC LIMIT 1;

-- 44. Find average cost price of all shop inventory items
SELECT ROUND(AVG(cp), 2) AS avg_cost_price FROM Shop_Inventory;

-- 45. Show customer name and their bill total using INNER JOIN
SELECT c.name, b.total_amount, b.status
FROM Customer c
JOIN Bills b ON c.customer_id = b.customer_id;

-- 46. Show all medicines along with their company name
SELECT m.medicine_id, m.type, m.content, c.name AS company_name
FROM Medicine m
JOIN Company c ON m.company_id = c.company_id;

-- 47. Find all shop items where selling price is greater than 20
SELECT name, sp FROM Shop_Inventory WHERE sp > 20;

-- 48. Count how many bills each customer has (GROUP BY)
SELECT c.name, COUNT(b.bill_id) AS total_bills
FROM Customer c
JOIN Bills b ON c.customer_id = b.customer_id
GROUP BY c.customer_id, c.name;

-- 49. Show all wholesellers sorted by name alphabetically
SELECT * FROM Wholeseller ORDER BY name ASC;

-- 50. Find total quantity of all items in shop inventory
SELECT SUM(qty) AS total_stock FROM Shop_Inventory;
