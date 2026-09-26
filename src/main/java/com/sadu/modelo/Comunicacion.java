package com.sadu.modelo;

import java.sql.Date;
import java.sql.Timestamp;

/**
 * Clase modelo que representa la tabla comunicaciones de la base de datos.
 * Cada instancia corresponde a una comunicación radicada en el sistema SADU.
 *
 * Campos de la tabla comunicaciones:
 *   id_comunicacion, radicado, tipo, dependencia, asunto,
 *   fecha_comunicacion, estado, id_usuario, fecha_registro
 */
public class Comunicacion {

    // Identificador único (AUTO_INCREMENT)
    private int idComunicacion;

    // Número de radicado único (ej: RAD-2026-001)
    private String radicado;

    // Tipo: INTERNA o EXTERNA
    private String tipo;

    // Dependencia que genera o recibe la comunicación
    private String dependencia;

    // Asunto o descripción breve de la comunicación
    private String asunto;

    // Fecha oficial de la comunicación
    private Date fechaComunicacion;

    // Estado: RECIBIDA, EN_TRAMITE o RESPONDIDA
    private String estado;

    // ID del usuario que registró la comunicación
    private int idUsuario;

    // Nombre del usuario (se obtiene con JOIN al listar)
    private String nombreUsuario;

    // Fecha y hora en que se registró en el sistema
    private Timestamp fechaRegistro;

    // ── Constructor vacío ──────────────────────────────────────────
    public Comunicacion() {}

    // ── Getters y Setters ──────────────────────────────────────────

    public int getIdComunicacion()              { return idComunicacion; }
    public void setIdComunicacion(int v)        { this.idComunicacion = v; }

    public String getRadicado()                 { return radicado; }
    public void setRadicado(String v)           { this.radicado = v; }

    public String getTipo()                     { return tipo; }
    public void setTipo(String v)               { this.tipo = v; }

    public String getDependencia()              { return dependencia; }
    public void setDependencia(String v)        { this.dependencia = v; }

    public String getAsunto()                   { return asunto; }
    public void setAsunto(String v)             { this.asunto = v; }

    public Date getFechaComunicacion()          { return fechaComunicacion; }
    public void setFechaComunicacion(Date v)    { this.fechaComunicacion = v; }

    public String getEstado()                   { return estado; }
    public void setEstado(String v)             { this.estado = v; }

    public int getIdUsuario()                   { return idUsuario; }
    public void setIdUsuario(int v)             { this.idUsuario = v; }

    public String getNombreUsuario()            { return nombreUsuario; }
    public void setNombreUsuario(String v)      { this.nombreUsuario = v; }

    public Timestamp getFechaRegistro()         { return fechaRegistro; }
    public void setFechaRegistro(Timestamp v)   { this.fechaRegistro = v; }
}