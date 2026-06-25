

-- VISTAS -- 
CREATE VIEW vw_vehiculos_disponibles AS 
SELECT  
    v.nroPatente, 
    ma.nombreMarca, 
    mo.nombreModelo, 
    tv.nombreTipo, 
    s.nombreSucursal, 
    s.ubicacion, 
    v.detalleConfort, 
    e.nombreTipoEstado 
FROM vehiculo v 
INNER JOIN modelo mo  
    ON v.idModelo = mo.idModelo 
INNER JOIN marca ma  
    ON mo.idMarca = ma.idMarca 
INNER JOIN tipo_vehiculo tv  
    ON v.idTipo = tv.idTipo 
INNER JOIN sucursal s  
    ON v.idSucursal = s.idSucursal 
INNER JOIN estado e  
    ON v.idTipoEstado = e.idTipoEstado 
WHERE e.nombreTipoEstado = 'DISPONIBLE'; 



CREATE VIEW vw_alquileres_activos AS 
SELECT  
    a.idAlquiler, 
    c.idUsuario, 
    c.DNI, 
    c.nombreYapellido AS cliente, 
    a.nroPatente, 
    ma.nombreMarca, 
    mo.nombreModelo, 
    s.nombreSucursal, 
    a.fechaInicio, 
    a.fechaDevolucionPrevista, 
    a.fechaDevolucionReal, 
    a.cantidadKMinicio, 
    a.cantidadKMfin, 
    t.valorDiario, 
    t.porcentaje_recargo_hora 
FROM alquiler a 
INNER JOIN cliente c  
    ON a.idUsuario = c.idUsuario 
INNER JOIN vehiculo v  
    ON a.nroPatente = v.nroPatente 
INNER JOIN modelo mo  
    ON v.idModelo = mo.idModelo 
INNER JOIN marca ma  
    ON mo.idMarca = ma.idMarca 
INNER JOIN sucursal s  
    ON v.idSucursal = s.idSucursal 
INNER JOIN tarifa t  
    ON a.idTarifa = t.idTarifa 
WHERE a.fechaDevolucionReal IS NULL; 


CREATE VIEW vw_alquileres_vencidos AS 
SELECT  
    a.idAlquiler, 
    c.idUsuario, 
    c.DNI, 
    c.nombreYapellido AS cliente, 
    a.nroPatente, 
    ma.nombreMarca, 
    mo.nombreModelo, 
    s.nombreSucursal, 
    a.fechaInicio, 
    a.fechaDevolucionPrevista, 
    NOW() AS fechaConsulta, 
    TIMESTAMPDIFF(HOUR, a.fechaDevolucionPrevista, NOW()) AS horasVencidas 
FROM alquiler a 
INNER JOIN cliente c  
    ON a.idUsuario = c.idUsuario 
INNER JOIN vehiculo v  
    ON a.nroPatente = v.nroPatente 
INNER JOIN modelo mo  
    ON v.idModelo = mo.idModelo 
INNER JOIN marca ma  
    ON mo.idMarca = ma.idMarca 
INNER JOIN sucursal s  
    ON v.idSucursal = s.idSucursal 
WHERE a.fechaDevolucionReal IS NULL 
  AND a.fechaDevolucionPrevista < NOW(); 
  
  
  CREATE VIEW vw_facturas_emitidas AS 
SELECT  
    f.nroFactura, 
    f.fecha, 
    f.total, 
    c.idUsuario, 
    c.DNI, 
    c.nombreYapellido AS cliente, 
    a.idAlquiler, 
    a.nroPatente, 
    ma.nombreMarca, 
    mo.nombreModelo, 
    a.fechaInicio, 
    a.fechaDevolucionPrevista, 
    a.fechaDevolucionReal 
FROM factura f 
INNER JOIN cliente c  
    ON f.idUsuario = c.idUsuario 
INNER JOIN alquiler a  
    ON f.idAlquiler = a.idAlquiler 
INNER JOIN vehiculo v  
    ON a.nroPatente = v.nroPatente 
INNER JOIN modelo mo  
    ON v.idModelo = mo.idModelo 
INNER JOIN marca ma  
    ON mo.idMarca = ma.idMarca; 
    
    
    
    
CREATE VIEW vw_logs_auditoria AS 
SELECT  
    idLog, 
    tablaAfectada, 
    operacion, 
    usuarioBD, 
    fechaHora, 
    idRegistro, 
    valoresAnteriores, 
    valoresNuevos 
FROM log_auditoria; 

CREATE VIEW vw_reporte_alquileres_vencidos AS 
SELECT 
r.idReporte, 
r.idAlquiler, 
r.nroPatente, 
c.DNI, 
c.nombreYapellido AS cliente, 
r.fechaDevolucionPrevista, 
r.fechaDeteccion, 
r.observacion 
FROM reporte_alquiler_vencido r 
INNER JOIN cliente c 
ON r.idUsuario = c.idUsuario; 



-- Procedimientos --

DELIMITER $$ 
 
CREATE PROCEDURE sp_validar_disponibilidad_vehiculo( 
    IN p_nroPatente VARCHAR(20), 
    IN p_fechaInicio DATETIME, 
    IN p_fechaFin DATETIME, 
    IN p_idReservaIgnorar INT, 
    OUT p_estaDisponible BOOLEAN, 
    OUT p_mensaje VARCHAR(255) 
) 
BEGIN 
    DECLARE v_existeVehiculo INT DEFAULT 0; 
    DECLARE v_estadoVehiculo INT; 
    DECLARE v_nombreEstado VARCHAR(50); 
    DECLARE v_superposicionReservas INT DEFAULT 0; 
    DECLARE v_superposicionAlquileres INT DEFAULT 0; 
    
      DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN 
        SET p_estaDisponible = FALSE; 
        SET p_mensaje = 'Error BD: No se pudo validar la disponibilidad del vehículo.'; 
    END; 
 
    SET p_estaDisponible = FALSE; 
    SET p_mensaje = ''; 
 
    -- 1. Validar que las fechas no sean nulas 
    IF p_fechaInicio IS NULL OR p_fechaFin IS NULL THEN 
 
        SET p_mensaje = 'Error: Las fechas no pueden ser nulas.'; 
 
    -- 2. Validar que la fecha de fin sea posterior a la fecha de inicio 
    ELSEIF p_fechaInicio >= p_fechaFin THEN 
 
        SET p_mensaje = 'Error: La fecha de fin debe ser posterior a la fecha de inicio.'; 
 
    ELSE 
 
        -- 3. Validar que el vehículo exista y obtener su estado actual 
        SELECT  
            COUNT(*), 
            MAX(v.idTipoEstado), 
            MAX(e.nombreTipoEstado) 
        INTO  
            v_existeVehiculo, 
            v_estadoVehiculo, 
            v_nombreEstado 
        FROM vehiculo v 
        INNER JOIN estado e  
            ON v.idTipoEstado = e.idTipoEstado 
        WHERE v.nroPatente = p_nroPatente; 
 
        IF v_existeVehiculo = 0 THEN 
 
            SET p_mensaje = 'Error: El vehículo especificado no existe.'; 
 
        -- 4. Validar que el vehículo esté físicamente disponible 
        ELSEIF v_nombreEstado <> 'DISPONIBLE' THEN 
 
            SET p_mensaje = CONCAT( 
                'Error: El vehículo no está disponible. Estado actual: ', 
                v_nombreEstado 
            ); 
              ELSE 
 
            -- 5. Validar superposición con reservas activas 
            SET v_superposicionReservas = fn_validar_superposicion( 
                p_nroPatente, 
                p_fechaInicio, 
                p_fechaFin, 
                p_idReservaIgnorar 
            ); 
 
            -- 6. Validar superposición con alquileres en curso 
            SELECT COUNT(*) 
            INTO v_superposicionAlquileres 
            FROM alquiler 
            WHERE nroPatente = p_nroPatente 
              AND fechaDevolucionReal IS NULL 
              AND p_fechaInicio < fechaDevolucionPrevista 
              AND p_fechaFin > fechaInicio; 
 
            IF v_superposicionReservas > 0 THEN 
 
                SET p_mensaje = 'Error: El vehículo ya posee una reserva activa en esas 
fechas.'; 
 
            ELSEIF v_superposicionAlquileres > 0 THEN 
 
                SET p_mensaje = 'Error: El vehículo posee un alquiler en curso que se superpone 
