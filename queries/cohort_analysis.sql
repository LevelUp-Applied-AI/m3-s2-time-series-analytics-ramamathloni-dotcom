-- Using FIRST_VALUE window function to define cohorts
WITH FirstPurchases AS (
    SELECT 
        customer_id,
        order_date,
        FIRST_VALUE(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) as first_order_date
    FROM orders
),
Cohorts AS (
    SELECT 
        customer_id,
        first_order_date,
        DATE_TRUNC('month', first_order_date) as cohort_month
    FROM FirstPurchases
    GROUP BY 1, 2, 3
),
RetentionData AS (
    SELECT 
        c.cohort_month,
        o.customer_id,
        (o.order_date::date - c.first_order_date::date) as days_diff
    FROM orders o
    JOIN Cohorts c ON o.customer_id = c.customer_id
)
SELECT 
    cohort_month,
    COUNT(DISTINCT customer_id) as cohort_size,
    ROUND(COUNT(DISTINCT CASE WHEN days_diff > 0 AND days_diff <= 30 THEN customer_id END) * 100.0 / COUNT(DISTINCT customer_id), 2) as retention_30d_pct,
    ROUND(COUNT(DISTINCT CASE WHEN days_diff > 30 AND days_diff <= 60 THEN customer_id END) * 100.0 / COUNT(DISTINCT customer_id), 2) as retention_60d_pct,
    ROUND(COUNT(DISTINCT CASE WHEN days_diff > 60 AND days_diff <= 90 THEN customer_id END) * 100.0 / COUNT(DISTINCT customer_id), 2) as retention_90d_pct
FROM RetentionData
GROUP BY 1
ORDER BY 1;