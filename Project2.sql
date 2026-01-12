SELECT * FROM public."Customer"
LIMIT 100
ALTER TABLE "Customer" RENAME TO customer;
--Q1: What is the total revenue generetaed by male vs female customers?
select gender, sum(purchase_amount) as revenue
from customer
group by gender;

--Q2: WHICH CUSTOMERS USED A DISCOUNT BUT STILL SPEND MORE THAN THE AVG PURCHANSE AMOUNT?
select customer_id, purchase_amount
from customer
where discount_applied='Yes' and purchase_amount>=(select avg(purchase_amount) from customer)

--Q3. Which are the top 5 products with the highest avg review rating?
select item_purchased, avg(review_rating) as Average_prodcut
from customer
group by 1 
order by 2 desc
limit 5

--Q4: COMPARE THE AVERAGE PURCHASE AMOUNTS BETWEEN STANDARD AND EXPRESS SHIPPING.
select shipping_type, avg(purchase_amount)
from customer
where shipping_type in ('Standard','Express')
group by 1

--Q5: Do subscribed customers spend more? Compare avg spend and total revenue between subscribers and non-subscribers.
select subscription_status, count(customer_id) as total_customers, avg(purchase_amount) as avg_spend,
sum(purchase_amount) as total_revenue
from customer
group by 1
order by total_revenue, avg_spend desc;

-- Q6: Which 5 products have the highest percentage of purchase with discounts applied?
select item_purchased, 
SUM(100*CASE WHEN discount_applied='Yes' then 1 else 0 end)/count(*) as discount_rate
from customer
group by 1
order by 2 desc
limit 5;

--Q7: Segement customers into new, returning, and loyal based on their total number of previous purchase 
-- and show the count of each segement.
with customer_type as 
( select previous_purchases,
case 
when previous_purchases = 1 then 'New'
when previous_purchases between 2 and 14 then 'Returning'
else 'Loyal'
end as customer_segement
from customer
)
select customer_segement, count(*) as "No of customers"
from customer_type
group by 1

--Q8: What are the top 3 most purchased products within each category?

with item_counts as (
select category, item_purchased, count(customer_id) as total_orders,
row_number() over(partition by category order by count(customer_id)desc) as item_rank
from customer
group by 1,2
)
select item_rank, category, item_purchased, total_orders
from item_counts
where item_rank<=3

--Q9: Are customers who are repeat buyers (more than 5 previous purchase) also like;y to subscribe?
select subscription_status, count(customer_id)
from customer
where previous_purchases>5
group by 1

--Q10: What is the revenue contribution of each age group
select age_group, sum(purchase_amount) as "Revenue"
from customer
group by 1
