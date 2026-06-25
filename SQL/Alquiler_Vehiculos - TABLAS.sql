CREATE DATABASE alquiler_vehiculos;
USE alquiler_vehiculos;


-- Crear un nuevo usuario para que cada uno no tenga que modificar el archivp de conexion a la BD
CREATE USER 'admin_alquileres'@'localhost' IDENTIFIED BY '123456';
GRANT ALL PRIVILEGES ON alquiler_vehiculos.* TO 'admin_alquileres'@'localhost';
FLUSH PRIVILEGES;
-- =========================
-- USUARIO
-- =========================

CREATE TABLE usuario (
    idUsuario INT AUTO_INCREMENT,
    nombreDeUsuario VARCHAR(50) NOT NULL,
    contrasenia VARCHAR(255) NOT NULL,

    CONSTRAINT pk_usuario PRIMARY KEY (idUsuario),
    CONSTRAINT uq_usuario_nombre UNIQUE (nombreDeUsuario)
) ENGINE=InnoDB;

-- =========================
-- CLIENTE
-- =========================

CREATE TABLE cliente (
    idUsuario INT,
    DNI VARCHAR(20) NOT NULL,
    nombreYapellido VARCHAR(100) NOT NULL,
    telefono VARCHAR(30),
    fechaNac DATE,

    CONSTRAINT pk_cliente PRIMARY KEY (idUsuario),
    CONSTRAINT uq_cliente_dni UNIQUE (DNI),

    CONSTRAINT fk_cliente_usuario
        FOREIGN KEY (idUsuario)
        REFERENCES usuario(idUsuario)
) ENGINE=InnoDB;

-- =========================
-- ADMINISTRADOR
-- =========================

CREATE TABLE administrador (
    idUsuario INT,
    nombreYapellido VARCHAR(100) NOT NULL,
    mail VARCHAR(100) NOT NULL,

    CONSTRAINT pk_administrador PRIMARY KEY (idUsuario),
    CONSTRAINT uq_administrador_mail UNIQUE (mail),

    CONSTRAINT fk_administrador_usuario
        FOREIGN KEY (idUsuario)
        REFERENCES usuario(idUsuario)
) ENGINE=InnoDB;

-- =========================
-- MARCA
-- =========================

CREATE TABLE marca (
    idMarca INT AUTO_INCREMENT,
    nombreMarca VARCHAR(50) NOT NULL,

    CONSTRAINT pk_marca PRIMARY KEY (idMarca),
    CONSTRAINT uq_marca_nombre UNIQUE (nombreMarca)
) ENGINE=InnoDB;

-- =========================
-- MODELO
-- =========================

CREATE TABLE modelo (
    idModelo INT AUTO_INCREMENT,
    nombreModelo VARCHAR(50) NOT NULL,
    idMarca INT NOT NULL,

    CONSTRAINT pk_modelo PRIMARY KEY (idModelo),

    CONSTRAINT fk_modelo_marca
        FOREIGN KEY (idMarca)
        REFERENCES marca(idMarca)
) ENGINE=InnoDB;

-- =========================
-- SUCURSAL
-- =========================

CREATE TABLE sucursal (
    idSucursal INT AUTO_INCREMENT,
    nombreSucursal VARCHAR(100) NOT NULL,
    ubicacion VARCHAR(150) NOT NULL,

    CONSTRAINT pk_sucursal PRIMARY KEY (idSucursal)
) ENGINE=InnoDB;

-- =========================
-- TIPO VEHICULO
-- =========================

CREATE TABLE tipo_vehiculo (
    idTipo INT AUTO_INCREMENT,
    nombreTipo VARCHAR(50) NOT NULL,

    CONSTRAINT pk_tipo_vehiculo PRIMARY KEY (idTipo),
    CONSTRAINT uq_tipo_vehiculo_nombre UNIQUE (nombreTipo)
) ENGINE=InnoDB;

-- =========================
-- ESTADO
-- =========================

CREATE TABLE estado (
    idTipoEstado INT AUTO_INCREMENT,
    nombreTipoEstado VARCHAR(50) NOT NULL,

    CONSTRAINT pk_estado PRIMARY KEY (idTipoEstado),
    CONSTRAINT uq_estado_nombre UNIQUE (nombreTipoEstado)
) ENGINE=InnoDB;

-- =========================
-- TARIFA
-- La tarifa depende de la sucursal y del tipo de vehículo.
-- =========================

