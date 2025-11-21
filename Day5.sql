/* 
========================================================
 Day 5 – SQL Joins & Table Relationships
 Target DB : MySQL with sakila sample DB installed
========================================================
 CONTENT:
 1. Table Relationships (1:1, 1:Many, Many:Many)
 2. INNER / LEFT / RIGHT JOIN
 3. FULL OUTER JOIN (simulated via UNION in MySQL)
 4. CROSS JOIN
 5. SELF JOIN
========================================================
*/

USE sakila;

/* -----------------------------------------------------
 0. SETUP – helper tables for 1:1 and friendships
------------------------------------------------------ */

-- Clean up if re-running
DROP TABLE IF EXISTS customer_profile;
DROP TABLE IF EXISTS customer_friendship;

-- 0.1 One-to-One example: customer <-> customer_profile
CREATE TABLE customer_profile (
    customer_id   SMALLINT UNSIGNED PRIMARY KEY,
    phone_number  VARCHAR(20),
    preferences   VARCHAR(255),
    CONSTRAINT fk_profile_customer
        FOREIGN KEY (customer_id)
        REFERENCES customer(customer_id)
        ON DELETE CASCADE
);

-- Insert a few sample profiles
INSERT INTO customer_profile (customer_id, phone_number, preferences)
VALUES
(1, '555-1111', 'likes comedy'),
(2, '555-2222', 'prefers action'),
(3, '555-3333', 'family-friendly only');

