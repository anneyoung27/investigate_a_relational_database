/* 
Question 1
We want to understand more about the movies that families are watching. 
The following categories are considered family movies: Animation, Children, Classics, Comedy, Family and Music.
Create a query that lists each movie, the film category it is classified in, and the number of times it has been rented OUT
*/
WITH t1 AS(
	SELECT f.title AS film_name, c."name" AS category, COUNT(*) AS rental_count
FROM rental r
JOIN inventory i 
	ON
r.inventory_id = i.inventory_id
JOIN film f 
	ON
i.film_id = f.film_id
JOIN film_category fc 
	ON
f.film_id = fc.film_id
JOIN category c 
	ON
fc.category_id = c.category_id
WHERE c."name" IN('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
GROUP BY 1, 2
ORDER BY 3)

SELECT category, SUM(rental_count) AS total_rentals, RANK() OVER(
ORDER BY SUM(rental_count) ASC) AS "rank"
FROM t1
GROUP BY 1
ORDER BY 3

/*
Question 2
Now we need to know how the length of rental duration of these family-friendly movies compares to the duration that all movies are rented for.
Can you provide a table with the movie titles and divide them into 4 levels (first_quarter, second_quarter, third_quarter, and final_quarter) based on the quartiles (25%, 50%, 75%) of the rental duration for movies across all 
categories? Make sure to also indicate the category that these family-friendly movies fall into. 
*/
WITH q AS (
	SELECT c."name" AS category, f.title, NTILE(4) OVER(
ORDER BY f.rental_duration) AS quartiles
FROM category c
JOIN film_category fc
	ON
c.category_id = fc.category_id
JOIN film f 
	ON
fc.film_id = f.film_id
WHERE c."name" IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
ORDER BY 3
)
SELECT *
FROM q;

/*
Question 3
Finally, provide a table with the family-friendly film category, each of the quartiles, and the corresponding count of movies within each combination of film category for each 
corresponding rental duration category. The resulting table should have three columns:

a. Category
b. Rental length category
c. Count
The Count column should be sorted first by Category and then by Rental Duration category.
*/
SELECT t.category, t.quartiles AS rental_length_category, COUNT(t.quartiles) AS count
FROM(SELECT c."name" AS category, f.title, NTILE(4) OVER(
ORDER BY f.rental_duration) AS quartiles
FROM category c
JOIN film_category fc
	ON
c.category_id = fc.category_id
JOIN film f 
	ON
fc.film_id = f.film_id
WHERE c."name" IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
ORDER BY 3
) AS t
GROUP BY 1, 2
ORDER BY 3;

/*
Question 4
We want to find out how the two stores compare in their count of rental orders during every month for all the years we have data for. 
Write a query that returns the store ID for the store, the year and month and the number of rental orders each store has fulfilled for that month. 
Your table should include a column for each of the following: year, month, store ID and count of rental orders fulfilled during that month.
The count of rental orders is sorted in descending order.
*/
SELECT s.store_id, date_part('year', r.rental_date) AS YEAR, date_part('month', r.rental_date) AS MONTH, COUNT(r.rental_id) AS cnt_rental_orders
FROM store s
JOIN staff s2 
ON
s.store_id = s2.store_id
JOIN payment p 
ON
s2.staff_id = p.staff_id
JOIN rental r 
ON
p.rental_id = r.rental_id
GROUP BY 1, 2, 3
ORDER BY 4 DESC;

/*
Question 5
How many movies are there for each Family-friendly category (Animation, Children, Classics, Comedy, Family and Music)?
Hoy many rentals are there for each category? (Total rentals)
What is the most popular (by number of rentals) family-friendly movie?
What is the most popular family-friendly category?
 */

SELECT f.title, c."name" AS category, COUNT(f.film_id) AS movies_count, COUNT(r.rental_id) AS total_rentals
FROM film f
JOIN film_category fc 
	ON
f.film_id = fc.film_id
JOIN category c 
	ON
c.category_id = fc.category_id
JOIN inventory i 
	ON
f.film_id = i.film_id
JOIN rental r 
	ON
i.inventory_id = r.inventory_id
WHERE c."name" IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
GROUP BY 1, 2
ORDER BY 3 DESC, 4 DESC
LIMIT 5;


