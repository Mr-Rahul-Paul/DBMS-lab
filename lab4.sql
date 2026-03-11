CREATE DATABASE IF NOT EXISTS LAB4;
USE LAB4;

CREATE TABLE Customer_table (
    customer_id       INT PRIMARY KEY,
    customer_name     VARCHAR(50),
    city              VARCHAR(30),
    balance           INT,
    registration_year INT,
    account_type      VARCHAR(20)
);

INSERT INTO Customer_table VALUES
(1, 'Rohan Shah',   'Ahmedabad',  5000,  2019, 'Savings'),
(2, 'Meera Patel',  'Surat',      12000, 2020, 'Current'),
(3, 'Aakash Mehta', 'Vadodara',   8000,  2021, 'Savings'),
(4, 'Nidhi Desai',  'Rajkot',     15000, 2022, 'Current'),
(5, 'Kunal Joshi',  'Bhavnagar',  3000,  2023, 'Savings');

CREATE TABLE Transaction_table (
    transaction_id     INT PRIMARY KEY,
    customer_id        INT,
    transaction_amount INT,
    transaction_type   VARCHAR(20)
);

INSERT INTO Transaction_table VALUES
(1, 1, 2000, 'Deposit'),
(2, 2, 5000, 'Withdrawal'),
(3, 3, 1500, 'Deposit'),
(4, 4, 3000, 'Withdrawal'),
(5, 5, 1000, 'Deposit');

ALTER TABLE Transaction_table
ADD CONSTRAINT fk_transaction_customer
FOREIGN KEY (customer_id) REFERENCES Customer_table(customer_id)
ON UPDATE CASCADE;

CREATE VIEW Customer_view AS
SELECT customer_id, customer_name, city
FROM Customer_table;

SELECT * FROM Customer_view;


DELIMITER //
CREATE TRIGGER trigger_before_insert
BEFORE INSERT ON Customer_table
FOR EACH ROW
BEGIN
    IF NEW.balance < 1000 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Balance must be at least 1000';
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trigger_before_insert_account
BEFORE INSERT ON Customer_table
FOR EACH ROW
BEGIN
    IF NEW.account_type IS NULL THEN
        SET NEW.account_type = 'Savings';
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trigger_before_delete
BEFORE DELETE ON Customer_table
FOR EACH ROW
BEGIN
    IF (SELECT COUNT(*) FROM Transaction_table WHERE customer_id = OLD.customer_id) > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete: customer has existing transactions';
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trigger_before_update
BEFORE UPDATE ON Customer_table
FOR EACH ROW
BEGIN
    IF NEW.balance < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Balance cannot be negative';
    END IF;
END //
DELIMITER ;


INSERT INTO Customer_table VALUES (6, 'Test User', 'Delhi', 500, 2024, 'Savings');

INSERT INTO Customer_table VALUES (7, 'Ravi Kumar', 'Pune', 5000, 2024, NULL);
SELECT * FROM Customer_table WHERE customer_id = 7;

DELETE FROM Customer_table WHERE customer_id = 1;

UPDATE Customer_table SET balance = -100 WHERE customer_id = 2;

SELECT * FROM Customer_table;
SELECT * FROM Transaction_table;