CREATE TABLE tarifa (
    idTarifa INT AUTO_INCREMENT,
    valorDiario DECIMAL(10,2) NOT NULL,
    porcentaje_recargo_hora DECIMAL(5,2) NOT NULL,
    idTipo INT NOT NULL,
    idSucursal INT NOT NULL,

    CONSTRAINT pk_tarifa PRIMARY KEY (idTarifa),

    CONSTRAINT fk_tarifa_tipo
        FOREIGN KEY (idTipo)
        REFERENCES tipo_vehiculo(idTipo),

    CONSTRAINT fk_tarifa_sucursal
        FOREIGN KEY (idSucursal)
        REFERENCES sucursal(idSucursal),

    CONSTRAINT uq_tarifa_tipo_sucursal UNIQUE (idTipo, idSucursal),

    CONSTRAINT chk_tarifa_valor_diario CHECK (valorDiario > 0),
    CONSTRAINT chk_tarifa_recargo CHECK (porcentaje_recargo_hora >= 0)
) ENGINE=InnoDB;

-- =========================
-- VEHICULO
-- =========================

CREATE TABLE vehiculo (
    nroPatente VARCHAR(20),
    detalleConfort VARCHAR(255),
    idSucursal INT NOT NULL,
    idModelo INT NOT NULL,
    idTipo INT NOT NULL,
    idTipoEstado INT NOT NULL,

    CONSTRAINT pk_vehiculo PRIMARY KEY (nroPatente),

    CONSTRAINT fk_vehiculo_sucursal
        FOREIGN KEY (idSucursal)
        REFERENCES sucursal(idSucursal),

    CONSTRAINT fk_vehiculo_modelo
        FOREIGN KEY (idModelo)
        REFERENCES modelo(idModelo),

    CONSTRAINT fk_vehiculo_tipo
        FOREIGN KEY (idTipo)
        REFERENCES tipo_vehiculo(idTipo),

    CONSTRAINT fk_vehiculo_estado
        FOREIGN KEY (idTipoEstado)
        REFERENCES estado(idTipoEstado)
) ENGINE=InnoDB;

-- =========================
-- IMAGEN VEHICULO
-- Para representar las imágenes del vehículo.
-- =========================

CREATE TABLE imagen_vehiculo (
    idImagen INT AUTO_INCREMENT,
    nroPatente VARCHAR(20) NOT NULL,
    urlImagen VARCHAR(255) NOT NULL,

    CONSTRAINT pk_imagen_vehiculo PRIMARY KEY (idImagen),

    CONSTRAINT fk_imagen_vehiculo
        FOREIGN KEY (nroPatente)
        REFERENCES vehiculo(nroPatente)
) ENGINE=InnoDB;

-- =========================
-- ALQUILER
-- Cada alquiler corresponde a un cliente, vehículo y tarifa aplicada.
-- =========================

CREATE TABLE alquiler (
    idAlquiler INT AUTO_INCREMENT,
    cantidadKMinicio INT NOT NULL,
    cantidadKMfin INT,
    fechaInicio DATETIME NOT NULL,
    fechaDevolucionPrevista DATETIME NOT NULL,
    fechaDevolucionReal DATETIME,
    idUsuario INT NOT NULL,
    nroPatente VARCHAR(20) NOT NULL,
    idTarifa INT NOT NULL,

    CONSTRAINT pk_alquiler PRIMARY KEY (idAlquiler),

    CONSTRAINT fk_alquiler_cliente
        FOREIGN KEY (idUsuario)
        REFERENCES cliente(idUsuario),

    CONSTRAINT fk_alquiler_vehiculo
        FOREIGN KEY (nroPatente)
        REFERENCES vehiculo(nroPatente),

    CONSTRAINT fk_alquiler_tarifa
        FOREIGN KEY (idTarifa)
        REFERENCES tarifa(idTarifa),

    CONSTRAINT chk_alquiler_fecha_prevista CHECK (fechaDevolucionPrevista > fechaInicio),
    CONSTRAINT chk_alquiler_km_inicio CHECK (cantidadKMinicio >= 0),
    CONSTRAINT chk_alquiler_km_fin CHECK (cantidadKMfin IS NULL OR cantidadKMfin >= cantidadKMinicio)
) ENGINE=InnoDB;

-- =========================
-- FACTURA
-- Una factura se genera al finalizar un alquiler.
-- =========================

