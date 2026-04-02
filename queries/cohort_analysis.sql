-- Step 1: Define cohorts by the month of the first purchase
WITH FirstPurchases AS (
    SELECT 
        customer_id,
        MIN(order_date) as first_order_date,
        DATE_TRUNC('month', MIN(order_date)) as cohort_month
    FROM orders
    GROUP BY 1
),
-- Step 2: Calculate days between subsequent orders and the first purchase
RetentionData AS (
    SELECT 
        fp.cohort_month,
        o.customer_id,
        (o.order_date::date - fp.first_order_date::date) as days_diff
    FROM orders o
    JOIN FirstPurchases fp ON o.customer_id = fp.customer_id
)
-- Step 3: Aggregate metrics to show cohort size and retention percentages
SELECT 
    cohort_month,
    COUNT(DISTINCT customer_id) as cohort_size,
    ROUND(COUNT(DISTINCT CASE WHEN days_diff > 0 AND days_diff <= 30 THEN customer_id END) * 100.0 / COUNT(DISTINCT customer_id), 2) as retention_30d_pct,
    ROUND(COUNT(DISTINCT CASE WHEN days_diff > 30 AND days_diff <= 60 THEN customer_id END) * 100.0 / COUNT(DISTINCT customer_id), 2) as retention_60d_pct,
    ROUND(COUNT(DISTINCT CASE WHEN days_diff > 60 AND days_diff <= 90 THEN customer_id END) * 100.0 / COUNT(DISTINCT customer_id), 2) as retention_90d_pct
FROM RetentionData
GROUP BY 1
ORDER BY 1; 