package com.sadu.dao;

import com.sadu.config.Conexion;
import com.sadu.modelo.LogAuditoria;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 * Clase DAO que maneja todas las operaciones de base de datos
 * relacionadas con la tabla logs_auditoria del sistema SADU.
 *
 * Operaciones disponibles:
 *   registrarLog()        → INSERT automático de un evento
 *   listarLogs()          → SELECT todos los logs con nombre de usuario
 *   buscarLogs()          → SELECT con filtros por acción, usuario y fecha
 *   contarLogs()          → COUNT total de logs registrados
 *
 * IMPORTANTE:
 *   Este DAO es llamado por OTROS servlets automáticamente cada vez
 *   que ocurre un evento importante. El administrador solo consulta
 *   los logs, no los crea manualmente.
 *
 * Eventos que se registran automáticamente:
 *   - LOGIN exitoso
 *   - LOGOUT
 *   - REGISTRO_USUARIO
 *   - REGISTRO_DOCUMENTO
 *   - REGISTRO_COMUNICACION
 *   - ENVIO_MENSAJE
 *   - RECUPERACION_PASSWORD
 */
public class LogAuditoriaDAO {

    /**
     * Registra un nuevo evento en la tabla logs_auditoria.
     * Este método es llamado automáticamente por los demás servlets
     * cuando ocurre una acción importante.
     *
     * Uso desde otro servlet:
     *   LogAuditoriaDAO logDao = new LogAuditoriaDAO();
     *   logDao.registrarLog(idUsuario, "LOGIN", "Usuario inició sesión desde IP 192.168.1.1");
     *
     * @param idUsuario ID del usuario que realizó la acción
     * @param accion    Nombre de la acción (máximo 150 caracteres)
     * @param detalle   Descripción detallada del evento
     * @return true si se registró correctamente, false si ocurrió un error
     */
    public boolean registrarLog(int idUsuario, String accion, String detalle) {
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = Conexion.getConnection();

            // fecha_log se asigna automáticamente por el DEFAULT CURRENT_TIMESTAMP de la BD
            String sql = "INSERT INTO logs_auditoria (id_usuario, accion, detalle) " +
                         "VALUES (?, ?, ?)";

            ps = con.prepareStatement(sql);
            ps.setInt(1,    idUsuario);
            ps.setString(2, accion);
            ps.setString(3, detalle);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            // No lanzar excepción — el log no debe interrumpir el flujo principal
            System.err.println("[LogAuditoriaDAO] Error al registrar log: " + e.getMessage());
            return false;
        } finally {
            cerrarRecursos(null, ps, con);
        }
    }

    /**
     * Lista todos los logs de auditoría ordenados del más reciente al más antiguo.
     * Incluye el nombre completo del usuario mediante JOIN con la tabla usuarios.
     * Limitado a los últimos 500 registros para evitar sobrecargar la interfaz.
     *
     * @return Lista de objetos LogAuditoria con todos sus datos
     */
    public List<LogAuditoria> listarLogs() {
        List<LogAuditoria> lista = new ArrayList<>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConnection();

            String sql = "SELECT l.id_log, l.id_usuario, u.nombre_completo, " +
                         "       l.accion, l.detalle, l.fecha_log " +
                         "FROM logs_auditoria l " +
                         "INNER JOIN usuarios u ON l.id_usuario = u.id_usuario " +
                         "ORDER BY l.fecha_log DESC " +
                         "LIMIT 500";

            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                lista.add(mapearLog(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            cerrarRecursos(rs, ps, con);
        }

        return lista;
    }

    /**
     * Busca logs aplicando filtros combinados.
     * Los campos vacíos o nulos se ignoran en la búsqueda.
     *
     * @param accion      Texto a buscar en el campo acción (búsqueda parcial)
     * @param idUsuario   ID del usuario específico (0 = todos los usuarios)
     * @param fechaDesde  Fecha inicial del rango (formato YYYY-MM-DD, puede ser null)
     * @param fechaHasta  Fecha final del rango (formato YYYY-MM-DD, puede ser null)
     * @return Lista de logs que coinciden con los filtros
     */
    public List<LogAuditoria> buscarLogs(
            String accion,
            int    idUsuario,
            String fechaDesde,
            String fechaHasta) {

        List<LogAuditoria> lista = new ArrayList<>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConnection();

            StringBuilder sql = new StringBuilder(
                "SELECT l.id_log, l.id_usuario, u.nombre_completo, " +
                "       l.accion, l.detalle, l.fecha_log " +
                "FROM logs_auditoria l " +
                "INNER JOIN usuarios u ON l.id_usuario = u.id_usuario " +
                "WHERE 1=1 "
            );

            List<Object> parametros = new ArrayList<>();

            // Filtro por acción — búsqueda parcial
            if (accion != null && !accion.trim().isEmpty()) {
                sql.append("AND l.accion LIKE ? ");
                parametros.add("%" + accion.trim() + "%");
            }

            // Filtro por usuario específico
            if (idUsuario > 0) {
                sql.append("AND l.id_usuario = ? ");
                parametros.add(idUsuario);
            }

            // Filtro por fecha desde
            if (fechaDesde != null && !fechaDesde.trim().isEmpty()) {
                sql.append("AND DATE(l.fecha_log) >= ? ");
                parametros.add(fechaDesde.trim());
            }

            // Filtro por fecha hasta
            if (fechaHasta != null && !fechaHasta.trim().isEmpty()) {
                sql.append("AND DATE(l.fecha_log) <= ? ");
                parametros.add(fechaHasta.trim());
            }

            sql.append("ORDER BY l.fecha_log DESC LIMIT 500");

            ps = con.prepareStatement(sql.toString());

            for (int i = 0; i < parametros.size(); i++) {
                ps.setObject(i + 1, parametros.get(i));
            }

            rs = ps.executeQuery();

            while (rs.next()) {
                lista.add(mapearLog(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            cerrarRecursos(rs, ps, con);
        }

        return lista;
    }

    /**
     * Cuenta el total de logs registrados en la base de datos.
     * Útil para mostrar estadísticas en el panel de auditoría.
     *
     * @return Total de logs registrados
     */
    public int contarLogs() {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConnection();
            ps  = con.prepareStatement("SELECT COUNT(*) FROM logs_auditoria");
            rs  = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            cerrarRecursos(rs, ps, con);
        }

        return 0;
    }

    /**
     * Cuenta los logs del día actual.
     * Útil para el panel de estadísticas.
     *
     * @return Total de logs registrados hoy
     */
    public int contarLogsHoy() {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConnection();
            ps  = con.prepareStatement(
                    "SELECT COUNT(*) FROM logs_auditoria WHERE DATE(fecha_log) = CURDATE()");
            rs  = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            cerrarRecursos(rs, ps, con);
        }

        return 0;
    }

    /**
     * Cuenta los usuarios distintos que han tenido actividad registrada.
     *
     * @return Total de usuarios con actividad en logs
     */
    public int contarUsuariosActivos() {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConnection();
            ps  = con.prepareStatement(
                    "SELECT COUNT(DISTINCT id_usuario) FROM logs_auditoria");
            rs  = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            cerrarRecursos(rs, ps, con);
        }

        return 0;
    }

    /**
     * Mapea una fila del ResultSet a un objeto LogAuditoria.
     *
     * @param rs ResultSet posicionado en la fila actual
     * @return Objeto LogAuditoria con los datos de la fila
     */
    private LogAuditoria mapearLog(ResultSet rs) throws Exception {
        LogAuditoria log = new LogAuditoria();
        log.setIdLog(rs.getInt("id_log"));
        log.setIdUsuario(rs.getInt("id_usuario"));
        log.setNombreUsuario(rs.getString("nombre_completo"));
        log.setAccion(rs.getString("accion"));
        log.setDetalle(rs.getString("detalle"));
        log.setFechaLog(rs.getTimestamp("fecha_log"));
        return log;
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
