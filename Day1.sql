/*  PRACTICE
========================================================
 Day 1 – SQL Basics + DDL + DML/DQL + Constraints
 Target DB: MySQL (with sakila sample DB installed)
 File: day1.sql
========================================================
 HOW TO USE:
 1. Open MySQL client / Workbench.
 2. Run this file step by step or all at once (except DROPs if you want to keep data).
========================================================
*/


/* -----------------------------------------------------
 1. BASIC CONCEPTS (COMMENTS ONLY)
--------------------------------------------------------
 - Database: An organized collection of related data.
 - DBMS: Software that manages databases (MySQL, PostgreSQL, etc.).
 - SQL: Structured Query Language – used to create, read, update, delete data.
 - Schema: The structure of the database (tables, columns, relations, constraints).

 SQL Command Categories:
 - DDL: Data Definition Language  -> CREATE, ALTER, DROP, TRUNCATE
 - DML: Data Manipulation Language -> INSERT, UPDATE, DELETE
 - DQL: Data Query Language        -> SELECT (read data)
 - DCL: Data Control Language      -> GRANT, REVOKE (permissions)
 - TCL: Transaction Control Lang.  -> COMMIT, ROLLBACK, SAVEPOINT
------------------------------------------------------ */


/* -----------------------------------------------------
 2. DATA DEFINITION LANGUAGE (DDL)
    - Creating and managing structure
------------------------------------------------------ */

-- 2.1 CREATE DATABASE
-- NOTE: We use a separate practice DB to avoid breaking sakila.
CREATE DATABASE IF NOT EXISTS practice_session1_db;

-- Switch to our practice DB
USE practice_session1_db;

DROP TABLE employees;
-- 2.2 CREATE TABLE
-- Example: Simple employees table
CREATE TABLE employees (
    emp_id      INT AUTO_INCREMENT,
    first_name  VARCHAR(50),
    last_name   VARCHAR(50),
    email       VARCHAR(100),
    hire_date   DATE,
    salary      DECIMAL(10,2),
    PRIMARY KEY (emp_id)
);

-- show create table employees;
-- 2.3 ALTER TABLE – ADD COLUMN
-- Add a department column
ALTER TABLE employees
ADD COLUMN department VARCHAR(50);

-- 2.4 ALTER TABLE – RENAME COLUMN (MySQL 8+ syntax)
-- Rename 'department' -> 'dept_name'
ALTER TABLE employees
RENAME COLUMN department TO dept_name;

-- 2.5 DROP TABLE – removes the table structure and all data, permanently
-- (Uncomment if you want to test)
-- DROP TABLE employees;

-- 2.6 TRUNCATE TABLE – removes ALL rows but keeps table structure
-- Faster than DELETE without WHERE. Auto-increment is reset.
TRUNCATE TABLE employees;

-- Re-insert some fresh rows later in DML section
-- (employees table still exists, just empty)

/*
 2.7 DROP vs DELETE (Concept)
 - DROP TABLE employees; 
      -> removes the table *definition* and data. Table no longer exists.
 - DELETE FROM employees; 
      -> removes rows (data) from an existing table. Structure remains.
*/


/* -----------------------------------------------------
 3. DATA MANIPULATION / QUERY (DML + DQL)
------------------------------------------------------ */

-- 3.1 INSERT data into employees
INSERT INTO employees (first_name, last_name, email, hire_date, salary, dept_name)
VALUES
('Alice',  'Smith',   'alice.smith@example.com',  '2023-01-10', 60000.00, 'Engineering'),
('Bob',    'Johnson', 'bob.johnson@example.com',  '2023-02-15', 55000.00, 'Finance'),
('Carol',  'Brown',   'carol.brown@example.com',  '2023-03-20', 65000.00, 'Engineering');

-- 3.2 SELECT data (DQL)
-- 3.2.1 SELECT all columns
SELECT * FROM employees;

-- 3.2.2 SELECT specific columns only
SELECT first_name, last_name, salary
FROM employees;

-- 3.2.3 SELECT with a simple filter
SELECT *
FROM employees
WHERE dept_name = 'Engineering';

-- 3.3 DELETE data from a table
-- Delete ONE employee with a specific id (example)
DELETE FROM employees
WHERE emp_id = 2;

-- Check remaining rows
SELECT * FROM employees;


/* -----------------------------------------------------
 3.4 Simple DQL examples using the sakila database
     (read-only practice on sample data)
------------------------------------------------------ */

-- Switch to sakila to run these examples
USE sakila;

-- Example: select first 10 actors
SELECT actor_id, first_name, last_name
FROM actor
LIMIT 10;

