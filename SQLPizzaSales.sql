-- Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS Total_Orders
FROM
    Orders;


-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS Total_Revenue
FROM
    orders_details
        JOIN
    pizzas ON orders_details.pizza_id = pizzas.pizza_id;


-- Identify the highest-priced pizza.

SELECT 
    pizza_types.name as Highest_Price_Pizza, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;


-- Identify the most common pizza size ordered.

SELECT 
    pizzas.size AS Most_Common_Pizza_Size,
    SUM(orders_details.quantity) AS Total_Orders
FROM
    pizzas
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size
ORDER BY SUM(orders_details.quantity) DESC
LIMIT 1;


-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name AS Most_Ordered_Pizzas,
    SUM(orders_details.quantity) AS Overall_Quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizza_types.name
ORDER BY SUM(orders_details.quantity) DESC
LIMIT 5;


-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(orders_details.quantity) AS Total_QTY
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizza_types.category
ORDER BY Total_QTY DESC


-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(orders.order_time) as Hour, COUNT(orders.order_id) as Distribution
FROM
    orders
GROUP BY HOUR(orders.order_time)
order by distribution


-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    Category, COUNT(name) Pizza
FROM
    pizza_types
GROUP BY category;


-- Group the orders by date and calculate the average number of pizzas ordered per day.

WITH Order_QTY as (SELECT 
    orders.order_date, SUM(orders_details.quantity) AS QTY
FROM
    orders
        JOIN
    orders_details ON orders.order_id = orders_details.order_id
GROUP BY orders.order_date)

SELECT 
    ROUND(AVG(QTY), 0) AS AVG_Orders_Per_Day
FROM
    Order_QTY


-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.Name,
    ROUND(SUM(orders_details.quantity * pizzas.price), 2) AS Total_Revenue
FROM
    orders_details
    JOIN pizzas ON orders_details.pizza_id = pizzas.pizza_id
    JOIN pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY 
    pizza_types.name
ORDER BY 
    Total_Revenue DESC
LIMIT 3;



-- Calculate the percentage contribution of each pizza category to total revenue.

with A as (SELECT 
                    SUM(orders_details.quantity * pizzas.price) as Total_Revenue
                FROM
                    orders_details
                        JOIN
                    pizzas ON orders_details.pizza_id = pizzas.pizza_id)

SELECT 
    pizza_types.category,
    ROUND(SUM(orders_details.quantity * pizzas.price) * 100 /(select Total_Revenue from A),2) AS 'Revenue in %'
FROM
    orders_details
        JOIN
    pizzas ON orders_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.category
ORDER BY 'Revenue in %' DESC


-- Analyze the cumulative revenue generated over time.

SELECT 
    order_date, 
    SUM(Revenue) OVER (ORDER BY order_date) AS cumulative_revenue
FROM (
    SELECT 
        orders.order_date,
        SUM(orders_details.quantity * pizzas.price) AS Revenue
    FROM
        orders_details
        JOIN pizzas ON orders_details.pizza_id = pizzas.pizza_id
        JOIN orders ON orders.order_id = orders_details.order_id
    GROUP BY 
        orders.order_date
) AS sales;



-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT 
    Category, 
    Name, 
    Revenue 
FROM (
    SELECT 
        category, 
        name, 
        Revenue, 
        RANK() OVER (PARTITION BY category 
        ORDER BY Revenue DESC) AS Ranking 
    FROM (
        SELECT 
            pizza_types.category, 
            pizza_types.name, 
            SUM(orders_details.quantity 
            * pizzas.price) AS Revenue 
        FROM 
            pizzas 
            JOIN orders_details ON pizzas.pizza_id = orders_details.pizza_id 
            JOIN pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id 
        GROUP BY 
            pizza_types.category, 
            pizza_types.name 
        ORDER BY 
            pizza_types.category, 
            Revenue DESC
    ) AS A
) AS B WHERE Ranking <= 3;
