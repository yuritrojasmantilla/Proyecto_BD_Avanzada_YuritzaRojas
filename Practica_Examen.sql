/*
===============================================================================
TALLER DE PRACTICA: BASE DE DATOS DE UN E-COMMERCE (MYSQL AVANZADO)
===============================================================================
*/

USE ecommerce;


/*=============================================================================
1. EVENTO PROGRAMADO: DESACTIVAR PRODUCTOS SIN ROTACION
=============================================================================*/

-- La columna conserva la fecha de la venta mas reciente de cada producto.
ALTER TABLE productos
    ADD COLUMN fecha_ultima_venta DATETIME NULL DEFAULT NULL;

-- Inicializa la columna con el historial que ya existe antes de crear el trigger.
UPDATE productos AS p
LEFT JOIN (
    SELECT
        dv.producto_id,
        MAX(v.fecha_venta) AS ultima_venta
    FROM detalle_de_venta AS dv
    INNER JOIN ventas AS v
        ON v.id_venta = dv.venta_id
    GROUP BY dv.producto_id
) AS historial
    ON historial.producto_id = p.id_producto
SET p.fecha_ultima_venta = historial.ultima_venta;

DROP TRIGGER IF EXISTS trg_actualizar_fecha_ultima_venta;

DELIMITER //

CREATE TRIGGER trg_actualizar_fecha_ultima_venta
AFTER INSERT ON detalle_de_venta
FOR EACH ROW
BEGIN
    /*
      Se toma la fecha de la venta asociada al detalle. Si por alguna razon la
      fecha fuera NULL, se utiliza el instante actual como valor de respaldo.
    */
    UPDATE productos AS p
    SET p.fecha_ultima_venta = COALESCE(
        (SELECT v.fecha_venta
         FROM ventas AS v
         WHERE v.id_venta = NEW.venta_id),
        NOW()
    )
    WHERE p.id_producto = NEW.producto_id;
END //

DELIMITER ;

DROP EVENT IF EXISTS evt_desactivar_productos_obsoletos;

-- Esta instruccion necesita privilegios administrativos.
SET GLOBAL event_scheduler = ON;

DELIMITER //

CREATE EVENT evt_desactivar_productos_obsoletos
ON SCHEDULE EVERY 1 MONTH
STARTS TIMESTAMP(DATE_FORMAT(CURRENT_DATE + INTERVAL 1 MONTH,
                             '%Y-%m-01 00:00:00'))
DO
BEGIN
    /*
      Caso 1: el producto tuvo ventas, pero la ultima fue hace mas de un ano.
      Caso 2: nunca se vendio y fue creado hace mas de un ano.
    */
    UPDATE productos
    SET activo = FALSE
    WHERE activo = TRUE
      AND (
            fecha_ultima_venta < NOW() - INTERVAL 1 YEAR
            OR (
                fecha_ultima_venta IS NULL
                AND fecha_creacion < NOW() - INTERVAL 1 YEAR
            )
          );
END //

DELIMITER ;


/*=============================================================================
2. TRIGGER: AUDITORIA DE CAMBIOS DE PRECIO Y COSTO
=============================================================================*/

