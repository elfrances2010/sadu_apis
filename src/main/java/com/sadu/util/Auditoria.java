package com.sadu.util;

import com.sadu.dao.LogAuditoriaDAO;

/**
 * Clase utilitaria para registrar eventos de auditoría fácilmente
 * desde cualquier servlet del sistema SADU.
 *
 * En lugar de instanciar LogAuditoriaDAO en cada servlet, se llama
 * a este método estático con una sola línea de código.
 *
 * ═══════════════════════════════════════════════════════════
 * CÓMO USARLO DESDE CUALQUIER SERVLET:
 * ═══════════════════════════════════════════════════════════
 *
 *   import com.sadu.util.Auditoria;
 *
 *   // Al hacer login exitoso en LoginServlet:
 *   Auditoria.registrar(idUsuario, "LOGIN",
 *       "Usuario inició sesión: " + username);
 *
 *   // Al registrar un documento en DocumentoServlet:
 *   Auditoria.registrar(idUsuario, "REGISTRO_DOCUMENTO",
 *       "Documento registrado: " + codigo);
 *
 *   // Al enviar un mensaje en EnviarMensajeServlet:
 *   Auditoria.registrar(idUsuario, "ENVIO_MENSAJE",
 *       "Mensaje enviado con asunto: " + asunto);
 *
 * ═══════════════════════════════════════════════════════════
 * ACCIONES ESTÁNDAR DEL SISTEMA:
 * ═══════════════════════════════════════════════════════════
 *   LOGIN                  → Inicio de sesión exitoso
 *   LOGOUT                 → Cierre de sesión
 *   REGISTRO_USUARIO       → Registro de nuevo usuario
 *   REGISTRO_DOCUMENTO     → Registro de nuevo documento
 *   REGISTRO_COMUNICACION  → Radicación de nueva comunicación
 *   ENVIO_MENSAJE          → Envío de mensaje en chat interno
 *   RECUPERACION_PASSWORD  → Solicitud de recuperación de contraseña
 * ═══════════════════════════════════════════════════════════
 */
public class Auditoria {

    /**
     * Registra un evento de auditoría en la base de datos.
     * Este método nunca lanza excepciones — si falla el log,
     * el flujo principal del servlet continúa sin interrupciones.
     *
     * @param idUsuario ID del usuario que realizó la acción
     * @param accion    Nombre de la acción (ver lista de acciones estándar arriba)
     * @param detalle   Descripción detallada del evento
     */
    public static void registrar(int idUsuario, String accion, String detalle) {
        try {
            LogAuditoriaDAO dao = new LogAuditoriaDAO();
            dao.registrarLog(idUsuario, accion, detalle);
        } catch (Exception e) {
            // Si el log falla, solo se imprime en consola — no interrumpe el flujo
            System.err.println("[Auditoria] No se pudo registrar el log: " + e.getMessage());
        }
    }
}