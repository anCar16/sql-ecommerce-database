-- Sample data.
USE venta_linea;

INSERT INTO clientes (nombre, direccion, correo_electronico) VALUES
    ('Juan Perez',    'Calle A, Ciudad X',   'juan.perez@example.com'),
    ('María García',  'Avenida B, Ciudad Y', 'maria.garcia@example.com'),
    ('Luis Martínez', 'Carrera C, Ciudad Z', 'luis.martinez@example.com');

INSERT INTO productos (nombre, descripcion, precio, inventario) VALUES
    ('Camiseta', 'Camiseta de algodón blanco', 19.99, 15),
    ('Pantalón', 'Pantalón vaquero azul',      29.99, 13),
    ('Zapatos',  'Zapatos de cuero marrón',    39.99, 10);

INSERT INTO pedidos (id_cliente, fecha_pedido, estado_pedido) VALUES
    (1, '2024-04-09', 'Pendiente'),
    (2, '2024-04-08', 'Enviado'),
    (3, '2024-04-07', 'Entregado');

INSERT INTO detalles_pedido (id_pedido, id_producto, cantidad) VALUES
    (1, 1, 3),
    (1, 2, 2),
    (2, 2, 1),
    (3, 3, 2);

INSERT INTO envios (id_pedido, fecha_envio, estado_envio) VALUES
    (2, '2024-04-08', 'En proceso'),
    (3, '2024-04-07', 'Entregado');
