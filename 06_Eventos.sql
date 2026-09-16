USE ecommerce;

-- ================================================
-- EVENTOS
-- ================================================

DROP EVENT IF EXISTS evt_generate_weekly_sales_report;
DROP EVENT IF EXISTS evt_cleanup_temp_tables_daily;
DROP EVENT IF EXISTS evt_archive_old_logs_monthly;
DROP EVENT IF EXISTS evt_deactivate_expired_promotions_hourly;
DROP EVENT IF EXISTS evt_recalculate_customer_loyalty_tiers_nightly;
DROP EVENT IF EXISTS evt_generate_reorder_list_daily;
DROP EVENT IF EXISTS evt_rebuild_indexes_weekly;
DROP EVENT IF EXISTS evt_suspend_inactive_accounts_quarterly;
DROP EVENT IF EXISTS evt_aggregate_daily_sales_data;
DROP EVENT IF EXISTS evt_check_data_consistency_nightly;

SET GLOBAL event_scheduler = ON;


-- 1. evt_generate_weekly_sales_report
-- CREATE TABLE reportes_ventas_semanales (
--    id_reporte       INT AUTO_INCREMENT PRIMARY KEY,
--    fecha_inicio     DATE NOT NULL,
--    fecha_fin        DATE NOT NULL,
--    cantidad_ventas  INT NOT NULL,
--    total_ventas     DECIMAL(10,2) NOT NULL,
--    fecha_generacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- );

DELIMITER //

CREATE EVENT evt_generate_weekly_sales_report
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    INSERT INTO reportes_ventas_semanales (
        fecha_inicio,
        fecha_fin,
        cantidad_ventas,
        total_ventas
    )
    SELECT
        DATE_SUB(CURRENT_DATE, INTERVAL 7 DAY),
        CURRENT_DATE,
        COUNT(id_venta),
        COALESCE(SUM(total), 0)
    FROM ventas
    WHERE fecha_venta >= DATE_SUB(CURRENT_DATE, INTERVAL 7 DAY)
      AND fecha_venta < CURRENT_DATE
      AND estado != 'Cancelado';
END //

DELIMITER ;




-- 2. evt_cleanup_temp_tables_daily
-- CREATE TABLE temp_datos_ventas (
--    id INT AUTO_INCREMENT PRIMARY KEY,
--    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- );

DELIMITER //

CREATE EVENT evt_cleanup_temp_tables_daily
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    DELETE FROM temp_datos_ventas;
END //

DELIMITER ;



-- 3. evt_archive_old_logs_monthly
-- CREATE TABLE historial_logs_precios (
--    id_log INT,
--    producto_id INT,
--    precio_anterior DECIMAL(10,2),
--    precio_nuevo DECIMAL(10,2),
--    fecha_cambio TIMESTAMP
-- );

DELIMITER //

CREATE EVENT evt_archive_old_logs_monthly
ON SCHEDULE EVERY 1 MONTH
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    INSERT INTO historial_logs_precios
    SELECT *
    FROM logs_precios
    WHERE fecha_cambio < DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 6 MONTH);

    DELETE FROM logs_precios
    WHERE fecha_cambio < DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 6 MONTH);
END //

DELIMITER ;



-- 4. evt_deactivate_expired_promotions_hourly
-- CREATE TABLE promociones (
--    id_promocion INT AUTO_INCREMENT PRIMARY KEY,
--    codigo VARCHAR(50) NOT NULL UNIQUE,
--    porcentaje DECIMAL(5,2) NOT NULL,
--    fecha_expiracion DATE NOT NULL,
--    activa BOOLEAN DEFAULT TRUE
-- );

DELIMITER //

CREATE EVENT evt_deactivate_expired_promotions_hourly
ON SCHEDULE EVERY 1 HOUR
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    UPDATE promociones
    SET activa = FALSE
    WHERE fecha_expiracion <= CURRENT_DATE
      AND activa = TRUE;
END //

DELIMITER ;



-- 5. evt_recalculate_customer_loyalty_tiers_nightly
ALTER TABLE clientes
ADD COLUMN nivel_lealtad VARCHAR(20) DEFAULT 'Bronce';

