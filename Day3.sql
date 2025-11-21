/* 
========================================================
 Day 3 – SQL Built-in Functions
 Strings • Math • Dates/Times • Type Casting
 Target DB : MySQL with sakila sample DB installed
========================================================
 Take away:
 - String functions help clean, shape, and format text.
 - Math functions support scoring, rounding, analytics.
 - Date functions let you understand timelines and history.
 - Casting helps when mixing text and numbers.
========================================================
*/

USE sakila;

/* -----------------------------------------------------
 1. STRING FUNCTIONS
   (Useful for cleaning, formatting, extracting, searching)
------------------------------------------------------ */

-- LPAD / RPAD → helpful for alignment or fixed-width formatting
SELECT 
    first_name,
    LPAD(first_name, 10, '*') AS padded_left,
    RPAD(first_name, 10, '.') AS padded_right
FROM actor
LIMIT 5;

-- LEFT / RIGHT / SUBSTRING → quick ways to slice strings
SELECT 
    last_name,
    LEFT(last_name, 3) AS first_three,
    RIGHT(last_name, 3) AS last_three,
    SUBSTRING(last_name, 2, 4) AS mid_substring
FROM actor
LIMIT 5;

-- CONCAT → build readable labels (names, emails, tags)
SELECT 
    actor_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    CONCAT(LOWER(first_name), '.', LOWER(last_name), '@example.com') AS fake_email
FROM actor
LIMIT 5;

-- LOCATE / SUBSTRING_INDEX → handy for splitting usernames + domains
SELECT 
    customer_id,
    email,
    LOCATE('@', email) AS at_position,
    SUBSTRING(email, 1, LOCATE('@', email) - 1) AS email_username,
    SUBSTRING_INDEX(email, '@', -1) AS email_domain
FROM customer
LIMIT 10;

-- UPPER / LOWER / REPLACE → quick clean-up or normalization
SELECT 
    title,
    UPPER(title) AS title_upper,
    LOWER(title) AS title_lower,
    REPLACE(title, ' ', '_') AS title_with_underscores
FROM film
LIMIT 5;

-- REGEXP → goes beyond LIKE for advanced text filtering
-- A: eliminate names with 3+ vowels in a row
SELECT 
    last_name
FROM actor
WHERE last_name NOT REGEXP '[aeiouAEIOU]{3}'
LIMIT 20;

-- B: titles ending with a vowel
SELECT 
    film_id,
    title
FROM film
WHERE title REGEXP '[aeiouAEIOU]$'
LIMIT 20;


/* -----------------------------------------------------
 2. MATH FUNCTIONS
   (Great for analytics, scoring, rounding, calculations)
------------------------------------------------------ */

-- COUNT / SUM / AVG → core summary stats
SELECT 
    COUNT(*)          AS total_payments,
    SUM(amount)       AS total_amount,
    AVG(amount)       AS avg_payment
FROM payment;

-- POWER / MOD → tiny tools with big impact (squares, even/odd)
SELECT 
    payment_id,
    amount,
    POWER(amount, 2) AS amount_squared,
    MOD(payment_id, 2) AS payment_id_even_odd
FROM payment
LIMIT 10;

-- RAND → useful for sampling or quick scoring (0–99)
SELECT
    customer_id,
    FLOOR(RAND() * 100) AS random_score
FROM customer
LIMIT 10;

-- CEIL / FLOOR / ROUND → different rounding strategies
SELECT 
    amount,
    CEIL(amount)  AS ceil_amount,
    FLOOR(amount) AS floor_amount,
    ROUND(amount, 2) AS rounded_2_dec,
    ROUND(amount, 0) AS rounded_int
FROM payment
LIMIT 10;

-- Adding a computed field to a table (optional metric)
-- Reminder: this alters the real sakila.film structure
ALTER TABLE film
ADD COLUMN cost_per_day DECIMAL(10,2) NULL;

-- Filling the computed metric
UPDATE film
SET cost_per_day = 
    CASE 
        WHEN rental_duration > 0 THEN replacement_cost / rental_duration
        ELSE NULL
    END;

-- Quick check of computed values
SELECT 
    film_id,
    title,
    rental_duration,
    replacement_cost,
    cost_per_day
FROM film
LIMIT 10;


/* -----------------------------------------------------
 3. DATE / TIME FUNCTIONS + CASTING
   (Essential for tracking timelines & structuring reports)
------------------------------------------------------ */

-- DATEDIFF → helps to measure durations between events
SELECT 
    rental_id,
    rental_date,
    return_date,
    DATEDIFF(return_date, rental_date) AS days_rented
FROM rental
WHERE return_date IS NOT NULL
LIMIT 10;

-- YEAR / MONTH / MONTHNAME → extracting calendar components
SELECT 
    payment_id,
    payment_date,
    YEAR(payment_date)      AS payment_year,
    MONTH(payment_date)     AS payment_month_num,
    MONTHNAME(payment_date) AS payment_month_name
FROM payment
LIMIT 10;

-- NOW / CURDATE / CURRENT_TIME → current system timestamps
SELECT 
    NOW() AS current_datetime,
    CURDATE() AS current_date,
    CURRENT_TIME() AS current_time;

-- INTERVAL → great for "last X hours/days/weeks" style queries
-- Note: sakila’s old dates may not match real-time filters
SELECT 
    payment_id,
    customer_id,
    amount,
    payment_date
FROM payment
WHERE payment_date >= NOW() - INTERVAL 1 DAY;

-- Last 7 days of rentals (relative to NOW)
SELECT 
    rental_id,
    customer_id,
    rental_date
FROM rental
WHERE rental_date >= NOW() - INTERVAL 7 DAY
ORDER BY rental_date DESC
LIMIT 20;

-- CAST → converting between types (text ↔ number, etc.)
-- A: numbers → strings
SELECT 
    payment_id,
    amount,
    CAST(amount AS CHAR(10)) AS amount_as_char,
    CONCAT('Amount: $', CAST(amount AS CHAR(10))) AS amount_text
FROM payment
LIMIT 10;

-- B: strings → dates
SELECT 
    '2025-01-01' AS original_string,
    CAST('2025-01-01' AS DATE) AS cast_to_date,
    CAST('2025-01-01 15:30:00' AS DATETIME) AS cast_to_datetime;

-- C: integer → decimal / char
SELECT 
    42 AS original_int,
    CAST(42 AS DECIMAL(10,2)) AS cast_to_decimal,
    CAST(42 AS CHAR(5)) AS cast_to_char;

-- D: numeric text → integer
SELECT 
    '123' AS original_string,
    CAST('123' AS SIGNED) AS cast_to_int;


/* -----------------------------------------------------
 END OF DAY 3 SCRIPT
 Take away:
 - String helpers make data cleaner and easier to work with.
 - Math functions unlock scoring, summaries, and analytics.
 - Date tools help measure time and spot trends.
 - CAST fixes type mismatches and builds flexible queries.
------------------------------------------------------ */
