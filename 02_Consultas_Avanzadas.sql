USE ecommerce;

-- ================================================
-- CONSULTAS AVANZADAS
-- ================================================

-- 1. Top 10 productos más vendidos.
SELECT
	p.nombre AS Producto,
	SUM(dv.cantidad * dv.precio_unitario_congelado) AS TotalGenerado
FROM productos AS p
INNER JOIN detalle_de_venta dv
	ON p.id_producto = dv.producto_id
GROUP BY p.id_producto, p.nombre 
ORDER BY TotalGenerado DESC 
LIMIT 10;

SELECT
	p.nombre AS producto,
	SUM(dv.cantidad) AS totales_vendidos
FROM detalle_de_venta dv
JOIN productos p
	ON dv.producto_id = p.id_producto
GROUP BY p.id_producto, p.nombre
ORDER BY totales_vendidos DESC
LIMIT 10;

-- 3. 5 Clientes VIP
SELECT 
	c.nombre AS Cliente,
	SUM(v.total) AS GastoTotalHistorico
FROM clientes c 
INNER JOIN ventas v
	ON c.id_cliente = v.cliente_id
WHERE v.estado <> 'Cancelado'
GROUP BY c.nombre, c.id_cliente
ORDER BY GastoTotalHistorico DESC
LIMIT 5;


-- 4. Análisis de ventas mensuales
SELECT
	YEAR(fecha_venta) AS Año,
	MONTH(fecha_venta) AS Mes,
	SUM(total) AS TotalVentas
FROM ventas
GROUP BY YEAR(fecha_venta), MONTH(fecha_venta)
ORDER BY YEAR(fecha_venta) DESC, MONTH(fecha_venta) DESC;


-- 5. Crecimiento de clientes
SELECT 
	YEAR(fecha_registro) AS Año,
	QUARTER(fecha_registro) Trimestre,
	COUNT(id_cliente) ClientesNuevosRegistrados
FROM clientes
GROUP BY YEAR(fecha_registro), QUARTER(fecha_registro)
ORDER BY YEAR(fecha_registro) DESC, QUARTER(fecha_registro) DESC;


-- 7. Productos comprados juntos frecuentemente
SELECT all 
	p1.nombre AS Producto1,
	p2.nombre AS Producto2,
	COUNT(*) AS Frecuencia
FROM detalle_de_venta dv1
INNER JOIN detalle_de_venta dv2
	ON dv1.venta_id = dv2.venta_id
	AND dv1.producto_id < dv2.producto_id
INNER JOIN productos p1
	ON dv1.producto_id = p1.id_producto
INNER JOIN productos p2
	ON dv2.producto_id = p2.id_producto
GROUP BY dv1.producto_id, dv2.producto_id, p1.nombre, p2.nombre
ORDER BY Frecuencia DESC;


-- 8. Rotación de inventario
SELECT
	c.nombre AS Categoria,
	SUM(dv.cantidad) / SUM(p.stock) AS Rotacion
FROM productos p
INNER JOIN detalle_de_venta dv
	ON p.id_producto = dv.producto_id
INNER JOIN categorias c
	ON p.categoria_id = c.id_categoria
GROUP BY c.id_categoria, c.nombre
ORDER BY Rotacion DESC;

SELECT
	c.nombre AS Categoria,
	SUM(dv.cantidad) / (
		SELECT SUM(p2.stock)
		FROM productos p2
		WHERE p2.categoria_id = c.id_categoria
		) AS Rotacion
FROM productos p
JOIN detalle_de_venta dv
	ON p.id_producto = dv.producto_id
JOIN categorias c
	ON p.categoria_id = c.id_categoria
GROUP BY c.id_categoria, c.nombre
ORDER BY Rotacion DESC;

	
-- 9. Productos que necesitan reabastecimiento
SELECT 
	id_producto AS ID,
	nombre AS Producto,
	stock AS Stock,
	sku AS SKU
FROM productos
WHERE stock < 10
ORDER BY stock ASC;


-- 10. Análisis de carrito abandonado
SELECT
	c.id_cliente AS ID_Cliente,
	c.nombre AS Cliente,
	v.id_venta AS ID_Venta,
	v.estado AS Estado
FROM ventas v
INNER JOIN clientes c 
	ON v.cliente_id = c.id_cliente
WHERE v.estado = 'Cancelado';


-- 11. Rendimiento de proovedores
SELECT
	pv.id_proveedor AS ID_Proveedor,
	pv.nombre AS Proveedor,
	SUM(dv.cantidad) AS VolumenVendido
FROM proveedores pv
INNER JOIN productos p
	ON pv.id_proveedor = p.proveedor_id
INNER JOIN detalle_de_venta dv
	ON p.id_producto = dv.producto_id
GROUP BY pv.id_proveedor, pv.nombre
ORDER BY VolumenVendido DESC;


-- 12. Análisis geográfico de ventas
SELECT
	c.municipio AS Municipio,
	COUNT(v.id_venta) AS CantidadVentas,
	SUM(v.total) AS TotalVentas
FROM ventas v
INNER JOIN clientes c 
	ON v.cliente_id = c.id_cliente
GROUP BY c.municipio
ORDER BY TotalVentas DESC;


-- 13. Ventas por hora del día
SELECT
	HOUR(fecha_venta) AS Hora,
	COUNT(id_venta) AS CantidadVentas
FROM ventas
GROUP BY HOUR(fecha_venta)
ORDER BY Hora ASC;


-- 15. Análisis de Cohort
SELECT
	CONCAT(
		YEAR(PrimeraCompra), 
		' - ',
		MONTH(PrimeraCompra)
	) AS Cohorte,		
	TIMESTAMPDIFF(
		MONTH,
		PrimeraCompra,
		FechaVenta
	) AS MesDesdePrimeraCompra,
	COUNT(DISTINCT cliente_id) AS ClientesRetenidos		
FROM (
	SELECT 
		v.cliente_id,
		v.fecha_venta AS FechaVenta,
		MIN(v2.fecha_venta) AS PrimeraCompra
	FROM ventas v
	INNER JOIN ventas v2
		ON v.cliente_id = v2.cliente_id
	GROUP BY v.cliente_id, v.fecha_venta
) AS Compras
GROUP BY 
	CONCAT(
		YEAR(PrimeraCompra), 
		' - ',
		MONTH(PrimeraCompra)
	),	
	TIMESTAMPDIFF(
		MONTH,
		PrimeraCompra,
		FechaVenta
	)
ORDER BY Cohorte, MesDesdePrimeraCompra;