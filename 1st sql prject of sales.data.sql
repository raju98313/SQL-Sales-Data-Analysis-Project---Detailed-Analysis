create database e_commerce;
  
drop database e_commerce;
  
create database sales;
use sales;

  
select * from sales.data;

# select function 
select InvoiceNo, StockCode, Description, Quantity, UnitPrice, Country 
from sales.data;

-- Shows basic sales info (InvoiceNo, Description, Quantity, and Price).
SELECT InvoiceNo, Description, Quantity, UnitPrice
FROM sales.data;

-- Returns only records from UK customers.
select country
from sales.data
where country = "United Kingdom";

  
-- Shows most expensive products first.
select  Description, unitprice
from sales.data
order by UnitPrice  desc;

-- Displays which country bought the most items.
select country, sum(quantity) as total_quantity
from sales.data
group by country
order by total_quantity desc;


-- Find top 5 countries by total sales value.
select country, sum(quantity * unitprice) as total_sales 
from sales.data
group by country
order by total_sales desc
limit 5;

## joins 

 
CREATE TABLE customers_info (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    Email VARCHAR(100),
    LoyaltyLevel VARCHAR(20)
);

INSERT INTO customers_info (CustomerID, CustomerName, Email, LoyaltyLevel)
VALUES
(12568, 'Diana Patel', 'diana.patel@example.com', 'Silver'),
(12569, 'Ethan Wright', 'ethan.wright@example.com', 'Gold'),
(12570, 'Fatima Khan', 'fatima.khan@example.com', 'Bronze'),
(12571, 'George Liu', 'george.liu@example.com', 'Silver'),
(12572, 'Hannah Mehta', 'hannah.mehta@example.com', 'Gold'),
(12573, 'Isaac Roy', 'isaac.roy@example.com', 'Bronze'),
(12574, 'Jasmine Kaur', 'jasmine.kaur@example.com', 'Silver'),
(12575, 'Karan Desai', 'karan.desai@example.com', 'Gold'),
(12576, 'Lily Thomas', 'lily.thomas@example.com', 'Bronze'),
(12577, 'Mohit Verma', 'mohit.verma@example.com', 'Silver'),
(12578, 'Nina D’Souza', 'nina.dsouza@example.com', 'Gold'),
(12579, 'Omar Sheikh', 'omar.sheikh@example.com', 'Bronze'),
(12580, 'Priya Nair', 'priya.nair@example.com', 'Silver'),
(12581, 'Rahul Sharma', 'rahul.sharma@example.com', 'Gold'),
(12582, 'Sneha Reddy', 'sneha.reddy@example.com', 'Bronze'),
(12583, 'Tanvi Joshi', 'tanvi.joshi@example.com', 'Silver'),
(12584, 'Vikram Singh', 'vikram.singh@example.com', 'Gold');-- Not in sales table

select * from customers_info;

## inner join 
SELECT s.InvoiceNo, s.Description, c.CustomerName, c.LoyaltyLevel
FROM sales.data s
INNER JOIN customers_info c ON s.CustomerID = c.CustomerID;

## left join
SELECT s.InvoiceNo, s.Description, c.CustomerName, c.LoyaltyLevel
FROM sales.data s
LEFT JOIN customers_info c ON s.CustomerID = c.CustomerID;

# right join
SELECT s.InvoiceNo, s.Description, c.CustomerName, c.LoyaltyLevel
FROM sales.data s
RIGHT JOIN customers_info c ON s.CustomerID = c.CustomerID;


## subquaries 
-- 1. Find customers who made purchases above the average unit price
select customerId, description, unitprice
from sales.data
where unitprice > ( select avg(unitprice) from sales.data);

-- 2. get the names and emils of custmoers who made purchase 
select customername, email
from customers_info 
where customerId in ( select distinct customerid from sales.data);

-- 3. Find products with quantity greater than the average quantity sold
select description, quantity
from sales.data
where Quantity > ( select avg(quantity) from sales.data);