CREATE TABLE factura (
    nroFactura INT AUTO_INCREMENT,
    fecha DATE NOT NULL,
    total DECIMAL(10,2) NOT NULL DEFAULT 0,
    idUsuario INT NOT NULL,
    idAlquiler INT NOT NULL,

    CONSTRAINT pk_factura PRIMARY KEY (nroFactura),

    CONSTRAINT uq_factura_alquiler UNIQUE (idAlquiler),

    CONSTRAINT fk_factura_cliente
        FOREIGN KEY (idUsuario)
        REFERENCES cliente(idUsuario),

    CONSTRAINT fk_factura_alquiler
        FOREIGN KEY (idAlquiler)
        REFERENCES alquiler(idAlquiler),

    CONSTRAINT chk_factura_total CHECK (total >= 0)
) ENGINE=InnoDB;

-- =========================
-- DETALLE FACTURA
-- Una factura puede tener varios renglones.
-- =========================

CREATE TABLE detalle_factura (
    nroFactura INT NOT NULL,
    nroRenglon INT NOT NULL,
    concepto VARCHAR(100) NOT NULL,
    cantidad DECIMAL(10,2) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    subTotal DECIMAL(10,2) NOT NULL,

    CONSTRAINT pk_detalle_factura PRIMARY KEY (nroFactura, nroRenglon),

    CONSTRAINT fk_detalle_factura
        FOREIGN KEY (nroFactura)
        REFERENCES factura(nroFactura),

    CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_precio CHECK (precio >= 0),
    CONSTRAINT chk_detalle_subtotal CHECK (subTotal >= 0)
) ENGINE=InnoDB;

-- =========================
-- REGISTRO ESTADO
-- Historial de estados del vehículo.
-- =========================

CREATE TABLE registro_estado (
    idReg INT AUTO_INCREMENT,
    fechaInicio DATE NOT NULL,
    fechaFin DATE,
    observacion VARCHAR(255),
    idTipoEstado INT NOT NULL,
    nroPatente VARCHAR(20) NOT NULL,

    CONSTRAINT pk_registro_estado PRIMARY KEY (idReg),

    CONSTRAINT fk_registro_estado_tipo
        FOREIGN KEY (idTipoEstado)
        REFERENCES estado(idTipoEstado),

    CONSTRAINT fk_registro_estado_vehiculo
        FOREIGN KEY (nroPatente)
        REFERENCES vehiculo(nroPatente),

    CONSTRAINT chk_registro_estado_fechas CHECK (fechaFin IS NULL OR fechaFin >= fechaInicio)
) ENGINE=InnoDB;


CREATE TABLE reserva (
    idReserva INT AUTO_INCREMENT,
    fechaReserva DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fechaInicio DATETIME NOT NULL,
    fechaFin DATETIME NOT NULL,
    estadoReserva VARCHAR(30) NOT NULL DEFAULT 'ACTIVA',
    idUsuario INT NOT NULL,
    nroPatente VARCHAR(20) NOT NULL,
    CONSTRAINT pk_reserva PRIMARY KEY (idReserva),
    CONSTRAINT fk_reserva_cliente
        FOREIGN KEY (idUsuario) REFERENCES cliente(idUsuario),
    CONSTRAINT fk_reserva_vehiculo
        FOREIGN KEY (nroPatente) REFERENCES vehiculo(nroPatente),
    CONSTRAINT chk_reserva_fechas
        CHECK (fechaFin > fechaInicio),
    CONSTRAINT chk_reserva_estado
        CHECK (estadoReserva IN ('ACTIVA', 'CANCELADA', 'UTILIZADA', 'VENCIDA'))
) ENGINE=InnoDB;

ALTER TABLE alquiler
ADD COLUMN idReserva INT NULL,
ADD CONSTRAINT fk_alquiler_reserva
FOREIGN KEY (idReserva) REFERENCES reserva(idReserva);


CREATE TABLE log_auditoria (
    idLog INT AUTO_INCREMENT,
    tablaAfectada VARCHAR(100) NOT NULL,
    operacion VARCHAR(20) NOT NULL,
    usuarioBD VARCHAR(100) NOT NULL,
    fechaHora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    idRegistro VARCHAR(100),
    valoresAnteriores JSON,
    valoresNuevos JSON,

    CONSTRAINT pk_log_auditoria PRIMARY KEY (idLog),

    CONSTRAINT chk_log_operacion
        CHECK (operacion IN ('INSERT', 'UPDATE', 'DELETE'))
) ENGINE=InnoDB;

