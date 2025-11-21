/* ================================
   1️⃣ STRING FUNCTION PRACTICE
   ================================ */

-- LOWER / UPPER
SELECT LOWER(title) AS lower_title,
       UPPER(title) AS upper_title
FROM sakila.film
LIMIT 5;

-- LEFT / RIGHT
SELECT title,
       LEFT(title, 4) AS first4,
       RIGHT(title, 4) AS last4
FROM sakila.film
LIMIT 5;

-- SUBSTRING + LOCATE
SELECT title,
       SUBSTRING(description, LOCATE('of', description), 20) AS snippet
FROM sakila.film
LIMIT 5;

-- TRIM / LTRIM / RTRIM
SELECT TRIM('   HELLO   ') AS trimmed_text;
SELECT LTRIM('   HELLO') AS left_trimmed;
SELECT RTRIM('HELLO   ') AS right_trimmed;

-- ASCII
SELECT first_name,
       ASCII(first_name) AS first_char_code
FROM sakila.customer
LIMIT 10;

-- INSERT()
SELECT title,
       INSERT(title, 1, 3, '***') AS masked_title
FROM sakila.film
LIMIT 5;

-- REPLACE()
SELECT description,
       REPLACE(description, 'the', 'THE')
FROM sakila.film
LIMIT 5;

-- FIELD()
SELECT title,
       FIELD(rating, 'G','PG','PG-13','R') AS rating_rank
FROM sakila.film
LIMIT 5;


/* ================================
   2️⃣ DATE & TIME PRACTICE
   ================================ */

-- DATEDIFF()
SELECT rental_id, rental_date, return_date,
       DATEDIFF(return_date, rental_date) AS days_rented
FROM sakila.rental
WHERE return_date IS NOT NULL
LIMIT 10;

-- MONTH / MONTHNAME
SELECT last_update,
       MONTH(last_update) AS month_no,
       MONTHNAME(last_update) AS month_name
FROM sakila.film
LIMIT 10;

-- YEAR()
SELECT rental_date,
       YEAR(rental_date) AS rental_year
FROM sakila.rental
LIMIT 10;

-- Payments grouped by date
SELECT DATE(payment_date) AS pay_date,
       SUM(amount) AS total_paid
FROM sakila.payment
GROUP BY DATE(payment_date)
ORDER BY pay_date DESC;

-- Payments in last 24 hours
SELECT customer_id, amount, payment_date
FROM sakila.payment
WHERE payment_date >= NOW() - INTERVAL 1 DAY;

-- Payments in last 10 days using subquery
SELECT customer_id, amount, payment_date
FROM sakila.payment
WHERE payment_date >= (
        SELECT MAX(payment_date) - INTERVAL 10 DAY
        FROM sakila.payment
);

-- NOW(), CURDATE(), CURRENT_TIME
SELECT NOW(), CURDATE(), CURRENT_TIME;


/* ================================
   3️⃣ SUBQUERY PRACTICE
   ================================ */

-- IN Subquery
SELECT first_name, last_name
FROM sakila.customer
WHERE address_id IN (
      SELECT address_id
      FROM sakila.customer
      WHERE customer_id = 1
);

-- Correlated Subquery — Actor Film Count
SELECT actor_id, first_name, last_name,
(
    SELECT COUNT(*)
    FROM sakila.film_actor fa
    WHERE fa.actor_id = a.actor_id
) AS film_count
FROM sakila.actor a;

-- Compare payment amount > customer avg
SELECT customer_id, amount, payment_date
FROM sakila.payment p1
WHERE amount > (
      SELECT AVG(amount)
      FROM sakila.payment p2
      WHERE p2.customer_id = p1.customer_id
);

-- Derived Table — Group last names
SELECT *
FROM (
    SELECT last_name,
           CASE
               WHEN LEFT(last_name, 1) BETWEEN 'A' AND 'M'
                   THEN 'Group A-M'
               WHEN LEFT(last_name, 1) BETWEEN 'N' AND 'Z'
                   THEN 'Group N-Z'
               ELSE 'Other'
           END AS group_label
    FROM sakila.customer
) AS grouped
WHERE group_label = 'Group A-M'
LIMIT 10;

-- Actors who acted in more than 10 films
SELECT actor_id, COUNT(film_id) AS films_done
FROM sakila.film_actor
GROUP BY actor_id
HAVING COUNT(film_id) > 10;



-- Clean customer name (capitalize first letter)
SELECT first_name,
       CONCAT(UPPER(LEFT(first_name,1)), LOWER(SUBSTRING(first_name,2))) AS formatted_name
FROM sakila.customer;

-- Extract half of film description
SELECT title,
       SUBSTRING(description, 1, LENGTH(description)/2) AS half_desc
FROM sakila.film
LIMIT 5;

