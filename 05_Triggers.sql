USE ecommerce;

-- ================================================
-- TRIGGERS
-- ================================================

DROP TRIGGER IF EXISTS trg_audit_precio_producto_after_update;
DROP TRIGGER IF EXISTS trg_check_stock_before_insert_venta;
DROP TRIGGER IF EXISTS trg_update_stock_after_insert_venta;
DROP TRIGGER IF EXISTS trg_prevent_delete_categoria_with_products;
DROP TRIGGER IF EXISTS trg_log_new_customer_after_insert;
DROP TRIGGER IF EXISTS trg_update_total_gastado_cliente;
DROP TRIGGER IF EXISTS trg_set_fecha_modificacion_producto;
DROP TRIGGER IF EXISTS trg_prevent_negative_stock;
DROP TRIGGER IF EXISTS trg_capitalize_nombre_cliente;
DROP TRIGGER IF EXISTS trg_recalculate_total_venta_on_detalle_change;



-- 1. trg_audit_precio_producto_after_update
-- CREATE TABLE logs_precios (
--	  id_log          INT AUTO_INCREMENT PRIMARY KEY,
--	  producto_id     INT NOT NULL,
--	  precio_anterior DECIMAL(10,2) NOT NULL,
--	  precio_nuevo    DECIMAL(10,2) NOT NULL,
--	  fecha_cambio    TIMESTAMP
-- );

DELIMITER //

CREATE TRIGGER trg_audit_precio_producto_after_update 
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN
	IF NEW.precio <> OLD.precio THEN
		INSERT INTO logs_precios (producto_id, precio_anterior, precio_nuevo, fecha_cambio)
		VALUES (OLD.id_producto, OLD.precio, NEW.precio, CURRENT_TIMESTAMP);
	END IF;
END //

DELIMITER ;

-- UPDATE productos
-- SET precio = 2800000
-- WHERE id_producto = 1;

-- SELECT * FROM productos;
-- SELECT * FROM logs_precios;



-- 2. trg_check_stock_before_insert_venta
DELIMITER //

CREATE TRIGGER trg_check_stock_before_insert_venta 
BEFORE INSERT ON detalle_de_venta
FOR EACH ROW
BEGIN
	DECLARE v_StockActual INT;

	SELECT stock
	INTO v_StockActual
	FROM productos
	WHERE id_producto = NEW.producto_id;
	
	IF v_StockActual < NEW.cantidad THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Unidades no disponibles en stock.';
	END IF;
END //

DELIMITER ;

-- INSERT INTO detalle_de_venta (venta_id, producto_id, cantidad, precio_unitario_congelado)
-- VALUES (3, 1, 20, 2800000);



-- 3. trg_update_stock_after_insert_venta
DELIMITER //

CREATE TRIGGER trg_update_stock_after_insert_venta
AFTER INSERT ON detalle_de_venta
FOR EACH ROW
BEGIN
	UPDATE productos
	SET stock = stock - NEW.cantidad
	WHERE id_producto = NEW.producto_id;
END //

DELIMITER ;

-- INSERT INTO detalle_de_venta (venta_id, producto_id, cantidad, precio_unitario_congelado)
-- VALUES (5, 14, 20, 92000);

-- SELECT * FROM productos WHERE id_producto = 14;



-- 4. trg_prevent_delete_categoria_with_products
DELIMITER //

CREATE TRIGGER trg_prevent_delete_categoria_with_products
BEFORE DELETE ON categorias
FOR EACH ROW
BEGIN
	DECLARE v_CantidadProductos INT;

	SELECT 
		COUNT(*)
	INTO v_CantidadProductos
	FROM productos
	WHERE categoria_id = OLD.id_categoria;
	
	IF v_CantidadProductos > 0 THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'No se puede eliminar la categoría porque tiene productos asociados.';
	END IF;
END //

DELIMITER ;

-- SELECT 
--    c.id_categoria,
--    c.nombre,
--    COUNT(p.id_producto) AS cantidad_productos
-- FROM categorias c
-- INNER JOIN productos p
--    ON c.id_categoria = p.categoria_id
-- GROUP BY c.id_categoria;

-- DELETE FROM categorias
-- WHERE id_categoria = 3;



