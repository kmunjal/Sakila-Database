-- HW 1

USE sakila;

-- 1a. Display the first and last names of all actors from the table actor
SELECT first_name, last_name 
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. 
-- Name the column Actor Name
SELECT CONCAT(first_name, ' ', last_name) AS Actor_Name
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, 
-- of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE "%Gen%";

-- 2c. Find all actors whose last names contain the letters LI. 
-- This time, order the rows by last name and first name, in that order:
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE "%LI%"
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: 
-- Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. 
-- You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB
ALTER TABLE actor
ADD description BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. 
-- Delete the description column.
ALTER TABLE actor
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name)
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name)
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) > 1;

SET SQL_SAFE_UPDATES = 0;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
-- Write a query to fix the record.
UPDATE actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO";

-- 4d. In a single query, if the first name of the actor is currently HARPO, 
-- change it to GROUCHO.
UPDATE actor
SET first_name = "GROUCHO"
WHERE first_name = "HARPO";

-- 5a. You cannot locate the schema of the address table. 
-- Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, 
-- of each staff member. Use the tables staff and address:
SELECT staff.first_name, staff.last_name, address.address
FROM staff
JOIN address ON staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
-- Use tables staff and payment.
SELECT staff.first_name, staff.last_name, SUM(payment.amount) AS Total
FROM staff
JOIN payment ON staff.staff_id = payment.staff_id
WHERE payment.payment_date BETWEEN '2005-08-01' AND '2005-08-31'
GROUP BY payment.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. 
-- Use tables film_actor and film. Use inner join.
SELECT f.title, COUNT(fa.actor_id) AS num_of_actors
FROM film f
INNER JOIN film_actor fa ON f.film_id = fa.film_id
GROUP BY f.film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT f.title, COUNT(inventory_id)
FROM film f
INNER JOIN inventory i ON f.film_id = i.film_id
WHERE f.title = "Hunchback Impossible";

-- 6e. Using the tables payment and customer and the JOIN command, 
-- list the total paid by each customer. List the customers alphabetically by last name:
SELECT c.first_name, c.last_name, SUM(amount)
FROM payment p
JOIN customer c ON p.customer_id = c.customer_id
GROUP BY p.customer_id
ORDER BY last_name ASC;

-- 7a. Use subqueries to display the titles of movies starting 
-- with the letters K and Q whose language is English.
SELECT title 
FROM film
WHERE language_id in
	(SELECT language_id 
	FROM language
	WHERE name = "English" )
	AND (title LIKE "K%") OR (title LIKE "Q%");

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
	(SELECT actor_id FROM film_actor
    WHERE film_id IN 
		(SELECT film_id FROM film
        WHERE title = "Alone Trip"));

-- 7c. You want to run an email marketing campaign in Canada, 
-- for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
SELECT country, last_name, first_name, email
FROM country c
LEFT JOIN customer cu
ON c.country_id = cu.customer_id
WHERE country = 'Canada';

-- 7d. Sales have been lagging among young families, 
-- and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
SELECT title, category
FROM film_list
WHERE category = 'Family';

-- 7e. Display the most frequently rented movies in descending order.
SELECT title, COUNT(f.film_id) AS 'Count_of_Rented_Movies'
FROM  film f
JOIN inventory i ON f.film_id= i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY title ORDER BY Count_of_Rented_Movies DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, SUM(p.amount) 
FROM payment p
JOIN staff s ON p.staff_id=s.staff_id
GROUP BY store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country 
FROM store s
JOIN address a ON (s.address_id=a.address_id)
JOIN city c ON (a.city_id=c.city_id)
JOIN country cntry ON (c.country_id=cntry.country_id);

-- 7h. List the top five genres in gross revenue in descending order. 
SELECT c.name AS 'Top_Five', SUM(p.amount) AS 'Gross'
FROM category c
JOIN film_category fc ON c.category_id=fc.category_id
JOIN inventory i ON fc.film_id=i.film_id
JOIN rental r ON i.inventory_id=r.inventory_id
JOIN payment p ON r.rental_id=p.rental_id
GROUP BY c.name 
ORDER BY Gross DESC
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of 
-- viewing the Top five genres by gross revenue
CREATE VIEW top_five_grossing_genres AS
SELECT c.name AS 'Top_Five', SUM(p.amount) AS 'Gross'
FROM category c
JOIN film_category fc ON c.category_id=fc.category_id
JOIN inventory i ON fc.film_id=i.film_id
JOIN rental r ON i.inventory_id=r.inventory_id
JOIN payment p ON r.rental_id=p.rental_id
GROUP BY c.name 
ORDER BY Gross DESC
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_grossing_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_grossing_genres;





