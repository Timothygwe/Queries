-- Запрос 1:Вывести количество фильмов в каждой категории, отсортировать по убыванию.
SELECT 
    COUNT(film_id) AS countage, 
    category.name AS name_of_category
FROM 
    film_category
INNER JOIN 
    category USING(category_id) 
GROUP BY 
    category.name
ORDER BY 
    countage DESC;

-- Запрос 2:Вывести 10 актеров, чьи фильмы большего всего арендовали, отсортировать по убыванию.
SELECT 
    CONCAT(actor.first_name, ' ', actor.last_name) AS actor,
    COUNT(rental_id) AS countage
FROM 
    actor
JOIN 
    film_actor USING (actor_id)
JOIN 
    inventory USING (film_id)
JOIN 
    rental USING (inventory_id)
GROUP BY 
    CONCAT(actor.first_name, ' ', actor.last_name)
ORDER BY 
    countage DESC
LIMIT 10;

-- Запрос 3:Вывести категорию фильмов, на которую потратили больше всего денег.
SELECT 
    category.name AS category_name, 
    SUM(payment.amount) AS spendings
FROM 
    category 
JOIN 
    film_category USING (category_id)
JOIN 
    inventory USING (film_id)
JOIN 
    rental USING (inventory_id)
JOIN 
    payment USING (rental_id)
GROUP BY 
    category.name
ORDER BY 
    spendings DESC 
LIMIT 1;

-- Запрос 4: Вывести названия фильмов, которых нет в inventory. 
SELECT 
    title
FROM 
    film
LEFT JOIN 
    inventory USING (film_id)
WHERE 
    inventory_id IS NULL;

-- Запрос 5: Топ 3 актеров, которые больше всего появлялись в фильмах категории “Children”
WITH ranked_actors AS (
    SELECT 
        first_name,
        last_name,
        COUNT(film_id) AS countage,
        RANK() OVER (ORDER BY COUNT(film_id) DESC) AS film_count
    FROM 
        actor
    JOIN 
        film_actor USING (actor_id)
    JOIN 
        film_category USING (film_id)
    JOIN 
        category USING (category_id)
    WHERE 
        category.name = 'Children'
    GROUP BY 
        first_name, last_name
)
SELECT 
    CONCAT(first_name, ' ', last_name) AS actor_name,
    countage
FROM 
    ranked_actors
WHERE 
    film_count <= 3;

-- Запрос 6:Вывести топ 3 актеров, которые больше всего появлялись в фильмах в категории “Children”. 
SELECT 
    city,
    SUM(CASE WHEN active = 0 THEN 1 ELSE 0 END) AS non_active,
    SUM(CASE WHEN active = 1 THEN 1 ELSE 0 END) AS active
FROM 
    city
JOIN 
    address USING (city_id)
JOIN 
    customer USING (address_id)
GROUP BY 
    city
ORDER BY 
    non_active DESC;

-- Запрос 7:Вывести категорию фильмов, у которой самое большое кол-во часов суммарной аренды в городах 
-- и которые начинаются на букву “a”. + тоже самое с городами c "%-%"
WITH rentals_by_city AS (
    SELECT 
        f.title, 
        c.name AS category, 
        ci.city,
        SUM(f.length) AS total_hours_rented
    FROM 
        rental r
    JOIN 
        inventory AS i USING (inventory_id)
    JOIN 
        film AS f USING (film_id)
    JOIN 
        film_category USING (film_id)
    JOIN 
        category AS c USING (category_id)
    JOIN 
        customer AS cu USING (customer_id)
    JOIN 
        address AS a USING (address_id)
    JOIN 
        city AS ci USING (city_id)
    GROUP BY 
        f.title, c.name, ci.city
),
max_for_a_cities AS (
    SELECT 
        category,
        SUM(total_hours_rented) AS total_hours
    FROM 
        rentals_by_city
    WHERE 
        city LIKE 'a%'
    GROUP BY 
        category
    ORDER BY 
        total_hours DESC
    LIMIT 1
),
max_for_dash_cities AS (
    SELECT 
        category,
        SUM(total_hours_rented) AS total_hours
    FROM 
        rentals_by_city
    WHERE 
        city LIKE '%-%'
    GROUP BY 
        category
    ORDER BY 
        total_hours DESC
    LIMIT 1
)

SELECT 
    'Cities starting with a' AS condition,
    category,
    total_hours
FROM 
    max_for_a_cities
UNION
SELECT 
    'Cities containing -' AS condition,
    category,
    total_hours
FROM 
    max_for_dash_cities;
