package com.sadu.modelo;

import java.sql.Timestamp;

/**
 * Clase modelo que representa la tabla mensajes_chat de la base de datos.
 * Cada instancia corresponde a un mensaje enviado por un usuario.
 */
public class Mensaje {

    // Identificador único del mensaje
    private int idMensaje;

    // ID del usuario que envió el mensaje
    private int idUsuario;

    // Nombre completo del usuario (se obtiene con JOIN al listar)
    private String nombreUsuario;

    // Asunto del mensaje
    private String asunto;

    // Contenido del mensaje
    private String mensaje;

    // Estado: PENDIENTE, LEIDO o RESPONDIDO
    private String estado;

    // Fecha y hora en que se envió el mensaje
    private Timestamp fechaEnvio;

    /**
     * Constructor vacío requerido para instanciar desde el DAO.
     */
    public Mensaje() {
    }

    /**
     * Constructor completo con todos los campos.
     */
    public Mensaje(int idMensaje, int idUsuario, String nombreUsuario,
                   String asunto, String mensaje, String estado, Timestamp fechaEnvio) {
        this.idMensaje     = idMensaje;
        this.idUsuario     = idUsuario;
        this.nombreUsuario = nombreUsuario;
        this.asunto        = asunto;
        this.mensaje       = mensaje;
        this.estado        = estado;
        this.fechaEnvio    = fechaEnvio;
    }

    // --- Getters y Setters ---

    public int getIdMensaje() {
        return idMensaje;
    }

    public void setIdMensaje(int idMensaje) {
        this.idMensaje = idMensaje;
    }

    public int getIdUsuario() {
        return idUsuario;
    }

    public void setIdUsuario(int idUsuario) {
        this.idUsuario = idUsuario;
    }

    public String getNombreUsuario() {
        return nombreUsuario;
    }

    public void setNombreUsuario(String nombreUsuario) {
        this.nombreUsuario = nombreUsuario;
    }

    public String getAsunto() {
        return asunto;
    }

    public void setAsunto(String asunto) {
        this.asunto = asunto;
    }

    public String getMensaje() {
        return mensaje;
    }

    public void setMensaje(String mensaje) {
        this.mensaje = mensaje;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public Timestamp getFechaEnvio() {
        return fechaEnvio;
    }

    public void setFechaEnvio(Timestamp fechaEnvio) {
        this.fechaEnvio = fechaEnvio;
    }
}