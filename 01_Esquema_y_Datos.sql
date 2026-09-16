DROP DATABASE IF EXISTS ecommerce;
CREATE DATABASE ecommerce;
USE ecommerce;


-- ================================================
-- ESTRUCTURA COMPLETA DE LA BASE DE DATOS
-- ================================================

CREATE TABLE categorias (
	id_categoria INT AUTO_INCREMENT PRIMARY KEY,
	nombre       VARCHAR(100) NOT NULL UNIQUE,
	descripcion  VARCHAR(255)
);

CREATE TABLE proveedores (
	id_proveedor      INT AUTO_INCREMENT PRIMARY KEY,
	nombre            VARCHAR(150) NOT NULL,
	email_contacto    VARCHAR(100) NOT NULL UNIQUE,
	telefono_contacto VARCHAR(20)
);

CREATE TABLE productos (
	id_producto    INT AUTO_INCREMENT PRIMARY KEY,
	nombre         VARCHAR(150) NOT NULL UNIQUE,
	categoria_id   INT NOT NULL,
	descripcion    VARCHAR(255),
	precio         DECIMAL(10,2) NOT NULL CHECK (precio > 0),
	proveedor_id   INT NOT NULL,
	costo          DECIMAL(10,2) NOT NULL CHECK (costo >= 0),
	stock          INT NOT NULL DEFAULT 0 CHECK (stock >= 0),
	sku            VARCHAR(50) NOT NULL UNIQUE,
	peso_kg        DECIMAL(5,2) NOT NULL CHECK (peso_kg > 0),           
	fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	activo         BOOLEAN NOT NULL DEFAULT TRUE,
	FOREIGN KEY (categoria_id) REFERENCES categorias(id_categoria),
	FOREIGN KEY (proveedor_id) REFERENCES proveedores(id_proveedor) 
);