CREATE TABLE IF NOT EXISTS auditoria_precios_productos (
    id_auditoria      INT AUTO_INCREMENT PRIMARY KEY,
    id_producto       INT NOT NULL,
    campo_modificado  VARCHAR(20) NOT NULL,
    valor_antiguo     DECIMAL(10,2) NOT NULL,
    valor_nuevo       DECIMAL(10,2) NOT NULL,
    usuario           VARCHAR(288) NOT NULL,
    fecha_modificacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_auditoria_producto
        FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

DROP TRIGGER IF EXISTS trg_audit_producto_after_update;

DELIMITER //

CREATE TRIGGER trg_audit_producto_after_update
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN
    /* Cada IF es independiente: si cambian ambos campos se insertan dos filas. */
    IF NOT (NEW.precio <=> OLD.precio) THEN
        INSERT INTO auditoria_precios_productos
            (id_producto, campo_modificado, valor_antiguo, valor_nuevo,
             usuario, fecha_modificacion)
        VALUES
            (NEW.id_producto, 'precio', OLD.precio, NEW.precio,
             CURRENT_USER(), NOW());
    END IF;

    IF NOT (NEW.costo <=> OLD.costo) THEN
        INSERT INTO auditoria_precios_productos
            (id_producto, campo_modificado, valor_antiguo, valor_nuevo,
             usuario, fecha_modificacion)
        VALUES
            (NEW.id_producto, 'costo', OLD.costo, NEW.costo,
             CURRENT_USER(), NOW());
    END IF;
END //

DELIMITER ;


/*=============================================================================
3. PROCEDIMIENTO: CANCELACION TRANSACCIONAL Y RESTAURACION DE STOCK
=============================================================================*/

CREATE TABLE IF NOT EXISTS cancelaciones_ventas (
    id_cancelacion    INT AUTO_INCREMENT PRIMARY KEY,
    id_venta          INT NOT NULL,
    motivo            VARCHAR(500) NOT NULL,
    fecha_cancelacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_cancelacion_venta UNIQUE (id_venta),
    CONSTRAINT fk_cancelacion_venta
        FOREIGN KEY (id_venta) REFERENCES ventas(id_venta)
);

DROP PROCEDURE IF EXISTS sp_CancelarVenta;

DELIMITER //

CREATE PROCEDURE sp_CancelarVenta (
    IN id_venta_in INT,
    IN motivo_in   VARCHAR(500)
)
BEGIN
    DECLARE v_existe INT DEFAULT 0;
    DECLARE v_estado VARCHAR(30);

    /* Cualquier error revierte en conjunto inventario, estado y bitacora. */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    IF id_venta_in IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Debe indicar el identificador de la venta.';
    END IF;

    IF motivo_in IS NULL OR TRIM(motivo_in) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Debe indicar el motivo de la cancelacion.';
    END IF;

    SELECT COUNT(*)
    INTO v_existe
    FROM ventas
    WHERE id_venta = id_venta_in;

    IF v_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La venta indicada no existe.';
    END IF;

    /* FOR UPDATE bloquea la venta y evita cancelaciones concurrentes. */
    SELECT estado
    INTO v_estado
    FROM ventas
    WHERE id_venta = id_venta_in
    FOR UPDATE;

    IF v_estado = 'Cancelado' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La venta ya se encuentra cancelada.';
    END IF;

    IF v_estado = 'Entregado' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se puede cancelar una venta entregada.';
    END IF;

    /*
      La subconsulta agrupa por producto; asi funciona incluso si una orden
      tuviera varias lineas para el mismo articulo.
    */
    UPDATE productos AS p
    INNER JOIN (
        SELECT producto_id, SUM(cantidad) AS cantidad_a_reintegrar
        FROM detalle_de_venta
        WHERE venta_id = id_venta_in
        GROUP BY producto_id
    ) AS d
        ON d.producto_id = p.id_producto
    SET p.stock = p.stock + d.cantidad_a_reintegrar;

    UPDATE ventas
    SET estado = 'Cancelado'
    WHERE id_venta = id_venta_in;

    INSERT INTO cancelaciones_ventas
        (id_venta, motivo, fecha_cancelacion)
    VALUES
        (id_venta_in, TRIM(motivo_in), NOW());

    COMMIT;
END //

DELIMITER ;


/*=============================================================================
4. FUNCION: MARGEN NETO GENERADO POR UN CLIENTE
=============================================================================*/

DROP FUNCTION IF EXISTS fn_CalcularMargenNetoCliente;

DELIMITER //

CREATE FUNCTION fn_CalcularMargenNetoCliente (id_cliente_in INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_margen DECIMAL(12,2) DEFAULT 0.00;

    /*
      Solo se consideran ventas efectivas: Enviado y Entregado. COALESCE hace
      que un cliente sin compras efectivas obtenga 0.00 en lugar de NULL.

      Se declara DETERMINISTIC conforme al requisito academico del ejercicio:
      para un mismo estado de los datos y el mismo cliente produce igual valor.
      En sentido estricto, el resultado puede variar si las tablas se modifican.
    */
    SELECT COALESCE(
               SUM((dv.precio_unitario_congelado - p.costo) * dv.cantidad),
               0.00
           )
    INTO v_margen
    FROM ventas AS v
    INNER JOIN detalle_de_venta AS dv
        ON dv.venta_id = v.id_venta
    INNER JOIN productos AS p
        ON p.id_producto = dv.producto_id
    WHERE v.cliente_id = id_cliente_in
      AND v.estado IN ('Entregado', 'Enviado');

    RETURN v_margen;
END //

DELIMITER ;


/*=============================================================================
5. CONSULTA AVANZADA: CLASIFICACION ABC POR INGRESOS
=============================================================================*/

WITH ventas_por_producto AS (
    /*
      LEFT JOIN incluye todo el catalogo, incluso productos sin ventas.
      Las ventas canceladas no representan facturacion efectiva.
    */
    SELECT
        p.id_producto,
        p.nombre AS producto,
        c.nombre AS categoria,
        COALESCE(
            SUM(
                CASE
                    WHEN v.estado <> 'Cancelado'
                    THEN dv.cantidad * dv.precio_unitario_congelado
                    ELSE 0
                END
            ),
            0
        ) AS total_ventas
    FROM productos AS p
    INNER JOIN categorias AS c
        ON c.id_categoria = p.categoria_id
    LEFT JOIN detalle_de_venta AS dv
        ON dv.producto_id = p.id_producto
    LEFT JOIN ventas AS v
        ON v.id_venta = dv.venta_id
    GROUP BY p.id_producto, p.nombre, c.nombre
),
metricas AS (
    SELECT
        id_producto,
        producto,
        categoria,
        total_ventas,
        SUM(total_ventas) OVER () AS facturacion_global,
        SUM(total_ventas) OVER (
            ORDER BY total_ventas DESC, id_producto ASC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS ventas_acumuladas
    FROM ventas_por_producto
),
porcentajes AS (
    SELECT
        id_producto,
        producto,
        categoria,
        total_ventas,
        COALESCE(
            100.0 * total_ventas / NULLIF(facturacion_global, 0),
            0.0
        ) AS porcentaje_participacion,
        COALESCE(
            100.0 * ventas_acumuladas / NULLIF(facturacion_global, 0),
            0.0
        ) AS porcentaje_acumulado
    FROM metricas
)
SELECT
    id_producto,
    producto,
    categoria,
    ROUND(total_ventas, 2) AS total_ventas,
    ROUND(porcentaje_participacion, 2) AS porcentaje_participacion,
    ROUND(porcentaje_acumulado, 2) AS porcentaje_acumulado,
    CASE
        WHEN porcentaje_acumulado <= 80 THEN 'Clase A'
        WHEN porcentaje_acumulado <= 95 THEN 'Clase B'
        ELSE 'Clase C'
    END AS clasificacion_abc
FROM porcentajes
ORDER BY total_ventas DESC, id_producto ASC;


/*=============================================================================
PRUEBAS OPCIONALES
===============================================================================

-- Verificar el evento y el planificador:
SHOW VARIABLES LIKE 'event_scheduler';
SHOW EVENTS FROM ecommerce LIKE 'evt_desactivar_productos_obsoletos';

-- Probar la auditoria (reemplace 1 por un producto existente):
UPDATE productos
SET precio = precio + 1000,
    costo  = costo + 500
WHERE id_producto = 1;
SELECT * FROM auditoria_precios_productos ORDER BY id_auditoria DESC;

-- Probar la funcion (reemplace 1 por un cliente existente):
SELECT fn_CalcularMargenNetoCliente(1) AS margen_neto_cliente;

-- Probar la cancelacion solo con una venta Pendiente de pago o Procesando:
CALL sp_CancelarVenta(4, 'Solicitud del cliente');
SELECT * FROM cancelaciones_ventas ORDER BY id_cancelacion DESC;

=============================================================================*/
