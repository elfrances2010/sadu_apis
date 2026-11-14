-- =============================================================================
-- SADU - SISTEMA DE ARCHIVO DIGITAL
-- Script de Migración: Tipos de Microfilminas, Fotografías, OCR y Preservación
-- =============================================================================

USE `sadu_apis`;

-- Eliminar tabla previa si existe para aplicar los nuevos tipos
DROP TABLE IF EXISTS `documento_soporte_especial`;

CREATE TABLE `documento_soporte_especial` (
    `id_soporte` INT(11) NOT NULL AUTO_INCREMENT,
    `id_documento` INT(11) NOT NULL,
    
    -- Tipos de microfilminas y soportes especiales (VARCHAR flexible para formatos archivísticos)
    -- Valores estándar: MICROFILM_16MM, MICROFILM_35MM, MICROFICHA, JACKET_MICROFILM, TARJETA_APERTURA, FOTOGRAFIA, NEGATIVO, DIAPOSITIVA
    `tipo_soporte` VARCHAR(40) NOT NULL COMMENT 'Tipo de soporte analógico digitalizado',
    
    -- Contexto y ubicación física del soporte analógico original
    `rollo_caja` VARCHAR(60) DEFAULT NULL COMMENT 'Código de rollo, estante, fichero o gaveta física de conservación',
    `numero_fotograma` VARCHAR(30) DEFAULT NULL COMMENT 'Número de fotograma (frame), cuadrícula o tarjeta',
    
    -- Objeto Visual Digitalizado (Arquitectura de 2 capas: Master TIFF + Web WebP/JPEG)
    `ruta_master_tiff` VARCHAR(255) DEFAULT NULL COMMENT 'Ruta interna del máster de preservación sin compresión (TIFF)',
    `ruta_acceso_web` VARCHAR(255) NOT NULL COMMENT 'Ruta de la copia optimizada para consulta web (WebP/JPEG/PDF)',
    
    -- Parámetros técnicos de captura (Metadatos PREMIS / NISO Z39.87)
    `resolucion_dpi` INT(11) DEFAULT 300 COMMENT 'Resolución de escaneo (DPI)',
    `profundidad_color` VARCHAR(40) DEFAULT 'Escala de grises (8-bit)' COMMENT 'Profundidad cromática',
    `hash_sha256` VARCHAR(64) DEFAULT NULL COMMENT 'Checksum SHA-256 para validación de integridad',
    
    -- Texto extraído mediante OCR para indexación y búsqueda instantánea
    `texto_ocr` LONGTEXT DEFAULT NULL COMMENT 'Texto extraído por OCR del fotograma o soporte',
    
    -- Diagnóstico del soporte analógico original
    `observaciones_conservacion` TEXT DEFAULT NULL COMMENT 'Estado físico (síndrome de vinagre, hongos, emulsión de plata)',
    `fecha_digitalizacion` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (`id_soporte`),
    KEY `fk_soporte_documento` (`id_documento`),
    KEY `idx_tipo_soporte` (`tipo_soporte`),
    KEY `idx_rollo_caja` (`rollo_caja`),
    FULLTEXT KEY `idx_texto_ocr` (`texto_ocr`),
    CONSTRAINT `fk_soporte_documento_ref` FOREIGN KEY (`id_documento`) REFERENCES `documentos` (`id_documento`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- INSERCIÓN DE TIPOS DE MICROFILMINAS Y FOTOGRAFÍAS REALES PARA SADU
-- =============================================================================

INSERT INTO `documento_soporte_especial` 
(`id_documento`, `tipo_soporte`, `rollo_caja`, `numero_fotograma`, `ruta_master_tiff`, `ruta_acceso_web`, `resolucion_dpi`, `profundidad_color`, `hash_sha256`, `texto_ocr`, `observaciones_conservacion`)
VALUES
-- 1. Rollo de 16 mm (Documentación administrativa, correspondencia y resoluciones estándar)
(1, 'MICROFILM_16MM', 'ROLLO-16MM-ACTAS-1985', 'FRAME-0142', 
 'storage/masters/16mm_actas_1985_f142.tiff', 'storage/web/16mm_actas_1985_f142.webp', 400, 'Escala de grises (8-bit)', 
 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', 
 'ACTA NUMERO 42 DE CONSEJO DIRECTIVO ORDINARIO. En la sala de juntas de Rectoría, se reúnen los delegados de facultades para aprobar el presupuesto de inversión municipal y la dotación de laboratorios de cómputo.', 
 'Película de sales de plata sobre base de poliéster de 16 mm. Óptima nitidez, sin acorchamiento ni olor a vinagre.'),

-- 2. Rollo de 35 mm (Periódicos históricos, gacetas y actas de gran formato)
(2, 'MICROFILM_35MM', 'ROLLO-35MM-GACETAS-1975', 'FRAME-0008', 
 'storage/masters/35mm_gaceta_1975_f008.tiff', 'storage/web/35mm_gaceta_1975_f008.webp', 450, 'Escala de grises (8-bit)', 
 '7d8389da4d53cda18c2baa0c0354bb5f9a3ecbe5ed12ab4d8e11ba873c2f1116', 
 'GACETA OFICIAL UNIVERSITARIA No. 128. Publicación del Decreto Rectoral sobre creación del Archivo Central Universitario y reglamentación de las Tablas de Retención Documental para todas las dependencias académicas.', 
 'Rollo de 35 mm en haluro de plata. Ligera curvatura lateral en las primeras 5 espiras, fotograma legible al 100%.'),

-- 3. Microficha (Matriz plana 105 x 148 mm - Expedientes académicos y tesis)
(3, 'MICROFICHA', 'FICHA-EXPED-ING-04', 'COL-3-FILA-4', 
 'storage/masters/microficha_expediente_1992.tiff', 'storage/web/microficha_expediente_1992.webp', 300, 'Blanco y Negro (1-bit)', 
 '2c6ee81538da27d34d2b4063421e8d5f63fed316b20108347f017a212e13f90e', 
 'EXPEDIENTE ACADEMICO Y ACTA DE SUSTENTACION DE GRADO. Tesis titulada: Automatización de Procesos de Información para Bibliotecas y Archivos Públicos. Aprobada con mención de honor y recomendación de publicación.', 
 'Microficha plana formato 24x estándar A6 (105x148 mm). Emulsión diazo azul, sin rayaduras mecánicas.'),

-- 4. Jacket de Microfilm (Funda plástica de tiras de 16mm para expedientes de personal)
(1, 'JACKET_MICROFILM', 'JACKET-DOCENTES-B-12', 'CANAL-2-POS-3', 
 'storage/masters/jacket_docente_burbano.tiff', 'storage/web/jacket_docente_burbano.webp', 300, 'Escala de grises (8-bit)', 
 'b5d4045c3f466fa91fe2cc6abe79232a1a57cdf104f7a26e716e0a1e2789df78', 
 'HOJA DE SERVICIOS Y RESOLUCION DE NOMBRAMIENTO EN PROPIEDAD. Reconocimiento de escalafón docente universitario y asignación de carga académica en el área de Sistemas y Desarrollo de Software.', 
 'Jacket de poliéster de 5 canales de 16 mm. Conservación excelente, mangas selladas sin desprendimiento.'),

-- 5. Tarjeta de Apertura / Aperture Card (Tarjeta perforada con ventana para planos de 35 mm)
(2, 'TARJETA_APERTURA', 'TARJETERO-INFRAEST-PL-09', 'CARD-0341', 
 'storage/masters/aperture_plano_biblioteca.tiff', 'storage/web/aperture_plano_biblioteca.webp', 600, 'Escala de grises (8-bit)', 
 'a384b6463fc216a5f8ecb6670f86456a2f31fd42b795737b893494f6f3456789', 
 'PLANO ARQUITECTONICO GENERAL DEL EDIFICIO DE BIBLIOTECA Y ARCHIVO CENTRAL. Distribución de áreas de depósito, salas de consulta, climatización, detectores de humo y estantería móvil rodante para acervo histórico.', 
 'Tarjeta perforada Hollerith de 80 columnas con fotograma de 35 mm montado en ventana troquelada. Conservación estable.'),

-- 6. Fotografía Histórica Patrimonial
(3, 'FOTOGRAFIA', 'CAJA-FOTO-HIST-01', 'FOTO-0089', 
 'storage/masters/inauguracion_sede_1978.tiff', 'storage/web/inauguracion_sede_1978.jpg', 600, 'Color RGB (24-bit)', 
 '4f53cda18c2baa0c0354bb5f9a3ecbe5ed12ab4d8e11ba873c2f11161202b945', 
 'Inauguración de la sede central de archivo administrativo municipal. Asistencia de alcaldía, rectoría y comitiva de obras públicas durante el acto de corte de cinta y bendición de las instalaciones.', 
 'Fotografía original en papel baritado en blanco y negro, ligero desvanecimiento en bordes superiores por exposición a luz ambiental.');
