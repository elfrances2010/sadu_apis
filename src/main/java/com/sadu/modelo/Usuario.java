package com.sadu.modelo;

import java.sql.Timestamp;

/**
 * ════════════════════════════════════════════════════════════════
 * Usuario — Clase modelo que representa la tabla usuarios
 * ════════════════════════════════════════════════════════════════
 *
 * Cada instancia de esta clase corresponde a un registro de la tabla
 * usuarios de la base de datos del sistema SADU.
 *
 * Campos de la tabla usuarios:
 *   id_usuario, nombre_completo, correo, username, password,
 *   estado, id_rol, fecha_creacion
 *
 * Campo adicional (no está en la tabla, viene del JOIN con roles):
 *   nombreRol — nombre legible del rol (ADMINISTRADOR, GESTOR_ARCHIVO, DEPENDENCIA)
 */
public class Usuario {

    // ── Campos mapeados directamente desde la tabla usuarios ──────

    /** Identificador único del usuario (AUTO_INCREMENT) */
    private int idUsuario;

    /** Nombre completo del usuario (ej: "Diana Zamudio") */
    private String nombreCompleto;

    /** Correo electrónico único del usuario */
    private String correo;

    /** Nombre de usuario para acceso al sistema (único) */
    private String username;

    /** Contraseña del usuario (actualmente en texto plano) */
    private String password;

    /** Estado del usuario: "ACTIVO" o "INACTIVO" */
    private String estado;

    /** ID del rol asignado (FK → roles.id_rol) */
    private int rolId;

    /** Fecha y hora en que fue creado el registro */
    private Timestamp fechaCreacion;

    // ── Campo calculado (viene del JOIN con la tabla roles) ────────

    /**
     * Nombre legible del rol asignado.
     * No está en la tabla usuarios — se obtiene con JOIN en UsuarioDAO.
     * Ejemplos: "ADMINISTRADOR", "GESTOR_ARCHIVO", "DEPENDENCIA"
     */
    private String nombreRol;

    // ── Constructor vacío ──────────────────────────────────────────

    /** Constructor vacío requerido para crear instancias sin parámetros */
    public Usuario() {}

    // ── Constructor con todos los parámetros ───────────────────────

    /**
     * Constructor completo para crear un usuario con todos sus datos.
     *
     * @param idUsuario      ID único del usuario
     * @param nombreCompleto Nombre completo
     * @param correo         Correo electrónico
     * @param username       Nombre de usuario
     * @param password       Contraseña
     * @param estado         Estado ACTIVO o INACTIVO
     * @param rolId          ID del rol asignado
     * @param fechaCreacion  Fecha de creación del registro
     */
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
    }

    // ── Getters y Setters ──────────────────────────────────────────

    /** @return ID único del usuario */
    public int getIdUsuario()              { return idUsuario; }
    /** @param idUsuario ID único del usuario */
    public void setIdUsuario(int v)        { this.idUsuario = v; }

    /** @return Nombre completo del usuario */
    public String getNombreCompleto()      { return nombreCompleto; }
    /** @param v Nombre completo del usuario */
    public void setNombreCompleto(String v){ this.nombreCompleto = v; }

    /** @return Correo electrónico del usuario */
    public String getCorreo()              { return correo; }
    /** @param v Correo electrónico */
    public void setCorreo(String v)        { this.correo = v; }

    /** @return Username del usuario */
    public String getUsername()            { return username; }
    /** @param v Username del usuario */
    public void setUsername(String v)      { this.username = v; }

    /** @return Contraseña del usuario */
    public String getPassword()            { return password; }
    /** @param v Contraseña */
    public void setPassword(String v)      { this.password = v; }

    /** @return Estado: ACTIVO o INACTIVO */
    public String getEstado()              { return estado; }
    /** @param v Estado del usuario */
    public void setEstado(String v)        { this.estado = v; }

    /** @return ID del rol asignado */
    public int getRolId()                  { return rolId; }
    /** @param v ID del rol */
    public void setRolId(int v)            { this.rolId = v; }

    /** @return Fecha y hora de creación */
    public Timestamp getFechaCreacion()    { return fechaCreacion; }
    /** @param v Fecha de creación */
    public void setFechaCreacion(Timestamp v){ this.fechaCreacion = v; }

    /**
     * @return Nombre del rol (viene del JOIN con roles).
     *         Puede ser "ADMINISTRADOR", "GESTOR_ARCHIVO" o "DEPENDENCIA"
     */
    public String getNombreRol()           { return nombreRol; }
    /**
     * @param v Nombre del rol obtenido del JOIN con la tabla roles
     */
    public void setNombreRol(String v)     { this.nombreRol = v; }
}