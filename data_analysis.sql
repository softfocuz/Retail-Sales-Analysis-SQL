CREATE DATABASE data_analysis;

CREATE TABLE retail_sales(
				transactions_id INT PRIMARY KEY,
				sale_date DATE,
				sale_time TIME,
				customer_id INT,
				gender VARCHAR(6),
				age INT,
				category VARCHAR(15),	
				quantity INT,	
				price_per_unit FLOAT,	
				cogs FLOAT,
				total_sale FLOAT
);

SELECT * FROM retail_sales
LIMIT 20;

SELECT
	COUNT(*)
FROM retail_sales; -- Total Rows: 2000

-- Checking NULL values
SELECT * FROM retail_sales
WHERE
	transactions_id IS NULL
	OR
	sale_date IS NULL
	OR 
	sale_time IS NULL
	OR
	customer_id IS NULL
	OR
	gender IS NULL
	OR
	age IS NULL
	OR 
	category IS NULL
	OR 
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR 
	cogs IS NULL
	OR
	total_sale IS NULL;
	
-- DATA CLEANING
-- Remove incomplete records (rows with missing values) 
DELETE FROM retail_sales
WHERE
	transactions_id IS NULL
	OR
	sale_date IS NULL
	OR 
	sale_time IS NULL
	OR
	customer_id IS NULL
	OR
	gender IS NULL
	OR
	age IS NULL
	OR 
	category IS NULL
	OR 
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR 
	cogs IS NULL
	OR
	total_sale IS NULL;

SELECT 
	COUNT(*)
FROM retail_sales; -- Total Rows: 1987

-- DATA EXPLORATION
-- Retrieve all columns for sales made on '2022-11-05'
SELECT * FROM retail_sales
WHERE sale_date = '2022-11-05';

-- What is the date range of sales?
SELECT
	MIN(sale_date) AS starting_range,
	MAX(sale_date) AS ending_range,
	CONCAT(MIN(sale_date), ' to ', MAX(sale_date)) AS date_range
FROM retail_sales;

-- What is the total revenue?
SELECT 
	SUM(total_sale) AS total_revenue
FROM retail_sales;
	
-- What is the average transaction value?
SELECT
	AVG(total_sale) AS avg_transaction_val
FROM retail_sales;

-- Which category generates the most revenue?
SELECT
	category,
	SUM(total_sale)
FROM retail_sales
GROUP BY category
ORDER BY 2 DESC
LIMIT 1;

-- Which age group spends the most?
SELECT
	CASE
		WHEN age < 20 THEN 'Teenager'
		WHEN age BETWEEN 20 AND 29 THEN 'Young Adult'
		WHEN age BETWEEN 30 AND 39 THEN 'Early Adult'
		WHEN age BETWEEN 40 AND 49 THEN 'Mid Adult'
		WHEN age BETWEEN 50 AND 59 THEN 'Late Adult'
		ELSE 'Senior'
	END AS age_group,
	SUM(total_sale) AS total_spend
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- What is the total quantity sold per category?
SELECT 
	category,
	SUM(quantity) AS total_quantity
FROM retail_sales
GROUP BY category;

-- What is the average price per unit by category?
SELECT
	category,
	AVG(price_per_unit) AS avg_price_per_unit
FROM retail_sales
GROUP BY category;
	
-- What is the profit margin by category?
SELECT
	category,
	SUM(total_sale) AS revenue,
	SUM(cogs) AS cost,
	(SUM(total_sale) - SUM(cogs)) / SUM(total_sale) * 100 AS profit_margin
FROM retail_sales
GROUP BY category
ORDER BY profit_margin DESC;
	
-- Calculate the total sales (total_sale) for each category
SELECT DISTINCT category FROM retail_sales; -- just to know all the different categories

-- Electronics
SELECT 
	category,
	SUM(total_sale) AS sum_total_sale
FROM retail_sales
WHERE category = 'Electronics'
GROUP BY category; -- Total sales for Electronics: 311,445

-- Clothing
SELECT 
	category,
	SUM(total_sale) AS sum_total_sale
FROM retail_sales
WHERE category = 'Clothing'
GROUP BY category; -- Total sales for Clothing: 309,995

-- Beauty 
SELECT 
	category,
	SUM(total_sale) AS sum_total_sale
FROM retail_sales
WHERE category = 'Beauty'
GROUP BY category;

-- Find the average age of customers who purchased items from the 'Beauty' category
SELECT
	category,
	AVG(age) AS customers_avg_age
FROM retail_sales
WHERE category = 'Beauty'
GROUP BY category; -- AVERAGE: ~40.42

-- Find all transactions where the total_sale is greater than 1000
SELECT
	transactions_id,
	total_sale
FROM retail_sales
WHERE total_sale > 1000;

-- Find the total number of transactions (transaction_id) made by each gender in each category
SELECT 
	gender,
	category,
	COUNT(transactions_id) AS total_transactions
FROM retail_sales
GROUP BY
	gender,
	category
ORDER BY 
	category,
	gender;
	
-- Calculate the average sale for each month. Find out best selling month in each year
--Average sale for each month
SELECT
	EXTRACT(YEAR FROM sale_date) AS year,
	EXTRACT(MONTH FROM sale_date) AS month,
	AVG(total_sale) AS avg_sale
FROM retail_sales
GROUP BY 1, 2
ORDER BY year ASC, month ASC;

-- Best selling month in each year
SELECT
	year,
	month, 
	avg_sale
FROM
(
	SELECT
		EXTRACT(YEAR FROM sale_date) AS year,
		EXTRACT(MONTH FROM sale_date) AS month,
		AVG(total_sale) AS avg_sale,
		RANK()OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) as rankk
	FROM retail_sales
	GROUP BY 1, 2
) as best_selling_month_tb
WHERE rankk = 1;

-- Find the top 5 customers based on the highest total sales
SELECT 
	customer_id,
	SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;

-- Find the number of unique customers who purchased items from each category
SELECT 
	category,
	COUNT(DISTINCT customer_id) AS unique_customer
FROM retail_sales
GROUP BY category;

-- Create each shift and number of orders (Morning <=12, Afternoon Between 12 & 17, Evening >17)
WITH hourly_sale
AS
(
	SELECT *,
		CASE
			WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
			WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
			ELSE 'Evening'
		END AS shift
	FROM retail_sales
)
SELECT
	shift,
	COUNT(*) as total_orders
FROM hourly_sale
GROUP BY shift;

-- END OF PROJECT



