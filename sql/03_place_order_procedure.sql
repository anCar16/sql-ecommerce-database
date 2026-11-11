-- Stored procedure: place an order atomically.
--
-- Creates the order, its order line and a pending shipment, and decrements stock,
-- all in one transaction. If anything fails, nothing is written.
--
-- p_resultado = 1 on success. On failure the procedure raises an error (SQLSTATE 45000)
-- with a readable message, so callers cannot ignore it.
USE venta_linea;

DROP PROCEDURE IF EXISTS realizar_pedido;

DELIMITER $$

CREATE PROCEDURE realizar_pedido(
    IN  p_id_cliente  INT,
    IN  p_id_producto INT,
    IN  p_cantidad    INT,
    OUT p_resultado   INT
)
BEGIN
    -- Parameters use a p_ prefix and variables a v_ prefix. A parameter named like a column
    -- (id_producto = id_producto) silently compares the parameter with itself and matches every row.
    DECLARE v_stock     INT DEFAULT NULL;
    DECLARE v_id_pedido INT;

    -- Any error inside the transaction undoes all its writes before propagating.
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_resultado = 0;
        RESIGNAL;
    END;

    SET p_resultado = 0;

    IF p_cantidad IS NULL OR p_cantidad <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cantidad debe ser mayor que cero.';
    END IF;

    START TRANSACTION;

    -- FOR UPDATE locks the product row: two concurrent orders cannot sell the same units twice.
    SELECT inventario INTO v_stock
    FROM productos
    WHERE id_producto = p_id_producto
    FOR UPDATE;

    IF v_stock IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El producto no existe.';
    END IF;

    IF v_stock < p_cantidad THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay suficientes existencias para el producto seleccionado.';
    END IF;

    INSERT INTO pedidos (id_cliente, fecha_pedido, estado_pedido)
    VALUES (p_id_cliente, NOW(), 'Pendiente');
    SET v_id_pedido = LAST_INSERT_ID();

    INSERT INTO detalles_pedido (id_pedido, id_producto, cantidad)
    VALUES (v_id_pedido, p_id_producto, p_cantidad);

    UPDATE productos
    SET inventario = inventario - p_cantidad
    WHERE id_producto = p_id_producto;

    INSERT INTO envios (id_pedido, fecha_envio, estado_envio)
    VALUES (v_id_pedido, NULL, 'En proceso');

    COMMIT;
    SET p_resultado = 1;
END $$

DELIMITER ;
