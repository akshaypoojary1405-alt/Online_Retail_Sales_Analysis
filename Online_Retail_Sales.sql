create database online_retail_db;
use online_retail_db;
select * from online_retail_tb;
select count(*) from online_retail_tb;
describe online_retail_tb;
alter table online_retail_tb modify column customer_id varchar(20);
alter table online_retail_tb modify column invoice_no varchar(20);
select round(sum(sales),2) as total_sales 
from online_retail_tb;
select sum(quantity) as total_quantity
from online_retail_tb;
select count(distinct customer_id) as unique_customers
from online_retail_tb;
select count(distinct invoice_no) as total_orders
from online_retail_tb;
select round(sum(sales)/count(distinct invoice_no),2) as avg_order_value
from online_retail_tb ;
select stock_code,
description,
sum(quantity) as total_quantity_sold,
round(sum(sales),2) as total_sales
from online_retail_tb 
group by 1,2 order by 3 desc               
limit 10;
select country,
round(sum(sales),2) as total_sales,
count(distinct invoice_no) as total_orders
from online_retail_tb 
group by 1 order by 2 desc
limit 10;
select date_format(str_to_date (invoice_date,'%c/%e/%Y  %k:%i'),'%Y-%m') as sales_month,
round(sum(sales),2) as monthly_sales
from online_retail_tb 
group by 1 order by 1;
select invoice_date from online_retail_tb limit 10;
select invoice_date,
str_to_date(invoice_date,'%c/%e/%Y %k:%i') as coverted_date
from online_retail_tb 
limit 10;
select customer_id,
round(sum(sales),2) as total_sales,
count(distinct invoice_no) as total_orders
from online_retail_tb 
where customer_id is not null
group by 1 order by 2 desc
limit 10;
select count(*) as cancelled_transaction,
round(sum(sales),2) as cancellation_value
from online_retail_tb 
where invoice_no like 'c%';
select round(sum(sales),2) as net_sales,
round(sum(case when invoice_no not like 'c%' then sales else 0 end),2) as sales_excluding_cancellations
from online_retail_tb;
select country,
round(sum(sales),2) as total_sales,
count(distinct invoice_no) as total_orders
from online_retail_tb 
where invoice_no not like 'c%'
group by 1 order by 2 desc
limit 10;
select case when total_orders =1 then 'one-time customer' else 'repeat customer' end as customer_type,
count(*) as number_of_customers 
from (select customer_id,
count( distinct invoice_no) as total_orders
from online_retail_tb
where customer_id is not null and invoice_no not like '%c'
group by 1) as customer_summary
group by customer_type;
select round(avg(total_orders),2) as avg_orders_per_customer 
from (select customer_id,
count(distinct(invoice_no)) as total_orders
from online_retail_tb 
where customer_id is not null and invoice_no not like 'c%'
group by 1)as customer_summary;
select date_format(str_to_date(invoice_date,'%c/%e/%Y %k:%i'),'%Y-%m') as sales_month,
count(distinct invoice_no) as total_orders
from online_retail_tb 
where invoice_no not like 'c%'
group by 1 order by 1;
select country,
round(sum(sales)/count(distinct invoice_no),2) as average_order_value
from online_retail_tb where invoice_no not like 'c%'
group by 1
having count(distinct invoice_no) >0
order by 2 desc
limit 10;
select dayname(str_to_date(invoice_date,'%c/%e/%Y %k:%i')) as day_name,
round(sum(sales),2) as total_sales
from online_retail_tb  
where invoice_no not like 'c%'
group by 
dayofweek(str_to_date(invoice_date,'%c/%e/%Y %k:%i')),
dayname(str_to_date(invoice_date,'%c/%e/%Y %k:%I'))
order by total_sales desc;
select case when order_value <100 then 'Small Order'
when order_value < 500 then 'Medium Order' else 'Large Order' end as order_category,
count(*) as total_orders,
round(sum(order_value),2) as total_sales 
from(
      select 
      invoice_no,
      sum(sales) as order_value
      from online_retail_tb 
      where invoice_no not like 'c%'
      group by invoice_no 
      )as orders
group by order_category
order by total_sales desc;
select country,
count(distinct invoice_no) as total_orders,
count(distinct customer_id) as unique_customers,
round(sum(sales),2) as total_sales
from online_retail_tb 
where invoice_no not like 'c%'
group by 1
order by total_orders desc
limit 10;
select customer_id,
count(distinct invoice_no) as total_orders,
round(sum(sales),2) as total_spending
from online_retail_tb  
where nullif(trim(customer_id),'') is not null and invoice_no not like 'c%'
group by 1 
order by 3 desc
limit 10;
select hour(str_to_date(invoice_date,'%c/%e/%Y %k:%i')) as order_hour,
count(distinct invoice_no) as total_orders,
round(sum(sales),2) as total_sales
from online_retail_tb  
where invoice_no not like 'c%'
group by 1
order by 3 desc;
select stock_code,
description,
abs(sum(quantity)) as total_returned_quantity,
round(abs(sum(sales)),2) as return_value
from online_retail_tb 
where quantity < 0
group by 1,2
order by 3 desc
limit 10;
 with customer_orders as 
 (select 
 customer_id,
 count(distinct invoice_no) as total_orders,
 round(sum(sales),2) as total_spending
 from online_retail_tb
 where invoice_no not like 'c%'
 group by 1
 )
 select 
     case when total_orders = 1 then 'One-Time Customer' else 'Repeat Customer' end as customer_type,
     count(*) as total_customers,
     round(sum(total_spending),2) as total_revenue
     from customer_orders
     group by  1;
 with customer_months as (
 select distinct customer_id,
 date_format(str_to_date( invoice_date,'%c/%e/%Y %k:%i'),'%Y-%m') as purchase_month
 from online_retail_tb 
 where customer_id is not null and invoice_no not like '%c'
 )
 select customer_id,
 count(distinct purchase_month) as active_months
 from customer_months
 group by 1
 having count(distinct purchase_month) > 1 
 order by 2 desc
 limit 10;
 with customer_months as (
 select distinct customer_id,
 date_format(str_to_date(invoice_date,'%c/%e/%Y %k:%i'),'%Y-%m') as purchase_month
 from online_retail_tb 
 where customer_id is not null and trim(customer_id)<> '' and invoice_no not like '%c' 
 ),
 customer_retention as (
 select customer_id,
 count(distinct purchase_month) as active_months
 from customer_months 
 group by  1
 )
 select active_months,
 count(*) as total_customers
 from customer_retention 
 group by 1
 order by 1;
 with customer_spending as (
 select customer_id,
 round(sum(sales),2) as total_spending
 from online_retail_tb 
 where customer_id is not null and trim(customer_id)<> '' and invoice_no not like '%c'
 group by 1
 )
 select customer_id,
 total_spending,
 rank() over (order by total_spending desc) as customer_rank,
 dense_rank() over (order by total_spending desc) as dense_customer
 from customer_spending
 order by 2 desc
 limit 10;
 select count(*) as total_rows,
 count(distinct invoice_no) as total_invoices,
 count(distinct customer_id) as unique_customers
 from  online_retail_tb ;
 
