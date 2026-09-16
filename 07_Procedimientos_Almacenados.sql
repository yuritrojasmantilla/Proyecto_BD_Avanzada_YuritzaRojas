USE ecommerce;

-- ================================================
-- PROCEDIMIENTOS ALMACENADOS
-- ================================================

DROP PROCEDURE IF EXISTS sp_RealizarNuevaVenta;
DROP PROCEDURE IF EXISTS sp_AgregarNuevoProducto;
DROP PROCEDURE IF EXISTS sp_ActualizarDireccionCliente;
DROP PROCEDURE IF EXISTS sp_ProcesarDevolucion;
DROP PROCEDURE IF EXISTS sp_ObtenerHistorialComprasCliente;
DROP PROCEDURE IF EXISTS sp_EliminarClienteDeFormaSegura;
DROP PROCEDURE IF EXISTS sp_AplicarDescuentoPorCategoria;
DROP PROCEDURE IF EXISTS sp_GenerarReporteMensualVentas;
DROP PROCEDURE IF EXISTS sp_RegistrarNuevoCliente;
DROP PROCEDURE IF EXISTS sp_ObtenerDetallesProductoCompleto;


-- 1. sp_RealizarNuevaVenta
DELIMITER // 

CREATE PROCEDURE sp_RealizarNuevaVenta (
	IN p_cliente_id  INT,
	IN p_producto_id INT,
	IN p_cantidad    INT
)
BEGIN
	DECLARE v_precio DECIMAL(10,2);
	DECLARE v_total  DECIMAL(10,2);
	DECLARE v_venta_id INT;

	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
    	ROLLBACK;
    	RESIGNAL;
	END;

	START TRANSACTION;
	
	IF p_cantidad <= 0 THEN 
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = 'La cantidad debe ser mayor que cero.'; 
	END IF;
	
	IF NOT EXISTS ( 
		SELECT 1 
		FROM clientes 
		WHERE id_cliente = p_cliente_id 
	) THEN 
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = 'El cliente no existe.'; 
	END IF;
	
	IF NOT EXISTS (
		SELECT 1
		FROM productos
		WHERE id_producto = p_producto_id
	) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'El producto no existe.';
	END IF;
	
	SELECT precio 
	INTO v_precio
	FROM productos
	WHERE id_producto = p_producto_id;
	
	SET v_total = p_cantidad * v_precio;
	
	INSERT INTO ventas (cliente_id, estado, total)
	VALUES (p_cliente_id, 'Procesando', v_total);

	SET v_venta_id = LAST_INSERT_ID();
	
	INSERT INTO detalle_de_venta (venta_id, producto_id, cantidad,
									precio_unitario_congelado)
	VALUES (v_venta_id, p_producto_id, p_cantidad, v_precio);
	
	COMMIT;
END //

DELIMITER ;

-- CALL sp_RealizarNuevaVenta(1, 1, 2);

-- SELECT *
-- FROM ventas
-- ORDER BY id_venta DESC
-- LIMIT 1;



-- 2. sp_AgregarNuevoProducto
DELIMITER //

CREATE PROCEDURE sp_AgregarNuevoProducto (
	IN p_nombre        VARCHAR(150),
	IN p_categoria_id  INT,
	IN p_descripcion   VARCHAR(255),
	IN p_precio        DECIMAL(10,2),
	IN p_proveedor_id  INT,
	IN p_costo         DECIMAL(10,2),
	IN p_stock         INT,
	IN p_sku           VARCHAR(50),
	IN p_peso_kg       DECIMAL(5,2)   
)
BEGIN
	IF p_precio <= 0 THEN 
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = 'El precio debe ser mayor que cero.'; 
	END IF;

	IF p_costo < 0 THEN 
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = 'El costo no puede ser negativo.'; 
	END IF;
		
	IF p_stock < 0 THEN 
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = 'El stock no puede ser negativo.'; 
	END IF;
	
	IF NOT EXISTS ( 
		SELECT 1 
		FROM categorias
		WHERE id_categoria = p_categoria_id 
	) THEN 
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = 'La categoría no existe.'; 
	END IF;
	
	IF NOT EXISTS ( 
		SELECT 1 
		FROM proveedores 
		WHERE id_proveedor = p_proveedor_id 
	) THEN 
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = 'El proveedor no existe.'; 
	END IF;
	
	INSERT INTO productos (nombre, categoria_id, descripcion, precio, 
				proveedor_id, costo, stock, sku, peso_kg, fecha_creacion)
	VALUES (p_nombre, p_categoria_id, p_descripcion, p_precio, p_proveedor_id,
				p_costo, p_stock, p_sku, p_peso_kg, CURRENT_TIMESTAMP);
