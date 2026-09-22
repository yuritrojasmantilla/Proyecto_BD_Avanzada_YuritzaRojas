# Requisitos del proyecto de base de datos E-commerce

## 1. Consultas avanzadas (20 puntos)

1. **Top 10 productos más vendidos:** crear una consulta que ordene los productos según los ingresos generados y muestre los diez con mayor facturación.
2. **Productos con bajas ventas:** identificar los productos ubicados en el 10 % inferior de ventas para apoyar decisiones sobre su posible descontinuación.
3. **Clientes VIP:** mostrar los cinco clientes con mayor valor de vida, calculado a partir de todo el dinero que han gastado históricamente.
4. **Análisis de ventas mensuales:** agrupar y sumar las ventas por mes y año para observar el comportamiento de la facturación a través del tiempo.
5. **Crecimiento de clientes:** calcular cuántos clientes nuevos se registraron en cada trimestre.
6. **Tasa de compra repetida:** determinar qué porcentaje de los clientes ha realizado más de una compra.
7. **Productos comprados juntos frecuentemente:** encontrar parejas de productos que aparecen repetidamente dentro de una misma venta.
8. **Rotación de inventario:** calcular la velocidad con la que se vende y renueva el inventario de cada categoría de productos.
9. **Productos que necesitan reabastecimiento:** listar los productos cuyo stock se encuentre por debajo del nivel mínimo establecido.
10. **Análisis de carrito abandonado:** identificar, mediante una simulación, los clientes que agregaron productos al carrito, pero no finalizaron la compra dentro del periodo definido.
11. **Rendimiento de proveedores:** clasificar los proveedores de acuerdo con el volumen de ventas alcanzado por los productos que suministran.
12. **Análisis geográfico de ventas:** agrupar las ventas según la ciudad o región registrada para cada cliente.
13. **Ventas por hora del día:** establecer cuáles son las horas con mayor cantidad de compras para orientar las campañas de mercadeo.
14. **Impacto de promociones:** comparar las ventas de un producto antes, durante y después de una campaña de descuento.
15. **Análisis de cohortes:** analizar mes a mes la permanencia o retención de grupos de clientes desde el momento de su primera compra.
16. **Margen de beneficio por producto:** calcular la utilidad obtenida por cada producto mediante la diferencia entre su precio de venta y su costo.
17. **Tiempo promedio entre compras:** calcular el número medio de días que transcurre antes de que un cliente vuelva a comprar.
18. **Productos más vistos frente a productos comprados:** comparar el nivel de visitas de cada producto con la cantidad de compras realizadas.
19. **Segmentación de clientes RFM:** clasificar los clientes de acuerdo con la recencia de su última compra, la frecuencia de compra y el valor monetario gastado.
20. **Predicción simple de demanda:** utilizar el historial de ventas para estimar las ventas del próximo mes de una categoría específica.

## 2. Funciones definidas por el usuario (20 puntos)

