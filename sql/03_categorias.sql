-- Categorias com participação

    WITH receita_categoria AS (
        SELECT COALESCE(t.product_category_name_english,
                        p.product_category_name,
                        'sem_categoria') AS categoria,
               COUNT(DISTINCT o.order_id) AS pedidos,
               SUM(oi.price) AS receita
        FROM orders o
        JOIN order_items oi ON oi.order_id = o.order_id
        JOIN products p ON p.product_id = oi.product_id
        LEFT JOIN category_translation t
               ON t.product_category_name = p.product_category_name
        WHERE o.order_status NOT IN ('canceled', 'unavailable')
          AND o.order_purchase_timestamp >= '2017-01-01'
          AND o.order_purchase_timestamp <  '2018-09-01'
        GROUP BY 1
    )
    SELECT categoria,
           pedidos,
           ROUND(receita, 2) AS receita,
           ROUND(100.0 * receita / SUM(receita) OVER (), 1) AS pct_receita,
           ROUND(100.0 * SUM(receita) OVER (
                    ORDER BY receita DESC
                    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
                 / SUM(receita) OVER (), 1) AS pct_acumulado
    FROM receita_categoria
    ORDER BY receita DESC
    LIMIT 15