-- select some customers
SELECT customer_id, first_name, last_name, email, active
FROM customer
LIMIT 10;

-- Switch back to our practice DB
USE practice_session1_db;


/* -----------------------------------------------------
 4. SQL CONSTRAINTS
   - Enforce rules / integrity on data
   - NOT NULL, UNIQUE, PRIMARY KEY, FOREIGN KEY,
     CHECK, DEFAULT
------------------------------------------------------ */

-- Clean up in case you re-run the script
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;

-- 4.1 NOT NULL and UNIQUE constraints
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT,
    first_name  VARCHAR(50)    NOT NULL,         -- cannot be NULL
    last_name   VARCHAR(50)    NOT NULL,
    email       VARCHAR(100)   UNIQUE,           -- must be unique (or NULL)
    created_at  DATETIME       DEFAULT NOW(),
    PRIMARY KEY (customer_id)
);

-- Insert some customers to demonstrate constraints
INSERT INTO customers (first_name, last_name, email)
VALUES
('John', 'Doe', 'john.doe@example.com'),
('Jane', 'Doe', 'jane.doe@example.com');

-- This will fail if uncommented because email must be UNIQUE
-- INSERT INTO customers (first_name, last_name, email)
-- VALUES ('Jake', 'Doe', 'john.doe@example.com');

-- This will fail because first_name is NOT NULL
-- INSERT INTO customers (first_name, last_name, email)
-- VALUES (NULL, 'NoName', 'noname@example.com');


/* -----------------------------------------------------
 4.2 PRIMARY KEY
   - Already used in customers table (customer_id)
   - Example: create table without PK and add it later
------------------------------------------------------ */

CREATE TABLE orders (
    order_id     INT,
    customer_id  INT,
    order_date   DATE DEFAULT (CURRENT_DATE),
    amount       DECIMAL(10,2)
);

-- Add PRIMARY KEY via ALTER TABLE
ALTER TABLE orders
ADD CONSTRAINT pk_orders
PRIMARY KEY (order_id);

-- Dropping the primary key example:
-- ALTER TABLE orders DROP PRIMARY KEY;


/* -----------------------------------------------------
 4.3 FOREIGN KEY + referential integrity
   - orders.customer_id references customers.customer_id
   - ON DELETE RESTRICT: cannot delete a customer if orders exist
   - ON UPDATE CASCADE: if customer_id changes, orders are updated
------------------------------------------------------ */

ALTER TABLE orders
ADD CONSTRAINT fk_orders_customers
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id)
ON DELETE RESTRICT
ON UPDATE CASCADE;

-- Insert some orders
INSERT INTO orders (order_id, customer_id, order_date, amount)
VALUES
(1, 1, '2023-05-01', 100.00),
(2, 1, '2023-05-05', 150.00),
(3, 2, '2023-06-01', 200.00);

-- Test ON DELETE RESTRICT:
-- This will fail because customer_id = 1 is referenced by orders
-- DELETE FROM customers WHERE customer_id = 1;

-- Test normal delete for customer with no orders:
-- First delete their orders, then delete the customer
-- DELETE FROM orders WHERE customer_id = 2;
-- DELETE FROM customers WHERE customer_id = 2;


/* -----------------------------------------------------
 4.4 CHECK constraint
   - Example: age must be >= 18
   - Note: CHECK is fully enforced in MySQL 8+
------------------------------------------------------ */

DROP TABLE IF EXISTS users;

CREATE TABLE users (
    user_id   INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    age       INT,
    CONSTRAINT chk_age_18 CHECK (age >= 18)
);

-- Valid insert
INSERT INTO users (full_name, age)
VALUES ('Adult User', 25);

-- This will fail due to CHECK (age >= 18)
-- INSERT INTO users (full_name, age)
-- VALUES ('Underage User', 16);


/* -----------------------------------------------------
 4.5 DEFAULT constraint
   - Provides default value when none is given
------------------------------------------------------ */

DROP TABLE IF EXISTS products;

CREATE TABLE products (
    product_id   INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    price        DECIMAL(10,2) NOT NULL,
    status       VARCHAR(20) DEFAULT 'ACTIVE',   -- default value
    created_at   DATETIME DEFAULT NOW()
);

-- Insert without specifying status or created_at
INSERT INTO products (product_name, price)
VALUES ('USB Cable', 9.99);

-- Insert specifying status explicitly
INSERT INTO products (product_name, price, status)
VALUES ('HDMI Cable', 14.99, 'INACTIVE');

-- Check the result
SELECT * FROM products;


/* -----------------------------------------------------
 END OF DAY 1 SCRIPT
------------------------------------------------------ */
