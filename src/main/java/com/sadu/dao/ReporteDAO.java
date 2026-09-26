package com.sadu.dao;

import com.sadu.config.Conexion;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Clase DAO que ejecuta consultas de agregación (COUNT, GROUP BY)
 * para alimentar los gráficos del módulo de Reportes SADU.
 *
 * Cada método retorna un Map<String, Integer> donde:
 *   - la clave es la categoría (ej: "REGISTRADO", "Oficio", "Alcaldía")
 *   - el valor es el conteo de registros en esa categoría
 *
 * Se usa LinkedHashMap para conservar el orden de inserción,
 * lo cual es importante para que los gráficos se vean consistentes.
 */
public class ReporteDAO {

    /**
     * Cuenta documentos agrupados por estado (REGISTRADO, EN_PROCESO, ARCHIVADO).
     *
     * @return Mapa con estado → cantidad de documentos
     */
    public Map<String, Integer> documentosPorEstado() {
        return ejecutarConteo(
            "SELECT estado AS categoria, COUNT(*) AS total " +
            "FROM documentos GROUP BY estado ORDER BY total DESC"
        );
    }

    /**
     * Cuenta documentos agrupados por tipo (Oficio, Resolución, Acta, etc.).
     * Limita a los 8 tipos más frecuentes para no saturar el gráfico.
     *
     * @return Mapa con tipo de documento → cantidad
     */
    public Map<String, Integer> documentosPorTipo() {
        return ejecutarConteo(
            "SELECT tipo_documento AS categoria, COUNT(*) AS total " +
            "FROM documentos GROUP BY tipo_documento " +
            "ORDER BY total DESC LIMIT 8"
        );
    }

    /**
     * Cuenta documentos agrupados por dependencia.
     * Limita a las 8 dependencias con más documentos.
     *
     * @return Mapa con dependencia → cantidad de documentos
     */
    public Map<String, Integer> documentosPorDependencia() {
        return ejecutarConteo(
            "SELECT dependencia AS categoria, COUNT(*) AS total " +
            "FROM documentos GROUP BY dependencia " +
            "ORDER BY total DESC LIMIT 8"
        );
    }

    /**
     * Cuenta comunicaciones agrupadas por estado
     * (RECIBIDA, EN_TRAMITE, RESPONDIDA).
     *
     * @return Mapa con estado → cantidad de comunicaciones
     */
    public Map<String, Integer> comunicacionesPorEstado() {
        return ejecutarConteo(
            "SELECT estado AS categoria, COUNT(*) AS total " +
            "FROM comunicaciones GROUP BY estado ORDER BY total DESC"
        );
    }

    /**
     * Cuenta comunicaciones agrupadas por tipo (INTERNA / EXTERNA).
     *
     * @return Mapa con tipo → cantidad de comunicaciones
     */
    public Map<String, Integer> comunicacionesPorTipo() {
        return ejecutarConteo(
            "SELECT tipo AS categoria, COUNT(*) AS total " +
            "FROM comunicaciones GROUP BY tipo ORDER BY total DESC"
        );
    }

    /**
     * Cuenta usuarios agrupados por rol.
     * Hace JOIN con la tabla roles para mostrar el nombre del rol
     * en lugar del ID numérico.
     *
     * @return Mapa con nombre de rol → cantidad de usuarios
     */
    public Map<String, Integer> usuariosPorRol() {
        return ejecutarConteo(
            "SELECT r.nombre AS categoria, COUNT(*) AS total " +
            "FROM usuarios u " +
            "INNER JOIN roles r ON u.id_rol = r.id_rol " +
            "GROUP BY r.nombre ORDER BY total DESC"
        );
    }

    /**
     * Cuenta usuarios agrupados por estado (ACTIVO / INACTIVO).
     *
     * @return Mapa con estado → cantidad de usuarios
     */
    public Map<String, Integer> usuariosPorEstado() {
        return ejecutarConteo(
            "SELECT estado AS categoria, COUNT(*) AS total " +
            "FROM usuarios GROUP BY estado ORDER BY total DESC"
        );
    }

    /**
     * Cuenta eventos de auditoría agrupados por tipo de acción
     * (LOGIN, REGISTRO_DOCUMENTO, ENVIO_MENSAJE, etc.).
     * Limita a las 8 acciones más frecuentes.
     *
     * @return Mapa con acción → cantidad de eventos
     */
    public Map<String, Integer> auditoriaPorAccion() {
        return ejecutarConteo(
            "SELECT accion AS categoria, COUNT(*) AS total " +
            "FROM logs_auditoria GROUP BY accion " +
            "ORDER BY total DESC LIMIT 8"
        );
    }

