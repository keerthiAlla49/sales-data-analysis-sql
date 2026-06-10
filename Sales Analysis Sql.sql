-- ====================================
-- SALES DATA ANALYSIS PROJECT
-- ====================================



-- ====================================
-- DATABASE CREATION
-- ====================================

CREATE DATABASE sales_analysis;
GO

USE sales_analysis;
GO



-- ====================================
-- TABLE CREATION
-- ====================================

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    city VARCHAR(50)
);


CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    category VARCHAR(50),
    price INT
);


CREATE TABLE order_details (
    order_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    quantity INT,
    order_date DATE,

    FOREIGN KEY (customer_id)
    REFERENCES customers(customer_id),

    FOREIGN KEY (product_id)
    REFERENCES products(product_id)
);




-- ====================================
-- INSERT DATA
-- ====================================

INSERT customers VALUES
(1,'Rahul','Hyderabad'),
(2,'Kiran','Bangalore'),
(3,'Divya','Chennai'),
(4,'Sneha','Mumbai'),
(5,'Amit','Hyderabad');


INSERT INTO products VALUES
(101,'Laptop','Electronics',50000),
(102,'Phone','Electronics',30000),
(103,'Head phones','Accessories',2000),
(104,'Key Board','Accessories',1500),
(105,'Monitor','Electronics',12000);


INSERT INTO order_details VALUES
(1001,1,101,1,'2025-01-10'),
(1002,2,102,2,'2025-01-12'),
(1003,3,103,3,'2025-02-01'),
(1004,1,104,2,'2025-02-10'),
(1005,4,105,1,'2025-03-05'),
(1006,5,101,1,'2025-03-18'),
(1007,2,103,2,'2025-04-01'),
(1008,3,102,1,'2025-04-12'),
(1009,4,101,1,'2025-04-15'),
(1010,1,105,2,'2025-05-01');



-- ====================================
-- BASIC ANALYSIS QUERIES
-- ====================================

-- How much total revenue did the company generate?
select sum(p.price*o.quantity) as total_revenue
from products p inner join order_details o
on p.product_id=o.product_id;


-- Which products sold the highest quantity?
select p.product_id, sum(o.quantity)as product_sold 
from products p inner join order_details o
on p.product_id=o.product_id
group by p.product_id 
order by product_sold desc;


-- Which customers spent the most money?
select c.customer_name,sum(p.price*o.quantity)as cust_total
from order_details o inner join products p
on o.product_id=p.product_id
join customers c
on c.customer_id=o.customer_id
group by c.customer_name;


-- Which month generated the highest revenue?
select datepart(MM,o.order_date),
sum(p.price*o.quantity)as highest_mnth
from order_details o inner join products p
on o.product_id=p.product_id
group by datepart(MM,o.order_date)


-- Which product category generated the highest revenue?
select p.category,sum(p.price*o.quantity)as product_high
from order_details o inner join products p
on o.product_id=p.product_id
group by p.category
order by product_high desc;


select * from customers;
select * from products;
select * from order_details;

-- ====================================
-- ADVANCED ANALYSIS QUERIES
-- ====================================


-- Rank products based on total revenue generated.
select p.product_id,sum(p.price*o.quantity)as total_sum,rank()over(order by sum(p.price*o.quantity) desc )as rnk
from products p join order_details o 
on p.product_id=o.product_id
group by p.product_id 


-- Rank customers based on total spending.
select c.customer_name,sum(p.price*o.quantity)as total_sum,dense_rank()over(order by sum(p.price*o.quantity) desc) as rnk
from products p join order_details o 
on p.product_id=o.product_id
join customers c
on c.customer_id=o.customer_id
group by c.customer_name
order by rnk desc;


-- Which products generated above-average revenue?
with product_revenue as(select p.product_name,sum(p.price*o.quantity)as total_sum
from products p join order_details o 
on p.product_id=o.product_id
group by p.product_name
)
select * from product_revenue
where total_sum>(select avg(total_sum)from product_revenue
);


-- How does cumulative revenue grow month by month?
WITH monthly_sales AS (
    SELECT DATEPART(MM, o.order_date) AS sales_month,
           SUM(p.price * o.quantity) AS revenue
    FROM products p
    JOIN order_details o
    ON p.product_id = o.product_id
    GROUP BY DATEPART(MM, o.order_date)
)
select sales_month,
       revenue,
       SUM(revenue) over(
           order by sales_month
       ) as running_total
from monthly_sales;


-- Which product sold the highest quantity?
select top 1 p.product_name,sum(o.quantity)as total_sales
from products p join order_details o
on p.product_id=o.product_id
group by p.product_name
order by total_sales desc ;



-- ====================================
-- BUSINESS INSIGHTS
-- ====================================

-- Electronics category generated highest revenue.
SELECT p.category,SUM(p.price*o.quantity)AS highest_revenue
FROM products p JOIN order_details o
ON p.product_id=o.product_id
WHERE p.category='electronics'
GROUP BY p.category;


-- Laptop was the top revenue-generating product.
SELECT p.product_name,SUM(p.price*o.quantity)AS top_revenue
FROM products p JOIN order_details o
ON p.product_id=o.product_id 
WHERE p.product_name='Laptop'
GROUP BY p.product_name


-- Rahul was the highest spending customer.
SELECT c.customer_name, SUM(p.price*o.quantity)as highest_spent,RANK()OVER(ORDER BY SUM(p.price*o.quantity)DESC)AS rnk
FROM products p JOIN order_details o 
ON p.product_id=o.product_id 
JOIN customers c 
ON c.customer_id=o.customer_id 
GROUP BY c.customer_name;


-- Sales increased significantly in April.
SELECT datepart(MM,o.order_date)as month,SUM(p.price*o.quantity)as high_sales
FROM products p JOIN order_details o 
ON p.product_id=o.product_id 
GROUP BY datepart(MM,o.order_date)
ORDER BY high_sales DESC;


-- Accessories category generated lower revenue compared to Electronics.
SELECT p.category,SUM(p.price*o.quantity)AS total_revenue FROM 
products p JOIN order_details o
on p.product_id=o.product_id
GROUP BY p.category;