DELIMITER //

CREATE EVENT evt_recalculate_customer_loyalty_tiers_nightly
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    UPDATE clientes
    SET nivel_lealtad =
        CASE
            WHEN total_gastado >= 5000000 THEN 'Oro'
            WHEN total_gastado >= 1000000 THEN 'Plata'
            ELSE 'Bronce'
        END;
END //

DELIMITER ;



-- 6. evt_generate_reorder_list_daily
-- CREATE TABLE lista_reabastecimiento (
--    id_reabastecimiento INT AUTO_INCREMENT PRIMARY KEY,
--    producto_id INT NOT NULL,
--    stock_actual INT NOT NULL,
--    fecha_generacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--    FOREIGN KEY (producto_id) REFERENCES productos(id_producto)
-- );

DELIMITER //

CREATE EVENT evt_generate_reorder_list_daily
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    DELETE FROM lista_reabastecimiento;

    INSERT INTO lista_reabastecimiento (
        producto_id,
        stock_actual
    )
    SELECT
        id_producto,
        stock
    FROM productos
    WHERE stock < 5;
END //

DELIMITER ;



-- 7. evt_rebuild_indexes_weekly
DELIMITER //

CREATE EVENT evt_rebuild_indexes_weekly
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    OPTIMIZE TABLE productos;
    OPTIMIZE TABLE ventas;
    OPTIMIZE TABLE detalle_de_venta;
END //

DELIMITER ;



-- 8. evt_suspend_inactive_accounts_quarterly
ALTER TABLE clientes
ADD COLUMN activo BOOLEAN DEFAULT TRUE;

DELIMITER //

CREATE EVENT evt_suspend_inactive_accounts_quarterly
ON SCHEDULE EVERY 3 MONTH
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    UPDATE clientes c
    SET activo = FALSE
    WHERE activo = TRUE
      AND NOT EXISTS (
          SELECT 1
          FROM ventas v
          WHERE v.cliente_id = c.id_cliente
            AND v.fecha_venta >= DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR)
      );
END //

DELIMITER ;



-- 9. EVENT evt_aggregate_daily_sales_data
-- CREATE TABLE resumen_ventas_diarias (
--    id_resumen INT AUTO_INCREMENT PRIMARY KEY,
--    fecha DATE NOT NULL UNIQUE,
--    cantidad_ventas INT NOT NULL,
--    total_ventas DECIMAL(10,2) NOT NULL,
--    promedio_venta DECIMAL(10,2) NOT NULL
-- );

DELIMITER //

CREATE EVENT evt_aggregate_daily_sales_data
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    INSERT INTO resumen_ventas_diarias (
        fecha,
        cantidad_ventas,
        total_ventas,
        promedio_venta
    )
    SELECT
        DATE(fecha_venta),
        COUNT(id_venta),
        SUM(total),
        AVG(total)
    FROM ventas
    WHERE DATE(fecha_venta) = DATE_SUB(CURRENT_DATE, INTERVAL 1 DAY)
    	AND estado != 'Cancelado'
    GROUP BY DATE(fecha_venta)
    ON DUPLICATE KEY UPDATE
        cantidad_ventas = VALUES(cantidad_ventas),
        total_ventas = VALUES(total_ventas),
        promedio_venta = VALUES(promedio_venta);
END //

DELIMITER ;




-- 10. evt_check_data_consistency_nightly
-- CREATE TABLE inconsistencias_datos (
--    id_inconsistencia INT AUTO_INCREMENT PRIMARY KEY,
--    tipo VARCHAR(100) NOT NULL,
--    descripcion VARCHAR(255) NOT NULL,
--    fecha_deteccion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- );

DELIMITER //

CREATE EVENT evt_check_data_consistency_nightly
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    INSERT INTO inconsistencias_datos (
        tipo,
        descripcion
    )
    SELECT
        'Venta sin detalles',
        CONCAT('La venta ', v.id_venta, ' no tiene detalles asociados.')
    FROM ventas v
    LEFT JOIN detalle_de_venta dv
        ON v.id_venta = dv.venta_id
    WHERE dv.id_detalle IS NULL;
END //

DELIMITER ;
