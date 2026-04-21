# SQL Lab Exam Cheat Sheet

## 1. DDL & Constraints
Managing databases, tables, data types, and keys (PK, FK, Unique, Check, Default).

```sql
CREATE DATABASE IF NOT EXISTS lab_exam;
USE lab_exam;

DROP TABLE IF EXISTS Employee;

-- Composite Primary Key example: PRIMARY KEY (EmpID, ProjectID)
CREATE TABLE Employee (
    EmpID INT AUTO_INCREMENT PRIMARY KEY,                  -- Surrogate PK
    Name VARCHAR(50) NOT NULL,                             -- Not Null
    Email VARCHAR(100) UNIQUE,                             -- Alternate Key
    Salary DECIMAL(10,2) DEFAULT 0.00 CHECK (Salary >= 0), -- Default & Check
    DeptID INT,
    FOREIGN KEY (DeptID) REFERENCES Department(DeptID)     -- Referential Integrity
        ON DELETE SET NULL 
        ON UPDATE CASCADE
);

-- Altering tables
ALTER TABLE Employee ADD COLUMN Phone CHAR(10);
ALTER TABLE Employee ADD UNIQUE (Phone);
```

## 2. DML (Data Manipulation)
Inserting, updating, and deleting records.

```sql
-- Insert Single & Multiple
INSERT INTO Employee (Name, Salary, DeptID) 
VALUES ('Alice', 60000, 1), ('Bob', 45000, 2);

-- Update
UPDATE Employee 
SET Salary = Salary * 1.1 
WHERE DeptID = 1;

-- Delete
DELETE FROM Employee WHERE EmpID = 5;
```

## 3. DQL (Data Querying)
Filtering, functions, grouping, conditional logic, and subqueries.

```sql
-- Filtering, Sorting, Aliasing & Null Handling
SELECT DISTINCT Name, COALESCE(Salary, 0) AS SafeSalary 
FROM Employee 
WHERE Salary BETWEEN 40000 AND 80000 AND Name LIKE 'A%'
ORDER BY Salary DESC 
LIMIT 5;

-- Conditional Logic (CASE)
SELECT Name, 
    CASE WHEN Salary > 50000 THEN 'Senior' ELSE 'Junior' END AS Rank 
FROM Employee;

-- Aggregates (COUNT, SUM, AVG, MAX, MIN, ROUND) & Grouping
SELECT DeptID, COUNT(*) as TotalEmp, ROUND(AVG(Salary), 2) AS AvgSal 
FROM Employee 
GROUP BY DeptID 
HAVING AvgSal > 50000;

-- Subqueries (IN, Scalar)
SELECT Name FROM Employee 
WHERE DeptID IN (SELECT DeptID FROM Department WHERE Location = 'NY');
```

## 4. Joins
Combining multiple tables.

```sql
-- Inner Join (Matching rows)
SELECT e.Name, d.DeptName 
FROM Employee e 
INNER JOIN Department d ON e.DeptID = d.DeptID;

-- Left Join (All from left table, matching from right)
SELECT d.DeptName, e.Name 
FROM Department d 
LEFT JOIN Employee e ON d.DeptID = e.DeptID;

-- Self Join (Joining table to itself using aliases)
SELECT e1.Name, e2.Name, e1.Salary
FROM Employee e1 
INNER JOIN Employee e2 ON e1.Salary = e2.Salary AND e1.EmpID != e2.EmpID;
```

## 5. Views
Virtual tables for security and simplicity.

```sql
CREATE OR REPLACE VIEW HighEarners AS 
SELECT Name, Salary, DeptID FROM Employee WHERE Salary > 80000;

-- Querying the view
SELECT * FROM HighEarners;
```

## 6. Triggers
Automated database actions (`OLD` = existing row, `NEW` = incoming row).

```sql
DELIMITER $$

-- BEFORE Trigger (Validation/Constraints)
CREATE TRIGGER trg_before_insert 
BEFORE INSERT ON Employee 
FOR EACH ROW 
BEGIN
    IF NEW.Salary < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Salary cannot be negative.';
    END IF;
END $$

-- AFTER Trigger (Auditing/Logging)
CREATE TRIGGER trg_after_update 
AFTER UPDATE ON Employee 
FOR EACH ROW 
BEGIN
    IF OLD.Salary != NEW.Salary THEN
        INSERT INTO AuditLog (EmpID, OldSal, NewSal) 
        VALUES (NEW.EmpID, OLD.Salary, NEW.Salary);
    END IF;
END $$

DELIMITER ;
```