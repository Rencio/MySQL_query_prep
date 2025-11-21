/*  PRACTICE
========================================================
 Day 1 – SQL Basics + DDL + DML/DQL + Constraints
 Target DB : MySQL (with sakila sample DB installed)
 File      : day1.sql
========================================================
 Reminders:
 - SQL has two sides: defining structure (DDL) and working 
   with data (DML/DQL).
 - Constraints protect data quality from the start.
 - Knowing the difference between DELETE, DROP, TRUNCATE
   helps avoid accidental data loss.
========================================================
*/


/* -----------------------------------------------------
 1. BASIC CONCEPTS (Reference Only)
--------------------------------------------------------
 - Database: structured storage for related information.
 - DBMS: software that manages the database system.
 - SQL: the language for defining and manipulating data.
 - Schema: blueprint of tables, columns, and relationships.

 SQL Categories:
 - DDL → CREATE, ALTER, DROP (structure)
 - DML → INSERT, UPDATE, DELETE (data change)
 - DQL → SELECT (data retrieval)
 - DCL → GRANT, REVOKE (permissions)
 - TCL → COMMIT, ROLLBACK (transactions)
------------------------------------------------------ */


/* -----------------------------------------------------
 2. DATA DEFINITION LANGUAGE (DDL)
   (Shaping the database structure)
------------------------------------------------------ */

-- Creating a separate DB makes sure practice doesn't touch sakila
CREATE DATABASE IF NOT EXISTS practice_session1_db;

-- Work inside our practice DB
USE practice_session1_db;

DROP TABLE employees;

-- Defining a simple table layout
CREATE TABLE employees (
    emp_id      INT AUTO_INCREMENT,
    first_name  VARCHAR(50),
    last_name   VARCHAR(50),
    email       VARCHAR(100),
    hire_date   DATE,
    salary      DECIMAL(10,2),
    PRIMARY KEY (emp_id)
);

-- Adding new columns helps tables evolve over time
ALTER TABLE employees
ADD COLUMN department VARCHAR(50);

-- Renaming columns keeps structure meaningful as requirements change
ALTER TABLE employees
RENAME COLUMN department TO dept_name;

-- TRUNCATE keeps the table but clears all rows quickly
TRUNCATE TABLE employees;

-- DROP removes the entire table definition (a permanent action)
/*
 DROP TABLE employees;     -- table disappears completely
 DELETE FROM employees;    -- table stays, rows are removed
*/


/* -----------------------------------------------------
 3. DATA MANIPULATION / QUERY (DML + DQL)
   (Adding, viewing, and removing data)
------------------------------------------------------ */

-- Inserting sample employee records
INSERT INTO employees (first_name, last_name, email, hire_date, salary, dept_name)
VALUES
('Alice',  'Smith',   'alice.smith@example.com',  '2023-01-10', 60000.00, 'Engineering'),
('Bob',    'Johnson', 'bob.johnson@example.com',  '2023-02-15', 55000.00, 'Finance'),
('Carol',  'Brown',   'carol.brown@example.com',  '2023-03-20', 65000.00, 'Engineering');

-- SELECT shows the current table contents
SELECT * FROM employees;

-- Focusing on key columns avoids unnecessary clutter
SELECT first_name, last_name, salary
FROM employees;

-- Basic filtering by department
SELECT *
FROM employees
WHERE dept_name = 'Engineering';

-- Removing rows with DELETE keeps the table intact
DELETE FROM employees
WHERE emp_id = 2;

-- Check remaining data
SELECT * FROM employees;


/* -----------------------------------------------------
 3.4 Quick reads from the sakila sample DB
   (Useful for practicing real-world tables)
------------------------------------------------------ */

USE sakila;

SELECT actor_id, first_name, last_name
FROM actor
LIMIT 10;

SELECT customer_id, first_name, last_name, email, active
FROM customer
LIMIT 10;

-- Return to our practice DB
USE practice_session1_db;


/* -----------------------------------------------------
 4. SQL CONSTRAINTS
   (Rules that protect data quality and relationships)
------------------------------------------------------ */

-- Cleaning old test tables if they exist
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;

-- NOT NULL and UNIQUE stop invalid or duplicate entries
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT,
    first_name  VARCHAR(50)    NOT NULL,
    last_name   VARCHAR(50)    NOT NULL,
    email       VARCHAR(100)   UNIQUE,
    created_at  DATETIME       DEFAULT NOW(),
    PRIMARY KEY (customer_id)
);

-- Sample data showing constraints in action
INSERT INTO customers (first_name, last_name, email)
VALUES
('John', 'Doe', 'john.doe@example.com'),
('Jane', 'Doe', 'jane.doe@example.com');

/*
 Examples of constraint violations:
 - Duplicate email would fail due to UNIQUE
 - Missing first_name would fail due to NOT NULL
*/


/* -----------------------------------------------------
 4.2 PRIMARY KEY
   (Every row needs a unique, reliable identifier)
------------------------------------------------------ */

CREATE TABLE orders (
    order_id     INT,
    customer_id  INT,
    order_date   DATE DEFAULT (CURRENT_DATE),
    amount       DECIMAL(10,2)
);

-- Adding a primary key later is common during refactoring
ALTER TABLE orders
ADD CONSTRAINT pk_orders
PRIMARY KEY (order_id);


/* -----------------------------------------------------
 4.3 FOREIGN KEY
   (Keeps relationships consistent across tables)
------------------------------------------------------ */

ALTER TABLE orders
ADD CONSTRAINT fk_orders_customers
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id)
ON DELETE RESTRICT      -- prevents deleting customers with orders
ON UPDATE CASCADE;      -- updates child rows when IDs change

-- Example order records
INSERT INTO orders (order_id, customer_id, order_date, amount)
VALUES
(1, 1, '2023-05-01', 100.00),
(2, 1, '2023-05-05', 150.00),
(3, 2, '2023-06-01', 200.00);

/*
 Attempting to DELETE a customer with linked orders
 will fail due to ON DELETE RESTRICT.
*/


/* -----------------------------------------------------
 4.4 CHECK constraint
   (Basic rule checks for column values)
------------------------------------------------------ */

DROP TABLE IF EXISTS users;

CREATE TABLE users (
    user_id   INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    age       INT,
    CONSTRAINT chk_age_18 CHECK (age >= 18)
);

-- Valid example
INSERT INTO users (full_name, age)
VALUES ('Adult User', 25);

/*
 Age < 18 would break the CHECK constraint:
 INSERT INTO users (...) VALUES ('Underage User', 16);
*/


/* -----------------------------------------------------
 4.5 DEFAULT constraint
   (Auto-fill helpful values when none are provided)
------------------------------------------------------ */

DROP TABLE IF EXISTS products;

CREATE TABLE products (
    product_id   INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    price        DECIMAL(10,2) NOT NULL,
    status       VARCHAR(20) DEFAULT 'ACTIVE',
    created_at   DATETIME DEFAULT NOW()
);

INSERT INTO products (product_name, price)
VALUES ('USB Cable', 9.99);       -- status auto-fills

INSERT INTO products (product_name, price, status)
VALUES ('HDMI Cable', 14.99, 'INACTIVE');

SELECT * FROM products;


/* -----------------------------------------------------
 END OF DAY 1 SCRIPT
 take away:
 - DDL shapes the structure; DML works with the data.
 - Constraints protect the database from invalid entries.
 - Primary & foreign keys build trusted relationships.
 - DELETE removes rows; TRUNCATE resets; DROP erases entirely.
------------------------------------------------------ */
