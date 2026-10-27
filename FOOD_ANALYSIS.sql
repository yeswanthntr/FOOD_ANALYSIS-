use food;
select * from food limit 10;
select count(*) as total_orders from food;
select count(distinct(customer_id)) as unique_customers from food;
select count(distinct(restaurant_name)) as unique_resturants from food;
select distinct(cuisine_type) as cuisine from food;
SET SQL_SAFE_UPDATES = 0;
update food set rating= NULL where rating='Not given';
select * from food where rating is null;
select avg(cost_of_the_order) as avg_cost from food;
select min(cost_of_the_order) as min_cost,max(cost_of_the_order) as max_cost from food;
select sum(cost_of_the_order) as total_order_value from food;
select avg(delivery_time) as avg_time_delivery from food;
select avg(food_preparation_time) as avg_time from food;
select count(*) rating from food where rating is not null;
select count(*) rating from food where rating is null;
select day_of_the_week ,count(*)  as day from food group by day_of_the_week order by day desc;
select * from food where cost_of_the_order > 20;
select* from food where delivery_time >30;
select restaurant_name,count(distinct ﻿﻿order_id) as top from food group by restaurant_name order by top desc limit 10;
DESCRIBE food;
select cuisine_type,count('order_id') as counts from food group by cuisine_type order by counts desc;
select cuisine_type ,avg(cost_of_the_order) as avgs from food group by cuisine_type order by avgs desc;
-- Calculate total order value for each cuisine and rank it.
select cuisine_type,sum(cost_of_the_order) as total_order,rank() over(order by sum(cost_of_the_order)desc) as cuisine_rank from food
group by cuisine_type order by total_order desc;

-- Calculate average recorded rating for each cuisine.
select cuisine_type,avg(rating) as avg_rating from food group by cuisine_type order by avg_rating desc;

-- Find the 10 customers with the most orders
select customer_id,count('order_id') as top from food group by "ORDER_ID" limit 10;
-- Find the 10 customers with the most orders
SELECT
    customer_id,
    COUNT(DISTINCT 'order_id') AS total_orders
FROM food
GROUP BY customer_id
ORDER BY total_orders DESC
LIMIT 10;
-- Compare average delivery time across day categories.
SELECT DAY_OF_THE_WEEK,AVG(DELIVERY_TIME) AS AVGS FROM FOOD GROUP BY DAY_OF_THE_WEEK ORDER BY AVGS;

-- Find average food preparation time for each cuisine.
SELECT CUISINE_TYPE,AVG(FOOD_PREPARATION_TIME) AS AVGS FROM FOOD GROUP BY CUISINE_TYPE ORDER BY AVGS DESC;

-- Display orders costing more than the overall average order cost.

SELECT *
FROM food
WHERE cost_of_the_order > (
    SELECT AVG(cost_of_the_order)
    FROM food
);

-- Show restaurants with 20 or more orders
SELECT
    restaurant_name,
    COUNT(DISTINCT `﻿order_id`) AS total_orders
FROM food
GROUP BY restaurant_name
HAVING total_orders >= 20
ORDER BY total_orders DESC;

-- Calculate each cuisine's percentage of all orders.

-- Calculate each cuisine's percentage of all orders
SELECT
    cuisine_type,
    COUNT(DISTINCT `﻿order_id`) AS total_orders,
    ROUND(
        COUNT(DISTINCT `﻿order_id`) * 100.0 /
        (SELECT COUNT(DISTINCT `﻿order_id`) FROM food),
        2
    ) AS order_percentage
FROM food
GROUP BY cuisine_type
ORDER BY order_percentage DESC;


-- Count unrated orders for each cuisine
SELECT
    cuisine_type,
    COUNT(DISTINCT `﻿order_id`) AS unrated_orders
FROM food
WHERE rating IS NULL
   OR rating = 'Not given'
GROUP BY cuisine_type
ORDER BY unrated_orders DESC;

-- Count low ratings (1–2), medium ratings (3), and high ratings (4–5). Ignore NULL ratings.
-- Count low, medium, and high ratings
SELECT
    CASE
        WHEN CAST(rating AS UNSIGNED) IN (1, 2) THEN 'Low'
        WHEN CAST(rating AS UNSIGNED) = 3 THEN 'Medium'
        WHEN CAST(rating AS UNSIGNED) IN (4, 5) THEN 'High'
    END AS rating_category,
    COUNT(*) AS total_orders
FROM food
WHERE rating IS NOT NULL
  AND rating <> 'Not given'