-- 5. trg_log_new_customer_after_insert
-- CREATE TABLE logs_clientes (
--  	id_log          INT AUTO_INCREMENT PRIMARY KEY,
--	    cliente_id      INT NOT NULL,
--  	nombre_cliente  VARCHAR(100) NOT NULL,
--  	fecha_registro  TIMESTAMP, 
--  	accion          VARCHAR(50)
-- );

DELIMITER //

CREATE TRIGGER trg_log_new_customer_after_insert
AFTER INSERT ON clientes
FOR EACH ROW 
BEGIN
	INSERT INTO logs_clientes (cliente_id, nombre_cliente, fecha_registro, accion)
	VALUES (NEW.id_cliente, CONCAT(NEW.nombre, ' ', NEW.apellido), CURRENT_TIMESTAMP, 'Nuevo cliente registrado.');
END //

DELIMITER ;

-- INSERT INTO clientes (nombre, apellido, email, contrasena, fecha_nacimiento, municipio, direccion_envio)
-- VALUES ('Yuritza Juliana', 'Rojas Mantilla', 'yuritrojitas@hotmail.com', 'hash021', '2003-06-22', 'Bucaramanga', 'Carrera 28A manzana 19');

-- SELECT * FROM logs_clientes;



-- 6. trg_update_total_gastado_cliente
ALTER TABLE clientes
ADD COLUMN total_gastado DECIMAL(10,2) DEFAULT 0;

DELIMITER //

CREATE TRIGGER trg_update_total_gastado_cliente
AFTER INSERT ON ventas
FOR EACH ROW
BEGIN
	UPDATE clientes
	SET total_gastado = total_gastado + NEW.total
	WHERE id_cliente = NEW.cliente_id;
END //

DELIMITER ;

-- INSERT INTO ventas (cliente_id, estado, total)
-- VALUES (19, 'Enviado', 3800000);

-- SELECT * FROM clientes;



-- 7. trg_set_fecha_modificacion_producto
ALTER TABLE productos
ADD COLUMN fecha_modificacion TIMESTAMP;

DELIMITER //

CREATE TRIGGER trg_set_fecha_modificacion_producto 
BEFORE UPDATE ON productos 
FOR EACH ROW 
BEGIN
	SET NEW.fecha_modificacion = CURRENT_TIMESTAMP;
END //

DELIMITER ;

-- UPDATE productos
-- SET precio = 79000
-- WHERE id_producto = 18;

-- SELECT * FROM productos;



-- 8. trg_prevent_negative_stock
DELIMITER //

CREATE TRIGGER trg_prevent_negative_stock
BEFORE UPDATE ON productos
FOR EACH ROW
BEGIN
	IF NEW.stock < 0 THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'El stock no puede ser negativo.';
	END IF;
END //

DELIMITER ;

-- UPDATE productos 
-- SET stock = 5
-- WHERE id_producto = 2;

-- SELECT * FROM productos;



-- 9. trg_capitalize_nombre_cliente
DELIMITER //

CREATE TRIGGER trg_capitalize_nombre_cliente
BEFORE INSERT ON clientes
FOR EACH ROW
BEGIN
	SET NEW.nombre = CONCAT(
							UPPER(LEFT(NEW.nombre, 1)),
							SUBSTRING(NEW.nombre, 2));
	SET NEW.apellido = CONCAT(
							UPPER(LEFT(NEW.apellido, 1)),
							SUBSTRING(NEW.apellido, 2));
END //

DELIMITER ;

-- INSERT INTO clientes (nombre, apellido, email, contrasena, fecha_nacimiento, municipio, direccion_envio) 
-- VALUES ('esperanza', 'mantilla', 'esperanza654@hotmail.com', 'hash023', '1966-07-25', 'Bucaramanga', 'Carrera 27 # 43 -12');

-- SELECT * FROM clientes;



-- 10. trg_recalculate_total_venta_on_detalle_change
DELIMITER //

CREATE TRIGGER trg_recalculate_total_venta_on_detalle_change
AFTER UPDATE ON detalle_de_venta
FOR EACH ROW
BEGIN
	UPDATE ventas
	SET total = (
		SELECT SUM(cantidad * precio_unitario_congelado)
		FROM detalle_de_venta
		WHERE venta_id = NEW.venta_id)
	WHERE id_venta = NEW.venta_id;
END //

DELIMITER ;

-- UPDATE detalle_de_venta
-- SET cantidad = 5
-- WHERE id_detalle = 20;

-- SELECT * FROM detalle_de_venta;
-- SELECT * FROM ventas WHERE id_venta = 19;




