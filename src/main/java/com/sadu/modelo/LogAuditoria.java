package com.sadu.modelo;

import java.sql.Timestamp;

/**
 * Clase modelo que representa la tabla logs_auditoria de la base de datos.
 * Cada instancia corresponde a un evento registrado automáticamente
 * por el sistema SADU cuando un usuario realiza una acción importante.
 *
 * Campos de la tabla logs_auditoria:
 *   id_log, id_usuario, accion, detalle, fecha_log
 */
public class LogAuditoria {

    // Identificador único del log (AUTO_INCREMENT)
    private int idLog;

    // ID del usuario que realizó la acción
    private int idUsuario;

    // Nombre completo del usuario (se obtiene con JOIN al listar)
    private String nombreUsuario;

    // Acción realizada (ej: LOGIN, REGISTRO_DOCUMENTO, ENVIO_MENSAJE, etc.)
    private String accion;

    // Detalle adicional de la acción (descripción más amplia)
    private String detalle;

    // Fecha y hora exacta en que ocurrió el evento
    private Timestamp fechaLog;

    // ── Constructor vacío ──────────────────────────────────────────
    public LogAuditoria() {}

    /**
     * Constructor completo para crear un log desde el código
     * sin necesidad de llamar cada setter por separado.
     */
    public LogAuditoria(int idUsuario, String accion, String detalle) {
        this.idUsuario = idUsuario;
        this.accion    = accion;
        this.detalle   = detalle;
    }

    // ── Getters y Setters ──────────────────────────────────────────

    public int getIdLog()                   { return idLog; }
    public void setIdLog(int v)             { this.idLog = v; }

    public int getIdUsuario()               { return idUsuario; }
    public void setIdUsuario(int v)         { this.idUsuario = v; }

    public String getNombreUsuario()        { return nombreUsuario; }
    public void setNombreUsuario(String v)  { this.nombreUsuario = v; }

    public String getAccion()               { return accion; }
    public void setAccion(String v)         { this.accion = v; }

    public String getDetalle()              { return detalle; }
    public void setDetalle(String v)        { this.detalle = v; }

    public Timestamp getFechaLog()          { return fechaLog; }
    public void setFechaLog(Timestamp v)    { this.fechaLog = v; }
}