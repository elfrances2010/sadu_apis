package com.sadu.modelo;

import java.sql.Timestamp;

/**
 * Clase modelo que representa un mensaje del chat empresarial SADU.
 */
public class Mensaje {

    private int idMensaje;
    private int idUsuario;
    private String nombreUsuario;
    private Integer idReceptor;
    private String nombreReceptor;
    private String asunto;
    private String mensaje;
    private String tipo = "TEXTO";
    private String urlAdjunto;
    private boolean editado = false;
    private String estado = "PENDIENTE";
    private Timestamp fechaEnvio;

    public Mensaje() {
    }

    public Mensaje(int idMensaje, int idUsuario, String nombreUsuario, Integer idReceptor,
                   String asunto, String mensaje, String tipo, String urlAdjunto,
                   boolean editado, String estado, Timestamp fechaEnvio) {
        this.idMensaje     = idMensaje;
        this.idUsuario     = idUsuario;
        this.nombreUsuario = nombreUsuario;
        this.idReceptor    = idReceptor;
        this.asunto        = asunto;
        this.mensaje       = mensaje;
        this.tipo          = tipo;
        this.urlAdjunto    = urlAdjunto;
        this.editado       = editado;
        this.estado        = estado;
        this.fechaEnvio    = fechaEnvio;
    }

    public int getIdMensaje() { return idMensaje; }
    public void setIdMensaje(int idMensaje) { this.idMensaje = idMensaje; }

    public int getIdUsuario() { return idUsuario; }
    public void setIdUsuario(int idUsuario) { this.idUsuario = idUsuario; }

    public String getNombreUsuario() { return nombreUsuario; }
    public void setNombreUsuario(String nombreUsuario) { this.nombreUsuario = nombreUsuario; }

    public Integer getIdReceptor() { return idReceptor; }
    public void setIdReceptor(Integer idReceptor) { this.idReceptor = idReceptor; }

    public String getNombreReceptor() { return nombreReceptor; }
    public void setNombreReceptor(String nombreReceptor) { this.nombreReceptor = nombreReceptor; }

    public String getAsunto() { return asunto; }
    public void setAsunto(String asunto) { this.asunto = asunto; }

    public String getMensaje() { return mensaje; }
    public void setMensaje(String mensaje) { this.mensaje = mensaje; }

    public String getTipo() { return tipo; }
    public void setTipo(String tipo) { this.tipo = tipo; }

    public String getUrlAdjunto() { return urlAdjunto; }
    public void setUrlAdjunto(String urlAdjunto) { this.urlAdjunto = urlAdjunto; }

    public boolean isEditado() { return editado; }
    public void setEditado(boolean editado) { this.editado = editado; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public Timestamp getFechaEnvio() { return fechaEnvio; }
    public void setFechaEnvio(Timestamp fechaEnvio) { this.fechaEnvio = fechaEnvio; }
}