    /**
     * Cuenta documentos registrados por mes durante el año actual.
     * Útil para gráficos de tendencia/línea de tiempo.
     * Devuelve los 12 meses del año, incluso si algunos tienen 0 documentos.
     *
     * @return Mapa con nombre de mes → cantidad de documentos
     */
    public Map<String, Integer> documentosPorMes() {
        Map<String, Integer> resultado = new LinkedHashMap<>();

        // Nombres de los 12 meses en español (abreviados)
        String[] nombresMeses = {
            "Ene", "Feb", "Mar", "Abr", "May", "Jun",
            "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"
        };

        // Inicializar todos los meses en 0
        for (String mes : nombresMeses) {
            resultado.put(mes, 0);
        }

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConnection();

            String sql = "SELECT MONTH(fecha_registro) AS mes, COUNT(*) AS total " +
                         "FROM documentos " +
                         "WHERE YEAR(fecha_registro) = YEAR(CURDATE()) " +
                         "GROUP BY MONTH(fecha_registro)";

            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                int mesNumero = rs.getInt("mes");      // 1 = Enero, 12 = Diciembre
                int total     = rs.getInt("total");

                // Reemplazar el valor 0 inicial con el conteo real
                // mesNumero - 1 porque el arreglo de nombres empieza en índice 0
                if (mesNumero >= 1 && mesNumero <= 12) {
                    resultado.put(nombresMeses[mesNumero - 1], total);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            cerrarRecursos(rs, ps, con);
        }

        return resultado;
    }

    /**
     * Obtiene estadísticas generales del sistema para las tarjetas resumen.
     * Retorna un mapa con las claves: totalDocumentos, totalComunicaciones,
     * totalUsuarios, totalMensajes.
     *
     * @return Mapa con nombre de métrica → valor numérico
     */
    public Map<String, Integer> estadisticasGenerales() {
        Map<String, Integer> stats = new LinkedHashMap<>();

        stats.put("totalDocumentos",     contarFilas("documentos"));
        stats.put("totalComunicaciones", contarFilas("comunicaciones"));
        stats.put("totalUsuarios",       contarFilas("usuarios"));
        stats.put("totalMensajes",       contarFilas("mensajes_chat"));

        return stats;
    }

    // ════════════════════════════════════════════════════════════
    // MÉTODOS PRIVADOS DE APOYO
    // ════════════════════════════════════════════════════════════

    /**
     * Ejecuta una consulta SQL de tipo "SELECT categoria, COUNT(*) AS total
     * FROM ... GROUP BY categoria" y la convierte en un Map ordenado.
     *
     * @param sql Consulta SQL que debe retornar columnas "categoria" y "total"
     * @return Mapa con categoria → total, en el orden devuelto por la consulta
     */
    private Map<String, Integer> ejecutarConteo(String sql) {
        Map<String, Integer> resultado = new LinkedHashMap<>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConnection();
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                String categoria = rs.getString("categoria");
                int total = rs.getInt("total");

                // Si la categoría viene nula o vacía, mostrarla como "Sin dato"
                if (categoria == null || categoria.trim().isEmpty()) {
                    categoria = "Sin dato";
                }

                resultado.put(categoria, total);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            cerrarRecursos(rs, ps, con);
        }

        return resultado;
    }

    /**
     * Cuenta el total de filas de una tabla.
     * El nombre de la tabla viene de constantes internas del DAO,
     * nunca de input del usuario, por lo que es seguro concatenarlo.
     *
     * @param nombreTabla Nombre de la tabla a contar
     * @return Total de filas en la tabla, o 0 si ocurre un error
     */
    private int contarFilas(String nombreTabla) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConnection();
            ps = con.prepareStatement("SELECT COUNT(*) FROM " + nombreTabla);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            cerrarRecursos(rs, ps, con);
        }

        return 0;
    }

    /**
     * Cierra los recursos de base de datos de forma segura.
     */
    private void cerrarRecursos(ResultSet rs, PreparedStatement ps, Connection con) {
        try { if (rs  != null) rs.close();  } catch (Exception e) { e.printStackTrace(); }
        try { if (ps  != null) ps.close();  } catch (Exception e) { e.printStackTrace(); }
        try { if (con != null) con.close(); } catch (Exception e) { e.printStackTrace(); }
    }
}