CREATE TABLE reporte_alquiler_vencido (
    idReporte INT AUTO_INCREMENT,
    idAlquiler INT NOT NULL,
    nroPatente VARCHAR(20) NOT NULL,
    idUsuario INT NOT NULL,
    fechaDevolucionPrevista DATETIME NOT NULL,
    fechaDeteccion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    observacion VARCHAR(255),

    CONSTRAINT pk_reporte_alquiler_vencido PRIMARY KEY (idReporte),

    CONSTRAINT fk_reporte_alquiler
        FOREIGN KEY (idAlquiler)
        REFERENCES alquiler(idAlquiler),

    CONSTRAINT fk_reporte_cliente
        FOREIGN KEY (idUsuario)
        REFERENCES cliente(idUsuario),

    CONSTRAINT fk_reporte_vehiculo
        FOREIGN KEY (nroPatente)
        REFERENCES vehiculo(nroPatente)
) ENGINE=InnoDB;


USE alquiler_vehiculos;

-- =====================================================
-- 1. USUARIOS
-- =====================================================

INSERT INTO usuario (nombreDeUsuario, contrasenia) VALUES
('admin.principal', 'admin123'),
('lucia.gomez', 'cliente123'),
('martin.pereira', 'cliente123'),
('camila.rodriguez', 'cliente123'),
('juan.fernandez', 'cliente123'),
('mariana.silva', 'cliente123'),
('tomas.nieto', 'cliente123'),
('sofia.ramirez', 'cliente123');


-- =====================================================
-- 2. ADMINISTRADOR
-- idUsuario = 1
-- =====================================================

INSERT INTO administrador (idUsuario, nombreYapellido, mail) VALUES
(1, 'Administrador Principal', 'admin@alquilervehiculos.com');


-- =====================================================
-- 3. CLIENTES
-- idUsuario = 2 en adelante
-- =====================================================

INSERT INTO cliente (idUsuario, DNI, nombreYapellido, telefono, fechaNac) VALUES
(2, '40111222', 'Lucía Gómez', '3757-111111', '1998-04-15'),
(3, '39222333', 'Martín Pereira', '3757-222222', '1997-09-22'),
(4, '41555444', 'Camila Rodríguez', '3757-333333', '2000-01-10'),
(5, '38777666', 'Juan Fernández', '3757-444444', '1996-06-05'),
(6, '42123987', 'Mariana Silva', '3757-555555', '2001-11-18'),
(7, '39999888', 'Tomás Nieto', '3757-666666', '1999-08-30'),
(8, '43123456', 'Sofía Ramírez', '3757-777777', '2002-03-12');


-- =====================================================
-- 4. MARCAS
-- =====================================================

INSERT INTO marca (nombreMarca) VALUES
('Toyota'),
('Ford'),
('Chevrolet'),
('Volkswagen'),
('Renault'),
('Fiat'),
('Peugeot'),
('Nissan');


-- =====================================================
-- 5. MODELOS
-- =====================================================

INSERT INTO modelo (nombreModelo, idMarca) VALUES
('Corolla', 1),
('Hilux', 1),
('EcoSport', 2),
('Ranger', 2),
('Onix', 3),
('Cruze', 3),
('Vento', 4),
('Gol Trend', 4),
('Duster', 5),
('Kangoo', 5),
('Cronos', 6),
('Argo', 6),
('208', 7),
('Partner', 7),
('Versa', 8),
('Kicks', 8);


-- =====================================================
-- 6. SUCURSALES
-- =====================================================

INSERT INTO sucursal (nombreSucursal, ubicacion) VALUES
('Sucursal Centro', 'Av. San Martín 123 - Puerto Iguazú'),
('Sucursal Aeropuerto', 'Aeropuerto Internacional Cataratas del Iguazú'),
('Sucursal Terminal', 'Terminal de Ómnibus - Local 5'),
('Sucursal Posadas', 'Av. Uruguay 2450 - Posadas');


-- =====================================================
-- 7. TIPOS DE VEHÍCULO
-- =====================================================

INSERT INTO tipo_vehiculo (nombreTipo) VALUES
('Sedán'),
('SUV'),
('Cupé'),
('Camioneta'),
('Hatchback'),
('Utilitario');


-- =====================================================
-- 8. ESTADOS DEL VEHÍCULO
-- =====================================================

