package com.sadu.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

/**
 * Clase encargada de establecer la conexion con la base de datos SADU.
 * Implementa alta disponibilidad, redundancia por conmutacion (failover multi-host)
 * y verificacion de salud de conexion (Health Check).
 */
public class Conexion {

    // Valores por defecto para desarrollo LOCAL (localhost)
    private static final String URL_LOCAL = "jdbc:mysql://localhost:3306/sadu_apis?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    private static final String USER_LOCAL = "root";
    private static final String PASSWORD_LOCAL = "";

    /**
     * Metodo que retorna una conexion activa a la base de datos.
     * Soporta configuracion de alta disponibilidad y conmutacion automatica (Failover)
     * si se detectan variables de entorno para nodo secundario/replica.
     *
     * @return objeto Connection
     * @throws Exception si ocurre un error al conectar
     */
    public static Connection getConnection() throws Exception {
        // Cargar el driver JDBC de MySQL
        Class.forName("com.mysql.cj.jdbc.Driver");

        // 1. Probar si existe variable personalizada explicita DB_URL
        String url  = System.getenv("DB_URL");
        String user = System.getenv("DB_USER");
        String pass = System.getenv("DB_PASSWORD");

        if (url != null && !url.trim().isEmpty()) {
            return DriverManager.getConnection(url, user, pass);
        }

        // 2. Intentar detectar variables nativas de MySQL (Railway u otros proveedores cloud)
        String hostPrimario = System.getenv("MYSQLHOST");
        String portPrimario = System.getenv("MYSQLPORT");
        String dbName       = System.getenv("MYSQLDATABASE");

        // Soporte de redundancia: nodo secundario/replica
        String hostSecundario = System.getenv("MYSQLHOST_REPLICA");
        String portSecundario = System.getenv("MYSQLPORT_REPLICA");

        if (hostPrimario != null && !hostPrimario.trim().isEmpty() && dbName != null && !dbName.trim().isEmpty()) {
            user = System.getenv("MYSQLUSER") != null ? System.getenv("MYSQLUSER") : USER_LOCAL;
            pass = System.getenv("MYSQLPASSWORD") != null ? System.getenv("MYSQLPASSWORD") : PASSWORD_LOCAL;

            if (hostSecundario != null && !hostSecundario.trim().isEmpty()) {
                // Modo Redundante / Failover Activo-Pasivo
                String pSec = (portSecundario != null && !portSecundario.trim().isEmpty()) ? portSecundario : "3306";
                String pPri = (portPrimario != null && !portPrimario.trim().isEmpty()) ? portPrimario : "3306";

                url = "jdbc:mysql://" + hostPrimario + ":" + pPri + "," + hostSecundario + ":" + pSec + "/" + dbName
                    + "?autoReconnect=true&failOverReadOnly=false&secondsBeforeRetryMaster=60"
                    + "&connectTimeout=3000&socketTimeout=10000&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
            } else {
                // Modo Primario Unico Cloud
                String pPri = (portPrimario != null && !portPrimario.trim().isEmpty()) ? portPrimario : "3306";
                url = "jdbc:mysql://" + hostPrimario + ":" + pPri + "/" + dbName
                    + "?autoReconnect=true&connectTimeout=5000&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
            }

            try {
                return DriverManager.getConnection(url, user, pass);
            } catch (Exception exCloud) {
                // En caso de fallo critico en cloud, registrar y reintentar modo local si existe
                System.err.println("[SADU-FAILOVER] Falla al conectar con persistencia primaria: " + exCloud.getMessage());
            }
        }

        // 3. Fallback a entorno de desarrollo local
        try {
            return DriverManager.getConnection(URL_LOCAL, USER_LOCAL, PASSWORD_LOCAL);
        } catch (Exception exLocal) {
            throw new Exception("Error al conectar con la base de datos (Primaria y Fallback no disponibles): " + exLocal.getMessage(), exLocal);
        }
    }

    /**
     * Comprueba de manera autonoma si la persistencia de datos esta disponible.
     *
     * @return true si la conexion y consulta simple (SELECT 1) responden con exito.
     */
    public static boolean isHealthy() {
        try (Connection con = getConnection();
             Statement stmt = con.createStatement()) {
            stmt.setQueryTimeout(3);
            return stmt.execute("SELECT 1");
        } catch (Exception e) {
            return false;
        }
    }
}
