package com.sadu.config;

import java.sql.Connection;
import java.sql.DriverManager;

/**
 * Clase encargada de establecer la conexión con la base de datos.
 */
public class Conexion {

    // ═══════════════════════════════════════════════════════════════
    // Valores por defecto para desarrollo LOCAL (localhost)
    // En producción (Railway) se usan las variables de entorno:
    //   DB_URL, DB_USER, DB_PASSWORD
    // ═══════════════════════════════════════════════════════════════
    private static final String URL_LOCAL = "jdbc:mysql://localhost:3306/sadu_apis?useSSL=false&serverTimezone=UTC";
    private static final String USER_LOCAL = "root";
    private static final String PASSWORD_LOCAL = "";

    /**
     * Método que retorna una conexión activa a la base de datos.
     * Detecta automáticamente si está en Railway (variables de entorno)
     * o en localhost (valores por defecto).
     *
     * @return objeto Connection
     * @throws Exception si ocurre un error al conectar
     */
    public static Connection getConnection() throws Exception {

        // Cargar el driver JDBC de MySQL
        Class.forName("com.mysql.cj.jdbc.Driver");

        // Leer variables de entorno (Railway) o usar valores locales
        String url  = System.getenv("DB_URL")      != null ? System.getenv("DB_URL")      : URL_LOCAL;
        String user = System.getenv("DB_USER")     != null ? System.getenv("DB_USER")     : USER_LOCAL;
        String pass = System.getenv("DB_PASSWORD") != null ? System.getenv("DB_PASSWORD") : PASSWORD_LOCAL;

        // Retornar la conexión creada
        return DriverManager.getConnection(url, user, pass);
    }
}