INSERT INTO estado (nombreTipoEstado) VALUES
('DISPONIBLE'),
('ALQUILADO'),
('MANTENIMIENTO'),
('BAJA');


-- =====================================================
-- 9. TARIFAS
-- La tarifa depende de tipo de vehículo y sucursal.
-- =====================================================

INSERT INTO tarifa (valorDiario, porcentaje_recargo_hora, idTipo, idSucursal) VALUES
-- Sucursal Centro
(35000.00, 8.00, 1, 1),   -- Sedán
(50000.00, 10.00, 2, 1),  -- SUV
(42000.00, 9.00, 3, 1),   -- Cupé
(65000.00, 12.00, 4, 1),  -- Camioneta
(30000.00, 7.00, 5, 1),   -- Hatchback
(47000.00, 9.00, 6, 1),   -- Utilitario

-- Sucursal Aeropuerto
(40000.00, 9.00, 1, 2),
(56000.00, 11.00, 2, 2),
(47000.00, 10.00, 3, 2),
(72000.00, 13.00, 4, 2),
(35000.00, 8.00, 5, 2),
(52000.00, 10.00, 6, 2),

-- Sucursal Terminal
(33000.00, 8.00, 1, 3),
(48000.00, 10.00, 2, 3),
(40000.00, 9.00, 3, 3),
(63000.00, 12.00, 4, 3),
(29000.00, 7.00, 5, 3),
(45000.00, 9.00, 6, 3),

-- Sucursal Posadas
(36000.00, 8.00, 1, 4),
(51000.00, 10.00, 2, 4),
(43000.00, 9.00, 3, 4),
(66000.00, 12.00, 4, 4),
(31000.00, 7.00, 5, 4),
(48000.00, 9.00, 6, 4);


-- =====================================================
-- 10. VEHÍCULOS
-- nroPatente, detalleConfort, idSucursal, idModelo, idTipo, idTipoEstado
-- Estados:
-- 1 DISPONIBLE
-- 2 ALQUILADO
-- 3 MANTENIMIENTO
-- 4 BAJA
-- =====================================================

INSERT INTO vehiculo 
(nroPatente, detalleConfort, idSucursal, idModelo, idTipo, idTipoEstado) VALUES
('AA123BB', 'Aire acondicionado, caja automática, pantalla multimedia', 1, 1, 1, 1),
('AB456CD', 'Aire acondicionado, cámara de retroceso, bluetooth', 1, 3, 2, 1),
('AC789EF', 'Aire acondicionado, dirección asistida, pantalla táctil', 2, 5, 5, 1),
('AD321GH', 'Caja automática, control crucero, climatizador', 2, 7, 1, 1),
('AE654IJ', 'Aire acondicionado, doble airbag, bluetooth', 3, 9, 2, 1),
('AF987KL', 'Aire acondicionado, levantavidrios eléctricos', 3, 11, 1, 1),
('AG159MN', 'Pantalla multimedia, sensores de estacionamiento', 1, 13, 5, 1),
('AH753OP', 'Doble cabina, 4x4, aire acondicionado', 2, 2, 4, 3),
('AI852QR', 'Caja manual, aire acondicionado, bajo consumo', 4, 15, 1, 1),
('AJ951ST', 'Utilitario amplio, puerta lateral corrediza', 4, 10, 6, 1),
('AK147UV', 'Sistema multimedia, control de estabilidad', 2, 16, 2, 1),
('AL258WX', 'Caja automática, climatizador, asientos confort', 1, 6, 1, 2);


-- =====================================================
-- 11. IMÁGENES DE VEHÍCULOS
-- Según la consigna, cada vehículo puede tener entre 1 y 5 imágenes.
-- =====================================================

INSERT INTO imagen_vehiculo (nroPatente, urlImagen) VALUES
('AA123BB', 'https://imagenes.tfi/AA123BB_1.jpg'),
('AA123BB', 'https://imagenes.tfi/AA123BB_2.jpg'),

('AB456CD', 'https://imagenes.tfi/AB456CD_1.jpg'),
('AB456CD', 'https://imagenes.tfi/AB456CD_2.jpg'),

('AC789EF', 'https://imagenes.tfi/AC789EF_1.jpg'),

('AD321GH', 'https://imagenes.tfi/AD321GH_1.jpg'),

('AE654IJ', 'https://imagenes.tfi/AE654IJ_1.jpg'),

('AF987KL', 'https://imagenes.tfi/AF987KL_1.jpg'),

