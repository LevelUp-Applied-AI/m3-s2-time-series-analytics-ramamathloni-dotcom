-- Use Window Frames to calculate 7-day and 30-day Moving Averages
WITH DailyData AS (
    SELECT 
        order_date::date as date,
        SUM(oi.quantity * oi.unit_price) as daily_revenue,
        COUNT(DISTINCT o.order_id) as daily_orders
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY 1
)
SELECT 
    date,
    daily_revenue,
    -- 7-Day Moving Average for Revenue
    ROUND(AVG(daily_revenue) OVER (ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) as moving_avg_rev_7d,
    -- 30-Day Moving Average for Revenue
    ROUND(AVG(daily_revenue) OVER (ORDER BY date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW), 2) as moving_avg_rev_30d,
    -- 7-Day Moving Average for Order Count
    ROUND(AVG(daily_orders) OVER (ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) as moving_avg_orders_7d
FROM DailyData;