con esas fechas.'; 
 
            ELSE 
 
                SET p_estaDisponible = TRUE; 
                SET p_mensaje = 'Disponible.'; 
 
            END IF; 
 
        END IF; 
 
    END IF; 
 
END $$ 
DELIMITER ; 


DELIMITER $$ 
CREATE PROCEDURE sp_registrar_alquiler_sin_reserva( 
    IN p_idUsuario INT, 
      IN p_nroPatente VARCHAR(20), 
    IN p_cantidadKMinicio INT, 
    IN p_fechaInicio DATETIME, 
    IN p_fechaDevolucionPrevista DATETIME, 
    IN p_idTarifa INT, 
    OUT p_resultado VARCHAR(255) 
) 
BEGIN 
    DECLARE v_disponible BOOLEAN; 
    DECLARE v_msg VARCHAR(255); 
    DECLARE v_estadoFisico INT; 
 
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN 
        ROLLBACK; 
        SET p_resultado = 'Error BD: Fallo en la transacción al registrar alquiler directo.'; 
    END; 
 
    START TRANSACTION; 
 
      CALL sp_validar_disponibilidad_vehiculo(p_nroPatente, p_fechaInicio, 
p_fechaDevolucionPrevista, NULL, v_disponible, v_msg); 
 
    IF NOT v_disponible THEN 
        SET p_resultado = v_msg; 
        ROLLBACK; 
    ELSE 
        -- Bloqueamos para leer el estado físico real 
        SELECT idTipoEstado INTO v_estadoFisico FROM vehiculo WHERE nroPatente = 
p_nroPatente FOR UPDATE; 
         
        IF v_estadoFisico != 1 THEN 
            SET p_resultado = 'Error: El vehículo no se encuentra físicamente DISPONIBLE en 
la sucursal.'; 
            ROLLBACK; 
        ELSE 
            -- Insertamos el alquiler 
            INSERT INTO alquiler (cantidadKMinicio, fechaInicio, fechaDevolucionPrevista, 
idUsuario, nroPatente, idTarifa, idReserva) 
            VALUES (p_cantidadKMinicio, p_fechaInicio, p_fechaDevolucionPrevista, 
p_idUsuario, p_nroPatente, p_idTarifa, NULL); 
             
            -- Pasamos el auto a ALQUILADO 
            UPDATE vehiculo SET idTipoEstado = 2 WHERE nroPatente = p_nroPatente; 
             
            SET p_resultado = 'Éxito: Alquiler directo registrado. Vehículo entregado.'; 
            COMMIT; 
            END IF; 
END IF; 
END $$ 
DELIMITER ;




DELIMITER $$ 
 
CREATE PROCEDURE sp_registrar_alquiler_con_reserva( 
    IN p_idReserva INT, 
    IN p_cantidadKMinicio INT, 
    IN p_idTarifa INT, 
    OUT p_resultado VARCHAR(255) 
) 
BEGIN 
    DECLARE v_idUsuario INT; 
    DECLARE v_nroPatente VARCHAR(20); 
    DECLARE v_fechaInicio DATETIME; 
    DECLARE v_fechaFin DATETIME; 
    DECLARE v_estadoReserva VARCHAR(30); 
    DECLARE v_estadoFisico INT; 
 
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN 
        ROLLBACK; 
        SET p_resultado = 'Error BD: Fallo al procesar alquiler con reserva.'; 
    END; 
 
    START TRANSACTION; 
 
    -- Validamos y bloqueamos la reserva 
    SELECT idUsuario, nroPatente, fechaInicio, fechaFin, estadoReserva  
    INTO v_idUsuario, v_nroPatente, v_fechaInicio, v_fechaFin, v_estadoReserva 
    FROM reserva WHERE idReserva = p_idReserva FOR UPDATE; 
 
    IF v_estadoReserva IS NULL THEN 
        SET p_resultado = 'Error: La reserva indicada no existe.'; 
        ROLLBACK; 
    ELSEIF v_estadoReserva != 'ACTIVA' THEN 
        SET p_resultado = CONCAT('Error: La reserva no está ACTIVA. Estado actual: ', 
v_estadoReserva); 
        ROLLBACK; 
    ELSE 
        -- Validamos estado físico real 
        SELECT idTipoEstado INTO v_estadoFisico FROM vehiculo WHERE nroPatente = 
v_nroPatente FOR UPDATE; 
         
        IF v_estadoFisico != 1 THEN 
            SET p_resultado = 'Error crítico: La reserva está activa pero el vehículo no está 
físicamente DISPONIBLE.'; 
            ROLLBACK; 
        ELSE 
           -- Vinculamos el alquiler a la reserva 
            INSERT INTO alquiler (cantidadKMinicio, fechaInicio, fechaDevolucionPrevista, 
idUsuario, nroPatente, idTarifa, idReserva) 
            VALUES (p_cantidadKMinicio, v_fechaInicio, v_fechaFin, v_idUsuario, v_nroPatente, 
p_idTarifa, p_idReserva); 
             
            -- Consumimos reserva y entregamos auto 
            UPDATE reserva SET estadoReserva = 'UTILIZADA' WHERE idReserva = 
p_idReserva; 
            UPDATE vehiculo SET idTipoEstado = 2 WHERE nroPatente = v_nroPatente; 
             
            SET p_resultado = 'Éxito: Alquiler registrado exitosamente consumiendo la reserva.'; 
            COMMIT; 
        END IF; 
    END IF; 
END $$ 
 
DELIMITER ; 



DELIMITER $$ 
 
CREATE PROCEDURE sp_finalizar_alquiler( 
    IN p_idAlquiler INT, 
    IN p_cantidadKMfin INT, 
    IN p_fechaDevolucionReal DATETIME, 
    OUT p_resultado VARCHAR(255) 
) 
BEGIN 
    DECLARE v_nroPatente VARCHAR(20); 
    DECLARE v_idUsuario INT; 
    DECLARE v_fechaInicio DATETIME; 
    DECLARE v_fechaPrevista DATETIME; 
    DECLARE v_idTarifa INT; 
    DECLARE v_kmInicio INT; 
     
    DECLARE v_valorDiario DECIMAL(10,2); 
    DECLARE v_porcRecargo DECIMAL(5,2); 
    DECLARE v_dias INT; 
    DECLARE v_horas INT; 
 
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN 
        ROLLBACK;
        
         SET p_resultado = 'Error BD: Fallo al finalizar el alquiler. Se revirtieron todos los 
cambios.'; 
    END; 
 
    START TRANSACTION; 
 
    SELECT nroPatente, idUsuario, fechaInicio, fechaDevolucionPrevista, idTarifa, 
cantidadKMinicio 
    INTO v_nroPatente, v_idUsuario, v_fechaInicio, v_fechaPrevista, v_idTarifa, v_kmInicio 
    FROM alquiler WHERE idAlquiler = p_idAlquiler FOR UPDATE; 
 
    IF v_nroPatente IS NULL THEN 
        SET p_resultado = 'Error: El alquiler especificado no existe.'; 
        ROLLBACK; 
    ELSEIF p_cantidadKMfin < v_kmInicio THEN 
        SET p_resultado = 'Error: Los KM finales no pueden ser menores a los iniciales.'; 
        ROLLBACK; 
    ELSE 
        SELECT valorDiario, porcentaje_recargo_hora  
        INTO v_valorDiario, v_porcRecargo  
        FROM tarifa WHERE idTarifa = v_idTarifa; 
 
              SET v_dias = fn_calcular_dias_alquiler(v_fechaInicio, p_fechaDevolucionReal); 
        SET v_horas = fn_calcular_horas_excedidas(v_fechaPrevista, 
p_fechaDevolucionReal); 
 
        -- Actualizamos el alquiler cerrando el ciclo 
        UPDATE alquiler  
        SET cantidadKMfin = p_cantidadKMfin,  
            fechaDevolucionReal = p_fechaDevolucionReal  
        WHERE idAlquiler = p_idAlquiler; 
        -- Liberamos el vehículo (Estado 1: DISPONIBLE) 
        UPDATE vehiculo SET idTipoEstado = 1 WHERE nroPatente = v_nroPatente; 
        -- Delegamos la facturación 
        CALL sp_generar_factura(p_idAlquiler, v_idUsuario, DATE(p_fechaDevolucionReal), 
v_dias, v_valorDiario, v_horas, v_porcRecargo); 
 
        SET p_resultado = 'Éxito: Alquiler cerrado exitosamente y facturación generada con las 
