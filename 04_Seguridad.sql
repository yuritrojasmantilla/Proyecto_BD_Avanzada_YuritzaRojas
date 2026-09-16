USE ecommerce;

-- ================================================
-- SEGURIDAD BASE DE DATOS
-- ================================================

-- 1.
CREATE ROLE IF NOT EXISTS 'Administrador_Sistema';

GRANT ALL PRIVILEGES ON ecommerce.* TO 'Administrador_Sistema';

-- 2. 
CREATE ROLE IF NOT EXISTS 'Gerente_Marketing';

GRANT SELECT ON ecommerce.ventas TO 'Gerente_Marketing';
GRANT SELECT ON ecommerce.clientes TO 'Gerente_Marketing';

-- 3.
CREATE ROLE IF NOT EXISTS 'Analista_Datos';

GRANT SELECT ON ecommerce.categorias TO 'Analista_Datos';
GRANT SELECT ON ecommerce.proveedores TO 'Analista_Datos';
GRANT SELECT ON ecommerce.productos TO 'Analista_Datos';
GRANT SELECT ON ecommerce.clientes TO 'Analista_Datos';
GRANT SELECT ON ecommerce.ventas TO 'Analista_Datos';
GRANT SELECT ON ecommerce.detalle_de_venta TO 'Analista_Datos';
GRANT SELECT ON ecommerce.devoluciones TO 'Analista_Datos';
GRANT SELECT ON ecommerce.promociones TO 'Analista_Datos';
GRANT SELECT ON ecommerce.lista_reabastecimiento TO 'Analista_Datos';

-- 4.
CREATE ROLE IF NOT EXISTS 'Empleado_Inventario';

GRANT UPDATE (stock, sku) ON ecommerce.productos TO 'Empleado_Inventario';

-- 5.
CREATE ROLE IF NOT EXISTS 'Atencion_Cliente';

GRANT SELECT ON ecommerce.clientes TO 'Atencion_Cliente';
GRANT SELECT ON ecommerce.ventas TO 'Atencion_Cliente';

-- 6.
CREATE ROLE IF NOT EXISTS 'Auditor_Financiero';

GRANT SELECT ON ecommerce.ventas TO 'Auditor_Financiero';
GRANT SELECT ON ecommerce.productos TO 'Auditor_Financiero';
GRANT SELECT ON ecommerce.logs_precios TO 'Auditor_Financiero';

-- 7. 
CREATE USER IF NOT EXISTS 'admin_user'@'localhost'
IDENTIFIED BY 'Admin123';

GRANT 'Administrador_Sistema'
TO 'admin_user'@'localhost';

SET DEFAULT ROLE 'Administrador_Sistema'
TO 'admin_user'@'localhost';

-- 8. 
CREATE USER IF NOT EXISTS 'marketing_user'@'localhost'
IDENTIFIED BY 'Marketing123';

GRANT 'Gerente_Marketing'
TO 'marketing_user'@'localhost';

SET DEFAULT ROLE 'Gerente_Marketing'
TO 'marketing_user'@'localhost';

-- 9. 
CREATE USER IF NOT EXISTS 'inventory_user'@'localhost'
IDENTIFIED BY 'Inventory123';

GRANT 'Empleado_Inventario'
TO 'inventory_user'@'localhost';

SET DEFAULT ROLE 'Empleado_Inventario'
TO 'inventory_user'@'localhost';

-- 10.
CREATE USER IF NOT EXISTS 'support_user'@'localhost'
IDENTIFIED BY 'Support123';

GRANT 'Atencion_Cliente'
TO 'support_user'@'localhost';

SET DEFAULT ROLE 'Atencion_Cliente'
TO 'support_user'@'localhost';

-- 11.
REVOKE DELETE, DROP ON ecommerce.* FROM 'Analista_Datos';