1. **fn_CalcularTotalVenta:** crear una función que reciba una venta y devuelva su valor total calculado a partir de sus detalles.
2. **fn_VerificarDisponibilidadStock:** crear una función que compruebe si un producto dispone de unidades suficientes para atender una cantidad solicitada.
3. **fn_ObtenerPrecioProducto:** crear una función que reciba el identificador de un producto y retorne su precio actual.
4. **fn_CalcularEdadCliente:** crear una función que calcule la edad de un cliente utilizando su fecha de nacimiento.
5. **fn_FormatearNombreCompleto:** crear una función que una y presente el nombre y apellido del cliente con un formato uniforme.
6. **fn_EsClienteNuevo:** crear una función que indique si la primera compra de un cliente ocurrió durante los últimos 30 días.
7. **fn_CalcularCostoEnvio:** crear una función que calcule el costo del envío a partir del peso total de los productos incluidos en una venta.
8. **fn_AplicarDescuento:** crear una función que reciba un valor y un porcentaje de descuento, y devuelva el monto resultante.
9. **fn_ObtenerUltimaFechaCompra:** crear una función que retorne la fecha de la compra más reciente realizada por un cliente.
10. **fn_ValidarFormatoEmail:** crear una función que compruebe si una cadena cumple con la estructura básica de una dirección de correo electrónico.
11. **fn_ObtenerNombreCategoria:** crear una función que determine y devuelva el nombre de la categoría a la que pertenece un producto.
12. **fn_ContarVentasCliente:** crear una función que cuente la cantidad total de compras realizadas por un cliente.
13. **fn_CalcularDiasDesdeUltimaCompra:** crear una función que calcule cuántos días han pasado desde la última compra de un cliente.
14. **fn_DeterminarEstadoLealtad:** crear una función que asigne al cliente un nivel Bronce, Plata u Oro según su gasto acumulado.
15. **fn_GenerarSKU:** crear una función que produzca un código SKU único utilizando información como el nombre y la categoría del producto.
16. **fn_CalcularIVA:** crear una función que calcule el valor del IVA correspondiente al total de una venta.
17. **fn_ObtenerStockTotalPorCategoria:** crear una función que sume las existencias de todos los productos pertenecientes a una categoría.
18. **fn_EstimarFechaEntrega:** crear una función que estime la fecha de entrega de un pedido tomando en cuenta la ubicación del cliente.
19. **fn_ConvertirMoneda:** crear una función que convierta un monto a otra moneda mediante una tasa de cambio fija.
20. **fn_ValidarComplejidadContraseña:** crear una función que determine si una contraseña cumple requisitos como longitud y variedad de caracteres.

## 3. Seguridad y permisos (20 puntos)

1. **Rol Administrador_Sistema:** crear un rol con todos los privilegios necesarios para administrar completamente la base de datos.
2. **Rol Gerente_Marketing:** crear un rol con acceso de solo lectura a la información de ventas y clientes.
3. **Rol Analista_Datos:** crear un rol con acceso de lectura a todas las tablas, excepto aquellas destinadas a auditorías.
4. **Rol Empleado_Inventario:** crear un rol que únicamente pueda realizar las modificaciones autorizadas sobre la información de inventario de los productos, como stock y ubicación.
5. **Rol Atencion_Cliente:** crear un rol que pueda consultar clientes y ventas sin tener autorización para modificar precios.
6. **Rol Auditor_Financiero:** crear un rol de solo lectura para ventas, productos y registros históricos de cambios de precios.
7. **Usuario admin_user:** crear este usuario y asignarle el rol Administrador_Sistema.
8. **Usuario marketing_user:** crear este usuario y asignarle el rol Gerente_Marketing.
9. **Usuario inventory_user:** crear este usuario y asignarle el rol Empleado_Inventario.
10. **Usuario support_user:** crear este usuario y asignarle el rol Atencion_Cliente.
11. **Restricciones de Analista_Datos:** garantizar que este rol no pueda ejecutar operaciones DELETE ni TRUNCATE.
12. **Ejecución de reportes de marketing:** permitir que Gerente_Marketing ejecute los procedimientos almacenados relacionados con informes de mercadeo.
13. **Vista v_info_clientes_basica:** crear una vista que oculte los datos sensibles de los clientes y autorizar su consulta al rol Atencion_Cliente.
14. **Protección de precios:** retirar al rol Empleado_Inventario el permiso para actualizar la columna precio de la tabla productos.
15. **Política de contraseñas:** establecer requisitos de seguridad para las contraseñas de todos los usuarios de la base de datos.
16. **Protección del usuario root:** impedir que la cuenta root pueda utilizarse mediante conexiones remotas.
17. **Rol Visitante:** crear un rol que solamente tenga permiso para consultar la tabla productos.
18. **Límite de consultas:** restringir la cantidad de consultas por hora permitidas al Analista_Datos para prevenir sobrecargas.
19. **Separación por sucursal:** asegurar que cada usuario únicamente pueda consultar las ventas de la sucursal a la que pertenece, incorporando el identificador de sucursal requerido.
20. **Auditoría de accesos fallidos:** registrar todos los intentos fallidos de inicio de sesión en la base de datos.

## 4. Triggers o disparadores (20 puntos)

