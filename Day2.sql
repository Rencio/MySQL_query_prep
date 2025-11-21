/* PRACTICE
========================================================
 Day 2 – Data Query Language (DQL) + Filtering
 Target DB : MySQL with sakila sample DB installed
========================================================
 Reminders:
 - SELECT retrieves data; LIMIT keeps results manageable.
 - WHERE narrows down rows early, using conditions.
 - LIKE, BETWEEN, IN, NULL checks help shape filters.
 - GROUP BY organizes data into buckets; HAVING filters them.
 - ORDER BY sorts results in meaningful ways.
========================================================
*/

USE sakila;

/* -----------------------------------------------------
 1. BASIC DATA RETRIEVAL & SELECTION
   (Picking which columns and rows you want to see)
------------------------------------------------------ */

-- SELECT * shows everything, useful for exploration
SELECT * FROM actor;

-- Selecting specific columns keeps queries clean and focused
SELECT first_name, last_name FROM actor;

-- DISTINCT helps find unique values in a column
SELECT DISTINCT rating FROM film;

-- LIMIT controls how many rows are returned
SELECT * FROM customer LIMIT 5;

-- Quick preview of selected film details
SELECT film_id, title, rental_rate FROM film LIMIT 10;


/* -----------------------------------------------------
 2. FILTERING & OPERATORS (WHERE clause)
   (WHERE zeroes in on the rows that matter)
------------------------------------------------------ */

-- Simple equality check
SELECT * FROM customer
WHERE active = 1;

-- Combining conditions with AND / OR
SELECT * FROM film
WHERE rental_rate > 3.0
  AND rating = 'PG';

SELECT * FROM film
WHERE rating = 'G'
   OR rating = 'PG';

-- NOT helps exclude conditions
SELECT * FROM customer
WHERE NOT active = 1;

-- LIKE matches patterns (%, _)
-- Starts with A
SELECT * FROM actor
WHERE first_name LIKE 'A%';

-- Ends with N
SELECT * FROM actor
WHERE first_name LIKE '%N';

-- Contains “ER”
SELECT * FROM actor
WHERE first_name LIKE '%ER%';

-- _ matches a single character
SELECT * FROM actor
WHERE first_name LIKE '_A%';

-- BETWEEN checks numeric ranges
SELECT * FROM film
WHERE rental_rate BETWEEN 1.0 AND 3.0;

-- NULL and NOT NULL help with missing or optional data
SELECT * FROM address
WHERE address2 IS NULL;

SELECT * FROM address
WHERE address2 IS NOT NULL;


/* -----------------------------------------------------
 3. AGGREGATION & GROUPING
   (Summaries and grouped insights)
------------------------------------------------------ */

-- Aggregate helpers: COUNT, SUM, AVG, etc.
SELECT COUNT(*) AS total_films FROM film;

SELECT SUM(amount) AS total_payments
FROM payment;

-- GROUP BY organizes rows into categories
SELECT customer_id, COUNT(payment_id) AS total_payments
FROM payment
GROUP BY customer_id;

-- HAVING filters groups after aggregation
SELECT customer_id, SUM(amount) AS total_spent
FROM payment
GROUP BY customer_id
HAVING SUM(amount) > 100;

-- Rentals per customer, filtering by count
SELECT customer_id, COUNT(rental_id) AS total_rentals
FROM rental
GROUP BY customer_id
HAVING total_rentals > 20;

-- WHERE first → filters raw rows
SELECT * FROM payment
WHERE amount > 5;

-- HAVING later → filters grouped results
SELECT customer_id, SUM(amount) AS total_amount
FROM payment
GROUP BY customer_id
HAVING SUM(amount) > 20;


/* -----------------------------------------------------
 4. SORTING & SQL EXECUTION ORDER
   (ORDER BY shapes the final presentation of data)
------------------------------------------------------ */

-- ASC by default
SELECT film_id, title, rental_rate
FROM film
ORDER BY rental_rate ASC;

-- DESC reverses the order
SELECT film_id, title, rental_rate
FROM film
ORDER BY rental_rate DESC;

-- Sorting by multiple fields is common
SELECT film_id, title, rating
FROM film
ORDER BY rating ASC, title ASC;

-- ORDER BY often pairs with LIMIT for top-N results
SELECT title, rental_rate
FROM film
ORDER BY rental_rate DESC
LIMIT 5;


/* -----------------------------------------------------
 4.5 SQL ORDER OF EXECUTION (Reference Only)
---------------------------------------------------------
 SQL actually processes queries in this order:

   1. FROM
   2. JOIN
   3. WHERE
   4. GROUP BY
   5. HAVING
   6. SELECT
   7. ORDER BY
   8. LIMIT

 Reminders:
 - WHERE comes before GROUP BY → no aggregates allowed.
 - HAVING comes after GROUP BY → aggregates allowed.
 - ORDER BY can use SELECT aliases.
--------------------------------------------------------- */


/* -----------------------------------------------------
 END OF DAY 2 SCRIPT
 Take Away:
 - Filter first (WHERE), summarize later (GROUP BY/HAVING).
 - Use DISTINCT for unique values and LIMIT for control.
 - Sorting shapes the final answer, not the filtering.
------------------------------------------------------ */
