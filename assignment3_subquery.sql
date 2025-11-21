USE sakila;

-- 1. display all customer details who have made more than 5 payments.
SELECT *
FROM sakila.customer
WHERE customer_id IN (
    SELECT customer_id
    FROM sakila.payment
    GROUP BY customer_id
    HAVING COUNT(*) > 5
);

-- 2. Find the names of actors who have acted in more than 10 films.
SELECT 
    actor_id,
    first_name,
    last_name
FROM sakila.actor
WHERE actor_id IN (
    SELECT actor_id
    FROM sakila.film_actor
    GROUP BY actor_id
    HAVING COUNT(film_id) > 10
);

-- 3. Find the names of customers who never made a payment.
SELECT 
    customer_id,
    first_name,
    last_name
FROM sakila.customer
WHERE customer_id NOT IN (
    SELECT DISTINCT customer_id
    FROM sakila.payment
);

-- 4. List all films whose rental rate is higher than the average rental rate of all films.
SELECT 
    film_id,
    title,
    rental_rate
FROM sakila.film
WHERE rental_rate > (
    SELECT AVG(rental_rate)
    FROM sakila.film
);

-- 5. List the titles of films that were never rented.
SELECT 
    film_id,
    title
FROM sakila.film
WHERE film_id NOT IN (
    SELECT DISTINCT i.film_id
    FROM sakila.inventory i
    JOIN sakila.rental r 
      ON r.inventory_id = i.inventory_id
);

-- 6. Display the customers who rented films in the same month as customer with ID 5.
SELECT DISTINCT 
    c.customer_id,
    c.first_name,
    c.last_name
FROM sakila.customer c
WHERE c.customer_id IN (
    SELECT DISTINCT r2.customer_id
    FROM sakila.rental r2
    WHERE DATE_FORMAT(r2.rental_date, '%Y-%m') IN (
        SELECT DISTINCT DATE_FORMAT(r1.rental_date, '%Y-%m')
        FROM sakila.rental r1
        WHERE r1.customer_id = 5
    )
);

-- 7. Find all staff members who handled a payment greater than the average payment amount.
SELECT 
    staff_id,
    first_name,
    last_name
FROM sakila.staff
WHERE staff_id IN (
    SELECT DISTINCT staff_id
    FROM sakila.payment
    WHERE amount > (
        SELECT AVG(amount)
        FROM sakila.payment
    )
);


-- 8. Show the title and rental duration of films whose rental duration is greater than the average.
SELECT 
    title,
    rental_duration
FROM sakila.film
WHERE rental_duration > (
    SELECT AVG(rental_duration)
    FROM sakila.film
);

-- 9. Find all customers who have the same address as customer with ID 1.
SELECT 
    customer_id,
    first_name,
    last_name,
    address_id
FROM sakila.customer
WHERE address_id = (
    SELECT address_id
    FROM sakila.customer
    WHERE customer_id = 1
)
AND customer_id <> 1;   -- optional: exclude customer 1

-- 10. List all payments that are greater than the average of all payments.
SELECT 
    payment_id,
    customer_id,
    staff_id,
    amount,
    payment_date
FROM sakila.payment
WHERE amount > (
    SELECT AVG(amount)
    FROM sakila.payment
);
