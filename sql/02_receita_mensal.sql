--RECEITA MENSAL

    WITH receita_mensal AS (
        SELECT date_trunc('month', o.order_purchase_timestamp) AS mes,
               COUNT(DISTINCT o.order_id) AS pedidos,
               SUM(oi.price) AS receita
        FROM orders o
        JOIN order_items oi ON oi.order_id = o.order_id
        WHERE o.order_status NOT IN ('canceled', 'unavailable')
          AND o.order_purchase_timestamp >= '2017-01-01'
          AND o.order_purchase_timestamp <  '2018-09-01'
        GROUP BY 1
    ),
    com_variacoes AS (
        SELECT mes, pedidos, receita,
               receita / pedidos AS ticket_medio,
               100.0 * (receita / LAG(receita, 1)  OVER (ORDER BY mes) - 1) AS var_mensal_pct,
               100.0 * (receita / LAG(receita, 12) OVER (ORDER BY mes) - 1) AS var_anual_pct
        FROM receita_mensal
    )
    SELECT mes, pedidos,
           ROUND(receita, 2)        AS receita,
           ROUND(ticket_medio, 2)   AS ticket_medio,
           ROUND(var_mensal_pct, 1) AS var_mensal_pct,
           ROUND(var_anual_pct, 1)  AS var_anual_pct
    FROM com_variacoes
    ORDER BY mes

--BLACK FRIDAY

    SELECT CAST(o.order_purchase_timestamp AS DATE) AS dia,
           COUNT(DISTINCT o.order_id) AS pedidos,
           ROUND(SUM(oi.price), 2) AS receita
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
      AND o.order_purchase_timestamp >= '2017-11-01'
      AND o.order_purchase_timestamp <  '2017-12-01'
    GROUP BY 1
    ORDER BY receita DESC
    LIMIT 5
