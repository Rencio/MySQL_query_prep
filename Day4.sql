/* 
========================================================
 Day 4 – Query Optimization & Efficient SQL
 Target DB : MySQL • Sakila Sample Database
========================================================
 Reminders:
 - Optimized queries reduce workload for the database.  
 - Filtering early and selecting only what you need  
   often makes the biggest difference.  
 - JOINs are usually more efficient than subqueries.  
 - Functions on indexed columns can disable indexes.  
========================================================
*/

USE sakila;

/* -----------------------------------------------------
 1. SELECT Only What You Need (avoid SELECT *)
------------------------------------------------------ */

-- SELECT * pulls every column — useful for exploration,
-- but heavier than necessary during real work.
SELECT * 
FROM customer
LIMIT 5;

-- Smaller queries are faster, clearer, and more index-friendly.
SELECT 
    customer_id,
    first_name,
    last_name,
    email,
    active
FROM customer
LIMIT 5;

-- Another example using film
SELECT * 
FROM film
WHERE rating = 'PG';

-- Cleaner + more efficient version
SELECT 
    film_id,
    title,
    rating,
    rental_rate
FROM film
WHERE rating = 'PG';


/* -----------------------------------------------------
 2. Filter Early – WHERE Before GROUP BY / HAVING
------------------------------------------------------ */

-- Misuse example: HAVING used as a row filter
SELECT 
    customer_id,
    SUM(amount) AS total_amount
FROM payment
GROUP BY customer_id
HAVING amount > 5;   
-- Conceptually wrong, but seen often in beginner code

-- Good practice: use WHERE for row-level filtering,
-- then use HAVING only for group-level decisions
SELECT 
    customer_id,
    SUM(amount) AS total_amount
FROM payment
WHERE amount > 5
GROUP BY customer_id
HAVING total_amount > 50;


/* -----------------------------------------------------
 3. Pagination – LIMIT/OFFSET vs Indexed Paging
------------------------------------------------------ */

-- LIMIT gives a quick page of results
SELECT 
    customer_id,
    first_name,
    last_name,
    email
FROM customer
ORDER BY customer_id
LIMIT 10;

-- Large OFFSET is expensive:
SELECT 
    customer_id,
    first_name,
    last_name
FROM customer
ORDER BY customer_id
LIMIT 1000, 10;

-- Keyset pagination avoids scanning skipped rows:
-- “start after a known ID”
SELECT 
    customer_id,
    first_name,
    last_name
FROM customer
WHERE customer_id > 100    -- uses the primary key index
ORDER BY customer_id
LIMIT 10;


/* -----------------------------------------------------
 4. JOIN vs Subqueries
------------------------------------------------------ */

-- Subquery version
SELECT 
    customer_id,
    first_name,
    last_name
FROM customer
WHERE customer_id IN (
    SELECT DISTINCT customer_id
    FROM payment
    WHERE amount > 10
);

-- JOIN version tends to be clearer and faster
SELECT DISTINCT
    c.customer_id,
    c.first_name,
    c.last_name
FROM customer AS c
JOIN payment AS p
    ON c.customer_id = p.customer_id
WHERE p.amount > 10;


/* -----------------------------------------------------
 5. Avoid Functions on Indexed Columns
------------------------------------------------------ */


SELECT 
    rental_id,
    rental_date
FROM rental
WHERE YEAR(rental_date) = 2005;

-- Index-friendly range filter
SELECT 
    rental_id,
    rental_date
FROM rental
WHERE rental_date >= '2005-01-01'
  AND rental_date <  '2006-01-01';

-- Same rule applies with MONTH() + YEAR()
SELECT 
    payment_id,
    payment_date
FROM payment
WHERE MONTH(payment_date) = 5
  AND YEAR(payment_date) = 2005;

-- Range query prevents full scans
SELECT 
    payment_id,
    payment_date
FROM payment
WHERE payment_date >= '2005-05-01'
  AND payment_date <  '2005-06-01';


/* -----------------------------------------------------
 6. Use EXPLAIN to See How MySQL Executes Your Query
------------------------------------------------------ */

-- EXPLAIN shows:
-- - whether indexes are used
-- - join strategy
-- - table scan vs index lookup
-- - estimated rows processed
EXPLAIN
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(p.amount) AS total_spent
FROM customer AS c
JOIN payment AS p
    ON c.customer_id = p.customer_id
GROUP BY c.customer_id
HAVING total_spent > 50
ORDER BY total_spent DESC
LIMIT 10;


/* -----------------------------------------------------
 7. Maintenance Tools: ANALYZE & OPTIMIZE
------------------------------------------------------ */

-- ANALYZE updates index statistics,
-- choose better execution plans
ANALYZE TABLE payment;
ANALYZE TABLE rental;

-- OPTIMIZE reclaims space and reorganizes storage
-- Useful after heavy DELETE/UPDATE operations
OPTIMIZE TABLE payment;
OPTIMIZE TABLE rental;


/* -----------------------------------------------------
 END OF DAY 4 SCRIPT
 
------------------------------------------------------ */
