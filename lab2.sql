-- 1. Create DEPARTMENT table first (so Employees can be assigned to one)
CREATE TABLE DEPARTMENT (
    Dname VARCHAR(25) NOT NULL,
    Dnumber INT NOT NULL PRIMARY KEY,
    Mgr_ssn CHAR(9),
    Mgr_start_date DATE
);

-- 2. Create EMPLOYEE table
CREATE TABLE EMPLOYEE (
    Fname VARCHAR(15) NOT NULL,
    Minit CHAR(1),
    Lname VARCHAR(15) NOT NULL,
    Ssn CHAR(9) NOT NULL PRIMARY KEY,
    Bdate DATE,
    Address VARCHAR(50),
    Sex CHAR(1),
    Salary DECIMAL(10, 2),
    Super_ssn CHAR(9),
    Dno INT NOT NULL,
    FOREIGN KEY (Dno) REFERENCES DEPARTMENT(Dnumber)
);

-- 3. Create PROJECT table
CREATE TABLE PROJECT (
    Pname VARCHAR(25) NOT NULL,
    Pnumber INT NOT NULL PRIMARY KEY,
    Plocation VARCHAR(25),
    Dnum INT NOT NULL,
    FOREIGN KEY (Dnum) REFERENCES DEPARTMENT(Dnumber)
);

-- 4. Create WORKS_ON table (Links Employees and Projects)
CREATE TABLE WORKS_ON (
    Essn CHAR(9) NOT NULL,
    Pno INT NOT NULL,
    Hours DECIMAL(3, 1),
    PRIMARY KEY (Essn, Pno),
    FOREIGN KEY (Essn) REFERENCES EMPLOYEE(Ssn),
    FOREIGN KEY (Pno) REFERENCES PROJECT(Pnumber)
);

 -- Random operation 
INSERT INTO DEPARTMENT VALUES ('Research', 5, '333445555', '1988-05-22');
INSERT INTO DEPARTMENT VALUES ('Administration', 4, '987654321', '1995-01-01');
INSERT INTO DEPARTMENT VALUES ('Headquarters', 1, '888665555', '1981-06-19');

INSERT INTO PROJECT VALUES ('ProductX', 10, 'Stafford', 4);
INSERT INTO PROJECT VALUES ('ProductY', 20, 'Houston', 5);

INSERT INTO EMPLOYEE VALUES ('John', 'B', 'Brown', '123456789', '1965-01-09', '731 Fondren, Houston, TX', 'M', 30000, NULL, 5);