-- 4 show  invoice with total value greater then 50
select invoiceno , customerid
from sales.data
where invoiceno in ( 
	 select invoiceno 
	 from sales.data
     group by InvoiceNo
     having sum(UnitPrice * quantity) >50);
     
     
-- 5. List countries where customers have made more than 2 purchases
select distinct country
from sales.data
where customerid in (
       select customerid
       from sales.data
       group by customerid
       having count(*) > 2);
       
       
       
-- bouns find cusmtomer who have not made any purchase
select customername, email
from customers_info 
where customerId not in ( select distinct customerid from sales.data);


-- total sales values 
select sum(unitprice * quantity) as total_sales_values
from sales.data;

-- average quantity sold per product 
select description, avg(quantity) as avg_quantity_sold
from sales.data
group by Description;

-- total sales per invoice
select invoiceno,  sum(unitprice * quantity) as totalinvoice
from sales.data
group by invoiceno;

-- average spending per customer 
select customerid, avg(unitprice * quantity) as avgspending
from sales.data
group by CustomerID;

-- total sales by country 
select country, sum(unitprice * quantity) as countrysales
from sales.data
group by country;

-- average unit price per across all the products
select avg(unitprice) as averageunitprice
from sales.data;

-- bonus top 3 customers by total spendings
select customerid, sum(unitprice * quantity) as totalspent
from sales.data
group by customerid
order by customerid desc
limit 3;


-- 1.view total sales per customer 
create view total_sales_per_customer as 
select customerid, sum(unitprice * quantity) as totalspent
from sales.data
group by customerid;

-- 2.view average qauntity sold per product 
create view avg_quantity_per_product as
select description, avg(quantity) as avgquantity
from sales.data
group by Description;

-- 3.view invoice summary  with the total value
CREATE VIEW view_invoice_summary AS
SELECT InvoiceNo, CustomerID, SUM(UnitPrice * Quantity) AS InvoiceTotal
FROM sales
GROUP BY InvoiceNo, CustomerID;


-- 4.view country level sales perfromance
CREATE VIEW view_country_sales AS
SELECT Country, SUM(UnitPrice * Quantity) AS CountrySales
FROM sales
GROUP BY Country;

-- 5.view customer purchase detail with loyalty info
CREATE VIEW view_customer_purchase_loyalty AS
SELECT 
    s.CustomerID,
    c.CustomerName,
    c.LoyaltyLevel,
    SUM(s.UnitPrice * s.Quantity) AS TotalSpent,
    COUNT(DISTINCT s.InvoiceNo) AS TotalInvoices
FROM sales s
JOIN customers_info c ON s.CustomerID = c.CustomerID
GROUP BY s.CustomerID, c.CustomerName, c.LoyaltyLevel;

-- bonus view customers without purchase 
CREATE VIEW view_customers_without_sales AS
SELECT CustomerID, CustomerName, Email, LoyaltyLevel
FROM customers_info
WHERE CustomerID NOT IN (
    SELECT DISTINCT CustomerID FROM sales
);


##Optimize queries with indexes

-- 1 add index on customerid
CREATE INDEX idx_sales_customer_id ON sales(CustomerID);
CREATE INDEX idx_customers_info_customer_id ON customers_info(CustomerID);

-- 2 add index on invoice 
CREATE INDEX idx_sales_invoice_no ON sales(InvoiceNo);


-- 3 add index on invoicedate
CREATE INDEX idx_sales_invoice_date ON sales(InvoiceDate);

-- 4 add composite index on frequant joint + filter combo
CREATE INDEX idx_sales_customer_country ON sales(CustomerID, Country);

-- 5 add index on description
CREATE INDEX idx_sales_description ON sales(Description);

-- you can analyze query performance using
EXPLAIN SELECT * FROM sales WHERE CustomerID = 17850;

-- This shows whether MySQL is using your index or doing a full table scan.