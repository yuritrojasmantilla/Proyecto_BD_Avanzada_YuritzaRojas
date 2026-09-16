USE ecommerce;

-- ================================================
-- FUNCIONES DEL USUARIO
-- ================================================

DROP FUNCTION IF EXISTS fn_CalcularTotalVenta;
DROP FUNCTION IF EXISTS fn_VerificarDisponibilidadStock;
DROP FUNCTION IF EXISTS fn_ObtenerPrecioProducto;
DROP FUNCTION IF EXISTS fn_CalcularEdadCliente;
DROP FUNCTION IF EXISTS fn_FormatearNombreCompleto;
DROP FUNCTION IF EXISTS fn_EsClienteNuevo;
DROP FUNCTION IF EXISTS fn_CalcularCostoEnvio;
DROP FUNCTION IF EXISTS fn_AplicarDescuento;
DROP FUNCTION IF EXISTS fn_AplicarDescuento2;
DROP FUNCTION IF EXISTS fn_ObtenerUltimaFechaCompra;
DROP FUNCTION IF EXISTS fn_ValidarFormatoEmail;


-- 1. fn_CalcularTotalVenta
DELIMITER //

CREATE FUNCTION fn_CalcularTotalVenta (p_id_venta INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA

BEGIN
	DECLARE v_Total DECIMAL(10,2);

	IF NOT EXISTS (
		SELECT 1
		FROM ventas
		WHERE id_venta = p_id_venta
	) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'El ID de la venta no coincide con la base de datos.';
	END IF;
		
	SELECT 
		SUM(cantidad * precio_unitario_congelado)
	INTO v_Total
	FROM detalle_de_venta
	WHERE venta_id = p_id_venta;

	RETURN v_Total;
END //

DELIMITER ;

-- SELECT fn_CalcularTotalVenta(1) AS Total_de_la_Venta;



-- 2. fn_VerificarDisponibilidadStock
DELIMITER //

CREATE FUNCTION fn_VerificarDisponibilidadStock (
	p_id_producto INT,
	p_cantidad INT
)
RETURNS VARCHAR(50)
DETERMINISTIC
READS SQL DATA

BEGIN
	DECLARE v_StockActual INT;

	IF NOT EXISTS (
		SELECT 1
		FROM productos
		WHERE id_producto = p_id_producto
	) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'El ID del producto no coincide con la base de datos.';
	END IF;
	
	SELECT 
		stock
	INTO v_StockActual
	FROM productos
	WHERE id_producto = p_id_producto;
	
	IF v_StockActual >= p_cantidad THEN
		RETURN CONCAT('Producto disponible - Stock = ', v_StockActual);
	ELSE 
		RETURN CONCAT('Producto No Disponible - Stock = ', v_StockActual);
	END IF;
	
END //

DELIMITER ;

-- SELECT fn_VerificarDisponibilidadStock(1, 10) AS StockDisponible;



-- 3. fn_ObtenerPrecioProducto
DELIMITER //

CREATE FUNCTION fn_ObtenerPrecioProducto (p_id_producto INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA

BEGIN
	DECLARE v_PrecioActual DECIMAL(10,2);

	IF NOT EXISTS (
		SELECT 1
		FROM productos
		WHERE id_producto = p_id_producto
	) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'El ID del producto no coincide con la base de datos.';
	END IF;
	
	SELECT 
		precio
	INTO v_PrecioActual
	FROM productos
	WHERE id_producto = p_id_producto;
	
	RETURN v_PrecioActual;
END //

DELIMITER ;

-- SELECT fn_ObtenerPrecioProducto (1) AS Precio;



-- 4. fn_CalcularEdadCliente (Agregué fecha_nacimiento en Tabla)
-- ALTER TABLE clientes
-- ADD COLUMN fecha_nacimiento DATE NOT NULL;
DELIMITER //

CREATE FUNCTION fn_CalcularEdadCliente (p_id_cliente INT)
RETURNS INT
NOT DETERMINISTIC
READS SQL DATA

BEGIN
	DECLARE v_FechaNacimiento DATE;

	IF NOT EXISTS (
		SELECT 1
		FROM clientes
		WHERE id_cliente = p_id_cliente
	) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'El ID del cliente no coincide con la base de datos.';
	END IF;

	SELECT fecha_nacimiento
	INTO v_FechaNacimiento
	FROM clientes
	WHERE id_cliente = p_id_cliente;
	
	RETURN TIMESTAMPDIFF(YEAR, v_FechaNacimiento, CURRENT_DATE);
END //

DELIMITER ;

-- SELECT fn_CalcularEdadCliente(2);



-- 5. fn_FormatearNombreCompleto
DELIMITER //

CREATE FUNCTION fn_FormatearNombreCompleto (p_id_cliente INT)
RETURNS VARCHAR(100)
DETERMINISTIC
READS SQL DATA


BEGIN
	DECLARE v_NombreCompleto VARCHAR(100);

	IF NOT EXISTS (
		SELECT 1
		FROM clientes
		WHERE id_cliente = p_id_cliente
	) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'El ID del cliente no coincide con la base de datos.';
	END IF;
	
	SELECT 
		UPPER(CONCAT(nombre, ' ', apellido))
	INTO v_NombreCompleto
	FROM clientes
	WHERE id_cliente = p_id_cliente;
	
	RETURN v_NombreCompleto;
END //
DELIMITER ;

-- SELECT fn_FormatearNombreCompleto(2);



-- 6. fn_EsClienteNuevo
DELIMITER //

CREATE FUNCTION fn_EsClienteNuevo (p_id_cliente INT)
RETURNS VARCHAR(100)
NOT DETERMINISTIC
READS SQL DATA

BEGIN
	DECLARE v_FechaCompra DATE;

	IF NOT EXISTS (
		SELECT 1
		FROM clientes
		WHERE id_cliente = p_id_cliente
	) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'El ID del cliente no coincide con la base de datos.';
	END IF;

	SELECT MIN(fecha_venta)
	INTO v_FechaCompra
	FROM ventas
	WHERE cliente_id = p_id_cliente;
	
	IF v_FechaCompra >= DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY) THEN
		RETURN CONCAT('VERDADERO: el cliente ', p_id_cliente, ' es nuevo.');
	ELSE 
		RETURN CONCAT('FALSO: el cliente ', p_id_cliente, ' es antiguo.');
	END IF;
END //

DELIMITER ;

-- SELECT fn_EsClienteNuevo(20) ClienteNuevo;



-- 7. fn_CalcularCostoEnvio
-- ALTER TABLE productos
-- ADD COLUMN peso_kg DECIMAL(5,2) NOT NULL;
DELIMITER //

CREATE FUNCTION fn_CalcularCostoEnvio (p_id_venta INT)
RETURNS VARCHAR(100)
DETERMINISTIC
READS SQL DATA

BEGIN
	DECLARE v_PesoTotal DECIMAL(10,2);
	
	IF NOT EXISTS (
		SELECT 1
		FROM ventas
		WHERE id_venta = p_id_venta
	) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'El ID de la venta no coincide con la base de datos.';
	END IF;
	
	SELECT
		SUM(p.peso_kg * dv.cantidad)
	INTO v_PesoTotal
	FROM productos p
	JOIN detalle_de_venta dv
		ON p.id_producto = dv.producto_id
	WHERE venta_id = p_id_venta;
	
	IF v_PesoTotal <= 5 THEN
		RETURN CONCAT('Por ', v_PesoTotal, 'kg = $10.000');
	ELSEIF v_PesoTotal <= 10 THEN 
		RETURN CONCAT('Por ', v_PesoTotal, 'kg = $12.000');
	ELSEIF v_PesoTotal <= 15 THEN 
		RETURN CONCAT('Por ', v_PesoTotal, 'kg = $14.000');
	ELSE 
		RETURN CONCAT('Por ', v_PesoTotal, 'kg = $20.000');
	END IF;
END //

DELIMITER ;

-- SELECT fn_CalcularCostoEnvio(1) AS CostodeEnvio;



-- 8. fn_AplicarDescuento
DELIMITER //

CREATE FUNCTION fn_AplicarDescuento (
	p_id_venta INT, 
	p_porcentaje DECIMAL(5,2)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA

BEGIN 
	DECLARE v_PrecioConDescuento DECIMAL(10,2);

	IF NOT EXISTS (
		SELECT 1
		FROM ventas
		WHERE id_venta = p_id_venta
	) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'El ID de la venta no coincide con la base de datos.';
	END IF;
		
	IF p_porcentaje < 0 OR p_porcentaje >= 100 THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Porcentaje de descuento inválido.';
	END IF;
	
	SELECT 
		total - (total * p_porcentaje / 100)
	INTO v_PrecioConDescuento
	FROM ventas
	WHERE id_venta = p_id_venta;
	
	RETURN v_PrecioConDescuento;
END //

DELIMITER ;

-- SELECT fn_AplicarDescuento(1,20) AS TotalPosDescuento;


DELIMITER //

CREATE FUNCTION fn_AplicarDescuento2 (
    p_porcentaje DECIMAL(5,2),
    p_monto DECIMAL(10,2)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
NO SQL
BEGIN

    IF p_porcentaje < 0 OR p_porcentaje > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Porcentaje de descuento inválido.';
    END IF;

    IF p_monto < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El monto no puede ser negativo.';
    END IF;

    RETURN ROUND(
        p_monto - (p_monto * p_porcentaje / 100),
        2
    );

END //

DELIMITER ;

-- SELECT fn_AplicarDescuento2(20, 100000) AS TotalConDescuento;



-- 9. fn_ObtenerUltimaFechaCompra
DELIMITER //

CREATE FUNCTION fn_ObtenerUltimaFechaCompra (p_id_cliente INT)
RETURNS DATE
DETERMINISTIC 
READS SQL DATA

BEGIN
	DECLARE v_UltimaCompra DATE;

	IF NOT EXISTS (
		SELECT 1
		FROM ventas
		WHERE cliente_id = p_id_cliente
	) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'El ID del cliente no coincide con la base de datos.';
	END IF;
	
	SELECT 
		MAX(fecha_venta)
	INTO v_UltimaCompra
	FROM ventas
	WHERE cliente_id = p_id_cliente;
	
	RETURN v_UltimaCompra;
END //

DELIMITER ;

-- SELECT fn_ObtenerUltimaFechaCompra(1) AS UltimaCompra_DATE;



-- 10. fn_ValidarFormatoEmail
DELIMITER //

CREATE FUNCTION fn_ValidarFormatoEmail (p_email VARCHAR(100))
RETURNS VARCHAR(50)
DETERMINISTIC
NO SQL

BEGIN
	IF p_email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
		RETURN 'Correo válido.';
	ELSE
		RETURN 'Correo inválido.';
	END IF;
END //

DELIMITER ;

-- SELECT fn_ValidarFormatoEmail('yuritrojasmantilla@gmail.com') AS Formato_CorreoElectronico;

