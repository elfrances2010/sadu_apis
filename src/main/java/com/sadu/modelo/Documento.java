package com.sadu.modelo;

import java.sql.Date;
import java.sql.Timestamp;

/**
 * Clase modelo que representa la tabla documentos de la base de datos.
 * Cada instancia corresponde a un documento registrado en el sistema SADU.
 *
 * Campos de la tabla documentos:
 *   id_documento, codigo, nombre_documento, tipo_documento,
 *   dependencia, fecha_documento, ruta_archivo, qr_codigo,
 *   trd, estado, id_usuario, fecha_registro
 */
public class Documento {

    // Identificador único del documento (AUTO_INCREMENT)
    private int idDocumento;

    // Código único del documento (ej: DOC-2025-001)
    private String codigo;

    // Nombre o título del documento
    private String nombreDocumento;

    // Tipo de documento (ej: Oficio, Circular, Resolución, Acta, etc.)
    private String tipoDocumento;

    // Dependencia municipal que genera el documento
    private String dependencia;

    // Fecha del documento (no la fecha de registro en el sistema)
    private Date fechaDocumento;

    // Ruta del archivo digital (si fue digitalizado)
    private String rutaArchivo;

    // Código QR asignado al documento para trazabilidad
    private String qrCodigo;

    // Tabla de Retención Documental asignada
    private String trd;

    // Estado: REGISTRADO, EN_PROCESO o ARCHIVADO
    private String estado;

    // ID del usuario que registró el documento
    private int idUsuario;

    // Nombre del usuario (se obtiene con JOIN al listar)
    private String nombreUsuario;

    // Fecha y hora en que se registró en el sistema
    private Timestamp fechaRegistro;

    // ── Constructor vacío ──────────────────────────────────────────
    public Documento() {}

    // ── Getters y Setters ──────────────────────────────────────────

    public int getIdDocumento()            { return idDocumento; }
    public void setIdDocumento(int v)      { this.idDocumento = v; }

    public String getCodigo()              { return codigo; }
    public void setCodigo(String v)        { this.codigo = v; }

    public String getNombreDocumento()     { return nombreDocumento; }
    public void setNombreDocumento(String v){ this.nombreDocumento = v; }

    public String getTipoDocumento()       { return tipoDocumento; }
    public void setTipoDocumento(String v) { this.tipoDocumento = v; }

    public String getDependencia()         { return dependencia; }
    public void setDependencia(String v)   { this.dependencia = v; }

    public Date getFechaDocumento()        { return fechaDocumento; }
    public void setFechaDocumento(Date v)  { this.fechaDocumento = v; }

    public String getRutaArchivo()         { return rutaArchivo; }
    public void setRutaArchivo(String v)   { this.rutaArchivo = v; }

    public String getQrCodigo()            { return qrCodigo; }
    public void setQrCodigo(String v)      { this.qrCodigo = v; }

    public String getTrd()                 { return trd; }
    public void setTrd(String v)           { this.trd = v; }

    public String getEstado()              { return estado; }
    public void setEstado(String v)        { this.estado = v; }

    public int getIdUsuario()              { return idUsuario; }
    public void setIdUsuario(int v)        { this.idUsuario = v; }

    public String getNombreUsuario()       { return nombreUsuario; }
    public void setNombreUsuario(String v) { this.nombreUsuario = v; }

    public Timestamp getFechaRegistro()         { return fechaRegistro; }
    public void setFechaRegistro(Timestamp v)   { this.fechaRegistro = v; }
}
