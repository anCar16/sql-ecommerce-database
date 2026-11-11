-- Example queries over the online store database.
USE venta_linea;

-- 1. Place an order: customer 1 buys 2 units of product 1.
CALL realizar_pedido(1, 1, 2, @resultado);
SELECT @resultado AS resultado;  -- 1 = success

-- 2. Revenue and units sold by product.
SELECT p.nombre,
       SUM(d.cantidad)            AS unidades,
       SUM(d.cantidad * p.precio) AS ingresos
FROM detalles_pedido d
JOIN productos p ON p.id_producto = d.id_producto
GROUP BY p.id_producto, p.nombre
ORDER BY ingresos DESC;

-- 3. Customers with their number of orders and total spent (customers without orders included).
SELECT c.nombre,
       COUNT(DISTINCT pe.id_pedido)           AS pedidos,
       COALESCE(SUM(d.cantidad * pr.precio), 0) AS total_gastado
FROM clientes c
LEFT JOIN pedidos pe        ON pe.id_cliente = c.id_cliente
LEFT JOIN detalles_pedido d ON d.id_pedido = pe.id_pedido
LEFT JOIN productos pr      ON pr.id_producto = d.id_producto
GROUP BY c.id_cliente, c.nombre
ORDER BY total_gastado DESC;

-- 4. Orders that have not been delivered yet, with their shipment status.
SELECT pe.id_pedido,
       c.nombre,
       pe.fecha_pedido,
       pe.estado_pedido,
       COALESCE(e.estado_envio, 'Sin envío') AS estado_envio
FROM pedidos pe
JOIN clientes c     ON c.id_cliente = pe.id_cliente
LEFT JOIN envios e  ON e.id_pedido = pe.id_pedido
WHERE COALESCE(e.estado_envio, '') <> 'Entregado'
ORDER BY pe.fecha_pedido;

-- 5. Products at or below a reorder point of 10 units.
SELECT nombre, inventario
FROM productos
WHERE inventario <= 10
ORDER BY inventario;
