-- ============================================================
-- TFI ALQUILER DE VEHICULOS
-- GUIA DE PRUEBAS PARA DEMOSTRACION
-- Ejecutar BLOQUE POR BLOQUE en una copia de la base de datos.
-- ============================================================

USE alquiler_vehiculos;



-- ============================================================
-- BLOQUE 1. CRUD DE CLIENTE + TRIGGERS DE AUDITORIA
-- Demuestra:
-- - procedimiento sp_alta_cliente
-- - parametro OUT
-- - trigger INSERT de cliente
-- - procedimiento sp_modificar_cliente
-- - trigger UPDATE de cliente
-- - validacion por usuario duplicado
-- ============================================================


-- Carga un cliente
SET @resultado = '';

CALL sp_alta_cliente(
    'profesor.demo',
    'demo123',
    '99000001',
    'Cliente Demostracion',
    '3757-900001',
    '2000-01-01',
    @resultado
);

SELECT @resultado AS resultado_alta_cliente;

SELECT idUsuario
INTO @idClienteDemo
FROM cliente
WHERE DNI = '99000001'
LIMIT 1;

SELECT *
FROM cliente
WHERE idUsuario = @idClienteDemo;

CALL sp_modificar_cliente(
    @idClienteDemo,
    'Cliente Demostracion Actualizado',
    '3757-900002',
    '2000-01-01',
    @resultado
);

SELECT @resultado AS resultado_modificacion_cliente;


SELECT *
FROM vw_logs_auditoria where tablaAfectada = 'cliente';


-- Validacion esperada: debe rechazar el usuario duplicado.
CALL sp_alta_cliente(
    'profesor.demo',
    'otra-clave',
    '99000002',
    'Cliente Duplicado',
    '3757-900003',
    '2001-01-01',
    @resultado
);

SELECT @resultado AS resultado_esperado_usuario_duplicado;


-- ============================================================
-- BLOQUE 1B. BAJA DE CLIENTE + TRIGGER DELETE
-- Se usa un cliente descartable para no borrar al cliente principal.
-- ============================================================

CALL sp_alta_cliente(
    'profesor.baja',
    'demo123',
    '99000003',
    'Cliente Para Baja',
    '3757-900004',
    '2002-01-01',
    @resultado
);

SELECT @resultado AS resultado_alta_cliente_descartable;

SELECT idUsuario
INTO @idClienteBaja
FROM cliente
WHERE DNI = '99000003'
LIMIT 1;

CALL sp_baja_cliente(@idClienteBaja, @resultado);

SELECT @resultado AS resultado_baja_cliente;

SELECT *
FROM vw_logs_auditoria where tablaAfectada = 'cliente';


-- ============================================================
-- BLOQUE 2. CREAR VEHICULOS EXCLUSIVOS PARA LA DEMOSTRACION
-- Usa datos maestros ya cargados:
-- idSucursal = 1, idModelo = 1, idTipo = 1, idTipoEstado = 1
-- ============================================================

CALL sp_alta_vehiculo(
    'DEMO001',
    'Vehiculo de prueba para alquiler con reserva',
    1,
    1,
    1,
    1
);

CALL sp_alta_vehiculo(
    'DEMO002',
    'Vehiculo de prueba para alquiler directo y job',
    1,
    1,
    1,
    1
);

SELECT *
FROM vehiculo
WHERE nroPatente IN ('DEMO001', 'DEMO002');

SELECT *
FROM registro_estado
WHERE nroPatente IN ('DEMO001', 'DEMO002')
ORDER BY nroPatente, idReg;

SELECT idTarifa
INTO @idTarifaDemo
FROM tarifa
WHERE idTipo = 1
  AND idSucursal = 1
LIMIT 1;

SELECT @idTarifaDemo AS tarifa_utilizada;


-- ============================================================
-- BLOQUE 3. PROBAR FUNCIONES ECONOMICAS Y DE FECHAS
-- Resultados esperados:
-- dias = 3
-- horas_excedidas = 5
-- subtotal = 105000
-- recargo_por_hora = 2800
-- recargo_total = 14000
-- total_factura = 119000
-- ============================================================

SELECT
    fn_calcular_dias_alquiler(
        '2030-01-10 10:00:00',
        '2030-01-12 15:00:00'
    ) AS dias;

SELECT
    fn_calcular_horas_excedidas(
        '2030-01-12 10:00:00',
        '2030-01-12 15:00:00'
    ) AS horas_excedidas;

SELECT
    fn_calcular_subtotal_alquiler(35000.00, 3) AS subtotal;

SELECT
    fn_calcular_recargo_por_hora(35000.00, 8.00) AS recargo_por_hora;

SELECT
    fn_calcular_recargo_total(35000.00, 8.00, 5) AS recargo_total;

SELECT
    fn_calcular_total_factura(105000.00, 14000.00) AS total_factura;


-- ============================================================
-- BLOQUE 4. RESERVA EXITOSA + VALIDACION DE SUPERPOSICION
-- Demuestra:
-- - sp_validar_disponibilidad_vehiculo
-- - sp_registrar_reserva
-- - trigger INSERT de reserva
-- - validacion de fechas superpuestas
-- ============================================================

