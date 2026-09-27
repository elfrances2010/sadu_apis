package com.sadu.config;

import java.sql.Connection;
import java.sql.DriverManager;

/**
 * Clase encargada de establecer la conexion con la base de datos.
 */
public class Conexion {

    // Valores por defecto para desarrollo LOCAL (localhost)
    private static final String URL_LOCAL = "jdbc:mysql://localhost:3306/sadu_apis?useSSL=false&serverTimezone=UTC";
    private static final String USER_LOCAL = "root";
    private static final String PASSWORD_LOCAL = "";

    /**
     * Metodo que retorna una conexion activa a la base de datos.
     * Detecta automaticamente si esta en Railway (variables de entorno DB_* o MYSQL*)
     * o en localhost (valores por defecto).
     *
     * @return objeto Connection
     * @throws Exception si ocurre un error al conectar
     */
    public static Connection getConnection() throws Exception {

        // Cargar el driver JDBC de MySQL
        Class.forName("com.mysql.cj.jdbc.Driver");

        // 1. Probar primero si existen variables personalizadas DB_URL, DB_USER, DB_PASSWORD
        String url  = System.getenv("DB_URL");
        String user = System.getenv("DB_USER");
        String pass = System.getenv("DB_PASSWORD");

        // 2. Si no hay DB_URL, intentar detectar las variables nativas de MySQL en Railway
        if (url == null || url.trim().isEmpty()) {
            String host = System.getenv("MYSQLHOST");
            String port = System.getenv("MYSQLPORT");
            String db   = System.getenv("MYSQLDATABASE");

            if (host != null && !host.trim().isEmpty() && db != null && !db.trim().isEmpty()) {
                url  = "jdbc:mysql://" + host + ":" + (port != null ? port : "3306") + "/" + db + "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
                user = System.getenv("MYSQLUSER") != null ? System.getenv("MYSQLUSER") : USER_LOCAL;
                pass = System.getenv("MYSQLPASSWORD") != null ? System.getenv("MYSQLPASSWORD") : PASSWORD_LOCAL;
            } else {
                // 3. Si no se detectan variables de entorno, usar valores locales de NetBeans
                url  = URL_LOCAL;
                user = USER_LOCAL;
                pass = PASSWORD_LOCAL;
            }
        }

        // Retornar la conexion creada
        return DriverManager.getConnection(url, user, pass);
    }
}
