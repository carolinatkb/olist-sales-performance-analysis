-- Receita por estado

    SELECT c.customer_state AS estado,
           COUNT(DISTINCT o.order_id) AS pedidos,
           ROUND(SUM(oi.price), 2) AS receita,
           ROUND(100.0 * SUM(oi.price) / SUM(SUM(oi.price)) OVER (), 1) AS pct_receita,
           ROUND(SUM(oi.price) / COUNT(DISTINCT o.order_id), 2) AS receita_por_pedido
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN customers c    ON c.customer_id = o.customer_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
      AND o.order_purchase_timestamp >= '2017-01-01'
      AND o.order_purchase_timestamp <  '2018-09-01'
    GROUP BY 1
    ORDER BY receita DESC
    LIMIT 10

-- Prazo de entrega e atrasos por estado

    SELECT c.customer_state AS estado,
           COUNT(*) AS pedidos_entregues,
           ROUND(AVG((epoch(o.order_delivered_customer_date)
                    - epoch(o.order_purchase_timestamp)) / 86400.0), 1) AS dias_ate_entrega,
           ROUND(100.0 * AVG(CASE WHEN o.order_delivered_customer_date
                                       > o.order_estimated_delivery_date
                                  THEN 1 ELSE 0 END), 1) AS pct_atrasados
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_purchase_timestamp >= '2017-01-01'
      AND o.order_purchase_timestamp <  '2018-09-01'
    GROUP BY 1
    HAVING COUNT(*) >= 100
    ORDER BY dias_ate_entrega DESC

-- Atraso a nota de avaliação

    SELECT CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
                THEN 'atrasado' ELSE 'no_prazo' END AS entrega,
           COUNT(*) AS pedidos,
           ROUND(AVG(r.review_score), 2) AS nota_media
    FROM orders o
    JOIN reviews_por_pedido r ON r.order_id = o.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_purchase_timestamp >= '2017-01-01'
      AND o.order_purchase_timestamp <  '2018-09-01'
    GROUP BY 1