('AG159MN', 'https://imagenes.tfi/AG159MN_1.jpg'),

('AH753OP', 'https://imagenes.tfi/AH753OP_1.jpg'),

('AI852QR', 'https://imagenes.tfi/AI852QR_1.jpg'),

('AJ951ST', 'https://imagenes.tfi/AJ951ST_1.jpg'),

('AK147UV', 'https://imagenes.tfi/AK147UV_1.jpg'),

('AL258WX', 'https://imagenes.tfi/AL258WX_1.jpg');


-- =====================================================
-- 12. REGISTRO DE ESTADO DE VEHÍCULOS
-- Historial inicial de estados.
-- =====================================================

INSERT INTO registro_estado
(fechaInicio, fechaFin, observacion, idTipoEstado, nroPatente) VALUES
('2026-01-01', NULL, 'Vehículo disponible para alquiler', 1, 'AA123BB'),
('2026-01-01', NULL, 'Vehículo disponible para alquiler', 1, 'AB456CD'),
('2026-01-01', NULL, 'Vehículo disponible para alquiler', 1, 'AC789EF'),
('2026-01-01', NULL, 'Vehículo disponible para alquiler', 1, 'AD321GH'),
('2026-01-01', NULL, 'Vehículo disponible para alquiler', 1, 'AE654IJ'),
('2026-01-01', NULL, 'Vehículo disponible para alquiler', 1, 'AF987KL'),
('2026-01-01', NULL, 'Vehículo disponible para alquiler', 1, 'AG159MN'),

('2026-05-20', NULL, 'Vehículo enviado a mantenimiento preventivo', 3, 'AH753OP'),

('2026-01-01', NULL, 'Vehículo disponible para alquiler', 1, 'AI852QR'),
('2026-01-01', NULL, 'Vehículo disponible para alquiler', 1, 'AJ951ST'),
('2026-01-01', NULL, 'Vehículo disponible para alquiler', 1, 'AK147UV'),

('2026-05-25', NULL, 'Vehículo actualmente alquilado', 2, 'AL258WX');


-- =====================================================
-- 13. RESERVAS
-- IMPORTANTE:
-- Esto funciona si ya agregaste la tabla reserva.
-- =====================================================

INSERT INTO reserva 
(fechaReserva, fechaInicio, fechaFin, estadoReserva, idUsuario, nroPatente) VALUES
('2026-05-20 10:00:00', '2026-06-10 09:00:00', '2026-06-15 09:00:00', 'ACTIVA', 2, 'AA123BB'),

('2026-05-21 12:30:00', '2026-06-12 10:00:00', '2026-06-14 10:00:00', 'ACTIVA', 3, 'AC789EF'),

('2026-05-22 15:00:00', '2026-06-20 08:00:00', '2026-06-25 08:00:00', 'ACTIVA', 4, 'AE654IJ'),

('2026-05-18 09:20:00', '2026-06-05 09:00:00', '2026-06-08 09:00:00', 'CANCELADA', 5, 'AG159MN'),

('2026-05-23 11:10:00', '2026-06-18 14:00:00', '2026-06-22 14:00:00', 'ACTIVA', 6, 'AI852QR');


-- =====================================================
-- 14. ALQUILERES




INSERT INTO alquiler 
(cantidadKMinicio, cantidadKMfin, fechaInicio, fechaDevolucionPrevista, fechaDevolucionReal, idUsuario, nroPatente, idTarifa, idReserva) VALUES
(45000, NULL, '2026-05-25 09:00:00', '2026-05-30 09:00:00', NULL, 8, 'AL258WX', 7, NULL),

(12000, 12450, '2026-05-10 09:00:00', '2026-05-13 09:00:00', '2026-05-13 11:00:00', 5, 'AF987KL', 13, NULL),

(25000, 25320, '2026-05-01 10:00:00', '2026-05-04 10:00:00', '2026-05-04 10:00:00', 6, 'AC789EF', 11, NULL);



-- =====================================================
-- 15. FACTURAS
-- Se generan solo para alquileres finalizados.
-- Alquiler 2:
-- Vehículo AF987KL, tarifa idTarifa 13 = $33.000 por día.
-- 3 días = $99.000.
-- Devolución 2 horas tarde.
-- Recargo: 8% de 33.000 = 2.640 por hora.
-- 2 horas = 5.280.
-- Total = 104.280.
--
-- Alquiler 3:
-- Vehículo AC789EF, tarifa idTarifa 11 = $35.000 por día.
-- 3 días = $105.000.
-- Sin recargo.
-- Total = 105.000.
-- =====================================================