CALL sp_validar_disponibilidad_vehiculo(
    'DEMO001',
    '2030-01-10 10:00:00',
    '2030-01-12 10:00:00',
    NULL,
    @disponible,
    @mensaje
);

SELECT @disponible AS disponible_antes_de_reservar,
       @mensaje AS mensaje_disponibilidad;

CALL sp_registrar_reserva(
    @idClienteDemo,
    'DEMO001',
    '2030-01-10 10:00:00',
    '2030-01-12 10:00:00',
    @resultado
);

SELECT @resultado AS resultado_reserva_exitosa;

SELECT MAX(idReserva)
INTO @idReservaDemo
FROM reserva
WHERE idUsuario = @idClienteDemo
  AND nroPatente = 'DEMO001';

SELECT *
FROM reserva
WHERE idReserva = @idReservaDemo;

SELECT *
FROM vw_logs_auditoria;

-- Debe fallar porque se superpone con la reserva anterior.
CALL sp_registrar_reserva(
    @idClienteDemo,
    'DEMO001',
    '2030-01-11 10:00:00',
    '2030-01-13 10:00:00',
    @resultado
);

SELECT @resultado AS resultado_esperado_superposicion;


-- ============================================================
-- BLOQUE 5. CANCELACION DE RESERVA
-- Se crea otra reserva sobre DEMO002 y se cancela.
-- Demuestra:
-- - sp_cancelar_reserva
-- - trigger UPDATE de reserva
-- ============================================================

CALL sp_registrar_reserva(
    @idClienteDemo,
    'DEMO002',
    '2030-02-01 09:00:00',
    '2030-02-03 09:00:00',
    @resultado
);

SELECT @resultado AS resultado_reserva_para_cancelar;

SELECT MAX(idReserva)
INTO @idReservaCancelar
FROM reserva
WHERE idUsuario = @idClienteDemo
  AND nroPatente = 'DEMO002';

CALL sp_cancelar_reserva(@idReservaCancelar, @resultado);

SELECT @resultado AS resultado_cancelacion;

SELECT *
FROM reserva
WHERE idReserva = @idReservaCancelar;

SELECT *
FROM vw_logs_auditoria
WHERE tablaAfectada = 'reserva';

select * from reserva; 

-- ============================================================
-- BLOQUE 6. ALQUILER CON RESERVA + FINALIZACION + FACTURA
-- Demuestra:
-- - sp_registrar_alquiler_con_reserva
-- - trigger INSERT de alquiler
-- - cambio de reserva ACTIVA -> UTILIZADA
-- - sp_finalizar_alquiler
-- - trigger UPDATE de alquiler
-- - sp_generar_factura
-- - trigger INSERT de factura
-- - generacion de detalle_factura
-- ============================================================

CALL sp_registrar_alquiler_con_reserva(
    @idReservaDemo,
    10000,
    @idTarifaDemo,
    @resultado
);

SELECT @resultado AS resultado_alquiler_con_reserva;

SELECT MAX(idAlquiler)
INTO @idAlquilerConReserva
FROM alquiler
WHERE idReserva = @idReservaDemo;

SELECT *
FROM alquiler
WHERE idAlquiler = @idAlquilerConReserva;

SELECT *
FROM reserva
WHERE idReserva = @idReservaDemo;

SELECT nroPatente, idTipoEstado
FROM vehiculo
WHERE nroPatente = 'DEMO001';

-- La devolucion ocurre 5 horas tarde.
CALL sp_finalizar_alquiler(
    @idAlquilerConReserva,
    10350,
    '2030-01-12 15:00:00',
    @resultado
);

SELECT @resultado AS resultado_finalizacion;

SELECT *
FROM alquiler
WHERE idAlquiler = @idAlquilerConReserva;

SELECT nroPatente, idTipoEstado
FROM vehiculo
WHERE nroPatente = 'DEMO001';

SELECT *
FROM factura
WHERE idAlquiler = @idAlquilerConReserva;

SELECT df.*
FROM detalle_factura df
INNER JOIN factura f
    ON df.nroFactura = f.nroFactura
WHERE f.idAlquiler = @idAlquilerConReserva
ORDER BY df.nroRenglon;

SELECT *
FROM vw_logs_auditoria
WHERE tablaAfectada IN ('reserva', 'alquiler', 'factura')
ORDER BY idLog DESC
LIMIT 30;


-- ============================================================
-- BLOQUE 7. ALQUILER DIRECTO VENCIDO + VALIDACION DE ROLLBACK
-- Demuestra:
-- - sp_registrar_alquiler_sin_reserva
-- - vw_alquileres_vencidos
-- - validacion de KM finales
-- - rollback al intentar finalizar con KM invalidos
-- ============================================================

CALL sp_registrar_alquiler_sin_reserva(
    @idClienteDemo,
    'DEMO002',
    20000,
    DATE_SUB(NOW(), INTERVAL 2 DAY),
    DATE_SUB(NOW(), INTERVAL 1 DAY),
    @idTarifaDemo,
    @resultado
);

