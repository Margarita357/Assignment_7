## Instructions

# 1a. Display the first and last names of all actors from the table `actor`.
USE sakila;
SELECT 
	first_name,
    last_name
FROM actor; 

#* 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT CONCAT (first_name, ' ', last_name) AS 'Actor Name'
FROM actor; 

#* 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
#What is one query would you use to obtain this information?
SELECT
	actor_id,
	first_name,
	last_name
 FROM actor
 WHERE first_name= 'JOE';


#* 2b. Find all actors whose last name contain the letters `GEN`:
SELECT 
	last_name
FROM actor
WHERE last_name LIKE '%GEN%';


#* 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT 
	first_name,
	last_name
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

#* 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT 
	country_id,
    country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

# 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` 
#(Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).

ALTER TABLE  actor ADD COLUMN description BLOB;

#* 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.

ALTER TABLE  actor DROP COLUMN description;

#* 4a. List the last names of actors, as well as how many actors have that last name.

SELECT DISTINCT
	last_name,
    COUNT(last_name) AS count_last_names
FROM actor
GROUP BY last_name;

#* 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

SELECT * 
FROM (
		SELECT DISTINCT
			last_name,
			COUNT(last_name) AS count_last_names
		FROM actor
		GROUP BY last_name
	) AS new_actors
WHERE count_last_names != 1;

# 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

#* 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently 
#`HARPO`, change it to `GROUCHO`.
SET SQL_SAFE_UPDATES = 0;

UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO';


#* 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
#* Hint: <https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html>
CREATE TABLE address2 (
	id INT NOT NULL AUTO_INCREMENT,
	address VARCHAR (50) NOT NULL,
	address2 VARCHAR (50),
	district VARCHAR (20) NOT NULL,
	city_id INT NOT NULL,
	postal_code VARCHAR(10), 
	phone VARCHAR(20) NOT NULL,
	location GEOMETRY NOT NULL,
	last_update CURRENT_TIMESTAMP NOT NULL
);

#* 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT 
	address_id,
	first_name,
    last_name,
    address
FROM staff s 
LEFT JOIN address a USING (address_id);

#* 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.

SELECT
    staff_id,
	SUM(amount) AS total_amount_per_staff_aug
FROM staff s
LEFT JOIN payment p USING(staff_id)
WHERE payment_date LIKE '2005-08%'
GROUP BY staff_id;

#* 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.

SELECT 
	f.title,
	COUNT(fa.actor_id) AS total_actors 
FROM film_actor fa
JOIN film f USING(film_id)
GROUP BY film_id;

#* 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system? film and inventory

SELECT 
	f.title,
    COUNT(i.inventory_id) AS total_inventory
FROM film f
JOIN inventory i USING(film_id)
WHERE f.title='HUNCHBACK IMPOSSIBLE';

# 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. 
List the customers alphabetically by last name:

SELECT 
	last_name
	customer_id,
	SUM(amount) AS customer_total
FROM payment p
JOIN customer c USING(customer_id)
GROUP BY customer_id
ORDER BY last_name;
    
* 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence,
 films starting with the letters `K` and `Q` have also soared in popularity.
 Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
 
SELECT title 
FROM film f 
WHERE f.title LIKE 'Q%' OR title LIKE 'K%'
AND f.language_id IN(
		SELECT language_id
        FROM language
        WHERE name= 'English'
	);

* 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

SELECT first_name, last_name
FROM actor
WHERE actor_id IN (
	SELECT actor_id
    FROM film_actor
    WHERE film_id IN(
		SELECT film_id
        FROM film
        WHERE title = 'Alone Trip'));


* 7c. You want to run an email marketing campaign in Canada, for which you will need the names and 
email addresses of all Canadian customers. Use joins to retrieve this information.

SELECT last_name, first_name, email, country
FROM customer c
JOIN address  USING(address_id)
JOIN city USING(city_id)
JOIN country USING(country_id)
WHERE country.country = 'Canada';


* 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
Identify all movies categorized as family films.

SELECT title
FROM film
WHERE film_id IN (
	SELECT film_id
    FROM film_category
    WHERE category_id IN (
		SELECT category_id
        From category
        Where name = 'FAMILY'));

* 7e. Display the most frequently rented movies in descending order.

SELECT 
	title, 
    COUNT(film_id) AS count_of_rentals
FROM  film f
JOIN inventory i USING(film_id)
JOIN rental r USING(inventory_id)
GROUP BY title ORDER BY count_of_rentals DESC;        

* 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT 
	store_id,
	SUM(amount)
FROM payment 
JOIN staff USING(staff_id)
JOIN store USING(store_id)
GROUP BY store_id;

* 7g. Write a query to display for each store its store ID, city, and country.

* 7h. List the top five genres in gross revenue in descending order. 
(**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

* 8a. In your new role as an executive, you would like to have an easy way of viewing the 
Top five genres by gross revenue. Use the solution from the problem above to create a view. 
If you have not solved 7h, you can substitute another query to create a view.

* 8b. How would you display the view that you created in 8a?

* 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.

## Appendix: List of Tables in the Sakila DB

* A schema is also available as `sakila_schema.svg`. Open it with a browser to view.

```sql
	'actor'
	'actor_info'
	'address'
	'category'
	'city'
	'country'
	'customer'
	'customer_list'
	'film'
	'film_actor'
	'film_category'
	'film_list'
	'film_text'
	'inventory'
	'language'
	'nicer_but_slower_film_list'
	'payment'
	'rental'
	'sales_by_film_category'
	'sales_by_store'
	'staff'
	'staff_list'
	'store'
```

## Uploading Homework

* To submit this homework using BootCampSpot:

  * Create a GitHub repository.
  * Upload your .sql file with the completed queries.
  * Submit a link to your GitHub repo through BootCampSpot.

