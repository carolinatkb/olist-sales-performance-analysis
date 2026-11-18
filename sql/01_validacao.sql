-- Status dos pedidos

    SELECT order_status, COUNT(*) AS pedidos
    FROM orders
    GROUP BY 1
    ORDER BY 2 DESC

-- Período coberto

    SELECT MIN(order_purchase_timestamp) AS primeiro_pedido,
           MAX(order_purchase_timestamp) AS ultimo_pedido
    FROM orders

-- Checagem de avaliações

          SELECT review_id,
           COUNT(*) AS linhas,
           COUNT(DISTINCT order_id) AS pedidos_distintos
    FROM order_reviews
    GROUP BY 1
    HAVING COUNT(*) > 1
    ORDER BY linhas DESC
    LIMIT 10

          SELECT COUNT(*) AS pedidos_com_mais_de_uma_avaliacao
    FROM (
        SELECT order_id
        FROM order_reviews
        GROUP BY 1
        HAVING COUNT(*) > 1

-- Criação da visão reviews por pedido

    CREATE OR REPLACE VIEW reviews_por_pedido AS
    SELECT * EXCLUDE (rn)
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY order_id
                   ORDER BY review_answer_timestamp DESC
               ) AS rn
        FROM order_reviews
    )
    WHERE rn = 1

    SELECT COUNT(*) AS linhas, COUNT(DISTINCT order_id) AS pedidos_distintos
    FROM reviews_por_pedido
