select*from customer limit 20
-- total revenue genertaed by male vs female customer
SELECT "Gender",
       SUM("Purchase Amount (USD)") AS revenue
FROM customer
GROUP BY "Gender";
-- discount but still spend more than the avg purchases amount
select Customer ID,Purchase Amount(USD)
from customer
where Discount Applied= "Yes" and Purchase Amount(USD) >= (select AVG(Purchase Amount(USD) from customer ));
-- top 5 product with highest avg review rating
select "Item Purchased",round(avg("Review Rating")::numeric,2)
from customer
group by "Item Purchased" 
order by avg("Review Rating") desc
limit 5;
-- compare the avg purchased amount between standard and express shipping
select "Shipping Type", avg("Purchase Amount (USD)")
from customer
where "Shipping Type" in ('Standard','Express')
group by "Shipping Type";
-- subcribe customer spend more compare avg spend and total revenue between subscribe and non subscribe
select "Subscription Status",count("Customer ID"),
round(avg("Purchase Amount (USD)"::numeric),2)as avg_purchase,
round(sum("Purchase Amount (USD)"::numeric),2)as total_spend
from customer
group by "Subscription Status"
order by avg_purchase,total_spend
-- 5 product have the higest percentage of purchase with discount applied
select "Item Purchased",
round(100.0*sum(case when "Discount Applied" = 'Yes' then 1 else 0 end)/count(*)),2 as discount_rate
from customer
group by "Item Purchased"
order by discount_rate desc
limit 5;
--segment customer into new 
with customer_type as(
select "Customer ID", "Previous Purchases",
case 
when "Previous Purchases" = 1 then 'new'
when "Previous Purchases" between 2 and 10 then 'returning'
else 'loyal'
end as customer_segment
from customer
)
select customer_segment, count(*) as "number of customer"
from customer_type
group by customer_segment;
-- 
with item_count as(
select "Category",
"Item Purchased",
count("Customer ID") as total_orders,
row_number() over(partition by "Category" order by count("Customer ID")desc)
as item_rank
from customer
group by "Category", "Item Purchased"
)
select item_rank, "Category","Item Purchased",total_orders
from item_count
where item_rank <= 3;
--Are customer who are repeat buyers (more than 5 previous purchases) also likely to subcribe ?
select "Subscription Status",count("Customer ID") as repeat_buyers
from customer
where