nuevas métricas.'; 
        COMMIT; 
    END IF; 
END $$ 
 
DELIMITER ;



DELIMITER $$ 
 
CREATE PROCEDURE sp_registrar_reserva( 
    IN p_idUsuario INT, 
    IN p_nroPatente VARCHAR(20), 
    IN p_fechaInicio DATETIME, 
    IN p_fechaFin DATETIME, 
    OUT p_resultado VARCHAR(255) 
) 
BEGIN 
    DECLARE v_disponible BOOLEAN; 
    DECLARE v_msg VARCHAR(255); 
 
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN 
        ROLLBACK; 
        SET p_resultado = 'Error BD: Fallo en la transacción al registrar la reserva.'; 
    END; 
 
    START TRANSACTION; 
 
    -- LLAMADA AL VALIDADOR MAESTRO 
    CALL sp_validar_disponibilidad_vehiculo(p_nroPatente, p_fechaInicio, p_fechaFin, NULL, 
v_disponible, v_msg); 
 
    IF NOT v_disponible THEN 
        -- Si el validador dice que no, devolvemos el motivo exacto y cortamos 
        SET p_resultado = v_msg; 
        ROLLBACK; 
    ELSE 
        INSERT INTO reserva (fechaInicio, fechaFin, estadoReserva, idUsuario, nroPatente) 
        VALUES (p_fechaInicio, p_fechaFin, 'ACTIVA', p_idUsuario, p_nroPatente); 
         
        SET p_resultado = 'Éxito: Reserva registrada correctamente.'; 
        COMMIT; 
    END IF; 
END $$ 
 
DELIMITER ;