SELECT @resultado AS resultado_alquiler_directo;

SELECT MAX(idAlquiler)
INTO @idAlquilerDirecto
FROM alquiler
WHERE nroPatente = 'DEMO002'
  AND fechaDevolucionReal IS NULL;

SELECT *
FROM alquiler
WHERE idAlquiler = @idAlquilerDirecto;

SELECT *
FROM vw_alquileres_vencidos
WHERE idAlquiler = @idAlquilerDirecto;

-- Debe fallar: KM finales menores que KM iniciales.
CALL sp_finalizar_alquiler(
    @idAlquilerDirecto,
    19999,
    NOW(),
    @resultado
);

SELECT @resultado AS resultado_esperado_km_invalidos;

-- Debe seguir sin devolucion real porque hubo rollback.
SELECT *
FROM alquiler
WHERE idAlquiler = @idAlquilerDirecto;


-- ============================================================
-- BLOQUE 8. JOB DE ALQUILERES VENCIDOS
-- El evento original se ejecuta cada 1 hora.
-- Para una demostracion inmediata, se puede cambiar temporalmente
-- a 1 minuto y luego restaurarlo.
-- Requiere permisos suficientes en MySQL.
-- ============================================================

SHOW VARIABLES LIKE 'event_scheduler';

SHOW EVENTS FROM alquiler_vehiculos;

-- Ejecutar solamente si tenes permisos:
SET GLOBAL event_scheduler = ON;

ALTER EVENT ev_detectar_alquileres_vencidos
ON SCHEDULE EVERY 1 MINUTE
ENABLE;

-- Esperar aproximadamente un minuto y ejecutar:
SELECT *
FROM vw_reporte_alquileres_vencidos
WHERE idAlquiler = @idAlquilerDirecto;

-- Restaurar la frecuencia original:
ALTER EVENT ev_detectar_alquileres_vencidos
ON SCHEDULE EVERY 1 HOUR
ENABLE;


-- ============================================================
-- BLOQUE 9. CONSULTAR LOGS CON EL PROCEDIMIENTO
-- Demuestra:
-- - sp_listar_logs_auditoria
-- - filtros opcionales
-- - parametro OUT con cantidad total
-- ============================================================

SET @totalLogs = 0;

CALL sp_listar_logs_auditoria(
    NULL,
    NULL,
    NULL,
    NULL,
    @totalLogs
);

SELECT @totalLogs AS cantidad_total_logs;

CALL sp_listar_logs_auditoria(
    'reserva',
    'UPDATE',
    NULL,
    NULL,
    @totalLogs
);

SELECT @totalLogs AS cantidad_logs_reserva_update;


-- ============================================================
-- BLOQUE 10. CONSULTAR VISTAS PRINCIPALES
-- ============================================================

SELECT *
FROM vw_vehiculos_disponibles;

SELECT *
FROM vw_reservas_activas;

SELECT *
FROM vw_alquileres_activos;

SELECT *
FROM vw_alquileres_vencidos;

SELECT *
FROM vw_facturas_emitidas
ORDER BY nroFactura DESC;

SELECT *
FROM vw_logs_auditoria
ORDER BY idLog DESC
LIMIT 50;

SELECT *
FROM vw_reporte_alquileres_vencidos
ORDER BY fechaDeteccion DESC;


-- ============================================================
-- BLOQUE OPCIONAL 11. TRIGGERS DE TARIFA: INSERT, UPDATE Y DELETE
-- Crea una sucursal temporal para evitar repetir combinaciones
-- existentes de tipo de vehiculo y sucursal.
-- ============================================================

INSERT INTO sucursal(nombreSucursal, ubicacion)
VALUES ('Sucursal Temporal Demo', 'Ubicacion temporal');

SET @idSucursalTemporal = LAST_INSERT_ID();

CALL sp_alta_tarifa(
    12345.00,
    5.00,
    1,
    @idSucursalTemporal,
    @resultado
);

SELECT @resultado AS resultado_alta_tarifa;

SELECT idTarifa
INTO @idTarifaTemporal
FROM tarifa
WHERE idTipo = 1
  AND idSucursal = @idSucursalTemporal
LIMIT 1;

CALL sp_modificar_tarifa(
    @idTarifaTemporal,
    15000.00,
    6.00,
    1,
    @idSucursalTemporal,
    @resultado
);

SELECT @resultado AS resultado_modificacion_tarifa;

CALL sp_baja_tarifa(
    @idTarifaTemporal,
    @resultado
);

SELECT @resultado AS resultado_baja_tarifa;

SELECT *
FROM vw_logs_auditoria
WHERE tablaAfectada = 'tarifa'
  AND idRegistro = CAST(@idTarifaTemporal AS CHAR)
ORDER BY idLog DESC;

DELETE FROM sucursal
WHERE idSucursal = @idSucursalTemporal;


-- ============================================================
-- NOTA FINAL
-- No se recomienda limpiar manualmente todos los datos creados si
-- se quiere conservar la evidencia de auditoria. Para repetir la
-- demostracion desde cero, restaurar una copia limpia de la base.
-- ============================================================
