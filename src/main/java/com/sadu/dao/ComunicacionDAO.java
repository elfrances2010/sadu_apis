package com.sadu.dao;

import com.sadu.config.Conexion;
import com.sadu.modelo.Comunicacion;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 * Clase DAO que maneja todas las operaciones de base de datos
 * relacionadas con la tabla comunicaciones del sistema SADU.
 *
 * Operaciones disponibles:
 *   registrarComunicacion()  → INSERT de una nueva comunicación
 *   listarComunicaciones()   → SELECT todas las comunicaciones con nombre de usuario
 *   buscarComunicaciones()   → SELECT con filtros por tipo, dependencia y estado
 *   existeRadicado()         → Verifica si un radicado ya está registrado
 *   generarRadicado()        → Genera un radicado único automático (RAD-AÑO-SECUENCIA)
 *   cambiarEstado()          → UPDATE del estado de una comunicación
 */
public class ComunicacionDAO {

    /**
     * Registra una nueva comunicación en la base de datos.
     *
     * @param com Objeto Comunicacion con todos los datos a insertar
     * @return true si se insertó correctamente, false si ocurrió un error
     */
    public boolean registrarComunicacion(Comunicacion com) {
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = Conexion.getConnection();

            String sql = "INSERT INTO comunicaciones " +
                         "(radicado, tipo, dependencia, asunto, " +
                         " fecha_comunicacion, estado, id_usuario) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?)";

            ps = con.prepareStatement(sql);
            ps.setString(1, com.getRadicado());
            ps.setString(2, com.getTipo());
            ps.setString(3, com.getDependencia());
            ps.setString(4, com.getAsunto());
            ps.setDate(5,   com.getFechaComunicacion());
            ps.setString(6, com.getEstado());
            ps.setInt(7,    com.getIdUsuario());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            cerrarRecursos(null, ps, con);
        }
    }

    /**
     * Lista todas las comunicaciones registradas en el sistema,
     * incluyendo el nombre completo del usuario (JOIN).
     * Ordenadas de la más reciente a la más antigua.
     *
     * @return Lista de objetos Comunicacion con todos sus datos
     */
    public List<Comunicacion> listarComunicaciones() {
        List<Comunicacion> lista = new ArrayList<>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConnection();

            String sql = "SELECT c.id_comunicacion, c.radicado, c.tipo, c.dependencia, " +
                         "       c.asunto, c.fecha_comunicacion, c.estado, " +
                         "       c.id_usuario, u.nombre_completo, c.fecha_registro " +
                         "FROM comunicaciones c " +
                         "INNER JOIN usuarios u ON c.id_usuario = u.id_usuario " +
                         "ORDER BY c.fecha_registro DESC";

            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                lista.add(mapearComunicacion(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            cerrarRecursos(rs, ps, con);
        }

        return lista;
    }

    /**
     * Busca comunicaciones aplicando filtros combinados.
     * Los campos vacíos o nulos se ignoran en la búsqueda.
     *
     * @param tipo        Tipo de comunicación INTERNA/EXTERNA (puede ser vacío)
     * @param dependencia Dependencia exacta (puede ser vacía)
     * @param estado      Estado de la comunicación (puede ser vacío)
     * @param asunto      Texto a buscar en el asunto (búsqueda parcial)
     * @return Lista de comunicaciones que coinciden con los filtros
     */
    public List<Comunicacion> buscarComunicaciones(
            String tipo,
            String dependencia,
            String estado,
            String asunto) {

        List<Comunicacion> lista = new ArrayList<>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConnection();

            StringBuilder sql = new StringBuilder(
                "SELECT c.id_comunicacion, c.radicado, c.tipo, c.dependencia, " +
                "       c.asunto, c.fecha_comunicacion, c.estado, " +
                "       c.id_usuario, u.nombre_completo, c.fecha_registro " +
                "FROM comunicaciones c " +
                "INNER JOIN usuarios u ON c.id_usuario = u.id_usuario " +
                "WHERE 1=1 "
            );

            List<Object> parametros = new ArrayList<>();

            if (asunto != null && !asunto.trim().isEmpty()) {
                sql.append("AND c.asunto LIKE ? ");
                parametros.add("%" + asunto.trim() + "%");
            }

            if (tipo != null && !tipo.trim().isEmpty()) {
                sql.append("AND c.tipo = ? ");
                parametros.add(tipo.trim());
            }

            if (dependencia != null && !dependencia.trim().isEmpty()) {
                sql.append("AND c.dependencia = ? ");
                parametros.add(dependencia.trim());
            }

            if (estado != null && !estado.trim().isEmpty()) {
                sql.append("AND c.estado = ? ");
                parametros.add(estado.trim());
            }

            sql.append("ORDER BY c.fecha_registro DESC");

            ps = con.prepareStatement(sql.toString());

            for (int i = 0; i < parametros.size(); i++) {
                ps.setObject(i + 1, parametros.get(i));
            }

            rs = ps.executeQuery();

            while (rs.next()) {
                lista.add(mapearComunicacion(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            cerrarRecursos(rs, ps, con);
        }

        return lista;
    }

    /**
     * Verifica si un número de radicado ya existe en la base de datos.
     * Se usa antes de registrar para evitar duplicados.
     *
     * @param radicado Radicado a verificar
     * @return true si ya existe, false si está disponible
     */
    public boolean existeRadicado(String radicado) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConnection();
            String sql = "SELECT COUNT(*) FROM comunicaciones WHERE radicado = ?";
            ps = con.prepareStatement(sql);
            ps.setString(1, radicado);
            rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            cerrarRecursos(rs, ps, con);
        }

        return false;
    }

    /**
     * Genera automáticamente un número de radicado único con el formato:
     * RAD-AÑO-SECUENCIA. Ejemplo: RAD-2026-001, RAD-2026-002
     *
     * @return Radicado único generado
     */
    public String generarRadicado() {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConnection();

            int anio = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);

            String sql = "SELECT COUNT(*) FROM comunicaciones " +
                         "WHERE YEAR(fecha_registro) = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, anio);
            rs = ps.executeQuery();

            int secuencia = 1;
            if (rs.next()) {
                secuencia = rs.getInt(1) + 1;
            }

            return String.format("RAD-%d-%03d", anio, secuencia);

        } catch (Exception e) {
            e.printStackTrace();
            return "RAD-" + System.currentTimeMillis();
        } finally {
            cerrarRecursos(rs, ps, con);
        }
    }

    /**
     * Cambia el estado de una comunicación existente.
     *
     * @param idComunicacion ID de la comunicación a actualizar
     * @param nuevoEstado    Nuevo estado: RECIBIDA, EN_TRAMITE o RESPONDIDA
     * @return true si se actualizó correctamente
     */
    public boolean cambiarEstado(int idComunicacion, String nuevoEstado) {
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = Conexion.getConnection();
            String sql = "UPDATE comunicaciones SET estado = ? WHERE id_comunicacion = ?";
            ps = con.prepareStatement(sql);
            ps.setString(1, nuevoEstado);
            ps.setInt(2, idComunicacion);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            cerrarRecursos(null, ps, con);
        }
    }

    /**
     * Mapea una fila del ResultSet a un objeto Comunicacion.
     * Centraliza la lógica de mapeo para no repetirla en cada método.
     */
    private Comunicacion mapearComunicacion(ResultSet rs) throws Exception {
        Comunicacion com = new Comunicacion();
        com.setIdComunicacion(rs.getInt("id_comunicacion"));
        com.setRadicado(rs.getString("radicado"));
        com.setTipo(rs.getString("tipo"));
        com.setDependencia(rs.getString("dependencia"));
        com.setAsunto(rs.getString("asunto"));
        com.setFechaComunicacion(rs.getDate("fecha_comunicacion"));
        com.setEstado(rs.getString("estado"));
        com.setIdUsuario(rs.getInt("id_usuario"));
        com.setNombreUsuario(rs.getString("nombre_completo"));
        com.setFechaRegistro(rs.getTimestamp("fecha_registro"));
        return com;
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