DELIMITER $$ 
CREATE PROCEDURE sp_cancelar_reserva( 
    IN p_idReserva INT, 
    OUT p_resultado VARCHAR(255) 
) 
BEGIN 
    DECLARE v_estadoActual VARCHAR(30); 
 
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN 
        ROLLBACK; 
        SET p_resultado = 'Error BD: Fallo al intentar cancelar la reserva.'; 
    END; 
 
    START TRANSACTION; 
     
    SELECT estadoReserva INTO v_estadoActual  
    FROM reserva WHERE idReserva = p_idReserva FOR UPDATE; 
 
    IF v_estadoActual IS NULL THEN 
        SET p_resultado = 'Error: La reserva especificada no existe.'; 
        ROLLBACK; 
    ELSEIF v_estadoActual != 'ACTIVA' THEN 
        SET p_resultado = CONCAT('Error: Solo se pueden cancelar reservas en estado 
ACTIVA. Estado actual: ', v_estadoActual); 
        ROLLBACK; 
    ELSE 
        UPDATE reserva SET estadoReserva = 'CANCELADA' WHERE idReserva = 
p_idReserva; 
        SET p_resultado = 'Éxito: Reserva cancelada correctamente.'; 
        COMMIT; 
    END IF; 
END $$ 
DELIMITER ;  


DELIMITER $$
CREATE PROCEDURE sp_alta_cliente( 
    IN p_nombreUsuario VARCHAR(50), 
    IN p_contrasenia VARCHAR(255), 
    IN p_dni VARCHAR(20), 
    IN p_nombre VARCHAR(100), 
    IN p_telefono VARCHAR(30), 
    IN p_fechaNac DATE, 
    OUT p_resultado VARCHAR(200) 
) 
proc: BEGIN 
    DECLARE v_idUsuario INT; 
 
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN 
        ROLLBACK; 
        SET p_resultado = 'Error al crear cliente'; 
    END; 
 
    START TRANSACTION; 
 
    IF p_nombreUsuario IS NULL OR TRIM(p_nombreUsuario) = '' THEN 
        SET p_resultado = 'El nombre de usuario no puede estar vacío'; 
        ROLLBACK; 
        LEAVE proc; 
 
    ELSEIF p_contrasenia IS NULL OR TRIM(p_contrasenia) = '' THEN 
        SET p_resultado = 'La contraseña no puede estar vacía'; 
        ROLLBACK; 
        LEAVE proc; 
 
    ELSEIF p_dni IS NULL OR TRIM(p_dni) = '' THEN 
        SET p_resultado = 'El DNI no puede estar vacío'; 
        ROLLBACK; 
        LEAVE proc; 
 
    ELSEIF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN 
        SET p_resultado = 'El nombre y apellido no puede estar vacío'; 
        ROLLBACK; 
        LEAVE proc; 
 
    ELSEIF EXISTS ( 
        SELECT 1 
        FROM usuario 
        WHERE nombreDeUsuario = p_nombreUsuario 
    ) THEN 
        SET p_resultado = 'El nombre de usuario ya existe';
           ROLLBACK; 
        LEAVE proc; 
 
    ELSEIF EXISTS ( 
        SELECT 1 
        FROM cliente 
        WHERE DNI = p_dni 
    ) THEN 
        SET p_resultado = 'El DNI ya existe'; 
        ROLLBACK; 
        LEAVE proc; 
 
    ELSE 
        INSERT INTO usuario ( 
            nombreDeUsuario, 
            contrasenia 
        ) 
        VALUES ( 
            p_nombreUsuario, 
            p_contrasenia 
        ); 
 
        SET v_idUsuario = LAST_INSERT_ID(); 
 
        INSERT INTO cliente ( 
            idUsuario, 
            DNI, 
            nombreYapellido, 
            telefono, 
            fechaNac 
        ) 
        VALUES ( 
            v_idUsuario, 
            p_dni, 
            p_nombre, 
            p_telefono, 
            p_fechaNac 
        ); 
 
        COMMIT; 
 
        SET p_resultado = 'Cliente creado correctamente'; 
    END IF; 
	END $$ 
 
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_modificar_cliente( 
    IN p_idUsuario INT, 
    IN p_nombre VARCHAR(100), 
    IN p_telefono VARCHAR(30), 
    IN p_fechaNac DATE, 
    OUT p_resultado VARCHAR(200) 
) 
proc: BEGIN 
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN 
        ROLLBACK; 
        SET p_resultado = 'Error al modificar cliente'; 
    END; 
 
    START TRANSACTION; 
 
    IF NOT EXISTS ( 
        SELECT 1 
        FROM cliente 
        WHERE idUsuario = p_idUsuario 
    ) THEN 
        SET p_resultado = 'El cliente no existe'; 
        ROLLBACK; 
        LEAVE proc; 
 
    ELSEIF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN 
        SET p_resultado = 'El nombre y apellido no puede estar vacío'; 
        ROLLBACK; 
        LEAVE proc; 
 
    ELSE 
        UPDATE cliente 
        SET 
            nombreYapellido = p_nombre, 
            telefono = p_telefono, 
            fechaNac = p_fechaNac 
        WHERE idUsuario = p_idUsuario; 
 
        COMMIT; 
 
        SET p_resultado = 'Cliente modificado correctamente'; 
    END IF; 
END$$ 
 
DELIMITER ; 



DELIMITER $$
CREATE PROCEDURE sp_baja_cliente( 
    IN p_idUsuario INT, 
    OUT p_resultado VARCHAR(200) 
) 
proc: BEGIN 
    DECLARE v_tieneReservas INT DEFAULT 0; 
    DECLARE v_tieneAlquileres INT DEFAULT 0; 
    DECLARE v_tieneFacturas INT DEFAULT 0; 
 
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN 
        ROLLBACK; 
        SET p_resultado = 'Error al eliminar cliente'; 
    END; 
 
    START TRANSACTION; 
 
    IF NOT EXISTS ( 
        SELECT 1 
        FROM cliente 
        WHERE idUsuario = p_idUsuario 
    ) THEN 
        SET p_resultado = 'El cliente no existe'; 
        ROLLBACK; 
        LEAVE proc; 
    END IF; 
 
    SELECT COUNT(*) 
    INTO v_tieneReservas 
    FROM reserva 
    WHERE idUsuario = p_idUsuario; 
 
    IF v_tieneReservas > 0 THEN 
        SET p_resultado = 'No se puede eliminar el cliente porque posee reservas asociadas'; 
        ROLLBACK; 
        LEAVE proc; 
    END IF; 
 
    SELECT COUNT(*) 
    INTO v_tieneAlquileres 
    FROM alquiler 
    WHERE idUsuario = p_idUsuario; 
 
    IF v_tieneAlquileres > 0 THEN 
        SET p_resultado = 'No se puede eliminar el cliente porque posee alquileres asociados'; 
        ROLLBACK;
          LEAVE proc; 
    END IF; 
 
    SELECT COUNT(*) 
    INTO v_tieneFacturas 
    FROM factura 
    WHERE idUsuario = p_idUsuario; 
 
    IF v_tieneFacturas > 0 THEN 
        SET p_resultado = 'No se puede eliminar el cliente porque posee facturas asociadas'; 
        ROLLBACK; 
        LEAVE proc; 
    END IF; 
 
    DELETE FROM cliente 
    WHERE idUsuario = p_idUsuario; 
 
    DELETE FROM usuario 
    WHERE idUsuario = p_idUsuario; 
 
    COMMIT; 
 
    SET p_resultado = 'Cliente eliminado correctamente'; 
END$$ 
 
DELIMITER ;



 
DELIMITER $$ 
 
CREATE PROCEDURE sp_listar_clientes() 
BEGIN 
 
    SELECT 
 
        c.idUsuario, 
        c.DNI, 
        c.nombreYapellido, 
        c.telefono, 
        c.fechaNac, 
 
        u.nombreDeUsuario 
 
    FROM cliente c 
 
    INNER JOIN usuario u 
        ON c.idUsuario = u.idUsuario; 
 
END$$ 
 
DELIMITER ;


DELIMITER $$ 
 
CREATE PROCEDURE sp_alta_vehiculo( 
    IN p_nroPatente VARCHAR(20), 
    IN p_detalleConfort VARCHAR(255), 
    IN p_idSucursal INT, 
    IN p_idModelo INT, 
    IN p_idTipo INT, 
    IN p_idTipoEstado INT 
) 
BEGIN 
        DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN 
        ROLLBACK; 
        RESIGNAL SET MESSAGE_TEXT = 'Error al registrar el vehículo. Verifique los datos.'; 
    END; 
 
    START TRANSACTION; 
 
    -- 1. Insertar el vehículo 
     INSERT INTO vehiculo (nroPatente, detalleConfort, idSucursal, idModelo, idTipo, 
idTipoEstado) 
    VALUES (p_nroPatente, p_detalleConfort, p_idSucursal, p_idModelo, p_idTipo, 
p_idTipoEstado); 
 
    -- 2. Registrar el estado inicial en el historial 
    INSERT INTO registro_estado (fechaInicio, fechaFin, observacion, idTipoEstado, 
nroPatente) 
    VALUES (CURDATE(), NULL, 'Alta de vehículo en sistema', p_idTipoEstado, 
p_nroPatente); 
 
    COMMIT; 
END $$ 
 
DELIMITER ;


DELIMITER $$ 
 
CREATE PROCEDURE sp_modificar_vehiculo( 
    IN p_nroPatente VARCHAR(20), 
    IN p_detalleConfort VARCHAR(255), 
    IN p_idSucursal INT, 
    IN p_idModelo INT, 
    IN p_idTipo INT, 
    IN p_idTipoEstado INT 
) 
BEGIN 
    DECLARE v_estadoActual INT; 
 
    -- Manejo de errores 
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN 
        ROLLBACK; 
        RESIGNAL SET MESSAGE_TEXT = 'Error al modificar el vehículo. Verifique los 
datos.'; 
    END; 
 
    START TRANSACTION; 
 
    -- Obtenemos el estado actual del vehículo antes de modificarlo 
    SELECT idTipoEstado INTO v_estadoActual  
    FROM vehiculo WHERE nroPatente = p_nroPatente; 
 
    -- 1. Actualizamos los datos generales del vehículo 
    UPDATE vehiculo  
    SET detalleConfort = p_detalleConfort, 
        idSucursal = p_idSucursal, 
        idModelo = p_idModelo, 
        idTipo = p_idTipo, 
        idTipoEstado = p_idTipoEstado 
        
         WHERE nroPatente = p_nroPatente; 
 
    -- 2. Si el estado cambió, actualizamos el registro de estado 
    IF v_estadoActual <> p_idTipoEstado THEN 
        -- Cerramos el registro anterior (ponemos fecha de hoy como fin) 
        UPDATE registro_estado  
        SET fechaFin = CURDATE()  
        WHERE nroPatente = p_nroPatente AND fechaFin IS NULL; 
 
        -- Creamos el nuevo registro de estado 
        INSERT INTO registro_estado (fechaInicio, fechaFin, observacion, idTipoEstado, 
nroPatente) 
        VALUES (CURDATE(), NULL, 'Cambio de estado mediante modificación', 
p_idTipoEstado, p_nroPatente); 
    END IF; 
 
    COMMIT; 
END $$ 
 
DELIMITER ; 

DELIMITER $$ 
 
CREATE PROCEDURE sp_baja_vehiculo( 
    IN p_nroPatente VARCHAR(20) 
) 
BEGIN 
    DECLARE v_idEstadoBaja INT; 
 
    -- Manejo de errores 
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN 
        ROLLBACK; 
        RESIGNAL SET MESSAGE_TEXT = 'Error al dar de baja el vehículo.'; 
    END; 
 
          SET v_idEstadoBaja = 4;  
 
    START TRANSACTION; 
 
    -- 1. Actualizamos el estado del vehículo a 'BAJA' 
    UPDATE vehiculo  
    SET idTipoEstado = v_idEstadoBaja 
    WHERE nroPatente = p_nroPatente; 
 
    -- 2. Cerramos el registro de estado vigente 
    UPDATE registro_estado  
    SET fechaFin = CURDATE()  
    WHERE nroPatente = p_nroPatente AND fechaFin IS NULL; 
 
    -- 3. Insertamos el nuevo registro de estado indicando la BAJA 
    INSERT INTO registro_estado (fechaInicio, fechaFin, observacion, idTipoEstado, 
nroPatente)
VALUES (CURDATE(), NULL, 'Vehículo dado de baja del sistema', v_idEstadoBaja, 
p_nroPatente); 
 
    COMMIT; 
END $$ 
 
DELIMITER ;

DELIMITER $$  
 
CREATE PROCEDURE sp_listar_vehiculos( 
    IN p_idTipoEstado INT  
) 
BEGIN 
    SELECT  
        v.nroPatente, 
        m.nombreMarca, 
        mo.nombreModelo, 
        t.nombreTipo, 
        e.nombreTipoEstado, 
        v.detalleConfort, 
        s.nombreSucursal 
    FROM vehiculo v 
    INNER JOIN modelo mo ON v.idModelo = mo.idModelo 
    INNER JOIN marca m ON mo.idMarca = m.idMarca 
    INNER JOIN tipo_vehiculo t ON v.idTipo = t.idTipo 
    INNER JOIN estado e ON v.idTipoEstado = e.idTipoEstado 
    INNER JOIN sucursal s ON v.idSucursal = s.idSucursal 
    WHERE (p_idTipoEstado IS NULL OR v.idTipoEstado = p_idTipoEstado) 
    ORDER BY v.nroPatente; 
END $$ 
 
DELIMITER ;



DELIMITER $$ 
CREATE PROCEDURE sp_listar_logs_auditoria( 
    IN p_tablaAfectada VARCHAR(100), 
    IN p_operacion VARCHAR(20), 
    IN p_fechaDesde DATETIME, 
    IN p_fechaHasta DATETIME, 
    OUT p_total INT 
) 
BEGIN 
    -- Total de registros encontrados 
    SELECT COUNT(*) 
    INTO p_total 
    FROM log_auditoria l 
    WHERE 
        (p_tablaAfectada IS NULL OR TRIM(p_tablaAfectada) = '' OR l.tablaAfectada = 
p_tablaAfectada) 
        AND 
        (p_operacion IS NULL OR TRIM(p_operacion) = '' OR l.operacion = p_operacion) 
        AND 
        (p_fechaDesde IS NULL OR l.fechaHora >= p_fechaDesde) 
        AND 
        (p_fechaHasta IS NULL OR l.fechaHora <= p_fechaHasta); 
    -- Listado de logs 
    SELECT  
        l.idLog, 
        l.tablaAfectada, 
        l.operacion, 
        l.usuarioBD, 
        l.fechaHora, 
        l.idRegistro, 
        l.valoresAnteriores, 
        l.valoresNuevos 
    FROM log_auditoria l 
    WHERE 
        (p_tablaAfectada IS NULL OR TRIM(p_tablaAfectada) = '' OR l.tablaAfectada = 
p_tablaAfectada) 
        AND 
        (p_operacion IS NULL OR TRIM(p_operacion) = '' OR l.operacion = p_operacion) 
        AND 
        (p_fechaDesde IS NULL OR l.fechaHora >= p_fechaDesde) 
        AND 
        (p_fechaHasta IS NULL OR l.fechaHora <= p_fechaHasta) 
    ORDER BY l.fechaHora DESC; 
END $$ 
 
DELIMITER ;



DELIMITER $$ 
 
CREATE PROCEDURE sp_alta_tarifa( 
    IN p_valorDiario DECIMAL(10,2), 
    IN p_porcentaje_recargo DECIMAL(5,2), 
    IN p_idTipo INT, 
    IN p_idSucursal INT, 
    OUT p_resultado VARCHAR(200) 
) 
proc: BEGIN 
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN 
        ROLLBACK; 
        SET p_resultado = 'Error de base de datos al crear la tarifa'; 
    END; 
 
    START TRANSACTION; 
 
    IF p_valorDiario IS NULL OR p_valorDiario <= 0 THEN 
        SET p_resultado = 'El valor diario debe ser mayor a cero'; 
        ROLLBACK; 
        LEAVE proc; 
 
    ELSEIF p_porcentaje_recargo IS NULL OR p_porcentaje_recargo < 0 THEN 
        SET p_resultado = 'El porcentaje de recargo no puede ser negativo'; 
        ROLLBACK; 
        LEAVE proc; 
 
    ELSEIF NOT EXISTS ( 
        SELECT 1 
        FROM tipo_vehiculo 
        WHERE idTipo = p_idTipo 
    ) THEN 
        SET p_resultado = 'El tipo de vehículo indicado no existe'; 
        ROLLBACK; 
        LEAVE proc; 
 
    ELSEIF NOT EXISTS ( 
        SELECT 1 
        FROM sucursal 
        WHERE idSucursal = p_idSucursal 
    ) THEN 
        SET p_resultado = 'La sucursal indicada no existe'; 
        ROLLBACK; 
        LEAVE proc; 
        
        ELSEIF EXISTS ( 
        SELECT 1 
        FROM tarifa 
        WHERE idTipo = p_idTipo 
          AND idSucursal = p_idSucursal 
    ) THEN 
        SET p_resultado = 'Ya existe una tarifa para este tipo de vehículo en la sucursal 
indicada'; 
        ROLLBACK; 
        LEAVE proc; 
 
    ELSE 
        INSERT INTO tarifa ( 
            valorDiario, 
            porcentaje_recargo_hora, 
            idTipo, 
            idSucursal 
        ) 
        VALUES ( 
            p_valorDiario, 
            p_porcentaje_recargo, 
            p_idTipo, 
            p_idSucursal 
        ); 
 
        COMMIT; 
 
        SET p_resultado = 'Tarifa creada correctamente'; 
    END IF; 
END$$ 
 
DELIMITER ;


DELIMITER $$ 
CREATE PROCEDURE sp_modificar_tarifa( 
    IN p_idTarifa INT, 
    IN p_valorDiario DECIMAL(10,2), 
    IN p_porcentaje_recargo DECIMAL(5,2), 
    IN p_idTipo INT, 
    IN p_idSucursal INT, 
    OUT p_resultado VARCHAR(200) 
) 
proc: BEGIN 
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
      BEGIN 
        ROLLBACK; 
        SET p_resultado = 'Error de base de datos al modificar la tarifa'; 
    END; 
 
    START TRANSACTION; 
 
    IF NOT EXISTS ( 
        SELECT 1 
        FROM tarifa 
        WHERE idTarifa = p_idTarifa 
    ) THEN 
        SET p_resultado = 'La tarifa especificada no existe'; 
        ROLLBACK; 
        LEAVE proc; 
 
    ELSEIF p_valorDiario IS NULL OR p_valorDiario <= 0 THEN 
        SET p_resultado = 'El valor diario debe ser mayor a cero'; 
        ROLLBACK; 
        LEAVE proc; 
 
    ELSEIF p_porcentaje_recargo IS NULL OR p_porcentaje_recargo < 0 THEN 
        SET p_resultado = 'El porcentaje de recargo no puede ser negativo'; 
        ROLLBACK; 
        LEAVE proc; 
 
    ELSEIF NOT EXISTS ( 
        SELECT 1 
        FROM tipo_vehiculo 
        WHERE idTipo = p_idTipo 
    ) THEN 
        SET p_resultado = 'El tipo de vehículo indicado no existe'; 
        ROLLBACK; 
        LEAVE proc; 
 
    ELSEIF NOT EXISTS ( 
        SELECT 1 
        FROM sucursal 
        WHERE idSucursal = p_idSucursal 
    ) THEN 
        SET p_resultado = 'La sucursal indicada no existe'; 
        ROLLBACK; 
        LEAVE proc; 
 
    ELSEIF EXISTS ( 
        SELECT 1 
        FROM tarifa
         WHERE idTipo = p_idTipo 
          AND idSucursal = p_idSucursal 
          AND idTarifa <> p_idTarifa 
    ) THEN 
        SET p_resultado = 'Ya existe otra tarifa registrada para este tipo y sucursal'; 
        ROLLBACK; 
        LEAVE proc; 
 
    ELSE 
        UPDATE tarifa 
        SET  
            valorDiario = p_valorDiario, 
            porcentaje_recargo_hora = p_porcentaje_recargo, 
            idTipo = p_idTipo, 
            idSucursal = p_idSucursal 
        WHERE idTarifa = p_idTarifa; 
 
        COMMIT; 
 
        SET p_resultado = 'Tarifa modificada correctamente'; 
    END IF; 
END$$ 
 
DELIMITER ; 


DELIMITER $$ 
CREATE PROCEDURE sp_baja_tarifa( 
    IN p_idTarifa INT, 
    OUT p_resultado VARCHAR(200) 
) 
proc: BEGIN 
    DECLARE v_tieneAlquileres INT DEFAULT 0; 
 
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN 
        ROLLBACK; 
        SET p_resultado = 'Error al eliminar la tarifa'; 
    END; 
 
    START TRANSACTION; 
 
    IF NOT EXISTS ( 
        SELECT 1 
        FROM tarifa 
        WHERE idTarifa = p_idTarifa 
    ) THEN
    
     SET p_resultado = 'La tarifa no existe'; 
        ROLLBACK; 
        LEAVE proc; 
    END IF; 
 
    SELECT COUNT(*) 
    INTO v_tieneAlquileres 
    FROM alquiler 
    WHERE idTarifa = p_idTarifa; 
 
    IF v_tieneAlquileres > 0 THEN 
        SET p_resultado = 'No se puede eliminar la tarifa porque está asociada a alquileres 
históricos'; 
        ROLLBACK; 
        LEAVE proc; 
    END IF; 
 
    DELETE FROM tarifa 
    WHERE idTarifa = p_idTarifa; 
 
    COMMIT; 
 
    SET p_resultado = 'Tarifa eliminada correctamente'; 
END$$ 
 
DELIMITER ; 



DELIMITER $$ 
 
CREATE PROCEDURE sp_consultar_tarifas( 
    IN p_idTarifa INT -- Puede recibir el ID específico o NULL para traer todas 
) 
BEGIN 
    -- Para las lecturas simples no hace falta OUT parámetro ni transacciones manuales 
     
    IF p_idTarifa IS NULL THEN 
        -- Trae todas las tarifas con los nombres de la sucursal y el tipo 
        SELECT  
            t.idTarifa,  
            t.valorDiario,  
            t.porcentaje_recargo_hora,  
            tv.nombreTipo,  
            s.nombreSucursal  
        FROM tarifa t 
        INNER JOIN tipo_vehiculo tv ON t.idTipo = tv.idTipo 
        INNER JOIN sucursal s ON t.idSucursal = s.idSucursal; 
        ELSE 
        -- Trae una tarifa específica 
        SELECT  
            t.idTarifa,  
            t.valorDiario,  
            t.porcentaje_recargo_hora,  
            tv.nombreTipo,  
            s.nombreSucursal  
        FROM tarifa t 
        INNER JOIN tipo_vehiculo tv ON t.idTipo = tv.idTipo 
        INNER JOIN sucursal s ON t.idSucursal = s.idSucursal 
        WHERE t.idTarifa = p_idTarifa; 
    END IF; 
 
END $$ 
 
DELIMITER  ;


DELIMITER $$ 
 
CREATE PROCEDURE sp_generar_factura( 
    IN p_idAlquiler INT,  
    IN p_idUsuario INT,  
    IN p_fecha DATE, 
    IN p_dias INT,  
    IN p_valorDiario DECIMAL(10,2), 
    IN p_horasAtraso INT,  
    IN p_porcentaje DECIMAL(5,2) 
) 
BEGIN 
    DECLARE v_subtotalBase DECIMAL(10,2); 
    DECLARE v_recargo DECIMAL(10,2) DEFAULT 0; 
    DECLARE v_total DECIMAL(10,2); 
    DECLARE v_nroFactura INT; 
    DECLARE v_precioRecargoHora DECIMAL(10,2); 
    DECLARE v_existeFactura INT DEFAULT 0; 
 
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN 
        ROLLBACK; 
        RESIGNAL; 
    END; 
 
    -- Validar que el alquiler no tenga ya una factura generada 
    SELECT COUNT(*) 
    INTO v_existeFactura 
    FROM factura 
    WHERE idAlquiler = p_idAlquiler; 
 
    IF v_existeFactura > 0 THEN 
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El alquiler ya posee una factura asociada.'; 
    END IF; 
 
    -- 1. Cálculos económicos 
    SET v_subtotalBase = fn_calcular_subtotal_alquiler(p_valorDiario, p_dias); 
    SET v_recargo = fn_calcular_recargo_total(p_valorDiario, p_porcentaje, p_horasAtraso); 
    SET v_total = fn_calcular_total_factura(v_subtotalBase, v_recargo); 
 
    -- 2. Insertar cabecera de factura 
    INSERT INTO factura ( 
        fecha, 
        total, 
        idUsuario,
          idAlquiler 
    )  
    VALUES ( 
        p_fecha, 
        v_total, 
        p_idUsuario, 
        p_idAlquiler 
    ); 
     
    SET v_nroFactura = LAST_INSERT_ID(); 
 
    -- 3. Insertar detalle del alquiler base 
    INSERT INTO detalle_factura ( 
        nroFactura, 
        nroRenglon, 
        concepto, 
        cantidad, 
        precio, 
        subTotal 
    ) 
    VALUES ( 
        v_nroFactura, 
        1, 
        CONCAT('Alquiler por ', p_dias, ' días'), 
        p_dias, 
        p_valorDiario, 
        v_subtotalBase 
    ); 
 
    -- 4. Insertar detalle del recargo si hubo atraso 
    IF p_horasAtraso > 0 THEN 
 
        SET v_precioRecargoHora = fn_calcular_recargo_por_hora( 
            p_valorDiario, 
            p_porcentaje 
        ); 
         
        INSERT INTO detalle_factura ( 
            nroFactura, 
            nroRenglon, 
            concepto, 
            cantidad, 
            precio, 
            subTotal 
        ) 
        VALUES ( 
            v_nroFactura, 
              2, 
            CONCAT('Recargo por ', p_horasAtraso, ' horas de atraso'), 
            p_horasAtraso, 
            v_precioRecargoHora, 
            v_recargo 
        ); 
 
    END IF; 
END $$ 
 
DELIMITER ; 



-- FUNCIONES -- 
DELIMITER $$ 
CREATE FUNCTION fn_calcular_dias_alquiler( 
    p_fechaInicio DATETIME, 
    p_fechaFin DATETIME 
) 
RETURNS INT 
DETERMINISTIC 
BEGIN 
    DECLARE v_minutos INT; 
    DECLARE v_dias INT; 
 
    IF p_fechaInicio IS NULL OR p_fechaFin IS NULL THEN 
        RETURN 0; 
    END IF; 
 
    IF p_fechaFin <= p_fechaInicio THEN 
        RETURN 0; 
    END IF;
    SET v_minutos = TIMESTAMPDIFF(MINUTE, p_fechaInicio, p_fechaFin); 
    SET v_dias = CEIL(v_minutos / 1440); 
 
    IF v_dias < 1 THEN 
        SET v_dias = 1; 
    END IF; 
 
    RETURN v_dias; 
END $$ 
 
DELIMITER ;


DELIMITER $$ 
CREATE FUNCTION fn_calcular_horas_excedidas( 
    p_fechaDevolucionPrevista DATETIME, 
    p_fechaDevolucionReal DATETIME 
) 
RETURNS INT 
DETERMINISTIC 
BEGIN 
    DECLARE v_minutos INT; 
    DECLARE v_horas INT; 
 
    IF p_fechaDevolucionPrevista IS NULL OR p_fechaDevolucionReal IS NULL THEN 
        RETURN 0; 
    END IF; 
 
    IF p_fechaDevolucionReal <= p_fechaDevolucionPrevista THEN 
        RETURN 0; 
    END IF; 
 
    SET v_minutos = TIMESTAMPDIFF(MINUTE, p_fechaDevolucionPrevista, 
p_fechaDevolucionReal); 
    SET v_horas = CEIL(v_minutos / 60); 
 
    RETURN v_horas; 
END $$ 
DELIMITER ;


DELIMITER $$
CREATE FUNCTION fn_calcular_subtotal_alquiler( 
    p_valorDiario DECIMAL(10,2), 
    p_cantidadDias INT 
) 
RETURNS DECIMAL(10,2) 
DETERMINISTIC 
BEGIN 
    IF p_valorDiario IS NULL OR p_cantidadDias IS NULL THEN 
        RETURN 0; 
    END IF; 
 
    IF p_valorDiario < 0 OR p_cantidadDias < 0 THEN 
        RETURN 0; 
    END IF; 
 
    RETURN p_valorDiario * p_cantidadDias; 
END $$ 
 
DELIMITER ; 

DELIMITER $$
CREATE FUNCTION fn_calcular_recargo_por_hora( 
    p_valorDiario DECIMAL(10,2), 
    p_porcentajeRecargoHora DECIMAL(5,2) 
) 
RETURNS DECIMAL(10,2) 
DETERMINISTIC 
BEGIN 
    IF p_valorDiario IS NULL OR p_porcentajeRecargoHora IS NULL THEN 
        RETURN 0; 
    END IF; 
 
    IF p_valorDiario < 0 OR p_porcentajeRecargoHora < 0 THEN 
        RETURN 0; 
    END IF; 
 
    RETURN p_valorDiario * p_porcentajeRecargoHora / 100; 
END $$ 
DELIMITER ;


DELIMITER $$ 
 
CREATE FUNCTION fn_calcular_recargo_total( 
    p_valorDiario DECIMAL(10,2), 
    p_porcentajeRecargoHora DECIMAL(5,2), 
    p_horasExcedidas INT 
) 
RETURNS DECIMAL(10,2) 
DETERMINISTIC 
BEGIN 
    DECLARE v_recargoPorHora DECIMAL(10,2); 
 
    IF p_valorDiario IS NULL  
       OR p_porcentajeRecargoHora IS NULL  
       OR p_horasExcedidas IS NULL THEN 
        RETURN 0; 
    END IF; 
 
    IF p_valorDiario < 0  
       OR p_porcentajeRecargoHora < 0  
       OR p_horasExcedidas < 0 THEN 
        RETURN 0; 
    END IF; 
 
    SET v_recargoPorHora = fn_calcular_recargo_por_hora( 
        p_valorDiario, 
        p_porcentajeRecargoHora 
    ); 
 
    RETURN v_recargoPorHora * p_horasExcedidas; 
END $$ 
DELIMITER ; 




DELIMITER $$ 
 
CREATE FUNCTION fn_calcular_total_factura( 
    p_subtotalAlquiler DECIMAL(10,2), 
    p_subtotalRecargo DECIMAL(10,2) 
) 
RETURNS DECIMAL(10,2) 
DETERMINISTIC 
BEGIN 
    IF p_subtotalAlquiler IS NULL THEN
     SET p_subtotalAlquiler = 0; 
    END IF; 
 
    IF p_subtotalRecargo IS NULL THEN 
        SET p_subtotalRecargo = 0; 
    END IF; 
 
    IF p_subtotalAlquiler < 0 OR p_subtotalRecargo < 0 THEN 
        RETURN 0; 
    END IF; 
 
    RETURN p_subtotalAlquiler + p_subtotalRecargo; 
END $$ 
 
DELIMITER ; 


DELIMITER $$ 
 
CREATE FUNCTION fn_validar_superposicion( 
    p_nroPatente VARCHAR(20), 
    p_fechaInicio DATETIME, 
    p_fechaFin DATETIME, 
    p_idReservaIgnorar INT  
) RETURNS INT 
READS SQL DATA 
BEGIN 
    DECLARE v_cantidad INT DEFAULT 0; 
     
    SELECT COUNT(*) INTO v_cantidad 
    FROM reserva 
    WHERE nroPatente = p_nroPatente 
      AND estadoReserva = 'ACTIVA' 
      AND (p_idReservaIgnorar IS NULL OR idReserva != p_idReservaIgnorar) 
      AND (p_fechaInicio < fechaFin AND p_fechaFin > fechaInicio); 
       
    RETURN v_cantidad; 
END $$ 
DELIMITER ; 


-- Triggers -- 
DELIMITER $$ 
 
CREATE TRIGGER trg_cliente_after_insert 
AFTER INSERT ON cliente 
FOR EACH ROW 
BEGIN 
 
    INSERT INTO log_auditoria( 
        tablaAfectada, 
        operacion, 
        usuarioBD, 
        idRegistro, 
        valoresAnteriores, 
        valoresNuevos 
    ) 
    VALUES( 
        'cliente', 
        'INSERT', 
        CURRENT_USER(), 
        NEW.idUsuario, 
        NULL, 
 
        JSON_OBJECT( 
            'idUsuario', NEW.idUsuario, 
            'DNI', NEW.DNI, 
            'nombreYapellido', NEW.nombreYapellido, 
            'telefono', NEW.telefono, 
            'fechaNac', NEW.fechaNac 
        ) 
    ); 
 
END $$ 
 
DELIMITER ; 



DELIMITER $$ 
 
CREATE TRIGGER trg_cliente_after_update 
AFTER UPDATE ON cliente 
FOR EACH ROW 
BEGIN 
 
    INSERT INTO log_auditoria( 
        tablaAfectada, 
        operacion, 
        usuarioBD, 
        idRegistro, 
        valoresAnteriores, 
        valoresNuevos 
    ) 
     VALUES( 
        'cliente', 
        'UPDATE', 
        CURRENT_USER(), 
        NEW.idUsuario, 
 
        JSON_OBJECT( 
            'idUsuario', OLD.idUsuario, 
            'DNI', OLD.DNI, 
            'nombreYapellido', OLD.nombreYapellido, 
            'telefono', OLD.telefono, 
            'fechaNac', OLD.fechaNac 
        ), 
 
        JSON_OBJECT( 
            'idUsuario', NEW.idUsuario, 
            'DNI', NEW.DNI, 
            'nombreYapellido', NEW.nombreYapellido, 
            'telefono', NEW.telefono, 
            'fechaNac', NEW.fechaNac 
        ) 
    ); 
 
END $$ 
 
DELIMITER ; 




DELIMITER $$ 
 
CREATE TRIGGER trg_cliente_after_delete 
AFTER DELETE ON cliente 
FOR EACH ROW 
BEGIN 
 
    INSERT INTO log_auditoria( 
        tablaAfectada, 
        operacion, 
        usuarioBD, 
        idRegistro, 
        valoresAnteriores, 
        valoresNuevos 
    ) 
    VALUES( 
        'cliente', 
        'DELETE', 
        CURRENT_USER(), 
        OLD.idUsuario, 
 
        JSON_OBJECT( 
            'idUsuario', OLD.idUsuario, 
            'DNI', OLD.DNI, 
            'nombreYapellido', OLD.nombreYapellido, 
            'telefono', OLD.telefono,
               'fechaNac', OLD.fechaNac 
        ), 
 
        NULL 
    ); 
 
END $$ 
 
DELIMITER ;



DELIMITER $$ 
 
CREATE TRIGGER trg_tarifa_after_insert 
AFTER INSERT ON tarifa 
FOR EACH ROW 
BEGIN 
    INSERT INTO log_auditoria ( 
        tablaAfectada,  
        operacion,  
        usuarioBD,  
        fechaHora,  
        idRegistro,  
        valoresAnteriores,  
        valoresNuevos 
    ) VALUES ( 
        'tarifa', 
        'INSERT', 
        USER(), -- Captura el usuario de la base de datos que ejecutó la acción 
        NOW(), 
        CAST(NEW.idTarifa AS CHAR), 
        NULL, -- Como es un alta, no hay valores anteriores 
        JSON_OBJECT( 
            'valorDiario', NEW.valorDiario, 
            'porcentaje_recargo_hora', NEW.porcentaje_recargo_hora, 
            'idTipo', NEW.idTipo, 
            'idSucursal', NEW.idSucursal 
        ) 
    ); 
END$$ 
 
DELIMITER ;


DELIMITER $$ 
 
CREATE TRIGGER trg_tarifa_after_update 
AFTER UPDATE ON tarifa 
FOR EACH ROW 
BEGIN 
    INSERT INTO log_auditoria ( 
        tablaAfectada,  
        operacion,  
        usuarioBD,  
        fechaHora,  
        idRegistro,  
        valoresAnteriores,  
        valoresNuevos 
    ) VALUES ( 
        'tarifa', 
        'UPDATE', 
        USER(), 
        NOW(), 
        CAST(NEW.idTarifa AS CHAR), 
        JSON_OBJECT( 
            'valorDiario', OLD.valorDiario, 
            'porcentaje_recargo_hora', OLD.porcentaje_recargo_hora, 
            'idTipo', OLD.idTipo, 
            'idSucursal', OLD.idSucursal 
        ), 
        JSON_OBJECT( 
            'valorDiario', NEW.valorDiario, 
            'porcentaje_recargo_hora', NEW.porcentaje_recargo_hora, 
            'idTipo', NEW.idTipo, 
            'idSucursal', NEW.idSucursal 
        ) 
    ); 
END$$ 
 
DELIMITER ; 


DELIMITER $$ 
 
CREATE TRIGGER trg_tarifa_after_delete 
AFTER DELETE ON tarifa 
FOR EACH ROW 
BEGIN 
    INSERT INTO log_auditoria ( 
        tablaAfectada,  
        operacion,  
        usuarioBD,  
        fechaHora,  
        idRegistro,  
        valoresAnteriores,  
        valoresNuevos 
    ) VALUES ( 
        'tarifa', 
        'DELETE', 
        USER(), 
        NOW(), 
        CAST(OLD.idTarifa AS CHAR), 
        JSON_OBJECT( 
            'valorDiario', OLD.valorDiario, 
            'porcentaje_recargo_hora', OLD.porcentaje_recargo_hora, 
            'idTipo', OLD.idTipo, 
            'idSucursal', OLD.idSucursal 
        ), 
        NULL -- Como se eliminó, no hay valores nuevos 
    ); 
END$$ 
 
DELIMITER ; 


DELIMITER $$ 
 
 
CREATE TRIGGER trg_reserva_after_insert 
AFTER INSERT ON reserva 
FOR EACH ROW 
BEGIN 
    INSERT INTO log_auditoria (tablaAfectada, operacion, usuarioBD, idRegistro, 
valoresAnteriores, valoresNuevos) 
    VALUES ( 
        'reserva',  
        'INSERT',  
        CURRENT_USER(),  
        NEW.idReserva,  
        NULL, 
        JSON_OBJECT('idReserva', NEW.idReserva, 'fechaInicio', NEW.fechaInicio, 'fechaFin', 
NEW.fechaFin, 'estadoReserva', NEW.estadoReserva, 'idUsuario', NEW.idUsuario, 
'nroPatente', NEW.nroPatente) 
    ); 
END $$ 
 
DELIMITER ;


DELIMITER $$ 
 
 
CREATE TRIGGER trg_reserva_after_update 
AFTER UPDATE ON reserva 
FOR EACH ROW 
BEGIN 
    INSERT INTO log_auditoria (tablaAfectada, operacion, usuarioBD, idRegistro, 
valoresAnteriores, valoresNuevos) 
    VALUES ( 
        'reserva',  
        'UPDATE',  
        CURRENT_USER(),  
        NEW.idReserva, 
        JSON_OBJECT('idReserva', OLD.idReserva, 'fechaInicio', OLD.fechaInicio, 'fechaFin', 
OLD.fechaFin, 'estadoReserva', OLD.estadoReserva, 'idUsuario', OLD.idUsuario, 
'nroPatente', OLD.nroPatente), 
        JSON_OBJECT('idReserva', NEW.idReserva, 'fechaInicio', NEW.fechaInicio, 'fechaFin', 
NEW.fechaFin, 'estadoReserva', NEW.estadoReserva, 'idUsuario', NEW.idUsuario, 
'nroPatente', NEW.nroPatente) 
    ); 
END $$ 
 
DELIMITER ;




DELIMITER $$ 
 
 
CREATE TRIGGER trg_reserva_after_delete 
AFTER DELETE ON reserva 
FOR EACH ROW 
BEGIN 
    INSERT INTO log_auditoria (tablaAfectada, operacion, usuarioBD, idRegistro, 
valoresAnteriores, valoresNuevos) 
    VALUES ( 
        'reserva',  
        'DELETE',  
        CURRENT_USER(),  
        OLD.idReserva, 
        JSON_OBJECT('idReserva', OLD.idReserva, 'fechaInicio', OLD.fechaInicio, 'fechaFin', 
OLD.fechaFin, 'estadoReserva', OLD.estadoReserva, 'idUsuario', OLD.idUsuario, 
'nroPatente', OLD.nroPatente), 
        NULL 
    ); 
END $$ 
 
DELIMITER ; 


DELIMITER $$ 
 
 
CREATE TRIGGER trg_alquiler_after_insert 
AFTER INSERT ON alquiler 
FOR EACH ROW 
BEGIN 
    INSERT INTO log_auditoria (tablaAfectada, operacion, usuarioBD, idRegistro, 
valoresAnteriores, valoresNuevos) 
    VALUES ( 
        'alquiler', 'INSERT', CURRENT_USER(), NEW.idAlquiler, NULL, 
        JSON_OBJECT('idAlquiler', NEW.idAlquiler, 'cantidadKMinicio', NEW.cantidadKMinicio, 
'fechaInicio', NEW.fechaInicio, 'fechaDevolucionPrevista', NEW.fechaDevolucionPrevista, 
'idUsuario', NEW.idUsuario, 'nroPatente', NEW.nroPatente, 'idTarifa', NEW.idTarifa, 
'idReserva', NEW.idReserva) 
    ); 
END $$ 
DELIMITER ; 



DELIMITER $$ 
 
CREATE TRIGGER trg_alquiler_after_update 
AFTER UPDATE ON alquiler 
FOR EACH ROW 
BEGIN 
    INSERT INTO log_auditoria (tablaAfectada, operacion, usuarioBD, idRegistro, 
valoresAnteriores, valoresNuevos) 
    VALUES ( 
        'alquiler', 'UPDATE', CURRENT_USER(), NEW.idAlquiler, 
        JSON_OBJECT('idAlquiler', OLD.idAlquiler, 'cantidadKMinicio', OLD.cantidadKMinicio, 
'cantidadKMfin', OLD.cantidadKMfin, 'fechaDevolucionReal', OLD.fechaDevolucionReal, 
'idUsuario', OLD.idUsuario, 'nroPatente', OLD.nroPatente), 
        JSON_OBJECT('idAlquiler', NEW.idAlquiler, 'cantidadKMinicio', NEW.cantidadKMinicio, 
'cantidadKMfin', NEW.cantidadKMfin, 'fechaDevolucionReal', NEW.fechaDevolucionReal, 
'idUsuario', NEW.idUsuario, 'nroPatente', NEW.nroPatente) 
    ); 
END $$ 
DELIMITER ;



DELIMITER $$ 
CREATE TRIGGER trg_alquiler_after_delete 
AFTER DELETE ON alquiler 
FOR EACH ROW 
BEGIN 
    INSERT INTO log_auditoria (tablaAfectada, operacion, usuarioBD, idRegistro, 
valoresAnteriores, valoresNuevos) 
    VALUES ( 
        'alquiler', 'DELETE', CURRENT_USER(), OLD.idAlquiler, 
        JSON_OBJECT('idAlquiler', OLD.idAlquiler, 'fechaInicio', OLD.fechaInicio, 'idUsuario', 
OLD.idUsuario, 'nroPatente', OLD.nroPatente), 
        NULL 
    ); 
END $$ 
 
DELIMITER ;


DELIMITER $$ 
 
 
CREATE TRIGGER trg_factura_insert 
AFTER INSERT ON factura 
FOR EACH ROW 
BEGIN 
    INSERT INTO log_auditoria ( 
        tablaAfectada, 
        operacion, 
        usuarioBD, 
        idRegistro, 
        valoresAnteriores, 
        valoresNuevos 
    ) 
    VALUES ( 
        'factura', 
        'INSERT', 
        CURRENT_USER(), 
        CAST(NEW.nroFactura AS CHAR), 
        NULL, 
        JSON_OBJECT( 
            'nroFactura', NEW.nroFactura, 
            'fecha', NEW.fecha, 
            'total', NEW.total, 
            'idUsuario', NEW.idUsuario, 
            'idAlquiler', NEW.idAlquiler 
        ) 
    ); 
END $$ 
 
DELIMITER ; 


DELIMITER $$ 
 
CREATE TRIGGER trg_factura_update 
AFTER UPDATE ON factura 
FOR EACH ROW 
BEGIN 
    INSERT INTO log_auditoria ( 
        tablaAfectada, 
        operacion, 
        usuarioBD, 
        idRegistro, 
        valoresAnteriores, 
        valoresNuevos 
    ) 
    VALUES ( 
        'factura', 
        'UPDATE', 
        CURRENT_USER(), 
        CAST(OLD.nroFactura AS CHAR), 
        JSON_OBJECT( 
            'nroFactura', OLD.nroFactura, 
            'fecha', OLD.fecha, 
            'total', OLD.total, 
            'idUsuario', OLD.idUsuario, 
            'idAlquiler', OLD.idAlquiler 
        ), 
        JSON_OBJECT( 
            'nroFactura', NEW.nroFactura, 
            'fecha', NEW.fecha, 
            'total', NEW.total, 
            'idUsuario', NEW.idUsuario, 
            'idAlquiler', NEW.idAlquiler 
        ) 
    ); 
END $$ 
DELIMITER ;



DELIMITER $$ 
 
CREATE TRIGGER trg_factura_delete 
AFTER DELETE ON factura 
FOR EACH ROW 
BEGIN 
    INSERT INTO log_auditoria ( 
        tablaAfectada, 
        operacion, 
        usuarioBD, 
        idRegistro, 
        valoresAnteriores, 
        valoresNuevos 
    ) 
    VALUES ( 
        'factura', 
        'DELETE', 
        CURRENT_USER(), 
        CAST(OLD.nroFactura AS CHAR), 
        JSON_OBJECT( 
            'nroFactura', OLD.nroFactura, 
            'fecha', OLD.fecha, 
            'total', OLD.total, 
            'idUsuario', OLD.idUsuario, 
            'idAlquiler', OLD.idAlquiler 
        ), 
        NULL 
    ); 
END $$ 
 
DELIMITER ; 





-- JOB

SET GLOBAL event_scheduler = ON;  
DELIMITER $$ 
 
CREATE EVENT ev_detectar_alquileres_vencidos 
 
ON SCHEDULE EVERY 1 HOUR 
 
DO 
BEGIN 
 
    INSERT INTO reporte_alquiler_vencido( 
        idAlquiler, 
        nroPatente, 
        idUsuario, 
        fechaDevolucionPrevista, 
        observacion 
    ) 
 
    SELECT 
 
        a.idAlquiler, 
        a.nroPatente, 
        a.idUsuario, 
        a.fechaDevolucionPrevista, 
 
        'Vehículo no devuelto en tiempo previsto' 
 
    FROM alquiler a 
 
    WHERE 
        a.fechaDevolucionPrevista < NOW() 
        AND a.fechaDevolucionReal IS NULL 
        -- evitar duplicados 
        AND NOT EXISTS( 
 
            SELECT 1 
            FROM reporte_alquiler_vencido r 
            WHERE r.idAlquiler = a.idAlquiler 
        ); 
END $$ 
 
DELIMITER ;   