-- 0.2 Many-to-Many + self join example: friendships between customers
CREATE TABLE customer_friendship (
    user_id    SMALLINT UNSIGNED,
    friend_id  SMALLINT UNSIGNED,
    PRIMARY KEY (user_id, friend_id),
    CONSTRAINT fk_friend_user
        FOREIGN KEY (user_id) REFERENCES customer(customer_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_friend_friend
        FOREIGN KEY (friend_id) REFERENCES customer(customer_id)
        ON DELETE CASCADE
);

-- Insert some example friend relations (undirected stored as two rows)
INSERT INTO customer_friendship (user_id, friend_id)
VALUES
(1, 2),
(2, 1),
(1, 3),
(3, 1),
(2, 3),
(3, 2);


/* =====================================================
 1. UNDERSTANDING TABLE RELATIONSHIPS
===================================================== */

-- 1.1 One-to-One (1:1)
--   customer (1) <-> (0 or 1) customer_profile
--   Each customer has at most one profile row.

SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    p.phone_number,
    p.preferences
FROM customer AS c
LEFT JOIN customer_profile AS p
    ON c.customer_id = p.customer_id
WHERE c.customer_id <= 5;

-- 1.2 One-to-Many (1:Many)
--   One customer -> many payments
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    p.payment_id,
    p.amount,
    p.payment_date
FROM customer AS c
JOIN payment AS p
    ON c.customer_id = p.customer_id
WHERE c.customer_id = 1;

-- 1.3 Many-to-One (Many:1)
--   Same relationship viewed from payment's side:
--   Many payments -> one customer
SELECT 
    p.payment_id,
    p.amount,
    p.payment_date,
    c.customer_id,
    c.first_name,
    c.last_name
FROM payment AS p
JOIN customer AS c
    ON p.customer_id = c.customer_id
WHERE p.customer_id = 1
LIMIT 10;

-- 1.4 Many-to-Many (Many:Many)
--   film <-> actor through film_actor
SELECT 
    f.film_id,
    f.title,
    a.actor_id,
    a.first_name,
    a.last_name
FROM film AS f
JOIN film_actor AS fa
    ON f.film_id = fa.film_id
JOIN actor AS a
    ON fa.actor_id = a.actor_id
WHERE f.film_id = 1;


/* =====================================================
 2. TYPES OF JOINS – INNER, LEFT, RIGHT
===================================================== */

-- 2.1 INNER JOIN
--   Only rows with matches in BOTH tables
--   Example: customers who HAVE at least one payment
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(p.payment_id) AS num_payments
FROM customer AS c
INNER JOIN payment AS p
    ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY num_payments DESC
LIMIT 10;

-- 2.2 LEFT JOIN
--   All rows from LEFT; matching rows from RIGHT (or NULL if no match)
--   Example: all customers with their total payments (0 if no payments)
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    IFNULL(SUM(p.amount), 0) AS total_payments
FROM customer AS c
LEFT JOIN payment AS p
    ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_payments DESC
LIMIT 10;

-- 2.2.1 Identify customers with NO payments
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name
FROM customer AS c
LEFT JOIN payment AS p
    ON c.customer_id = p.customer_id
WHERE p.payment_id IS NULL;   -- unmatched rows only

-- 2.3 RIGHT JOIN
--   All rows from RIGHT; matching from LEFT
--   Example: all payments, even if some customer rows are missing (in theory)
--   In sakila this is mostly symmetric to LEFT JOIN, but we show syntax.
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    p.payment_id,
    p.amount
FROM customer AS c
RIGHT JOIN payment AS p
    ON c.customer_id = p.customer_id
LIMIT 10;


/* =====================================================
 3. FULL OUTER JOIN (SIMULATED IN MySQL)
   MySQL has no native FULL OUTER JOIN.
   Common pattern: LEFT JOIN + RIGHT JOIN + UNION
===================================================== */

-- Example scenario:
--   Combine ALL customer + payment combinations:
--   - Customers with payments
--   - Customers without payments
--   - (Theoretically) payments without customers
--   (sakila won't really have orphan payments, but query is valid)

-- Part 1: LEFT JOIN (customers + their payments, including NULL payments)
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    p.payment_id,
    p.amount,
    'LEFT' AS source_side
FROM customer AS c
LEFT JOIN payment AS p
    ON c.customer_id = p.customer_id

UNION

-- Part 2: RIGHT JOIN rows where customer is NULL (to avoid duplicates)
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    p.payment_id,
    p.amount,
    'RIGHT' AS source_side
FROM customer AS c
RIGHT JOIN payment AS p
    ON c.customer_id = p.customer_id
WHERE c.customer_id IS NULL;    -- only rows not already in LEFT part


/* =====================================================
 4. CROSS JOIN – Cartesian Product
   Be careful! Size = rows(A) * rows(B)
===================================================== */

-- Example: combine some languages with some film ratings
-- First, pick a small subset with WHERE / LIMIT to avoid explosion
SELECT * FROM language;

SELECT DISTINCT rating FROM film;

-- CROSS JOIN them
SELECT 
    l.language_id,
    l.name AS language_name,
    f.rating
FROM language AS l
CROSS JOIN (
    SELECT DISTINCT rating FROM film
) AS f
ORDER BY l.language_id, f.rating;


/* =====================================================
 5. SELF JOIN – a table joined to itself
   Useful for hierarchical data or relationships
===================================================== */

-- 5.1 Self-join on customer_friendship to show "friend graph"
-- Tables:
--   customer_friendship (user_id, friend_id)
--   customer c1 (user)
--   customer c2 (friend)
SELECT 
    c1.customer_id      AS user_id,
    CONCAT(c1.first_name, ' ', c1.last_name) AS user_name,
    c2.customer_id      AS friend_id,
    CONCAT(c2.first_name, ' ', c2.last_name) AS friend_name
FROM customer_friendship AS cf
JOIN customer AS c1
    ON cf.user_id = c1.customer_id
JOIN customer AS c2
    ON cf.friend_id = c2.customer_id
ORDER BY user_id, friend_id;

-- 5.2 Self-join without a linking table (logical relationships)
-- Example: actors with the same last name (siblings by name, just for fun)
SELECT 
    a1.actor_id AS actor1_id,
    CONCAT(a1.first_name, ' ', a1.last_name) AS actor1_name,
    a2.actor_id AS actor2_id,
    CONCAT(a2.first_name, ' ', a2.last_name) AS actor2_name
FROM actor AS a1
JOIN actor AS a2
    ON a1.last_name = a2.last_name
   AND a1.actor_id < a2.actor_id   -- prevent duplicates & self-match
ORDER BY a1.last_name, actor1_id, actor2_id;


/* =====================================================
END OF Day 5 SCRIPT
========================================================

