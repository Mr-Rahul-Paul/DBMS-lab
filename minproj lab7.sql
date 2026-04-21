-- Lab 7: Roommate Expense Splitter (Simplified)

DROP TABLE IF EXISTS expenses;
DROP TABLE IF EXISTS roommates;

-- 1) Minimal Tables
CREATE TABLE roommates (
    id INT PRIMARY KEY,
    name VARCHAR(50)
);

CREATE TABLE expenses (
    id INT PRIMARY KEY,
    payer_id INT REFERENCES roommates(id),
    amount INT,
    description VARCHAR(100)
);

-- 2) Clean Data
-- Adjusted so each person has exactly one summarized entry for simplicity.
-- Total expenses = 4000. The fair share per person is exactly 1000.
INSERT INTO roommates (id, name) VALUES
(1, 'Aarav'),
(2, 'Diya'),
(3, 'Kabir'),
(4, 'Meera');

INSERT INTO expenses (id, payer_id, amount, description) VALUES
(1, 1, 1800, 'Rent and Groceries'), -- Aarav paid 1800 (Owed 800)
(2, 2, 800, 'Electricity'),         -- Diya paid 800 (Owes 200)
(3, 3, 1000, 'WiFi and Dinner'),    -- Kabir paid 1000 (Settled)
(4, 4, 400, 'Cleaning Supplies');   -- Meera paid 400 (Owes 600)


-- 3) Minimal Queries for the Lab

-- Query A: Show each expense with roommate name
SELECT r.name, e.description, e.amount
FROM roommates r
JOIN expenses e ON r.id = e.payer_id;

-- Query B: Show total spent by each roommate
SELECT r.name, SUM(e.amount) AS total_spent
FROM roommates r
JOIN expenses e ON r.id = e.payer_id
GROUP BY r.name;

-- Query C: Show total expense pool and fair share per person
SELECT 
    SUM(amount) AS total_pool, 
    SUM(amount) / (SELECT COUNT(*) FROM roommates) AS fair_share 
FROM expenses;

-- Query D: Show roommates who still need to pay
SELECT 
    r.name, 
    SUM(e.amount) AS amount_paid,
    (SELECT SUM(amount)/COUNT(*) FROM roommates) - SUM(e.amount) AS amount_to_pay
FROM roommates r
JOIN expenses e ON r.id = e.payer_id
GROUP BY r.name
HAVING SUM(e.amount) < (SELECT SUM(amount)/COUNT(*) FROM roommates);

-- Query E: Show expenses greater than 500
SELECT r.name, e.description, e.amount
FROM roommates r
JOIN expenses e ON r.id = e.payer_id
WHERE e.amount > 500;

-- Query F: Show expenses related to groceries
SELECT r.name, e.description, e.amount
FROM roommates r
JOIN expenses e ON r.id = e.payer_id
WHERE e.description LIKE '%Groceries%';

-- Query G: Count expense entries per roommate
SELECT r.name, COUNT(e.id) AS number_of_purchases
FROM roommates r
JOIN expenses e ON r.id = e.payer_id
GROUP BY r.name;

-- Query H: Show the highest single expense
SELECT r.name, e.description, e.amount
FROM roommates r
JOIN expenses e ON r.id = e.payer_id
ORDER BY e.amount DESC
LIMIT 1;