INSERT INTO factura (fecha, total, idUsuario, idAlquiler) VALUES
('2026-05-13', 104280.00, 5, 2),
('2026-05-04', 105000.00, 6, 3);


-- =====================================================
-- 16. DETALLE FACTURA
-- =====================================================

INSERT INTO detalle_factura 
(nroFactura, nroRenglon, concepto, cantidad, precio, subTotal) VALUES
(1, 1, 'Alquiler vehículo Fiat Cronos por 3 días', 3, 33000.00, 99000.00),
(1, 2, 'Recargo por devolución fuera de término', 2, 2640.00, 5280.00),

(2, 1, 'Alquiler vehículo Chevrolet Onix por 3 días', 3, 35000.00, 105000.00);


-- =====================================================
-- 17. REPORTE DE ALQUILER VENCIDO
-- IMPORTANTE:
-- Esto funciona si ya creaste la tabla reporte_alquiler_vencido.
-- Este insert es opcional, porque después debería generarlo el EVENT.
-- =====================================================

INSERT INTO reporte_alquiler_vencido
(idAlquiler, nroPatente, idUsuario, fechaDevolucionPrevista, observacion)
VALUES
(1, 'AL258WX', 8, '2026-05-30 09:00:00', 'Registro de prueba: alquiler activo pendiente de devolución');


-- =====================================================
-- 18. LOGS DE AUDITORÍA DE PRUEBA
-- IMPORTANTE:
-- Esto funciona si ya creaste la tabla log_auditoria.
-- Estos logs son de ejemplo. Luego deberían generarse automáticamente con triggers.
-- =====================================================

INSERT INTO log_auditoria
(tablaAfectada, operacion, usuarioBD, idRegistro, valoresAnteriores, valoresNuevos)
VALUES
(
    'cliente',
    'INSERT',
    CURRENT_USER(),
    '2',
    NULL,
    JSON_OBJECT(
        'idUsuario', 2,
        'DNI', '40111222',
        'nombreYapellido', 'Lucía Gómez',
        'telefono', '3757-111111',
        'fechaNac', '1998-04-15'
    )
),
(
    'vehiculo',
    'INSERT',
    CURRENT_USER(),
    'AA123BB',
    NULL,
    JSON_OBJECT(
        'nroPatente', 'AA123BB',
        'detalleConfort', 'Aire acondicionado, caja automática, pantalla multimedia',
        'idSucursal', 1,
        'idModelo', 1,
        'idTipo', 1,
        'idTipoEstado', 1
    )
),
(
    'reserva',
    'INSERT',
    CURRENT_USER(),
    '1',
    NULL,
    JSON_OBJECT(
        'idReserva', 1,
        'fechaInicio', '2026-06-10 09:00:00',
        'fechaFin', '2026-06-15 09:00:00',
        'estadoReserva', 'ACTIVA',
        'idUsuario', 2,
        'nroPatente', 'AA123BB'
    )
);



-- SELECTS --
SELECT * FROM usuario;
SELECT * FROM cliente;
SELECT * FROM administrador;
SELECT * FROM marca;
SELECT * FROM modelo;
SELECT * FROM sucursal;
SELECT * FROM tipo_vehiculo;
SELECT * FROM estado;
SELECT * FROM tarifa;
SELECT * FROM vehiculo;
SELECT * FROM imagen_vehiculo;
SELECT * FROM registro_estado;
SELECT * FROM reserva;
SELECT * FROM alquiler;
SELECT * FROM factura;
SELECT * FROM detalle_factura;
SELECT * FROM log_auditoria;
SELECT * FROM reporte_alquiler_vencido;


SELECT 
    v.nroPatente,
    ma.nombreMarca,
    mo.nombreModelo,
    tv.nombreTipo,
    s.nombreSucursal,
    e.nombreTipoEstado,
    v.detalleConfort
FROM vehiculo v
INNER JOIN modelo mo ON v.idModelo = mo.idModelo
INNER JOIN marca ma ON mo.idMarca = ma.idMarca
INNER JOIN tipo_vehiculo tv ON v.idTipo = tv.idTipo
INNER JOIN sucursal s ON v.idSucursal = s.idSucursal
INNER JOIN estado e ON v.idTipoEstado = e.idTipoEstado;







