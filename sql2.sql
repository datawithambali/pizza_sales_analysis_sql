SELECT count(*) FROM pizzahut.orders;

 --  Retrieve the total number of orders placed
 
select count(*) as total_orders from orders;


-- calculate the total revnue generated from pizza sales

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;
    
-- Identify the highest priced pizza 

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1 ;

-- Identify the most common size pizza ordered

  select pizzas.size,
  count(order_details.order_details_id) as order_count
  from pizzas join order_details
  on pizzas.pizza_id = order_details.pizza_id
  group by pizzas.size order by order_count desc;

-- List the top 5 most ordered pizza along with their quantities.

select pizza_types.name,
sum(order_details.quantity) as quantity
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by quantity desc limit 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY 2 DESC;

-- determine the distribution of orders by hour of the day

select hour(order_time) as hour ,count(order_id) as order_count from orders
group by 1 ;


-- join relevant tables to find the
-- category wise distribution of pizzas

select category, count(*) from pizza_types
group by category;

-- group the orders by date and calculate the average
-- number of pizzas ordered

SELECT 
    ROUND(AVG(quantity), 0) avg_pizza_perday
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS order_quantity; 

-- determine the top most ordered pizza types based on revenue

select pizza_types.name, sum(order_details.quantity* pizzas.price)
as revenue
from 
order_details join pizzas on order_details.pizza_id =pizzas.pizza_id
join pizza_types on pizzas.pizza_type_id = pizza_types.pizza_type_id
group by pizza_types.name
order by revenue desc 
limit 3;

-- calcualte the percentage contribution of each pizza type to revenue

SELECT 
    pizza_types.category,
    ROUND(SUM(order_details.quantity * pizzas.price)*100 / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2) AS total_sales
                FROM
                    order_details
                        JOIN
                    pizzas ON order_details.pizza_id = pizzas.pizza_id) ,
            2) AS revenuepercent
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenuepercent DESC;


-- analayse the cumulative revenue generated over time
with cte as(
select orders.order_date,
round(sum(order_details.quantity *pizzas.price),0) as totalSales from 
order_details join pizzas on order_details.pizza_id =pizzas.pizza_id
join orders on orders.order_id=order_details.order_id
group by orders.order_date)

select order_date, totalSales,
sum(totalSales) over (order by order_date) as cumulativeRevenue
from cte order by order_date;
 
-- another way subquery
select order_date,totalSales,
sum(totalSales) over( order by order_date) as cumRev from
(select orders.order_date,
round(sum(order_details.quantity *pizzas.price),0) as totalSales from 
order_details join pizzas on order_details.pizza_id =pizzas.pizza_id
join orders on orders.order_id=order_details.order_id
group by orders.order_date) sal;


-- Determine the top 3 most ordered pizza types based on revenue fro each pizza category
select category ,name,revenue ,rnk from
(select category ,name,revenue,
rank() over (partition by category order by revenue desc) as rnk from
(select pizza_types.category,pizza_types.name, sum(order_details.quantity*pizzas.price)as revenue
from pizza_types join pizzas on pizza_types.pizza_type_id =pizzas.pizza_type_id
join order_details on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category ,pizza_types.name) as a) as b
where rnk <=3
;