1. **trg_audit_precio_producto_after_update:** crear un trigger que registre cada modificación efectuada sobre el precio de un producto.
2. **trg_check_stock_before_insert_venta:** crear un trigger que verifique la existencia de stock suficiente antes de insertar el detalle de una venta.
3. **trg_update_stock_after_insert_venta:** crear un trigger que descuente del inventario las unidades vendidas después de registrar una venta.
4. **trg_prevent_delete_categoria_with_products:** crear un trigger que impida eliminar una categoría mientras tenga productos relacionados.
5. **trg_log_new_customer_after_insert:** crear un trigger que registre en una tabla de auditoría cada nuevo cliente insertado.
6. **trg_update_total_gastado_cliente:** crear un trigger que actualice el gasto acumulado del cliente después de cada compra.
7. **trg_set_fecha_modificacion_producto:** crear un trigger que actualice automáticamente la fecha de última modificación del producto.
8. **trg_prevent_negative_stock:** crear un trigger que rechace cualquier actualización que deje el stock de un producto en un valor negativo.
9. **trg_capitalize_nombre_cliente:** crear un trigger que convierta en mayúscula la primera letra del nombre y apellido antes de registrar un cliente.
10. **trg_recalculate_total_venta_on_detalle_change:** crear un trigger que recalcule el total de una venta cuando se modifique uno de sus detalles.
11. **trg_log_order_status_change:** crear un trigger que audite cada cambio realizado en el estado de un pedido.
12. **trg_prevent_price_zero_or_less:** crear un trigger que impida guardar precios iguales o inferiores a cero.
13. **trg_send_stock_alert_on_low_stock:** crear un trigger que genere un registro de alerta cuando el stock descienda por debajo del umbral definido.
14. **trg_archive_deleted_venta:** crear un trigger que conserve en una tabla de archivo la información de una venta eliminada.
15. **trg_validate_email_format_on_customer:** crear un trigger que valide el formato del correo electrónico antes de insertar o actualizar un cliente.
16. **trg_update_last_order_date_customer:** crear un trigger que actualice en el cliente la fecha de su pedido más reciente.
17. **trg_prevent_self_referral:** crear un trigger que impida que un cliente se registre a sí mismo como referente.
18. **trg_log_permission_changes:** implementar un mecanismo de disparo o auditoría que registre los cambios efectuados sobre los permisos de los usuarios.
19. **trg_assign_default_category_on_null:** crear un trigger que asigne la categoría General cuando se intente insertar un producto sin categoría.
20. **trg_update_producto_count_in_categoria:** crear un trigger que mantenga actualizado el número de productos asociados a cada categoría.

## 5. Eventos programados (20 puntos)

1. **evt_generate_weekly_sales_report:** crear un evento que genere automáticamente un reporte de ventas cada semana.
2. **evt_cleanup_temp_tables_daily:** crear un evento diario que elimine los datos almacenados en las tablas temporales.
3. **evt_archive_old_logs_monthly:** crear un evento mensual que traslade a tablas históricas los registros de auditoría con más de seis meses.
4. **evt_deactivate_expired_promotions_hourly:** crear un evento por hora que desactive los códigos promocionales cuya fecha de vigencia haya finalizado.
5. **evt_recalculate_customer_loyalty_tiers_nightly:** crear un evento nocturno que recalcule el nivel de lealtad de cada cliente.
6. **evt_generate_reorder_list_daily:** crear un evento diario que genere la lista de productos que deben ser reabastecidos.
7. **evt_rebuild_indexes_weekly:** crear un evento semanal que optimice o reconstruya los índices de las tablas de uso frecuente.
8. **evt_suspend_inactive_accounts_quarterly:** crear un evento trimestral que desactive las cuentas sin actividad durante más de un año.
9. **evt_aggregate_daily_sales_data:** crear un evento que consolide diariamente las ventas en una tabla de resumen para agilizar los reportes.
10. **evt_check_data_consistency_nightly:** crear un evento nocturno que detecte inconsistencias, como ventas que no tengan detalles asociados.
11. **evt_send_birthday_greetings_daily:** crear un evento diario que genere una lista de los clientes que cumplen años para asignarles un cupón.
12. **evt_update_product_rankings_hourly:** crear un evento por hora que actualice el ranking de popularidad de los productos.
13. **evt_backup_critical_tables_daily:** crear un evento nocturno que realice un respaldo lógico de las tablas consideradas críticas.
14. **evt_clear_abandoned_carts_daily:** crear un evento diario que elimine los carritos abandonados durante más de 72 horas.
15. **evt_calculate_monthly_kpis:** crear un evento que calcule cada mes los indicadores clave de rendimiento y los almacene en una tabla.
16. **evt_refresh_materialized_views_nightly:** crear un evento nocturno que actualice la información de las vistas materializadas utilizadas por el sistema.
17. **evt_log_database_size_weekly:** crear un evento semanal que mida y registre el tamaño de la base de datos.
18. **evt_detect_fraudulent_activity_hourly:** crear un evento por hora que busque patrones sospechosos, como múltiples pedidos fallidos.
19. **evt_generate_supplier_performance_report_monthly:** crear un evento mensual que produzca un informe sobre el rendimiento de los proveedores.
20. **evt_purge_soft_deleted_records_weekly:** crear un evento semanal que elimine definitivamente los registros marcados para borrado desde hace más de 30 días.

