use sakila;

-- 1. Identify if there are duplicates in Customer table. Don't use customer id to check the duplicates
SELECT 
    first_name,
    last_name,
    email,
    COUNT(*) AS duplicate_count
FROM sakila.customer
GROUP BY first_name, last_name, email
HAVING COUNT(*) > 1;

-- with address

SELECT 
    first_name,
    last_name,
    email,
    address_id,
    COUNT(*) AS duplicate_count
FROM sakila.customer
GROUP BY first_name, last_name, email, address_id
HAVING COUNT(*) > 1;


SELECT 
    first_name,
    last_name,
    email,
    COUNT(*) AS duplicate_count
FROM sakila.customer
GROUP BY first_name, last_name, email
HAVING COUNT(*) > 1;
 
 
-- with address
SELECT 
    first_name,
    last_name,
    email,
    address_id,
    COUNT(*) AS duplicate_count
FROM sakila.customer
GROUP BY first_name, last_name, email, address_id
HAVING COUNT(*) > 1;


-- 2. Number of times letter 'a' is repeated in film descriptions
SELECT 
    SUM(
        LENGTH(LOWER(description)) 
      - LENGTH(REPLACE(LOWER(description), 'a', ''))
    ) AS total_a_count
FROM sakila.film;

SELECT 
    SUM(
        LENGTH(LOWER(description)) 
        - LENGTH(REPLACE(LOWER(description), 'a', ''))
    ) AS total_a_count
FROM sakila.film;



-- 3. Number of times each vowel is repeated in film descriptions 
SELECT
    SUM(LENGTH(LOWER(description)) - LENGTH(REPLACE(LOWER(description),'a',''))) AS count_a,
    SUM(LENGTH(LOWER(description)) - LENGTH(REPLACE(LOWER(description),'e',''))) AS count_e,
    SUM(LENGTH(LOWER(description)) - LENGTH(REPLACE(LOWER(description),'i',''))) AS count_i,
    SUM(LENGTH(LOWER(description)) - LENGTH(REPLACE(LOWER(description),'o',''))) AS count_o,
    SUM(LENGTH(LOWER(description)) - LENGTH(REPLACE(LOWER(description),'u',''))) AS count_u
FROM sakila.film;


-- 4. Display the payments made by each customer
--         1. Month wise
USE sakila;

SHOW TABLES LIKE 'payment';

DESCRIBE payment;


SELECT payment_id, customer_id, amount, payment_date
FROM payment
LIMIT 5;

SELECT 
    customer_id,
    DATE_FORMAT(payment_date, '%Y-%m') AS year_month,
    amount
FROM sakila.payment
LIMIT 5;

SELECT DATE_FORMAT(NOW(), '%Y-%m');


SELECT 
    customer_id,
    DATE_FORMAT(payment_date, '%Y-%m') AS year_month,
    SUM(amount) AS total_paid
FROM sakila.payment
GROUP BY customer_id, DATE_FORMAT(payment_date, '%Y-%m')
ORDER BY customer_id, DATE_FORMAT(payment_date, '%Y-%m');

SELECT 
    customer_id,
    DATE_FORMAT(payment_date, '%Y-%m') AS ym,   -- renamed alias
    SUM(amount) AS total_paid
FROM sakila.payment
GROUP BY 
    customer_id,
    DATE_FORMAT(payment_date, '%Y-%m')          -- use expression, not alias
ORDER BY 
    customer_id,
    ym;                                         -- now alias is safe



SELECT 
    customer_id,
    DATE_FORMAT(payment_date, '%Y-%m') AS `year_month`,
    SUM(amount) AS total_paid
FROM sakila.payment
GROUP BY 
    customer_id,
    DATE_FORMAT(payment_date, '%Y-%m')
ORDER BY 
    customer_id,
    `year_month`;







--         2. Year wise
SELECT 
    customer_id,
    YEAR(payment_date) AS pay_year,
    SUM(amount) AS total_paid
FROM sakila.payment
GROUP BY customer_id, YEAR(payment_date)
ORDER BY customer_id, pay_year;


--         3. Week wise

SELECT 
    customer_id,
    YEARWEEK(payment_date, 1) AS year_week,   -- ISO-style week
    SUM(amount) AS total_paid
FROM sakila.payment
GROUP BY customer_id, YEARWEEK(payment_date, 1)
ORDER BY customer_id, year_week;




-- 5. Check if any given year is a leap year or not. You need not consider any table from sakila database. Write within the select query with hardcoded date
SELECT 
    '2024-01-01' AS given_date,
    CASE 
        WHEN DAYOFYEAR(CONCAT(YEAR('2024-01-01'), '-12-31')) = 366
             THEN 'Leap Year'
        ELSE 'Not a Leap Year'
    END AS leap_status;


-- 6. Display number of days remaining in the current year from today.
SELECT 
    DATEDIFF(
        STR_TO_DATE(CONCAT(YEAR(CURDATE()), '-12-31'), '%Y-%m-%d'),
        CURDATE()
    ) AS days_remaining_in_year;


-- 7. Display quarter number(Q1,Q2,Q3,Q4) for the payment dates from payment table. 
SELECT
    payment_id,
    customer_id,
    payment_date,
    CONCAT('Q', QUARTER(payment_date)) AS payment_quarter
FROM sakila.payment
ORDER BY payment_date;
-- If they want it grouped by customer + quarter:
SELECT
    customer_id,
    YEAR(payment_date) AS pay_year,
    CONCAT('Q', QUARTER(payment_date)) AS payment_quarter,
    SUM(amount) AS total_paid
FROM sakila.payment
GROUP BY customer_id, YEAR(payment_date), QUARTER(payment_date)
ORDER BY customer_id, pay_year, payment_quarter;

-- 8. Display the age in year, months, days based on your date of birth. 

SELECT
  CONCAT(
    TIMESTAMPDIFF(YEAR, '1995-07-25', CURDATE()), ' years, ',
    TIMESTAMPDIFF(MONTH, '1995-07-25', CURDATE()) % 12, ' months, ',
    DATEDIFF(
      CURDATE(),
      DATE_ADD(
        DATE_ADD(
          '1995-07-25',
          INTERVAL TIMESTAMPDIFF(YEAR, '1995-07-25', CURDATE()) YEAR
        ),
        INTERVAL (TIMESTAMPDIFF(MONTH, '1995-07-25', CURDATE()) % 12) MONTH
      )
    ),
    ' days'
  ) AS age;

--    For example: 21 years, 4 months, 12 days