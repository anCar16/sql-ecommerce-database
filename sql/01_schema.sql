-- Online store database: customers, products, orders, order lines and shipments.
-- Identifiers are in Spanish (the original business context); comments are in English.

CREATE DATABASE IF NOT EXISTS venta_linea CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE venta_linea;

CREATE TABLE clientes (
    id_cliente          INT PRIMARY KEY AUTO_INCREMENT,
    nombre              VARCHAR(50)  NOT NULL,
    direccion           VARCHAR(100) NOT NULL,
    correo_electronico  VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE productos (
    id_producto  INT PRIMARY KEY AUTO_INCREMENT,
    nombre       VARCHAR(50)    NOT NULL,
    descripcion  TEXT           NOT NULL,
    precio       DECIMAL(10, 2) NOT NULL CHECK (precio >= 0),
    inventario   INT            NOT NULL CHECK (inventario >= 0)
);

CREATE TABLE pedidos (
    id_pedido      INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente     INT         NOT NULL,
    fecha_pedido   DATETIME    NOT NULL,
    estado_pedido  VARCHAR(20) NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES clientes (id_cliente)
);

CREATE TABLE detalles_pedido (
    id_detalle_pedido  INT PRIMARY KEY AUTO_INCREMENT,
    id_pedido          INT NOT NULL,
    id_producto        INT NOT NULL,
    cantidad           INT NOT NULL CHECK (cantidad > 0),
    FOREIGN KEY (id_pedido)   REFERENCES pedidos (id_pedido),
    FOREIGN KEY (id_producto) REFERENCES productos (id_producto)
);

CREATE TABLE envios (
    id_envio      INT PRIMARY KEY AUTO_INCREMENT,
    id_pedido     INT         NOT NULL,
    fecha_envio   DATETIME    NULL,
    estado_envio  VARCHAR(20) NOT NULL,
    FOREIGN KEY (id_pedido) REFERENCES pedidos (id_pedido)
);
