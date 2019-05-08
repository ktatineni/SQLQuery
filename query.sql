Use Sakila;
# 1a. Display the first and last name of the actor

Select first_name, last_name
From Actor;

# 1b. The first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.

Select Upper(concat(first_name, " ", last_name)) AS 'Actor Name'
From Actor;

# 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 

Select actor_id, first_name, last_name 
From Actor
Where first_name = 'Joe';

# 2b. Find all actors whose last name contain the letters `GEN`:
Select * 
From Actor
Where last_name like "%GEN%";

# 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
Select first_name
From Actor
Where last_name like '%li%' 
Order by last_name, first_name;

# 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
select * 
from country
where country in ('Afganistan', 'Bangladesh', 'China');

# 3a. You want to keep a description of each actor. 
# You don't think you will be performing queries on a description, 
# so create a column in the table `actor` named `description` 
# and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).

ALTER Table Actor
ADD description blob;

Select *
From Actor;

# 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.

ALTER TABLE Actor
Drop Column description;

# 4a. List the last names of actors, as well as how many actors have that last name.

Select *
From Actor;

Select count(last_name) as "Actors with Last Names"
From Actor;

# 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors.

Select count(actor_id) as Number_of_Actors, last_name
from actor
Group BY last_name
Having Number_of_Actors > 1;

# 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`

UPDATE actor
Set first_name = 'HARPO'
Where first_name = 'GROUCHO' and last_name = 'WILLIAMS';

select *
from actor
where first_name = 'HARPO';

# 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. 
# It turns out that `GROUCHO` was the correct name after all! 
# In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.

select *
from actor 
where first_name = 'HARPO';

Update actor
Set first_name = 'GROUCHO' 
Where first_name = 'HARPO';

# 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?

# Answer : Create Table

# 6a . Use `JOIN` to display the first and last names, as well as the address, of each staff member. 
#      Use the tables `staff` and `address`:

Select first_name, last_name, address
From address
Inner Join staff on staff.address_id=address.address_id;

# 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.

Select payment.staff_id, first_name, last_name, sum(amount) as "Total Cost" 
From payment 
Inner Join staff on payment.staff_id=staff.staff_id
Group By staff_id;

#6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.

Select title, count(actor_id) as "Number of Actors"
From film_actor
Inner Join film on film_actor.film_id = film.film_id
Group By title;

#6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?

select *
from film
where title like "%Hunchback Impossible%";

#6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. 
#    List the customers alphabetically by last name:

select payment.customer_id, sum(amount) as "total amount", last_name
from payment
Inner Join customer on payment.customer_id=customer.customer_id
Group By customer_id
Order BY  last_name ASC;

# 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
# As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
# Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.

select * 
from film 
where (title like "K%" or title like  "Q%") and language_id = 1;

# 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

Select *
From film_actor
Inner Join film on film.film_id = film_actor.film_id
where title like "%Alone Trip%";

# 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
# Use joins to retrieve this information.

select *
from customer
inner join (select address.city_id, country_id, address_id
from address
inner join city on city.city_id = address.city_id) as a on a.address_id = customer.address_id
where customer.address_id = 20;

# 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
# Identify all movies categorized as _family_ films.

select  title, name
from film
inner join (select film_id, name
	from film_category
	inner join category on category.category_id = film_category.category_id
	where name = 'Family') as a on film.film_id = a.film_id;
    
# 7d. Display the most frequently rented movies in descending order.

select inventory_id, count(inventory_id) 
from rental
Group By inventory_id
Order By count(inventory_id)  DESC;

# 7f. Write a query to display how much business, in dollars, each store brought in.

select store_id, city, country
from country
inner join (select store_id,  city, country_id
from store
inner join (select address_id, city.city_id, city, country_id
from address
inner join city on address.city_id = city.city_id) as h on h.address_id = store.address_id) as a on a.country_id = country.country_id;


# 7h. List the top five genres in gross revenue in descending order. 
# (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

select name, Total_Amount
from category
inner join (select category_id, Total_Amount
from film_category
inner join (select film_id, Total_Amount
from inventory
inner join (select rental.rental_id, inventory_id, Total_Amount
from rental
inner join (select payment.rental_id, sum(amount) as Total_Amount
from payment
group by rental_id) as a on a.rental_id = rental.rental_id) as a on a.inventory_id = inventory.inventory_id) as a on a.film_id = film_category.film_id) as a 
on a.category_id = category.category_id
Order By Total_Amount DESC;

# 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
# Use the solution from the problem above to create a view.

create view question_eight as 
select name, Total_Amount
from category
inner join (select category_id, Total_Amount
from film_category
inner join (select film_id, Total_Amount
from inventory
inner join (select rental.rental_id, inventory_id, Total_Amount
from rental
inner join (select payment.rental_id, sum(amount) as Total_Amount
from payment
group by rental_id) as a on a.rental_id = rental.rental_id) as a on a.inventory_id = inventory.inventory_id) as a on a.film_id = film_category.film_id) as a 
on a.category_id = category.category_id
Order By Total_Amount DESC;

# 8b. 
select *
from question_eight;
# or show create view

# 8c .You find that you no longer need the view `top_five_genres`. Write a query to delete it.

drop view question_eight;