END //

DELIMITER ;

-- CALL sp_AgregarNuevoProducto('Ipad 11Inch', 3, 'Tablet de 11 pulgadas Apple', 2400000, 5, 2000000, 5, 'SKU021', 1);
-- SELECT * FROM productos;



-- 3. sp_ActualizarDireccionCliente
DELIMITER //

CREATE PROCEDURE sp_ActualizarDireccionCliente (
	IN p_id_cliente      INT,
	IN p_municipio       VARCHAR(100),
	IN p_direccion_envio VARCHAR(200)
)
BEGIN
	IF NOT EXISTS (
		SELECT 1
		FROM clientes
		WHERE id_cliente = p_id_cliente
	) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'El cliente no existe.';
	END IF;

	UPDATE clientes
	SET municipio = p_municipio,
		direccion_envio = p_direccion_envio
	WHERE id_cliente = p_id_cliente;
END //

DELIMITER ;

-- CALL sp_ActualizarDireccionCliente(20, 'Villanueva', 'Carrera 32 #11-18');
-- SELECT * FROM clientes;



-- 4. sp_ProcesarDevolucion
-- CREATE TABLE devoluciones (
--    id_devolucion INT AUTO_INCREMENT PRIMARY KEY,
--    detalle_id INT NOT NULL,
--    cliente_id INT NOT NULL,
--    venta_id INT NOT NULL,
--    producto_id INT NOT NULL,
--    cantidad INT NOT NULL,
--    monto_credito DECIMAL(10,2) NOT NULL,
--    fecha_devolucion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--    FOREIGN KEY (detalle_id) REFERENCES detalle_de_venta(id_detalle),
--    FOREIGN KEY (cliente_id) REFERENCES clientes(id_cliente),
--    FOREIGN KEY (venta_id) REFERENCES ventas(id_venta),
--    FOREIGN KEY (producto_id) REFERENCES productos(id_producto)
-- );

DELIMITER //

