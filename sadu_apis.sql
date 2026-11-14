-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 15-08-2026 a las 18:16:12
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `sadu_apis`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `comunicaciones`
--

CREATE TABLE `comunicaciones` (
  `id_comunicacion` int(11) NOT NULL,
  `radicado` varchar(30) NOT NULL,
  `tipo` enum('INTERNA','EXTERNA') NOT NULL,
  `dependencia` varchar(100) NOT NULL,
  `asunto` varchar(200) NOT NULL,
  `fecha_comunicacion` date NOT NULL,
  `estado` enum('RECIBIDA','EN_TRAMITE','RESPONDIDA') DEFAULT 'RECIBIDA',
  `id_usuario` int(11) NOT NULL,
  `fecha_registro` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `comunicaciones`
--

INSERT INTO `comunicaciones` (`id_comunicacion`, `radicado`, `tipo`, `dependencia`, `asunto`, `fecha_comunicacion`, `estado`, `id_usuario`, `fecha_registro`) VALUES
(1, 'RAD-2026-001', 'INTERNA', 'ARCHIVO CENTRAL', 'Solicitud de expediente interno', '2026-05-20', 'RECIBIDA', 1, '2026-05-24 19:56:23'),
(2, 'RAD-2026-002', 'EXTERNA', 'SECRETARIA GENERAL', 'Respuesta a petición ciudadana', '2026-05-21', 'EN_TRAMITE', 2, '2026-05-24 19:56:23'),
(3, 'RAD-2026-003', 'INTERNA', 'PLANEACION', 'Remisión de informe técnico', '2026-05-22', 'RESPONDIDA', 3, '2026-05-24 19:56:23');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `documentos`
--

CREATE TABLE `documentos` (
  `id_documento` int(11) NOT NULL,
  `codigo` varchar(30) NOT NULL,
  `nombre_documento` varchar(150) NOT NULL,
  `tipo_documento` varchar(80) NOT NULL,
  `dependencia` varchar(100) NOT NULL,
  `fecha_documento` date NOT NULL,
  `ruta_archivo` varchar(255) DEFAULT NULL,
  `qr_codigo` varchar(120) DEFAULT NULL,
  `trd` varchar(100) DEFAULT NULL,
  `estado` enum('REGISTRADO','EN_PROCESO','ARCHIVADO') DEFAULT 'REGISTRADO',
  `id_usuario` int(11) NOT NULL,
  `fecha_registro` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `documentos`
--

INSERT INTO `documentos` (`id_documento`, `codigo`, `nombre_documento`, `tipo_documento`, `dependencia`, `fecha_documento`, `ruta_archivo`, `qr_codigo`, `trd`, `estado`, `id_usuario`, `fecha_registro`) VALUES
(1, 'DOC-001', 'Acta de reunión archivo', 'ACTA', 'ARCHIVO CENTRAL', '2026-05-20', 'uploads/acta1.pdf', 'QR-DOC-001', 'TRD-AC-01', 'REGISTRADO', 1, '2026-05-24 19:56:04'),
(2, 'DOC-002', 'Resolución administrativa', 'RESOLUCION', 'SECRETARIA GENERAL', '2026-05-21', 'uploads/resolucion1.pdf', 'QR-DOC-002', 'TRD-SG-02', 'EN_PROCESO', 2, '2026-05-24 19:56:04'),
(3, 'DOC-003', 'Informe de gestión', 'INFORME', 'PLANEACION', '2026-05-22', 'uploads/informe1.pdf', 'QR-DOC-003', 'TRD-PL-01', 'ARCHIVADO', 3, '2026-05-24 19:56:04');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `logs_auditoria`
--

CREATE TABLE `logs_auditoria` (
  `id_log` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `accion` varchar(150) NOT NULL,
  `detalle` text DEFAULT NULL,
  `fecha_log` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `logs_auditoria`
--

INSERT INTO `logs_auditoria` (`id_log`, `id_usuario`, `accion`, `detalle`, `fecha_log`) VALUES
(33, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-05-27 03:16:26'),
(34, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-05-27 04:49:29'),
(35, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-05-27 05:33:55'),
(36, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-05-29 06:05:32'),
(37, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-05-29 06:16:52'),
(38, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-05-29 06:26:53'),
(39, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-05-29 06:32:18'),
(40, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-05-29 06:37:21'),
(41, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-05-31 04:41:36'),
(42, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-06-01 06:50:04'),
(43, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-06-01 07:04:20'),
(44, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-06-01 07:18:17'),
(45, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-06-01 07:26:16'),
(46, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-06-15 10:25:38'),
(47, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-06-17 15:09:09'),
(48, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-06-19 00:46:22'),
(49, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-06-24 17:15:31'),
(50, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-06-24 17:30:06'),
(51, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-06-24 17:40:24'),
(52, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-06-24 17:43:32'),
(53, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-06-24 17:44:53'),
(54, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-06-24 17:46:50'),
(55, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-06-24 18:12:15'),
(56, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-06-24 18:13:23'),
(57, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-06-25 01:46:21'),
(58, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-06-25 03:43:00'),
(59, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-06-26 01:30:19'),
(60, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-06-26 02:57:47'),
(61, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-06-27 01:20:29'),
(62, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-06-28 00:45:43'),
(63, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-06-28 00:46:37'),
(64, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-06-28 01:32:14'),
(65, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-06-30 02:19:43'),
(66, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-06-30 02:44:59'),
(67, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-06-30 03:20:06'),
(68, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-07-05 03:07:48'),
(69, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-07-05 06:10:42'),
(70, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-07-05 06:42:36'),
(71, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-07-05 06:44:56'),
(72, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-07-05 06:48:00'),
(73, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-07-05 06:48:39'),
(74, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-07-05 06:59:32'),
(75, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-07-05 07:01:12'),
(76, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-07-05 07:01:33'),
(77, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-07-05 07:04:28'),
(78, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-07-05 13:44:13'),
(79, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-07-05 13:56:37'),
(80, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-07-05 21:20:09'),
(81, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-07-06 01:15:19'),
(82, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-07-06 01:35:01'),
(83, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-07-08 14:53:20'),
(84, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-07-08 15:04:09'),
(85, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-07-08 15:45:53'),
(86, 59, 'LOGIN', 'Inicio de sesión exitoso. Usuario: nsuarez | Correo: natalia.suarez@sadu.com', '2026-07-08 15:55:46'),
(87, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-07-08 17:07:00'),
(88, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-07-08 17:17:47'),
(89, 2, 'REGISTRAR_USUARIO', 'Admin \'scastro95\' registró al usuario: \'carolo\' | Correo: carolo@sadu.com | Rol ID: 3', '2026-07-08 17:19:12'),
(90, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-07-09 16:01:12'),
(91, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-07-28 14:18:53'),
(92, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-07-28 16:32:10'),
(93, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-07-28 17:47:31'),
(94, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-07-31 00:54:55'),
(95, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-07-31 01:28:07'),
(96, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-07-31 02:26:46'),
(97, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-07-31 03:22:15'),
(98, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-07-31 03:24:02'),
(99, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-07-31 19:26:01'),
(100, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmil.com', '2026-08-02 03:27:10'),
(101, 2, 'EDITAR_USUARIO', 'Admin \'scastro95\' editó al usuario ID: 2 | Nuevo username: \'scastro95\' | Nuevo correo: scastro95@gmail.com | Nuevo rol ID: 1', '2026-08-02 03:28:14'),
(102, 2, 'LOGIN', 'Inicio de sesión exitoso. Usuario: scastro95 | Correo: scastro95@gmail.com', '2026-08-02 05:14:52');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `mensajes_chat`
--

CREATE TABLE `mensajes_chat` (
  `id_mensaje` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `asunto` varchar(120) NOT NULL,
  `mensaje` text NOT NULL,
  `estado` enum('PENDIENTE','LEIDO','RESPONDIDO') DEFAULT 'PENDIENTE',
  `fecha_envio` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `mensajes_chat`
--

INSERT INTO `mensajes_chat` (`id_mensaje`, `id_usuario`, `asunto`, `mensaje`, `estado`, `fecha_envio`) VALUES
(9, 2, 'kk', 'yyuy', 'PENDIENTE', '2026-05-26 22:36:45');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `roles`
--

CREATE TABLE `roles` (
  `id_rol` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `roles`
--

INSERT INTO `roles` (`id_rol`, `nombre`, `descripcion`) VALUES
(1, 'ADMINISTRADOR', 'Control total del sistema'),
(2, 'GESTOR_ARCHIVO', 'Gestiona documentos y archivo'),
(3, 'DEPENDENCIA', 'Usuario de dependencia municipal');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id_usuario` int(11) NOT NULL,
  `nombre_completo` varchar(120) NOT NULL,
  `correo` varchar(120) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `estado` enum('ACTIVO','INACTIVO') NOT NULL DEFAULT 'ACTIVO',
  `id_rol` int(11) NOT NULL,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id_usuario`, `nombre_completo`, `correo`, `username`, `password`, `estado`, `id_rol`, `fecha_creacion`) VALUES
(1, 'Ana LÃ³pez Actualizada', 'admin@sadu.com', 'admin', '123456', 'INACTIVO', 1, '2026-05-20 00:14:15'),
(2, 'Samuel Castro', 'scastro95@gmail.com', 'scastro95', 'kamilo', 'ACTIVO', 1, '2026-05-24 17:02:22'),
(3, 'Ana LÃ³pez Actualizada', 'diana.zamudio@sadu.com', 'dzamudio', '123456', 'INACTIVO', 2, '2026-05-24 19:54:44'),
(4, 'Felipe Briceño', 'felipe.briceno@sadu.com', 'fbriceno', '123456', 'ACTIVO', 1, '2026-05-24 19:54:44'),
(5, 'Laura Gómez', 'laura.gomez@sadu.com', 'lgomez', '123456', 'ACTIVO', 3, '2026-05-24 19:54:44'),
(6, 'Carlos Martínez', 'carlos.martinez@sadu.com', 'cmartinez', '123456', 'ACTIVO', 3, '2026-05-24 19:54:44'),
(7, 'Andrea Rojas', 'andrea.rojas@sadu.com', 'arojas', '123456', 'ACTIVO', 2, '2026-05-24 19:54:44'),
(55, 'Miguel Torres', 'miguel.torres@sadu.com', 'mtorres', '123456', 'ACTIVO', 3, '2026-05-24 20:06:41'),
(56, 'Paula Ramírez', 'paula.ramirez@sadu.com', 'pramirez', '123456', 'ACTIVO', 3, '2026-05-24 20:06:41'),
(57, 'Sandra Morales', 'sandra.morales@sadu.com', 'smorales', '123456', 'ACTIVO', 2, '2026-05-24 20:06:41'),
(58, 'Jhon Castro', 'jhon.castro@sadu.com', 'jcastro', '123456', 'ACTIVO', 3, '2026-05-24 20:06:41'),
(59, 'Natalia Suárez', 'natalia.suarez@sadu.com', 'nsuarez', '123456', 'ACTIVO', 2, '2026-05-24 20:06:41'),
(60, 'Camilo Herrera', 'camilo.herrera@sadu.com', 'cherrera', '123456', 'ACTIVO', 3, '2026-05-24 20:06:41'),
(61, 'Luisa Fernanda Peña', 'luisa.pena@sadu.com', 'lpena', '123456', 'ACTIVO', 3, '2026-05-24 20:06:41'),
(64, 'Carolina lao', 'carolo@sadu.com', 'carolo', '123456', 'ACTIVO', 3, '2026-07-08 17:19:12');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `comunicaciones`
--
ALTER TABLE `comunicaciones`
  ADD PRIMARY KEY (`id_comunicacion`),
  ADD UNIQUE KEY `radicado` (`radicado`),
  ADD KEY `fk_comunicacion_usuario` (`id_usuario`);

--
-- Indices de la tabla `documentos`
--
ALTER TABLE `documentos`
  ADD PRIMARY KEY (`id_documento`),
  ADD UNIQUE KEY `codigo` (`codigo`),
  ADD KEY `fk_documento_usuario` (`id_usuario`);

--
-- Indices de la tabla `logs_auditoria`
--
ALTER TABLE `logs_auditoria`
  ADD PRIMARY KEY (`id_log`),
  ADD KEY `fk_log_usuario` (`id_usuario`);

--
-- Indices de la tabla `mensajes_chat`
--
ALTER TABLE `mensajes_chat`
  ADD PRIMARY KEY (`id_mensaje`),
  ADD KEY `fk_chat_usuario` (`id_usuario`);

--
-- Indices de la tabla `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id_rol`),
  ADD UNIQUE KEY `nombre` (`nombre`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `correo` (`correo`),
  ADD UNIQUE KEY `username` (`username`),
  ADD KEY `fk_usuario_rol` (`id_rol`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `comunicaciones`
--
ALTER TABLE `comunicaciones`
  MODIFY `id_comunicacion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `documentos`
--
ALTER TABLE `documentos`
  MODIFY `id_documento` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT de la tabla `logs_auditoria`
--
ALTER TABLE `logs_auditoria`
  MODIFY `id_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=103;

--
-- AUTO_INCREMENT de la tabla `mensajes_chat`
--
ALTER TABLE `mensajes_chat`
  MODIFY `id_mensaje` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de la tabla `roles`
--
ALTER TABLE `roles`
  MODIFY `id_rol` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=65;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `comunicaciones`
--
ALTER TABLE `comunicaciones`
  ADD CONSTRAINT `fk_comunicacion_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`);

--
-- Filtros para la tabla `documentos`
--
ALTER TABLE `documentos`
  ADD CONSTRAINT `fk_documento_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`);

--
-- Filtros para la tabla `logs_auditoria`
--
ALTER TABLE `logs_auditoria`
  ADD CONSTRAINT `fk_log_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`);

--
-- Filtros para la tabla `mensajes_chat`
--
ALTER TABLE `mensajes_chat`
  ADD CONSTRAINT `fk_chat_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`);

--
-- Filtros para la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD CONSTRAINT `fk_usuario_rol` FOREIGN KEY (`id_rol`) REFERENCES `roles` (`id_rol`);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `documento_soporte_especial`
-- Tipos de Microfilminas, Fotografías, Negativos y Búsqueda por Texto OCR
--

CREATE TABLE IF NOT EXISTS `documento_soporte_especial` (
  `id_soporte` int(11) NOT NULL AUTO_INCREMENT,
  `id_documento` int(11) NOT NULL,
  `tipo_soporte` varchar(40) NOT NULL COMMENT 'MICROFILM_16MM, MICROFILM_35MM, MICROFICHA, JACKET_MICROFILM, TARJETA_APERTURA, FOTOGRAFIA, NEGATIVO, DIAPOSITIVA',
  `rollo_caja` varchar(60) DEFAULT NULL,
  `numero_fotograma` varchar(30) DEFAULT NULL,
  `ruta_master_tiff` varchar(255) DEFAULT NULL,
  `ruta_acceso_web` varchar(255) NOT NULL,
  `resolucion_dpi` int(11) DEFAULT 300,
  `profundidad_color` varchar(40) DEFAULT 'Escala de grises (8-bit)',
  `hash_sha256` varchar(64) DEFAULT NULL,
  `texto_ocr` longtext DEFAULT NULL,
  `observaciones_conservacion` text DEFAULT NULL,
  `fecha_digitalizacion` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_soporte`),
  KEY `fk_soporte_documento` (`id_documento`),
  KEY `idx_tipo_soporte` (`tipo_soporte`),
  KEY `idx_rollo_caja` (`rollo_caja`),
  FULLTEXT KEY `idx_texto_ocr` (`texto_ocr`),
  CONSTRAINT `fk_soporte_documento_ref` FOREIGN KEY (`id_documento`) REFERENCES `documentos` (`id_documento`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `documento_soporte_especial`
--

INSERT INTO `documento_soporte_especial` 
(`id_soporte`, `id_documento`, `tipo_soporte`, `rollo_caja`, `numero_fotograma`, `ruta_master_tiff`, `ruta_acceso_web`, `resolucion_dpi`, `profundidad_color`, `hash_sha256`, `texto_ocr`, `observaciones_conservacion`, `fecha_digitalizacion`) VALUES
(1, 1, 'MICROFILM_16MM', 'ROLLO-16MM-ACTAS-1985', 'FRAME-0142', 'storage/masters/16mm_actas_1985_f142.tiff', 'storage/web/16mm_actas_1985_f142.webp', 400, 'Escala de grises (8-bit)', 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', 'ACTA NUMERO 42 DE CONSEJO DIRECTIVO ORDINARIO. En la sala de juntas de Rectoría, se reúnen los delegados de facultades para aprobar el presupuesto de inversión municipal y la dotación de laboratorios de cómputo.', 'Película de sales de plata sobre base de poliéster de 16 mm. Óptima nitidez, sin acorchamiento ni olor a vinagre.', '2026-05-24 20:00:00'),
(2, 2, 'MICROFILM_35MM', 'ROLLO-35MM-GACETAS-1975', 'FRAME-0008', 'storage/masters/35mm_gaceta_1975_f008.tiff', 'storage/web/35mm_gaceta_1975_f008.webp', 450, 'Escala de grises (8-bit)', '7d8389da4d53cda18c2baa0c0354bb5f9a3ecbe5ed12ab4d8e11ba873c2f1116', 'GACETA OFICIAL UNIVERSITARIA No. 128. Publicación del Decreto Rectoral sobre creación del Archivo Central Universitario y reglamentación de las Tablas de Retención Documental para todas las dependencias académicas.', 'Rollo de 35 mm en haluro de plata. Ligera curvatura lateral en las primeras 5 espiras, fotograma legible al 100%.', '2026-05-24 20:05:00'),
(3, 3, 'MICROFICHA', 'FICHA-EXPED-ING-04', 'COL-3-FILA-4', 'storage/masters/microficha_expediente_1992.tiff', 'storage/web/microficha_expediente_1992.webp', 300, 'Blanco y Negro (1-bit)', '2c6ee81538da27d34d2b4063421e8d5f63fed316b20108347f017a212e13f90e', 'EXPEDIENTE ACADEMICO Y ACTA DE SUSTENTACION DE GRADO. Tesis titulada: Automatización de Procesos de Información para Bibliotecas y Archivos Públicos. Aprobada con mención de honor y recomendación de publicación.', 'Microficha plana formato 24x estándar A6 (105x148 mm). Emulsión diazo azul, sin rayaduras mecánicas.', '2026-05-24 20:10:00'),
(4, 1, 'JACKET_MICROFILM', 'JACKET-DOCENTES-B-12', 'CANAL-2-POS-3', 'storage/masters/jacket_docente_burbano.tiff', 'storage/web/jacket_docente_burbano.webp', 300, 'Escala de grises (8-bit)', 'b5d4045c3f466fa91fe2cc6abe79232a1a57cdf104f7a26e716e0a1e2789df78', 'HOJA DE SERVICIOS Y RESOLUCION DE NOMBRAMIENTO EN PROPIEDAD. Reconocimiento de escalafón docente universitario y asignación de carga académica en el área de Sistemas y Desarrollo de Software.', 'Jacket de poliéster de 5 canales de 16 mm. Conservación excelente, mangas selladas sin desprendimiento.', '2026-05-24 20:15:00'),
(5, 2, 'TARJETA_APERTURA', 'TARJETERO-INFRAEST-PL-09', 'CARD-0341', 'storage/masters/aperture_plano_biblioteca.tiff', 'storage/web/aperture_plano_biblioteca.webp', 600, 'Escala de grises (8-bit)', 'a384b6463fc216a5f8ecb6670f86456a2f31fd42b795737b893494f6f3456789', 'PLANO ARQUITECTONICO GENERAL DEL EDIFICIO DE BIBLIOTECA Y ARCHIVO CENTRAL. Distribución de áreas de depósito, salas de consulta, climatización, detectores de humo y estantería móvil rodante para acervo histórico.', 'Tarjeta perforada Hollerith de 80 columnas con fotograma de 35 mm montado en ventana troquelada. Conservación estable.', '2026-05-24 20:20:00'),
(6, 3, 'FOTOGRAFIA', 'CAJA-FOTO-HIST-01', 'FOTO-0089', 'storage/masters/inauguracion_sede_1978.tiff', 'storage/web/inauguracion_sede_1978.jpg', 600, 'Color RGB (24-bit)', '4f53cda18c2baa0c0354bb5f9a3ecbe5ed12ab4d8e11ba873c2f11161202b945', 'Inauguración de la sede central de archivo administrativo municipal. Asistencia de alcaldía, rectoría y comitiva de obras públicas durante el acto de corte de cinta y bendición de las instalaciones.', 'Fotografía original en papel baritado en blanco y negro, ligero desvanecimiento en bordes superiores por exposición a luz ambiental.', '2026-05-24 20:25:00');

COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
