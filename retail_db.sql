use retail_events_db ;
show tables;
select*from data;
-- Query 1. Provide a list of products with a base price greater than 500 and that are featured in promo type of 'BOGOF' (Buy One Get One Free).
--  This information will help us identify high-value products that are currently being heavily discounted, 
-- which can be useful for evaluating our pricing and promotion strategies
SELECT 
    product_name,
    base_price,
    promo_type
FROM 
   data
WHERE 
    base_price > 500
    AND promo_type = 'BOGOF';
-- Query 2. Generate a report that provides an overview of the number of stores in each city. 
-- The results will be sorted in descending order of store counts, allowing us to identify the cities with the highest store presence. 
-- The report includes two essential fields: city and store count, 
-- which will assist in optimizing our retail operations.
SELECT 
    city,
    COUNT(*) AS store_count
FROM 
    stores
GROUP BY 
    city
ORDER BY 
    store_count DESC;
SELECT 
    campaign_name,
    ROUND(SUM(CASE WHEN start_date > '2024-01-10' THEN base_price * `quantity_sold(before_promo)` ELSE 0 END) / 1000000, 2) AS total_revenue_before_promotion,
    ROUND(SUM(CASE WHEN end_date < '2024-01-16' THEN base_price * `quantity_sold(after_promo)` ELSE 0 END) / 1000000, 2) AS total_revenue_after_promotion
FROM 
    data
WHERE 
    campaign_name = 'Sankranti'
GROUP BY 
    campaign_name
UNION ALL
SELECT
    campaign_name,
    ROUND(SUM(CASE WHEN start_date > '2023-11-12' THEN base_price * `quantity_sold(before_promo)` ELSE 0 END) / 1000000, 2) AS total_revenue_before_promotion,
    ROUND(SUM(CASE WHEN end_date < '2023-11-18' THEN base_price * `quantity_sold(after_promo)` ELSE 0 END) / 1000000, 2) AS total_revenue_after_promotion
FROM 
  data
WHERE 
    campaign_name = 'Diwali'
GROUP BY 
    campaign_name;


    -- Query 4.Produce a report that calculates the Incremental Sold Quantity (ISU%) for each category during the Diwali campaign. Additionally, provide rankings for the categories based on their ISU%.
    -- The report will include three key fields: category, isu%, and rank order. 
    -- This information will assist in assessing the category-wise success and impact of the Diwali campaign on incremental sales.
    
    SELECT 
	category,
    ROUND((SUM(CASE WHEN campaign_name = 'Diwali' THEN `quantity_sold(after_promo)` ELSE 0 END) / NULLIF(SUM(CASE WHEN campaign_name != 'Diwali' THEN `quantity_sold(after_promo)` ELSE 0 END), 0) - 1) * 100, 2) AS isu_percentage,
    RANK() OVER (ORDER BY (SUM(CASE WHEN campaign_name = 'Diwali' THEN `quantity_sold(after_promo)` ELSE 0 END) / NULLIF(SUM(CASE WHEN campaign_name != 'Diwali' THEN `quantity_sold(after_promo)` ELSE 0 END), 0) - 1) DESC) AS rank_order
FROM 
    data
GROUP BY 
    category;
-- Query 5.Create a report featuring the Top 5 products, ranked by Incremental Revenue Percentage (IR%), across all campaigns. The report will provide essential information including product name, category, and ir%. 
-- This analysis helps identify the most successful products in terms of incremental revenue across our campaigns, assisting in product optimization.
SELECT 
    product_name,
    category,
    ROUND(((SUM(CASE WHEN campaign_name = 'Diwali' THEN base_price * (`quantity_sold(after_promo)` - `quantity_sold(before_promo)`) ELSE 0 END) +
            SUM(CASE WHEN campaign_name != 'Diwali' THEN base_price * (`quantity_sold(after_promo)` - `quantity_sold(before_promo)`) ELSE 0 END)) /
           SUM(CASE WHEN campaign_name != 'Diwali' THEN base_price * `quantity_sold(before_promo)` ELSE 0 END)) * 100, 2) AS ir_percentage
FROM 
    data
GROUP BY 
    product_name,
    category
ORDER BY 
    ir_percentage DESC
LIMIT 5;
