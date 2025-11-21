/* 
========================================================
 Day 4 – Query Optimization & Writing Efficient SQL
 Target DB : MySQL with sakila sample DB installed
========================================================
 GOAL FOR TODAY:
 - Learn to write cleaner and faster SQL
 - Make the database do less work
 - Understand when (and why) queries slow down
 - Use EXPLAIN to peek inside MySQL’s thinking
========================================================
*/

USE sakila;

/* -----------------------------------------------------
 1. DON’T SELECT *  (Ask only for what you need)
------------------------------------------------------ */

-- When you use SELECT *, MySQL returns every column—even if
-- you only needed two of them. More data to send, more data
-- to scan, and harder for the optimizer to drop unused columns.
SELECT * 
FROM customer
LIMIT 5;

-- Much better: be specific. It’s faster AND more readable.
SELECT 
    customer_id,
    first_name,
    last_name,
    email,
    active
FROM customer
LIMIT 5;

-- Another example using film:
-- Not ideal: pulling the entire row when only 4 fields matter.
SELECT * 
FROM film
WHERE rating = 'PG';

-- Cleaner + faster:
SELECT 
    film_id,
    title,
    rating,
    rental_rate
FROM film
WHERE rating = 'PG';


/* -----------------------------------------------------
 2. FILTER EARLY – WHERE vs HAVING
   WHERE filters *rows* first.
   HAVING filters *groups* after aggregation.
   Using WHERE first is almost always faster.
------------------------------------------------------ */

-- A common mistake: using HAVING for non-aggregated filters.
-- HAVING runs AFTER grouping, so MySQL still has to group
-- everything first before applying the condition.
SELECT 
    customer_id,
    SUM(amount) AS total_amount
FROM payment
GROUP BY customer_id
HAVING amount > 5;   -- Logically wrong, but many beginners do this

-- Correct approach:
-- WHERE removes unnecessary rows early,
-- and HAVING handles only aggregate-level conditions.
SELECT 
    customer_id,
    SUM(amount) AS total_amount
FROM payment
WHERE amount > 5               -- filter here first
GROUP BY customer_id
HAVING total_amount > 50;      -- filter on grouped results


/* -----------------------------------------------------
 3. PAGINATION: LIMIT / OFFSET vs Keyset Pagination
------------------------------------------------------ */

-- LIMIT is great for grabbing a small top slice:
SELECT 
    customer_id,
    first_name,
    last_name,
    email
FROM customer
ORDER BY customer_id
LIMIT 10;   -- first page

-- But OFFSET is expensive for large numbers.
-- LIMIT 1000, 10 = MySQL still scans the first 1000 rows
-- just to throw them away.
SELECT 
    customer_id,
    first_name,
    last_name
FROM customer
ORDER BY customer_id
LIMIT 1000, 10;

-- Better way: Keyset pagination using an indexed column.
-- “Give me the next 10 rows after customer_id 100”
SELECT 
    customer_id,
    first_name,
    last_name
FROM customer
WHERE customer_id > 100     -- uses the PK index efficiently
ORDER BY customer_id
LIMIT 10;


/* -----------------------------------------------------
 4. JOIN vs SUBQUERY
   JOINs are usually easier for the optimizer to work with.
------------------------------------------------------ */

-- Using a subquery works, but MySQL has fewer optimization options.
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

-- Using a JOIN is cleaner, faster, and more flexible:
SELECT DISTINCT
    c.customer_id,
    c.first_name,
    c.last_name
FROM customer AS c
JOIN payment AS p
    ON c.customer_id = p.customer_id
WHERE p.amount > 10;


/* -----------------------------------------------------
 5. CTEs (WITH) – your friend for readability
   They make complex queries feel like clean, readable steps.
------------------------------------------------------ */

-- Step 1: compute total spending per customer.
-- Step 2: join with customer table to show names.
WITH customer_totals AS (
    SELECT 
        customer_id,
        SUM(amount) AS total_spent
    FROM payment
    GROUP BY customer_id
)
SELECT 
    ct.customer_id,
    c.first_name,
    c.last_name,
    ct.total_spent
FROM customer_totals AS ct
JOIN customer AS c
    ON ct.customer_id = c.customer_id
WHERE ct.total_spent > 100
ORDER BY ct.total_spent DESC
LIMIT 10;

-- CTEs shine when your query has multiple logical steps
-- and you want to keep each step readable.


/* -----------------------------------------------------
 6. DON’T apply functions to indexed columns
   Doing so prevents MySQL from using the index.
------------------------------------------------------ */

-- Problem: wrapping rental_date in YEAR() forces MySQL
-- to scan every row and evaluate YEAR() for each one.
SELECT 
    rental_id,
    rental_date
FROM rental
WHERE YEAR(rental_date) = 2005;

-- Much more efficient:
-- Use a range that keeps rental_date “index-friendly”
SELECT 
    rental_id,
    rental_date
FROM rental
WHERE rental_date >= '2005-01-01'
  AND rental_date <  '2006-01-01';

-- Same rule applies when filtering on MONTH() and YEAR()
SELECT 
    payment_id,
    payment_date
FROM payment
WHERE MONTH(payment_date) = 5
  AND YEAR(payment_date) = 2005;

-- Better version:
SELECT 
    payment_id,
    payment_date
FROM payment
WHERE payment_date >= '2005-05-01'
  AND payment_date <  '2005-06-01';


/* -----------------------------------------------------
 7. EXPLAIN – see how MySQL plans to run your query
------------------------------------------------------ */

-- EXPLAIN won’t execute the query.
-- It simply tells you *how* MySQL intends to execute it:
--   - which indexes will be used
--   - which joins are performed
--   - whether MySQL will scan the entire table
EXPLAIN
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(p.amount) AS total_spent
FROM customer AS c
JOIN payment  AS p
    ON c.customer_id = p.customer_id
GROUP BY c.customer_id
HAVING total_spent > 50
ORDER BY total_spent DESC
LIMIT 10;

-- MySQL 8 also supports:
-- EXPLAIN ANALYZE
-- which actually runs the query and shows timings.


/* -----------------------------------------------------
 8. MAINTENANCE COMMANDS
   ANALYZE TABLE & OPTIMIZE TABLE
------------------------------------------------------ */

-- These commands help MySQL stay healthy and efficient.
-- Use with care on production databases (they can lock tables).

-- ANALYZE TABLE updates internal statistics used by the optimizer.
ANALYZE TABLE payment;
ANALYZE TABLE rental;

-- OPTIMIZE TABLE reclaims disk space and defragments storage.
OPTIMIZE TABLE payment;
OPTIMIZE TABLE rental;


/* -----------------------------------------------------
 SUMMARY – TAKE AWAY IDEAS FROM DAY 4
---------------------------------------------------------
 1. Avoid SELECT * — be explicit and intentional.
 2. Filter early (WHERE), and use HAVING only for aggregates.
 3. Offset pagination is expensive; keyset pagination is your friend.
 4. JOINs usually beat subqueries for performance.
 5. CTEs make complex logic easy to read and maintain.
 6. Don’t wrap indexed columns in functions — keep them sargable.
 7. Use EXPLAIN to understand what MySQL is actually doing.
 8. Run ANALYZE/OPTIMIZE occasionally to keep tables fast.
------------------------------------------------------ */

-- END OF DAY 4 SCRIPT
