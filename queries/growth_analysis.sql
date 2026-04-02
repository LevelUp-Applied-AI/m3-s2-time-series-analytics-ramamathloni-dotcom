-- Calculate monthly revenue and volume growth using LAG
WITH MonthlyMetrics AS (
    SELECT 
        DATE_TRUNC('month', o.order_date) as month,
        SUM(oi.quantity * oi.unit_price) as revenue,
        COUNT(DISTINCT o.order_id) as order_volume
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY 1
)
SELECT 
    month,
    revenue,
    -- Month-over-Month Revenue Growth
    ROUND((revenue - LAG(revenue) OVER (ORDER BY month)) / LAG(revenue) OVER (ORDER BY month) * 100, 2) as mom_revenue_growth_pct,
    order_volume,
    -- Month-over-Month Order Volume Growth
    ROUND((order_volume - LAG(order_volume) OVER (ORDER BY month))::numeric / LAG(order_volume) OVER (ORDER BY month) * 100, 2) as mom_volume_growth_pct
FROM MonthlyMetrics;