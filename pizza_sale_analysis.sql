
/*Retrieve the total number of orders placed.*/
SELECT 
    COUNT(order_id)
FROM
    orders;

/*Calculate the total revenue generated from pizza sales.*/
SELECT 
    ROUND(SUM(order_detail.quantity * pizzas.price),
            2) AS Total_revenue
FROM
    order_detail
        JOIN
    pizzas ON order_detail.pizza_id = pizzas.pizza_id;

/*Identify the highest-priced pizza.*/

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT 
    pizzas.size,
    COUNT(order_detail.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_detail ON pizzas.pizza_id = order_detail.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name, sum(order_detail.quantity)
FROM
    order_detail
        JOIN
    pizzas ON order_detail.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.name
ORDER BY sum(order_detail.quantity) DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(order_detail.quantity) AS order_quantity
FROM
    order_detail
        JOIN
    pizzas ON order_detail.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.category
ORDER BY order_quantity DESC;

-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time), COUNT(order_id)
FROM
    orders
GROUP BY HOUR(order_time);

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;
-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity), 0)
FROM
    (SELECT 
        orders.order_date, SUM(order_detail.quantity) AS quantity
    FROM
        orders
    JOIN order_detail ON orders.order_id = order_detail.order_id
    GROUP BY orders.order_date) AS order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pizza_types.name,
    ROUND(SUM(order_detail.quantity * pizzas.price),
            0) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_detail ON pizzas.pizza_id = order_detail.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;


-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category,
    ROUND(SUM(order_detail.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_detail.quantity * pizzas.price),
                                2)
                FROM
                    order_detail
                        JOIN
                    pizzas ON order_detail.pizza_id = pizzas.pizza_id) * 100,
            0) AS revenue
FROM
    order_detail
        JOIN
    pizzas ON order_detail.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.category;

-- Analyze the cumulative revenue generated over time.
select order_date,round(sum(revenue) over(order by order_date),0) as cum_revenue
from
(select orders.order_date,
sum(order_detail.quantity*pizzas.price)as revenue
from order_detail
join orders 
on order_detail.order_id=orders.order_id
join pizzas 
on order_detail.pizza_id=pizzas.pizza_id
group by  orders.order_date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category,name,revenue
from
(select category,name,revenue,
rank() over(partition by category order by revenue) as rn
from
(select pizza_types.category,pizza_types.name,
sum(order_detail.quantity*pizzas.price) as revenue
from order_detail
join pizzas
on order_detail.pizza_id=pizzas.pizza_id
join pizza_types
on pizzas.pizza_type_id=pizza_types.pizza_type_id
group by pizza_types.category,pizza_types.name) as a) as b
where rn<=3;



























































