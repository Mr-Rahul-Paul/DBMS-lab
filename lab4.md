# Lab 4 — Triggers, Views & Foreign Keys

## Tables

### Customer_table
| Column            | Type        | Note        |
|-------------------|-------------|-------------|
| customer_id       | INT         | Primary Key |
| customer_name     | VARCHAR(50) |             |
| city              | VARCHAR(30) |             |
| balance           | INT         |             |
| registration_year | INT         |             |
| account_type      | VARCHAR(20) |             |

### Transaction_table
| Column             | Type        | Note                                      |
|--------------------|-------------|-------------------------------------------|
| transaction_id     | INT         | Primary Key                               |
| customer_id        | INT         | FK → Customer_table (ON UPDATE CASCADE)   |
| transaction_amount | INT         |                                           |
| transaction_type   | VARCHAR(20) |                                           |

## What was done

1. Created `Customer_table` with 5 sample records.
2. Created `Transaction_table` with 5 sample transactions.
3. Added a **foreign key** from `Transaction_table.customer_id` → `Customer_table.customer_id` with `ON UPDATE CASCADE`.
4. Created a **view** (`Customer_view`) showing `customer_id`, `customer_name`, `city`.
5. **BEFORE INSERT** trigger — rejects inserts with `balance < 1000`.
6. **AFTER INSERT** trigger — sets `account_type` to `'Savings'` when `NULL`.
7. **BEFORE DELETE** trigger — blocks deletion of customers who have transactions.
8. **BEFORE UPDATE** trigger — blocks updates that set `balance` to a negative value.
9. Test statements included at the end to verify each trigger.