CREATE PROCEDURE sp_ProcesarDevolucion (
    IN p_id_detalle INT,
    IN p_cantidad INT
)
BEGIN
    DECLARE v_cliente_id INT;
    DECLARE v_venta_id INT;
    DECLARE v_producto_id INT;
    DECLARE v_cantidad_comprada INT;
    DECLARE v_cantidad_devuelta INT;
    DECLARE v_precio DECIMAL(10,2);
    DECLARE v_credito DECIMAL(10,2);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    IF NOT EXISTS (
        SELECT 1
        FROM detalle_de_venta
        WHERE id_detalle = p_id_detalle
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El detalle de venta no existe.';
    END IF;

    IF p_cantidad <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La cantidad a devolver debe ser mayor que cero.';
    END IF;

    SELECT
        v.cliente_id,
        dv.venta_id,
        dv.producto_id,
        dv.cantidad,
        dv.precio_unitario_congelado
    INTO
        v_cliente_id,
        v_venta_id,
        v_producto_id,
        v_cantidad_comprada,
        v_precio
    FROM detalle_de_venta dv
    INNER JOIN ventas v
        ON dv.venta_id = v.id_venta
    WHERE dv.id_detalle = p_id_detalle;

    SELECT COALESCE(SUM(cantidad), 0)
    INTO v_cantidad_devuelta
    FROM devoluciones
    WHERE detalle_id = p_id_detalle;

    IF v_cantidad_devuelta + p_cantidad > v_cantidad_comprada THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La cantidad devuelta supera la cantidad comprada.';
    END IF;

    SET v_credito = p_cantidad * v_precio;

    UPDATE productos
    SET stock = stock + p_cantidad
    WHERE id_producto = v_producto_id;

    INSERT INTO devoluciones (detalle_id, cliente_id, venta_id, producto_id,
        						cantidad, monto_credito)
    VALUES (p_id_detalle, v_cliente_id, v_venta_id, v_producto_id, p_cantidad, v_credito);

    COMMIT;
END //

DELIMITER ;



-- 5. sp_ObtenerHistorialComprasCliente
DELIMITER //

CREATE PROCEDURE sp_ObtenerHistorialComprasCliente (IN p_id_cliente INT)
BEGIN

    IF NOT EXISTS (
        SELECT 1
        FROM clientes
        WHERE id_cliente = p_id_cliente
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El cliente no existe.';
    END IF;

    SELECT
        v.id_venta,
        v.fecha_venta,
        v.estado,
        v.total,
        p.nombre AS producto,
        dv.cantidad,
        dv.precio_unitario_congelado
    FROM ventas v
    INNER JOIN detalle_de_venta dv
        ON v.id_venta = dv.venta_id
    INNER JOIN productos p
        ON dv.producto_id = p.id_producto
    WHERE v.cliente_id = p_id_cliente
    ORDER BY v.fecha_venta DESC;

END //

DELIMITER ;



-- 7. sp_EliminarClienteDeFormaSegura
DELIMITER //

CREATE PROCEDURE sp_EliminarClienteDeFormaSegura (
    IN p_id_cliente INT
)
BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    IF NOT EXISTS (
        SELECT 1
        FROM clientes
        WHERE id_cliente = p_id_cliente
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El cliente no existe.';
    END IF;

    UPDATE clientes
    SET
        nombre = 'Cliente',
        apellido = 'Anonimizado',
        email = CONCAT('anonimizado_', p_id_cliente, '@anonimo.com'),
        contrasena = 'ANONIMIZADA',
        direccion_envio = NULL
    WHERE id_cliente = p_id_cliente;

    COMMIT;

END //

DELIMITER ;



-- 8. sp_AplicarDescuentoPorCategoria
DELIMITER //

CREATE PROCEDURE sp_AplicarDescuentoPorCategoria (
    IN p_categoria_id INT,
    IN p_porcentaje DECIMAL(5,2)
)
BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    IF NOT EXISTS (
        SELECT 1
        FROM categorias
        WHERE id_categoria = p_categoria_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La categoría no existe.';
    END IF;

    IF p_porcentaje <= 0 OR p_porcentaje >= 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El porcentaje debe estar entre 0 y 100.';
    END IF;

    UPDATE productos
    SET precio = ROUND(precio - (precio * p_porcentaje / 100), 2)
    WHERE categoria_id = p_categoria_id;

    COMMIT;

END //

DELIMITER ;



-- 9. sp_GenerarReporteMensualVentas
DELIMITER //

CREATE PROCEDURE sp_GenerarReporteMensualVentas (
    IN p_mes INT,
    IN p_anio INT
)
BEGIN

    IF p_mes < 1 OR p_mes > 12 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El mes debe estar entre 1 y 12.';
    END IF;

    IF p_anio < 2000 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El año ingresado no es válido.';
    END IF;

    SELECT
        YEAR(v.fecha_venta) AS Año,
        MONTH(v.fecha_venta) AS Mes,
        COUNT(v.id_venta) AS CantidadVentas,
        SUM(v.total) AS TotalVentas,
        AVG(v.total) AS PromedioVenta
    FROM ventas v
    WHERE YEAR(v.fecha_venta) = p_anio
      AND MONTH(v.fecha_venta) = p_mes
    GROUP BY YEAR(v.fecha_venta), MONTH(v.fecha_venta);

END //

DELIMITER ;



-- 11. sp_RegistrarNuevoCliente 
DELIMITER //

CREATE PROCEDURE sp_RegistrarNuevoCliente (
    IN p_nombre VARCHAR(100),
    IN p_apellido VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_contrasena VARCHAR(255),
    IN p_municipio VARCHAR(100),
    IN p_direccion_envio VARCHAR(200),
    IN p_fecha_nacimiento DATE
)
BEGIN

    IF EXISTS (
        SELECT 1
        FROM clientes
        WHERE email = p_email
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El email ya está registrado.';
    END IF;

    INSERT INTO clientes (nombre, apellido, email, contrasena, municipio,
    						direccion_envio, fecha_nacimiento)
    VALUES (p_nombre, p_apellido, p_email, p_contrasena, p_municipio,
       		 p_direccion_envio, p_fecha_nacimiento);

END //

DELIMITER ;



-- 12. sp_ObtenerDetallesProductoCompleto
DELIMITER //

CREATE PROCEDURE sp_ObtenerDetallesProductoCompleto (
    IN p_id_producto INT
)
BEGIN

    IF NOT EXISTS (
        SELECT 1
        FROM productos
        WHERE id_producto = p_id_producto
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El producto no existe.';
    END IF;

    SELECT
        p.id_producto,
        p.nombre AS producto,
        p.descripcion,
        p.precio,
        p.costo,
        p.stock,
        p.sku,
        p.peso_kg,
        p.fecha_creacion,
        p.activo,
        c.id_categoria,
        c.nombre AS categoria,
        c.descripcion AS descripcion_categoria,
        pr.id_proveedor,
        pr.nombre AS proveedor,
        pr.email_contacto,
        pr.telefono_contacto
    FROM productos p
    INNER JOIN categorias c
        ON p.categoria_id = c.id_categoria
    INNER JOIN proveedores pr
        ON p.proveedor_id = pr.id_proveedor
    WHERE p.id_producto = p_id_producto;

END //

DELIMITER ;
