/* PRACTICE
========================================================
 Day 2 – Data Query Language (DQL) + Filtering
 Target DB: MySQL with sakila sample DB installed
 File: session2_sakila_practice.sql
========================================================
 HOW TO USE:
 1. Install sakila DB.
 2. USE sakila;
 3. Run each section step-by-step for practice.
========================================================
*/

USE sakila;

/* -----------------------------------------------------
 1. BASIC DATA RETRIEVAL & SELECTION
------------------------------------------------------ */

-- 1.1 SELECT all columns from a table
SELECT * FROM actor;

-- 1.2 SELECT specific columns
SELECT first_name, last_name FROM actor;

-- 1.3 Using DISTINCT to get unique values
SELECT DISTINCT rating FROM film;

-- 1.4 LIMIT the number of rows returned
SELECT * FROM customer LIMIT 5;

-- Show 10 films only
SELECT film_id, title, rental_rate FROM film LIMIT 10;


/* -----------------------------------------------------
 2. FILTERING & OPERATORS (WHERE clause)
------------------------------------------------------ */

-- 2.1 SELECT with WHERE condition
SELECT * FROM customer
WHERE active = 1;

-- 2.2 Logical AND + OR
SELECT * FROM film
WHERE rental_rate > 3.0
  AND rating = 'PG';

SELECT * FROM film
WHERE rating = 'G'
   OR rating = 'PG';

-- 2.3 NOT operator
SELECT * FROM customer
WHERE NOT active = 1;

-- 2.4 LIKE pattern matching
-- starts with A
SELECT * FROM actor
WHERE first_name LIKE 'A%';

-- ends with N
SELECT * FROM actor
WHERE first_name LIKE '%N';

-- contains 'ER'
SELECT * FROM actor
WHERE first_name LIKE '%ER%';

-- single-character wildcard '_'
-- second letter = 'A'
SELECT * FROM actor
WHERE first_name LIKE '_A%';

-- 2.5 BETWEEN (range filtering)
SELECT * FROM film
WHERE rental_rate BETWEEN 1.0 AND 3.0;

-- 2.6 NULL value filtering
SELECT * FROM address
WHERE address2 IS NULL;

SELECT * FROM address
WHERE address2 IS NOT NULL;


/* -----------------------------------------------------
 3. AGGREGATION & GROUPING
------------------------------------------------------ */

-- 3.1 Aggregate functions
SELECT COUNT(*) AS total_films FROM film;

SELECT SUM(amount) AS total_payments
FROM payment;

-- 3.2 GROUP BY
SELECT customer_id, COUNT(payment_id) AS total_payments
FROM payment
GROUP BY customer_id;

-- 3.3 HAVING (filters AFTER grouping)
-- customers who paid more than 100 total
SELECT customer_id, SUM(amount) AS total_spent
FROM payment
GROUP BY customer_id
HAVING SUM(amount) > 100;

-- Another: count of rentals per customer > 20
SELECT customer_id, COUNT(rental_id) AS total_rentals
FROM rental
GROUP BY customer_id
HAVING total_rentals > 20;

-- 3.4 WHERE vs HAVING DEMO

-- WHERE filters BEFORE grouping:
SELECT * FROM payment
WHERE amount > 5;

-- HAVING filters AFTER aggregation:
SELECT customer_id, SUM(amount) AS total_amount
FROM payment
GROUP BY customer_id
HAVING SUM(amount) > 20;


/* -----------------------------------------------------
 4. SORTING & SQL EXECUTION ORDER
------------------------------------------------------ */

-- 4.1 ORDER BY (ASC = default)
SELECT film_id, title, rental_rate
FROM film
ORDER BY rental_rate ASC;

-- 4.2 ORDER BY DESC
SELECT film_id, title, rental_rate
FROM film
ORDER BY rental_rate DESC;

-- 4.3 ORDER BY multiple columns
-- Sort by rating, then sort alphabetically by title
SELECT film_id, title, rating
FROM film
ORDER BY rating ASC, title ASC;

-- 4.4 ORDER BY + LIMIT
SELECT title, rental_rate
FROM film
ORDER BY rental_rate DESC
LIMIT 5;


/* -----------------------------------------------------
 4.5 SQL ORDER OF EXECUTION (COMMENT ONLY)
---------------------------------------------------------
 The true SQL processing order is:

   1. FROM
   2. JOIN
   3. WHERE
   4. GROUP BY
   5. HAVING
   6. SELECT
   7. ORDER BY
   8. LIMIT

 This explains why:
 - WHERE cannot use SUM()/COUNT() (aggregation not done yet)
 - HAVING can use SUM()/COUNT()
 - ORDER BY can use SELECT aliases
--------------------------------------------------------- */


/* -----------------------------------------------------
 END OF DAY 2 SCRIPT

------------------------------------------------------ */
