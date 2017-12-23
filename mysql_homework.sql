-- using the sakila databse
USE sakila;

-- 1a. get a list of actor's first and last names
SELECT first_name, last_name
FROM actor;

-- 1b. joining 1st name and last name
SELECT concat(first_name," ", last_name) as Actor_Name
FROM actor;

-- 2a. get the id and other details of actor whose first_name is 'joe'
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name in ("Joe");

-- 2b. get actors whose last_name contains GEN
SELECT *
FROM actor
WHERE last_name like "%GEN%";

-- 2c. get actors with last name "Li" and arrange
SELECT *
FROM actor
WHERE last_name like "%LI%"
ORDER BY first_name, last_name;

-- 2d. display country id and country for Afganistan, Bangladesh and China
SELECT country_id, country
FROM country
WHERE country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Adding new column 'middle_name
ALTER TABLE actor
ADD COLUMN middle_name VARCHAR(255) AFTER first_name;

-- 3b. Change the last_name datatype to blobs
ALTER TABLE actor
MODIFY COLUMN last_name VARCHAR(255);

-- 3c Drop the middle_name column
ALTER TABLE actor
DROP middle_name;

-- 4a. list of last names and count of how many have that name
SELECT last_name, count(last_name)
FROM actor
GROUP BY last_name;

-- 4b. Selecting 2 or more actors with same last name 
SELECT last_name, count(last_name)
FROM actor
GROUP BY last_name HAVING COUNT(last_name) >= 2;

-- 4c. update the name
UPDATE actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO" and last_name = "WILLIAMS"
AND !isnull (first_name);

-- 4d. 
SET SQL_SAFE_UPDATES = 0;
UPDATE actor
SET first_name = "GROUCHO" 
WHERE first_name = "HARPO"
AND !isnull (first_name);

-- 5a. Create table address
SHOW CREATE TABLE address;

-- 6a. first_name and last_name and address of each staff
SELECT staff.first_name,staff.last_name,address.address
FROM address 
JOIN 
staff WHERE staff.address_id=address.address_id;

-- 6b. total amount rung up by each staff memeber in Aug 2005
SELECT concat(staff.first_name," ", staff.last_name) as full_name, sum(payment.amount) as total_amount
FROM staff
JOIN
payment WHERE payment.staff_id = staff.staff_id and YEAR(payment.payment_date) = 2005 and MONTH(payment.payment_date) = 8 
group by staff.staff_id;

-- 6c. get films and number of actors in each film
SELECT film.film_id, film.title,COUNT(film_actor.actor_id),film_actor.film_id
FROM film
INNER JOIN
film_actor WHERE film.film_id = film_actor.film_id
GROUP BY film.title;

-- 6d. how many copies of Hunchback Impossible movie in inventory
SELECT COUNT(film_id) as Total_no_of_copies
FROM inventory
WHERE film_id in (
	SELECT film_id
	FROM film
	WHERE title in ("Hunchback Impossible")
    );
    
-- 6e. 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer.
-- List the customers alphabetically by last name:
SELECT concat(customer.last_name," ", customer.first_name) as last_first_name, sum(payment.amount) as total_paid
FROM payment
INNER JOIN
customer WHERE payment.customer_id = customer.customer_id 
group by customer.customer_id order by customer.last_name asc;

    
-- 7a. get list of movies starting with K and Q
SELECT title as list_of_movies_starting_with_K_or_Q
FROM film
WHERE title like "K%" or title like "Q%" AND language_id in (1);

-- 7b. All actor who appear in movie "Alone trip""
SELECT concat(first_name," ", last_name) as Actor_in_Alonetrip
FROM actor 
WHERE actor_id in (
	SELECT actor_id 
	FROM film_actor
	WHERE film_id in (
	SELECT film_id
    FROM film
    WHERE title in ("Alone Trip")
    ));
    
-- 7c. Get Candian customers email and address
select cus.* from customer cus
join 
address ad 
join
city ci 
join country co
where ad.address_id = cus.address_id and ad.city_id = ci.city_id and ci.country_id=co.country_id and co.country="CANADA";

-- 7d. SELECT all family movies
SELECT title as Family_Movies
FROM film_text
WHERE film_id in (
SELECT film_id
FROM film_category
WHERE category_id in (
SELECT category_id
FROM category
WHERE name in ("family")));

-- 7e. Most rented movies in decensding order
SELECT title as Movie
FROM film_text
WHERE film_id in (
SELECT film_id
FROM inventory
WHERE inventory_id in (
SELECT inventory_id
FROM rental
GROUP BY inventory_id
ORDER BY COUNT(*) DESC));


-- 7e. Display the most frequently rented movies in descending order.
select temp.title, sum(temp.inv_count) from (
select ft.title, count( ren.inventory_id)  as inv_count from rental ren
inner join
inventory inv
inner join 
film_text ft
where ren.inventory_id = inv.inventory_id and inv.film_id = ft.film_id group by ren.inventory_id desc )  temp
group by temp.title order by sum(temp.inv_count) desc;


-- 7f. Write a query to display how much business, in dollars, each store brought in.
select inv.store_id as store_id , sum( py.amount ) as Amount from inventory inv
inner join 
rental ren
inner join
payment py
inner join
store s 
where py.rental_id = ren.rental_id and inv.inventory_id=ren.inventory_id and s.store_id = inv.store_id
group by inv.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
select s.store_id, ci.city,co.country from store s
join
address a 
join
city ci
join
country co
where
a.address_id=s.address_id and a.city_id=ci.city_id and co.country_id=ci.country_id;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select cat.name, sum(py.amount) as gross_revenue from inventory inv
inner join 
rental ren
inner join
payment py
join
category cat
join 
film_category fcat
where py.rental_id = ren.rental_id and inv.inventory_id=ren.inventory_id and fcat.film_id = inv.film_id and fcat.category_id = cat.category_id 
group by cat.name order by sum(py.amount) desc LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW Top_five_genres_by_gross_revenue AS
select cat.name, sum(py.amount) as gross_revenue from inventory inv
inner join 
rental ren
inner join
payment py
join
category cat
join 
film_category fcat
where py.rental_id = ren.rental_id and inv.inventory_id=ren.inventory_id and fcat.film_id = inv.film_id and fcat.category_id = cat.category_id 
group by cat.name order by sum(py.amount) desc LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM sakila.top_five_genres_by_gross_revenue;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW sakila.top_five_genres_by_gross_revenue;
