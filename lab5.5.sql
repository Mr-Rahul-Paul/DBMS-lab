USE MedicalShopDB;

-- ============================================================
-- LAB 5.5 — 10 Queries, One Topic Each
-- ============================================================

-- 1. DDL: CREATE TABLE with constraints
--    New table to store prescriptions linked to customers and medicines
CREATE TABLE IF NOT EXISTS Prescription (
    prescription_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id     INT NOT NULL,
    medicine_id     INT NOT NULL,
    prescribed_on   DATE NOT NULL,
    dosage          VARCHAR(100),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (medicine_id) REFERENCES Medicine(medicine_id) ON DELETE CASCADE
);

-- 2. DML: INSERT — populate Prescription with sample rows
INSERT INTO Prescription (customer_id, medicine_id, prescribed_on, dosage) VALUES
(1, 1, '2023-09-15', 'Twice a day after meals'),
(2, 2, '2023-10-01', 'Once at night'),
(3, 1, '2023-10-10', 'Thrice a day');

-- 3. DQL: INNER JOIN across three tables
--    List each prescription with customer name and medicine type
SELECT
    p.prescription_id,
    c.name          AS customer_name,
    m.type          AS medicine_type,
    p.prescribed_on,
    p.dosage
FROM Prescription p
JOIN Customer c ON p.customer_id = c.customer_id
JOIN Medicine m ON p.medicine_id = m.medicine_id;

-- 4. DQL: WHERE with BETWEEN and LIKE
--    Shop inventory items priced between 10 and 50 whose name starts with 'C'
SELECT name, cp, sp, expiry
FROM Shop_Inventory
WHERE sp BETWEEN 10 AND 50
  AND name LIKE 'C%';

-- 5. DQL: GROUP BY with aggregate functions
--    Total quantity and average selling price per medicine type from shop inventory
SELECT
    m.type                      AS medicine_type,
    SUM(si.qty)                 AS total_qty,
    ROUND(AVG(si.sp), 2)        AS avg_selling_price
FROM Shop_Inventory si
JOIN Medicine m ON si.medicine_id = m.medicine_id
GROUP BY m.type;

-- 6. DQL: HAVING — filter groups after aggregation
--    Show payment methods where the total number of past orders exceeds 4
SELECT
    payment_method,
    SUM(past_orders) AS total_orders
FROM Customer
GROUP BY payment_method
HAVING total_orders > 4;

-- 7. DQL: Subquery — find medicines stocked in the shop
--    that are also available in wholeseller inventory (correlated IN subquery)
SELECT name, qty, sp
FROM Shop_Inventory
WHERE medicine_id IN (
    SELECT medicine_id
    FROM Wholeseller_Inventory
    WHERE qty > 1000
);

-- 8. DML: UPDATE — apply a 10% price increase on all shop items whose margin < 50%
UPDATE Shop_Inventory
SET sp = ROUND(sp * 1.10, 2)
WHERE (sp - cp) / cp < 0.50;

-- 9. VIEW: CREATE a reusable view for profitability analysis
CREATE OR REPLACE VIEW Medicine_Profit_View AS
SELECT
    si.name,
    si.qty,
    si.cp,
    si.sp,
    ROUND((si.sp - si.cp), 2)           AS unit_profit,
    ROUND((si.sp - si.cp) * si.qty, 2)  AS total_profit
FROM Shop_Inventory si;

-- Query the view
SELECT * FROM Medicine_Profit_View ORDER BY total_profit DESC;

-- 10. TRIGGER: AFTER UPDATE — log when a bill's status changes to 'Paid'
--     First create a simple audit table to hold the log
CREATE TABLE IF NOT EXISTS Bill_Audit (
    audit_id    INT PRIMARY KEY AUTO_INCREMENT,
    bill_id     INT,
    customer_id INT,
    paid_on     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount      DECIMAL(10,2)
);

DELIMITER //
CREATE TRIGGER after_bill_status_update
AFTER UPDATE ON Bills
FOR EACH ROW
BEGIN
    IF NEW.status = 'Paid' AND OLD.status <> 'Paid' THEN
        INSERT INTO Bill_Audit (bill_id, customer_id, amount)
        VALUES (NEW.bill_id, NEW.customer_id, NEW.total_amount);
    END IF;
END //
DELIMITER ;

-- Verify trigger by updating a pending bill to Paid, then checking the audit table
UPDATE Bills SET status = 'Paid' WHERE bill_id = 2;
SELECT * FROM Bill_Audit;
