SELECT * FROM customer LIMIT 5;

-- Q1: Revenue by gender
SELECT gender,
       SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY gender;

-- Q1b: Customers and average spend by gender
SELECT gender,
       COUNT(*) AS customers,
       ROUND(AVG(purchase_amount), 2) AS avg_spend
FROM customer
GROUP BY gender;

-- Q2: Revenue by age group
SELECT age_group,
       COUNT(*) AS customers,
       SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY age_group
ORDER BY total_revenue DESC;

-- Q3: Category performance
SELECT category,
       COUNT(*) AS orders,
       ROUND(AVG(purchase_amount), 2) AS avg_purchase,
       ROUND(AVG(review_rating)::numeric, 2) AS avg_rating
FROM customer
GROUP BY category
ORDER BY orders DESC;

-- Q4: Top 5 products by rating
SELECT item_purchased,
       ROUND(AVG(review_rating)::numeric, 2) AS avg_rating
FROM customer
GROUP BY item_purchased
ORDER BY avg_rating DESC
LIMIT 5;

-- Q5: Subscription impact
SELECT subscription_status,
       COUNT(*) AS customers,
       ROUND(AVG(purchase_amount), 2) AS avg_spend,
       SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY subscription_status;


SELECT DISTINCT discount_applied FROM customer;
SELECT MIN(previous_purchases), MAX(previous_purchases) FROM customer;

-- Q6: Customers who used a discount and spent above the average purchase
SELECT customer_id,
       purchase_amount
FROM customer
WHERE discount_applied = 'Yes'
  AND purchase_amount >= (SELECT AVG(purchase_amount) FROM customer)
ORDER BY purchase_amount DESC;

-- Q7: Top 5 products by share of purchases made with a discount
SELECT item_purchased,
       ROUND(100.0 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END)
             / COUNT(*), 2) AS discount_rate
FROM customer
GROUP BY item_purchased
ORDER BY discount_rate DESC
LIMIT 5;

-- Q7b: Overall discount rate (baseline for Q7)
SELECT ROUND(100.0 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END)
       / COUNT(*), 2) AS overall_discount_rate
FROM customer;

-- Q8: Customer segments based on previous purchases
WITH customer_type AS (
    SELECT customer_id,
           previous_purchases,
           CASE
               WHEN previous_purchases = 1 THEN 'New'
               WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
               ELSE 'Loyal'
           END AS customer_segment
    FROM customer
)
SELECT customer_segment,
       COUNT(*) AS number_of_customers
FROM customer_type
GROUP BY customer_segment;

-- Q9: Top 3 best-selling products per category
WITH item_counts AS (
    SELECT category,
           item_purchased,
           COUNT(customer_id) AS total_orders,
           ROW_NUMBER() OVER (
               PARTITION BY category
               ORDER BY COUNT(customer_id) DESC
           ) AS item_rank
    FROM customer
    GROUP BY category, item_purchased
)
SELECT item_rank,
       category,
       item_purchased,
       total_orders
FROM item_counts
WHERE item_rank <= 3;

