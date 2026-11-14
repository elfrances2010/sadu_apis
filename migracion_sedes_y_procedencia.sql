-- =============================================================================
-- SADU - INTEGRACIÓN TERRITORIAL + SEDES Y DEPÓSITOS DE ARCHIVO
-- Une los datos territoriales con:
--   1. Procedencia de Correspondencia Oficial (Ventanilla Única)
--   2. Sedes Universitarias y Depósitos Físicos de Custodia de Archivo
-- =============================================================================

USE `sadu_apis`;

-- 1. Tabla de Sedes y Depósitos Físicos de Archivo
CREATE TABLE IF NOT EXISTS `sedes_depositos` (
    `id_deposito` INT(11) NOT NULL AUTO_INCREMENT,
    `nombre_sede` VARCHAR(120) NOT NULL COMMENT 'Ej: Sede Central Pasto, Campus Torobajo, Sede Regional Ipiales, Sede Tumaco',
    `codigo_sede` VARCHAR(30) NOT NULL UNIQUE COMMENT 'Ej: SEDE-PAS-01, SEDE-IPI-02, SEDE-TUM-03',
    `nombre_deposito` VARCHAR(120) NOT NULL COMMENT 'Ej: Depósito Central de Archivo Histórico, Bóveda Climatizada de Microfilmación',
    `id_municipio` INT(11) NOT NULL COMMENT 'Municipio donde se ubica la sede física (FK territorio_municipio)',
    `direccion` VARCHAR(150) DEFAULT NULL,
    `responsable_custodia` VARCHAR(120) DEFAULT NULL,
    `condiciones_ambientales` VARCHAR(100) DEFAULT '18°C a 20°C / 45% a 50% Humedad Relativa (Climatizado)',
    `capacidad_estanteria` INT(11) DEFAULT 100 COMMENT 'Metros lineales o estantes de archivo',
    `fecha_registro` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id_deposito`),
    KEY `idx_deposito_municipio` (`id_municipio`),
    CONSTRAINT `fk_deposito_municipio_ref` FOREIGN KEY (`id_municipio`) REFERENCES `territorio_municipio` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Sedes Universitarias y Depósitos por Defecto vinculados a Municipios Reales
-- Buscamos municipios como Pasto, Ipiales y Tumaco
INSERT INTO `sedes_depositos` 
(`nombre_sede`, `codigo_sede`, `nombre_deposito`, `id_municipio`, `direccion`, `responsable_custodia`, `condiciones_ambientales`, `capacidad_estanteria`)
SELECT 'Sede Central Pasto', 'SEDE-PAS-01', 'Depósito General de Archivo Central e Histórico', m.id, 'Calle 18 Carrera 50, Ciudad Universitaria', 'Coordinador de Gestión Documental', 'Climatizado 18°C - 48% HR (Norma AGN 5037)', 250
FROM `territorio_municipio` m WHERE m.nombre LIKE '%Pasto%' LIMIT 1
ON DUPLICATE KEY UPDATE `codigo_sede`=`codigo_sede`;

INSERT INTO `sedes_depositos` 
(`nombre_sede`, `codigo_sede`, `nombre_deposito`, `id_municipio`, `direccion`, `responsable_custodia`, `condiciones_ambientales`, `capacidad_estanteria`)
SELECT 'Sede Regional Ipiales', 'SEDE-IPI-02', 'Archivo de Gestión y Transferencias Secundarias', m.id, 'Avenida Panamericana Km 1', 'Auxiliar de Archivo y Correspondencia', 'Ventilación natural controlada con deshumidificador', 120
FROM `territorio_municipio` m WHERE m.nombre LIKE '%Ipiales%' LIMIT 1
ON DUPLICATE KEY UPDATE `codigo_sede`=`codigo_sede`;

INSERT INTO `sedes_depositos` 
(`nombre_sede`, `codigo_sede`, `nombre_deposito`, `id_municipio`, `direccion`, `responsable_custodia`, `condiciones_ambientales`, `capacidad_estanteria`)
SELECT 'Sede Regional Tumaco', 'SEDE-TUM-03', 'Bóveda Especial de Custodia y Microfilmación Marina', m.id, 'Sector La Florida, Edificio de Posgrados', 'Especialista en Preservación y Microfilmación', 'Cámara hiperbárica y deshumidificación continua 40% HR', 80
FROM `territorio_municipio` m WHERE m.nombre LIKE '%Tumaco%' LIMIT 1
ON DUPLICATE KEY UPDATE `codigo_sede`=`codigo_sede`;

-- 3. Vincular Procedencia Territorial a la tabla Comunicaciones (Ventanilla Única)
SET @col_exist = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'sadu_apis' 
      AND TABLE_NAME = 'comunicaciones' 
      AND COLUMN_NAME = 'municipio_procedencia'
);

SET @sql = IF(@col_exist = 0, 
    'ALTER TABLE `comunicaciones` 
     ADD COLUMN `municipio_procedencia` VARCHAR(120) NULL COMMENT "Municipio o ciudad de origen del remitente" AFTER `dependencia`,
     ADD COLUMN `id_municipio` INT(11) NULL COMMENT "FK municipio sincronizado" AFTER `municipio_procedencia`', 
    'SELECT "Columna ya existe en comunicaciones"');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 4. Vincular Sede/Depósito Físico a los soportes especiales (Microfilminas/Fotografías)
SET @col_soporte_exist = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'sadu_apis' 
      AND TABLE_NAME = 'documento_soporte_especial' 
      AND COLUMN_NAME = 'id_deposito'
);

SET @sql_soporte = IF(@col_soporte_exist = 0, 
    'ALTER TABLE `documento_soporte_especial` 
     ADD COLUMN `id_deposito` INT(11) NULL COMMENT "Depósito físico donde reposa el rollo o negativo" AFTER `id_documento`,
     ADD CONSTRAINT `fk_soporte_deposito_ref` FOREIGN KEY (`id_deposito`) REFERENCES `sedes_depositos` (`id_deposito`) ON DELETE SET NULL', 
    'SELECT "Columna ya existe en soporte especial"');
PREPARE stmt2 FROM @sql_soporte;
EXECUTE stmt2;
DEALLOCATE PREPARE stmt2;

