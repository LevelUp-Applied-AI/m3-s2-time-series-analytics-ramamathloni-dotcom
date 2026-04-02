-- Combine SUM window functions with LAG to analyze Category Market Share Trends
WITH CategorySales AS (
    SELECT 
        DATE_TRUNC('month', o.order_date) as month,
        p.category,
        SUM(oi.quantity * oi.unit_price) as category_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY 1, 2
)
SELECT 
    month,
    category,
    category_revenue,
    -- Calculate Category Share of Total Monthly Revenue
    ROUND(category_revenue / SUM(category_revenue) OVER (PARTITION BY month) * 100, 2) as monthly_market_share_pct,
    -- Compare Category Revenue to Previous Month
    LAG(category_revenue) OVER (PARTITION BY category ORDER BY month) as prev_month_revenue,
    -- Running Total of Revenue per Category
    SUM(category_revenue) OVER (PARTITION BY category ORDER BY month) as running_total_revenue
FROM CategorySales
ORDER BY month, category_revenue DESC;