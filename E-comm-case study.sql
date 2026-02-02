-- E-commerece company

select * from customers;
select * from orderdetails;
select * from orders;
select * from products;

#TOP 3 LOCATION WITH highest number of customers 
select location, count(customer_id) as number_of_customers
from Customers
group by location 
order by number_of_customers desc
limit 3;

#As per the last query's result, Which of the cities must be focused as a part of marketing strategies?
#DELHI CHENNAI JAIPUR

-- Determine the distribution of customers by the number of orders placed. 
-- This insight will help in segmenting customers into one-time buyers, occasional shoppers, and regular customers for tailored marketing strategies.

WITH order_counts AS (
    SELECT
        customer_id,
        COUNT(order_id) AS order_count
    FROM orders
    GROUP BY customer_id
)
SELECT
    order_count AS NumberOfOrders,
    COUNT(customer_id) AS CustomerCount
FROM order_counts
GROUP BY order_count
ORDER BY NumberOfOrders ASC;

#As per the Engagement Depth Analysis question, What is the trend of the number of customers v/s number of orders?
# number or order increases count of customers decreases


#As per the Engagement Depth Analysis question, Which customers category does the company experiences the most?
#Occasional shopper
WITH order_counts AS (
    SELECT
        customer_id,
        COUNT(order_id) AS order_count
    FROM orders
    GROUP BY customer_id
)
SELECT 
    order_count AS NumberOfOrders,
    CASE
        WHEN order_count = 1 THEN 'One-time buyer'
        WHEN order_count BETWEEN 2 AND 4 THEN 'Occasional shopper'
        ELSE 'Regular customer'
    END AS CustomerType,
    COUNT(customer_id) AS CustomerCount
FROM
    order_counts
GROUP BY order_count
ORDER BY NumberOfOrders;

#Identify products where the average purchase quantity per order is 2 but with a high total revenue, suggesting premium product trends.
# product id 1 and 8
SELECT 
    product_id,
    AVG(quantity) AS AvgQuantity,
    SUM(quantity * price_per_unit) AS TotalRevenue
FROM
    OrderDetails
GROUP BY product_id
HAVING AVG(quantity) = 2
ORDER BY TotalRevenue DESC;

-- For each product category, calculate the unique number of customers purchasing from it. 
-- This will help understand which categories have wider appeal across the customer base.

SELECT 
    p.category,
    COUNT(DISTINCT o.customer_id) AS unique_customers
FROM
    Products p
        JOIN
    OrderDetails od ON p.product_id = od.product_id
        JOIN
    Orders o ON od.order_id = o.order_id
GROUP BY p.category
ORDER BY unique_customers DESC;

#Analyze the month-on-month percentage change in total sales to identify growth trends.

with sales as (select date_format(order_date, "%Y-%m") as Month,
sum(total_amount) as TotalSales,
lag(sum(total_amount))over( order by date_format(order_date, "%Y-%m")) as Previous_m
from Orders
group by Month
order by month)

SELECT 
    month,
    TotalSales,
    ROUND(((totalsales - Previous_m) / previous_m * 100),
            2) AS PercentChange
FROM
    sales

-- Examine how the average order value changes month-on-month. Insights can guide pricing and promotional strategies to enhance order value.

with avg as(
select date_format(order_date, "%Y-%m") as Month,
round(avg(total_amount),2)as AvgOrderValue,
lag(round(avg(total_amount),2) )over(order by date_format(order_date, "%Y-%m")) as previous_m
from orders
group by month )

SELECT 
    month,
    AvgOrderValue,
    ROUND((AvgOrderValue - previous_m), 2) AS ChangeInValue
FROM
    avg
ORDER BY ChangeInValue DESC;

-- Based on sales data, identify products with the fastest turnover rates, suggesting high demand and the need for frequent restocking.

SELECT 
    product_id, COUNT(product_id) AS Salesfrequency
FROM
    OrderDetails
GROUP BY product_id
ORDER BY Salesfrequency DESC
LIMIT 5
#sales frequecy means count of product id

#List products purchased by less than 40% of the customer base, indicating potential mismatches between inventory and customer interest.

WITH total_customers AS (
    SELECT COUNT(DISTINCT customer_id) AS total_cnt
    FROM Customers
),
product_customer_count AS (
    SELECT
        p.product_id,
        p.name,
        COUNT(DISTINCT o.customer_id) AS UniqueCustomerCount
    FROM Products p
    JOIN OrderDetails od ON p.product_id = od.product_id
    JOIN Orders o ON od.order_id = o.order_id
    GROUP BY p.product_id, p.name
)
SELECT
    pc.product_id,
    pc.name,
    pc.UniqueCustomerCount
FROM product_customer_count pc
CROSS JOIN total_customers tc
WHERE pc.UniqueCustomerCount < 0.4 * tc.total_cnt
ORDER BY pc.UniqueCustomerCount;


 -- Evaluate the month-on-month growth rate in the customer base to understand the effectiveness of marketing campaigns and market expansion efforts.

with cnt as(select customer_id, min(date_format(order_date, "%Y-%m")) as firstPurchaseMonth
from Orders
group by customer_id)

SELECT 
    firstPurchaseMonth, COUNT(customer_id) AS TotalNewCustomers
FROM
    cnt
GROUP BY firstPurchaseMonth
ORDER BY firstPurchaseMonth ASC

-- Identify the months with the highest sales volume, aiding in planning for stock levels, marketing efforts, and staffing in anticipation of peak demand periods.

SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS Month,
    SUM(total_amount) AS TotalSales
FROM
    Orders
GROUP BY Month
ORDER BY TotalSales DESC
LIMIT 3;