GROUP BY rating_category
ORDER BY total_orders DESC;
SELECT
    COUNT(CASE WHEN rating IN ('1', '2') THEN 1 END) AS low_ratings,
    COUNT(CASE WHEN rating = '3' THEN 1 END) AS medium_ratings,
    COUNT(CASE WHEN rating IN ('4', '5') THEN 1 END) AS high_ratings
FROM food
WHERE rating IS NOT NULL
  AND rating <> 'Not given';
  -- Count orders in three groups: under $10, $10–$20 inclusive, and over $20.
  SELECT CASE 
  WHEN COST_OF_THE_ORDER < 10 THEN 'UNDER $10'
  WHEN COST_OF_THE_ORDER BETWEEN 10 AND 20 THEN '$10-$20 INCLUSIVE'
  WHEN COST_OF_THE_ORDER >20 THEN 'OVER $20 ' END 
  AS CATEGORY_GROUP ,COUNT(*) AS TOTAL_ORDERS FROM FOOD 
  GROUP BY CATEGORY_GROUP 
  ORDER BY MIN(COST_OF_THE_ORDER);
  
  
  
  -- For each restaurant, show order count, average order cost, and average rating.
  SELECT RESTAURANT_NAME,COUNT('ORDER_ID') AS ORDER_COUNT,ROUND(AVG(COST_OF_THE_ORDER),2) AS AVG_ORDER_COST,ROUND(AVG(RATING),2) AS AVG_RATING FROM FOOD 
  GROUP BY RESTAURANT_NAME ORDER BY ORDER_COUNT DESC;
  
  -- Show cuisines whose average order cost is greater than the overall average order cost.
  
-- Show cuisines with above-average order cost
SELECT
    cuisine_type,
    ROUND(AVG(cost_of_the_order), 2) AS avg_order_cost
FROM food
GROUP BY cuisine_type
HAVING AVG(cost_of_the_order) > (
    SELECT AVG(cost_of_the_order)
    FROM food
)
ORDER BY avg_order_cost DESC;
  --- Find the five customers with the highest total order value.
  SELECT DISTINCT(CUSTOMER_ID) ,ROUND(SUM(COST_OF_THE_ORDER),2) AS TOTAL_VALUE FROM FOOD GROUP BY CUSTOMER_ID ORDER BY TOTAL_VALUE DESC LIMIT 5;


-- Rank cuisines by total order count using a window function.
SELECT CUISINE_TYPE,COUNT('ORDER_ID') AS TOTAL,RANK()OVER(PARTITION BY CUISINE_TYPE) GROUP BY CUISINE_TYPE;
-- Rank cuisines by total order count using a window function
SELECT
    cuisine_type,
    COUNT(DISTINCT `﻿order_id`) AS total_orders,
    RANK() OVER (
        ORDER BY COUNT(DISTINCT `﻿order_id`) DESC
    ) AS cuisine_rank
FROM food
GROUP BY cuisine_type
ORDER BY cuisine_rank;

-- Find the restaurant with the most orders within each cuisine, using a window function.

SELECT RESTAURANT_NAME,CUISINE_TYPE,COUNT('ORDER_ID') MOST_ORDER ,RANK() OVER(ORDER BY COUNT("ORDER_ID")) AS MOST_ORDER
FROM FOOD GROUP BY CUISINE_TYPE ORDER BY MOST_ORDERS DESC;

-- Find the restaurant with the most orders within each cuisine
WITH restaurant_orders AS (
    SELECT
        restaurant_name,
        cuisine_type,
        COUNT(DISTINCT `﻿order_id`) AS total_orders
    FROM food
    GROUP BY restaurant_name, cuisine_type
),
ranked_restaurants AS (
    SELECT
        restaurant_name,
        cuisine_type,
        total_orders,
        RANK() OVER (
            PARTITION BY cuisine_type
            ORDER BY total_orders DESC
        ) AS restaurant_rank
    FROM restaurant_orders
)
SELECT
    restaurant_name,
    cuisine_type,
    total_orders,
    restaurant_rank
FROM ranked_restaurants
WHERE restaurant_rank = 1
ORDER BY cuisine_type;


--- Write one query returning total orders, unique customers, average order cost, total order value, average preparation time, average delivery time, and average recorded rating.
-- Overall Food Delivery Business KPIs
SELECT
    COUNT(DISTINCT `﻿order_id`) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers,
    ROUND(AVG(cost_of_the_order), 2) AS avg_order_cost,
    ROUND(SUM(cost_of_the_order), 2) AS total_order_value,
    ROUND(AVG(food_preparation_time), 2) AS avg_preparation_time,
    ROUND(AVG(delivery_time), 2) AS avg_delivery_time,
    ROUND(AVG(CAST(rating AS UNSIGNED)), 2) AS avg_recorded_rating
FROM food;