## 6. Procedimientos almacenados (20 puntos)

1. **sp_RealizarNuevaVenta:** crear un procedimiento que registre una venta completa dentro de una transacción y mantenga la consistencia de sus datos.
2. **sp_AgregarNuevoProducto:** crear un procedimiento que registre un producto nuevo junto con todos sus atributos iniciales.
3. **sp_ActualizarDireccionCliente:** crear un procedimiento que actualice la dirección del cliente en las tablas donde corresponda.
4. **sp_ProcesarDevolucion:** crear un procedimiento que gestione la devolución, reintegre las unidades al inventario y genere el crédito correspondiente.
5. **sp_ObtenerHistorialComprasCliente:** crear un procedimiento que devuelva todas las compras realizadas por un cliente.
6. **sp_AjustarNivelStock:** crear un procedimiento que permita ajustar manualmente el stock y deje registrado el motivo del cambio.
7. **sp_EliminarClienteDeFormaSegura:** crear un procedimiento que anonimice los datos personales del cliente sin eliminar los registros necesarios para mantener la integridad referencial.
8. **sp_AplicarDescuentoPorCategoria:** crear un procedimiento que aplique un descuento a todos los productos de una categoría indicada.
9. **sp_GenerarReporteMensualVentas:** crear un procedimiento que genere un informe de ventas para el mes y año proporcionados.
10. **sp_CambiarEstadoPedido:** crear un procedimiento que cambie el estado de un pedido y comunique la modificación a los sistemas relacionados.
11. **sp_RegistrarNuevoCliente:** crear un procedimiento que registre un cliente después de verificar que su correo electrónico no esté repetido.
12. **sp_ObtenerDetallesProductoCompleto:** crear un procedimiento que devuelva la información completa de un producto, junto con su proveedor y categoría.
13. **sp_FusionarCuentasCliente:** crear un procedimiento que combine dos cuentas duplicadas y concentre su información en una sola cuenta.
14. **sp_AsignarProductoAProveedor:** crear un procedimiento que permita asignar o cambiar el proveedor correspondiente a un producto.
15. **sp_BuscarProductos:** crear un procedimiento de búsqueda avanzada que admita filtros como nombre, categoría y rango de precios.
16. **sp_ObtenerDashboardAdmin:** crear un procedimiento que entregue los indicadores necesarios para un panel administrativo, como ventas del día y clientes nuevos.
17. **sp_ProcesarPago:** crear un procedimiento que simule el pago de una venta y actualice su estado a Pagado.
18. **sp_AñadirReseñaProducto:** crear un procedimiento que permita a un cliente calificar y reseñar únicamente los productos que haya comprado.
19. **sp_ObtenerProductosRelacionados:** crear un procedimiento que encuentre productos relacionados utilizando los patrones de compra de otros clientes.
20. **sp_MoverProductosEntreCategorias:** crear un procedimiento que traslade de forma segura uno o varios productos de una categoría a otra.