CREATE TABLE clientes (
	id_cliente       INT AUTO_INCREMENT PRIMARY KEY,
	nombre           VARCHAR(100) NOT NULL,
	apellido         VARCHAR(100) NOT NULL, 
	email            VARCHAR(100) NOT NULL UNIQUE,
	contrasena       VARCHAR(100) NOT NULL,
	fecha_nacimiento DATE NOT NULL,
	municipio        VARCHAR(100) NOT NULL,
	direccion_envio  VARCHAR(200),
	fecha_registro   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ventas (
	id_venta    INT AUTO_INCREMENT PRIMARY KEY,
	cliente_id  INT NOT NULL,
	fecha_venta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	estado      ENUM('Pendiente de pago', 'Procesando', 'Enviado', 'Entregado', 'Cancelado') NOT NULL,
	total       DECIMAL(10,2) NOT NULL CHECK (total >= 0),
	FOREIGN KEY (cliente_id) REFERENCES clientes(id_cliente)
);

CREATE TABLE detalle_de_venta (
	id_detalle                INT AUTO_INCREMENT PRIMARY KEY,
	venta_id                  INT NOT NULL,
	producto_id               INT NOT NULL,
	cantidad                  INT NOT NULL           CHECK (cantidad > 0),
	precio_unitario_congelado DECIMAL(10,2) NOT NULL CHECK (precio_unitario_congelado >= 0),
	FOREIGN KEY (venta_id) REFERENCES ventas(id_venta),
	FOREIGN KEY (producto_id) REFERENCES productos(id_producto),
	UNIQUE (venta_id, producto_id)
);     



-- Tablas adicionales por requerimientos del proyecto.

CREATE TABLE logs_precios (
	id_log          INT AUTO_INCREMENT PRIMARY KEY,
	producto_id     INT NOT NULL,
	precio_anterior DECIMAL(10,2) NOT NULL,
	precio_nuevo    DECIMAL(10,2) NOT NULL,
	fecha_cambio    TIMESTAMP
);    

CREATE TABLE logs_clientes (
	id_log          INT AUTO_INCREMENT PRIMARY KEY,
	cliente_id      INT NOT NULL,
	nombre_cliente  VARCHAR(100) NOT NULL,
	fecha_registro  TIMESTAMP, 
	accion          VARCHAR(50)
);      

CREATE TABLE devoluciones (
    id_devolucion    INT AUTO_INCREMENT PRIMARY KEY,
    detalle_id       INT NOT NULL,
    cliente_id       INT NOT NULL,
    venta_id         INT NOT NULL,
    producto_id      INT NOT NULL,
    cantidad         INT NOT NULL,
    monto_credito    DECIMAL(10,2) NOT NULL,
    fecha_devolucion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (detalle_id) REFERENCES detalle_de_venta(id_detalle),
    FOREIGN KEY (cliente_id) REFERENCES clientes(id_cliente),
    FOREIGN KEY (venta_id) REFERENCES ventas(id_venta),
    FOREIGN KEY (producto_id) REFERENCES productos(id_producto)
);     

CREATE TABLE reportes_ventas_semanales (
    id_reporte       INT AUTO_INCREMENT PRIMARY KEY,
    fecha_inicio     DATE NOT NULL,
    fecha_fin        DATE NOT NULL,
    cantidad_ventas  INT NOT NULL,
    total_ventas     DECIMAL(10,2) NOT NULL,
    fecha_generacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);   

CREATE TABLE temp_datos_ventas (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);   

CREATE TABLE historial_logs_precios (
    id_log          INT,
    producto_id     INT,
    precio_anterior DECIMAL(10,2),
    precio_nuevo    DECIMAL(10,2),
    fecha_cambio    TIMESTAMP
);    

CREATE TABLE promociones (
    id_promocion     INT AUTO_INCREMENT PRIMARY KEY,
    codigo           VARCHAR(50) NOT NULL UNIQUE,
    porcentaje       DECIMAL(5,2) NOT NULL,
    fecha_expiracion DATE NOT NULL,
    activa           BOOLEAN DEFAULT TRUE
);     

CREATE TABLE lista_reabastecimiento (
    id_reabastecimiento INT AUTO_INCREMENT PRIMARY KEY,
    producto_id         INT NOT NULL,
    stock_actual        INT NOT NULL,
    fecha_generacion    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (producto_id) REFERENCES productos(id_producto)
);    

CREATE TABLE resumen_ventas_diarias (
    id_resumen      INT AUTO_INCREMENT PRIMARY KEY,
    fecha           DATE NOT NULL UNIQUE,
    cantidad_ventas INT NOT NULL,
    total_ventas    DECIMAL(10,2) NOT NULL,
    promedio_venta  DECIMAL(10,2) NOT NULL
);    

CREATE TABLE inconsistencias_datos (
    id_inconsistencia INT AUTO_INCREMENT PRIMARY KEY,
    tipo              VARCHAR(100) NOT NULL,
    descripcion       VARCHAR(255) NOT NULL,
    fecha_deteccion   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);



-- ================================================
-- SENTENCIAS INSERT INTO
-- ================================================

INSERT INTO categorias (nombre, descripcion) VALUES
	('Electrónica', 'Productos electrónicos'),
	('Computadores', 'Computadores y accesorios'),
	('Celulares', 'Teléfonos móviles'),
	('Audio', 'Equipos de audio'),
	('Video', 'Equipos de video'),
	('Hogar', 'Productos para el hogar'),
	('Cocina', 'Electrodomésticos de cocina'),
	('Oficina', 'Productos para oficina'),
	('Accesorios', 'Accesorios tecnológicos'),
	('Videojuegos', 'Productos para videojuegos'),
	('Deportes', 'Artículos deportivos'),
	('Ropa', 'Prendas de vestir'),
	('Calzado', 'Zapatos y calzado'),
	('Belleza', 'Productos de belleza'),
	('Libros', 'Libros y material educativo'),
	('Juguetes', 'Juguetes para niños'),
	('Muebles', 'Muebles para el hogar'),
	('Iluminación', 'Lámparas y sistemas de iluminación'),
	('Herramientas', 'Herramientas y equipos'),
	('Jardinería', 'Productos para jardinería');

INSERT INTO proveedores (nombre, email_contacto, telefono_contacto) VALUES
	('Tech Colombia', 'contacto@techcolombia.com', '3001111111'),
	('Digital Store', 'contacto@digitalstore.com', '3002222222'),
	('ElectroMax', 'ventas@electromax.com', '3003333333'),
	('CompuWorld', 'ventas@compuworld.com', '3004444444'),
	('Mobile Center', 'info@mobilecenter.com', '3005555555'),
	('Audio Plus', 'info@audioplus.com', '3006666666'),
	('Casa Digital', 'ventas@casadigital.com', '3007777777'),
	('Office Pro', 'contacto@officepro.com', '3008888888'),
	('Game Zone', 'ventas@gamezone.com', '3009999999'),
	('Sport Market', 'info@sportmarket.com', '3011111111'),
	('Moda Express', 'ventas@modaexpress.com', '3012222222'),
	('Calzado Total', 'info@calzadototal.com', '3013333333'),
	('Beauty Shop', 'ventas@beautyshop.com', '3014444444'),
	('Librería Central', 'info@libreriacentral.com', '3015555555'),
	('Juguetería Feliz', 'ventas@jugueteriafeliz.com', '3016666666'),
	('Muebles del Norte', 'info@mueblesnorte.com', '3017777777'),
	('Luz y Diseño', 'ventas@luzydiseno.com', '3018888888'),
	('Herramientas Pro', 'info@herramientaspro.com', '3019999999'),
	('Jardín Colombia', 'ventas@jardincolombia.com', '3021111111'),
	('Importaciones Global', 'contacto@importacionesglobal.com', '3022222222');

INSERT INTO productos
(nombre, categoria_id, descripcion, precio, proveedor_id, costo, stock, sku, peso_kg) VALUES
	('Laptop Lenovo IdeaPad', 2, 'Computador portátil Lenovo', 2500000, 1, 1900000, 15, 'SKU001', 10),
	('Laptop HP Pavilion', 2, 'Computador portátil HP', 2800000, 4, 2100000, 10, 'SKU002', 8),
	('iPhone 15', 3, 'Teléfono inteligente Apple', 3500000, 5, 2900000, 8, 'SKU003', 1),
	('Samsung Galaxy S24', 3, 'Teléfono inteligente Samsung', 3200000, 5, 2600000, 12, 'SKU004', 1),
	('Audífonos Sony', 4, 'Audífonos inalámbricos', 450000, 6, 300000, 20, 'SKU005', 1),
	('Parlante JBL', 4, 'Parlante portátil Bluetooth', 600000, 6, 420000, 18, 'SKU006', 3),
	('Televisor LG 55 pulgadas', 5, 'Televisor Smart TV', 2800000, 3, 2200000, 7, 'SKU007', 25),
	('Monitor Samsung 24 pulgadas', 5, 'Monitor Full HD', 850000, 3, 650000, 14, 'SKU008', 7),
	('Teclado Logitech', 9, 'Teclado inalámbrico', 180000, 2, 110000, 30, 'SKU009', 2),
	('Mouse Logitech', 9, 'Mouse inalámbrico', 120000, 2, 70000, 35, 'SKU010', 1),
	('PlayStation 5', 10, 'Consola de videojuegos', 3000000, 9, 2500000, 6, 'SKU011', 4),
	('Control Xbox', 10, 'Control inalámbrico Xbox', 350000, 9, 250000, 16, 'SKU012', 1),
	('Bicicleta deportiva', 11, 'Bicicleta para deporte', 1800000, 10, 1400000, 5, 'SKU013', 38),
	('Camiseta deportiva', 12, 'Camiseta para ejercicio', 90000, 11, 50000, 40, 'SKU014', 1),
	('Tenis deportivos', 13, 'Calzado deportivo', 280000, 12, 190000, 25, 'SKU015', 2),
	('Perfume masculino', 14, 'Perfume de larga duración', 250000, 13, 160000, 18, 'SKU016', 1),
	('Libro de programación', 15, 'Libro sobre programación', 120000, 14, 70000, 22, 'SKU017', 2),
	('Lámpara LED', 18, 'Lámpara LED para escritorio', 80000, 17, 45000, 28, 'SKU018', 3),
	('Taladro eléctrico', 19, 'Taladro eléctrico profesional', 450000, 18, 320000, 10, 'SKU019', 1),
	('Kit de jardinería', 20, 'Kit básico para jardinería', 150000, 19, 90000, 15, 'SKU020', 5);

INSERT INTO clientes
(nombre, apellido, email, contrasena, fecha_nacimiento, municipio, direccion_envio) VALUES
	('Carlos', 'Gómez', 'carlos.gomez@email.com', 'hash001', '2003-10-12', 'Bucaramanga', 'Calle 10 #20-30'),
	('María', 'Rodríguez', 'maria.rodriguez@email.com', 'hash002', '2005-01-13',  'Bucaramanga', 'Carrera 15 #12-40'),
	('Juan', 'Martínez', 'juan.martinez@email.com', 'hash003', '2001-11-02',  'Piedecuesta', 'Calle 25 #30-15'),
	('Laura', 'Pérez', 'laura.perez@email.com', 'hash004', '2008-05-11',  'Floridablanca', 'Carrera 20 #18-25'),
	('Andrés', 'López', 'andres.lopez@email.com', 'hash005', '2003-10-12',  'San Gil', 'Calle 40 #15-20'),
	('Sofía', 'Ramírez', 'sofia.ramirez@email.com', 'hash006', '2003-10-12',  'Aratoca', 'Carrera 10 #25-35'),
	('Daniel', 'Torres', 'daniel.torres@email.com', 'hash007', '2003-10-12',  'Floridablanca', 'Calle 12 #40-50'),
	('Valentina', 'Castro', 'valentina.castro@email.com', 'hash008', '2003-06-22',  'Zapatoca', 'Carrera 30 #10-20'),
	('Sebastián', 'Moreno', 'sebastian.moreno@email.com', 'hash009', '2003-10-05',  'Zapatoca', 'Calle 18 #22-30'),
	('Camila', 'Vargas', 'camila.vargas@email.com', 'hash010', '2002-07-15',  'Floridablanca', 'Carrera 25 #14-16'),
	('Felipe', 'Rojas', 'felipe.rojas@email.com', 'hash011', '2005-11-12',  'Girón', 'Calle 35 #20-10'),
	('Natalia', 'Mendoza', 'natalia.mendoza@email.com', 'hash012', '2004-10-12',  'Malaga', 'Carrera 12 #30-40'),
	('Miguel', 'Suárez', 'miguel.suarez@email.com', 'hash013', '2004-12-19',  'Barichara', 'Calle 28 #15-25'),
	('Paula', 'Jiménez', 'paula.jimenez@email.com', 'hash014', '2003-05-12',  'Malaga', 'Carrera 18 #35-45'),
	('Diego', 'Herrera', 'diego.herrera@email.com', 'hash015', '2001-05-12',  'Bucaramanga', 'Calle 50 #10-30'),
	('Isabella', 'Navarro', 'isabella.navarro@email.com', 'hash016', '2003-06-12',  'Lebrija', 'Carrera 22 #16-28'),
	('Santiago', 'Ortiz', 'santiago.ortiz@email.com', 'hash017', '2000-10-12',  'Girón', 'Calle 15 #32-20'),
	('Gabriela', 'Silva', 'gabriela.silva@email.com', 'hash018', '2001-10-12',  'Bucaramanga', 'Carrera 28 #20-35'),
	('Alejandro', 'Mora', 'alejandro.mora@email.com', 'hash019', '2002-10-12',  'Girón', 'Calle 45 #25-15'),
	('Juliana', 'Cárdenas', 'juliana.cardenas@email.com', 'hash020', '2002-10-12',  'Bucaramanga', 'Carrera 35 #12-18');

INSERT INTO ventas (cliente_id, estado, total) VALUES
	(1, 'Entregado', 2620000),
	(2, 'Enviado', 3500000),
	(3, 'Procesando', 600000),
	(4, 'Pendiente de pago', 850000),
	(5, 'Entregado', 3000000),
	(6, 'Enviado', 470000),
	(7, 'Entregado', 1800000),
	(8, 'Procesando', 280000),
	(9, 'Cancelado', 120000),
	(10, 'Entregado', 3000000),
	(11, 'Enviado', 350000),
	(12, 'Procesando', 250000),
	(13, 'Entregado', 450000),
	(14, 'Pendiente de pago', 120000),
	(15, 'Enviado', 280000),
	(16, 'Entregado', 80000),
	(17, 'Procesando', 450000),
	(18, 'Entregado', 150000),
	(19, 'Enviado', 600000),
	(20, 'Pendiente de pago', 180000);

INSERT INTO detalle_de_venta
(venta_id, producto_id, cantidad, precio_unitario_congelado) VALUES
	(1, 1, 1, 2500000),
	(1, 9, 1, 180000),
	(2, 3, 1, 3500000),
	(3, 6, 1, 600000),
	(4, 8, 1, 850000),
	(5, 11, 1, 3000000),
	(6, 5, 1, 450000),
	(7, 13, 1, 1800000),
	(8, 15, 1, 280000),
	(9, 10, 1, 120000),
	(10, 11, 1, 3000000),
	(11, 12, 1, 350000),
	(12, 16, 1, 250000),
	(13, 19, 1, 450000),
	(14, 17, 1, 120000),
	(15, 15, 1, 280000),
	(16, 18, 1, 80000),
	(17, 19, 1, 450000),
	(18, 20, 1, 150000),
	(19, 6, 1, 600000);

