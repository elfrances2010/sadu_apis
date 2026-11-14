package com.sadu.modelo;

import java.sql.Timestamp;

/**
 * Usuario - Clase modelo que representa la tabla usuarios
 */
public class Usuario {

    private int idUsuario;
    private String nombreCompleto;
    private String correo;
    private String username;
    private String password;
    private String estado;
    private int rolId;
    private Timestamp fechaCreacion;
    private boolean requiereCambioClave;

    private String nombreRol;

    public Usuario() {}

    public Usuario(int idUsuario, String nombreCompleto, String correo,
                   String username, String password, String estado,
                   int rolId, Timestamp fechaCreacion) {
        this.idUsuario      = idUsuario;
        this.nombreCompleto = nombreCompleto;
        this.correo         = correo;
        this.username       = username;
        this.password       = password;
        this.estado         = estado;
        this.rolId          = rolId;
        this.fechaCreacion  = fechaCreacion;
        this.requiereCambioClave = false;
    }

    public int getIdUsuario()              { return idUsuario; }
    public void setIdUsuario(int v)        { this.idUsuario = v; }

    public String getNombreCompleto()      { return nombreCompleto; }
    public void setNombreCompleto(String v){ this.nombreCompleto = v; }

    public String getCorreo()              { return correo; }
    public void setCorreo(String v)        { this.correo = v; }

    public String getUsername()            { return username; }
    public void setUsername(String v)      { this.username = v; }

    public String getPassword()            { return password; }
    public void setPassword(String v)      { this.password = v; }

    public String getEstado()              { return estado; }
    public void setEstado(String v)        { this.estado = v; }

    public int getRolId()                  { return rolId; }
    public void setRolId(int v)            { this.rolId = v; }

    public Timestamp getFechaCreacion()    { return fechaCreacion; }
    public void setFechaCreacion(Timestamp v){ this.fechaCreacion = v; }

    public boolean isRequiereCambioClave() { return requiereCambioClave; }
    public void setRequiereCambioClave(boolean v) { this.requiereCambioClave = v; }

    public String getNombreRol()           { return nombreRol; }
    public void setNombreRol(String v)     { this.nombreRol = v; }
}
