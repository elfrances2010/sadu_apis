package com.sadu.dao;

import com.sadu.config.Conexion;
import com.sadu.modelo.Mensaje;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO para la gestion de mensajes en el chat empresarial SADU.
 */
public class MensajeDAO {

    public boolean enviarMensaje(Mensaje mensaje) {
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = Conexion.getConnection();

            String sql = "INSERT INTO mensajes_chat (id_usuario, id_receptor, asunto, mensaje, tipo, url_adjunto, editado) "
                       + "VALUES (?, ?, ?, ?, ?, ?, ?)";

            ps = con.prepareStatement(sql);
            ps.setInt(1, mensaje.getIdUsuario());

            if (mensaje.getIdReceptor() != null && mensaje.getIdReceptor() > 0) {
                ps.setInt(2, mensaje.getIdReceptor());
            } else {
                ps.setNull(2, Types.INTEGER);
            }

            ps.setString(3, mensaje.getAsunto() != null ? mensaje.getAsunto() : "Chat");
            ps.setString(4, mensaje.getMensaje() != null ? mensaje.getMensaje() : "");
            ps.setString(5, mensaje.getTipo() != null ? mensaje.getTipo() : "TEXTO");
            ps.setString(6, mensaje.getUrlAdjunto());
            ps.setBoolean(7, mensaje.isEditado());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            cerrar(null, ps, con);
        }
    }

    public List<Mensaje> listarMensajes() {
        return listarMensajes(0, null);
    }

    public List<Mensaje> listarMensajes(int usuarioId, Integer receptorId) {
        List<Mensaje> lista = new ArrayList<>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConnection();

            String sql;
            if (receptorId != null && receptorId > 0) {
                sql = "SELECT m.id_mensaje, m.id_usuario, u.nombre_completo AS remitente_nombre, "
                    + "       m.id_receptor, u2.nombre_completo AS receptor_nombre, "
                    + "       m.asunto, m.mensaje, m.tipo, m.url_adjunto, m.editado, m.estado, m.fecha_envio "
                    + "FROM mensajes_chat m "
                    + "INNER JOIN usuarios u ON m.id_usuario = u.id_usuario "
                    + "LEFT JOIN usuarios u2 ON m.id_receptor = u2.id_usuario "
                    + "WHERE (m.id_usuario = ? AND m.id_receptor = ?) "
                    + "   OR (m.id_usuario = ? AND m.id_receptor = ?) "
                    + "ORDER BY m.fecha_envio DESC LIMIT 50";
            } else {
                sql = "SELECT m.id_mensaje, m.id_usuario, u.nombre_completo AS remitente_nombre, "
                    + "       m.id_receptor, NULL AS receptor_nombre, "
                    + "       m.asunto, m.mensaje, m.tipo, m.url_adjunto, m.editado, m.estado, m.fecha_envio "
                    + "FROM mensajes_chat m "
                    + "INNER JOIN usuarios u ON m.id_usuario = u.id_usuario "
                    + "WHERE m.id_receptor IS NULL "
                    + "ORDER BY m.fecha_envio DESC LIMIT 50";
            }

            ps = con.prepareStatement(sql);
            if (receptorId != null && receptorId > 0) {
                ps.setInt(1, usuarioId);
                ps.setInt(2, receptorId);
                ps.setInt(3, receptorId);
                ps.setInt(4, usuarioId);
            }

            rs = ps.executeQuery();

            while (rs.next()) {
                Mensaje m = new Mensaje();
                m.setIdMensaje(rs.getInt("id_mensaje"));
                m.setIdUsuario(rs.getInt("id_usuario"));
                m.setNombreUsuario(rs.getString("remitente_nombre"));
                
                int rec = rs.getInt("id_receptor");
                if (!rs.wasNull()) {
                    m.setIdReceptor(rec);
                    m.setNombreReceptor(rs.getString("receptor_nombre"));
                }
                
                m.setAsunto(rs.getString("asunto"));
                m.setMensaje(rs.getString("mensaje"));
                
                String t = rs.getString("tipo");
                m.setTipo(t != null ? t : "TEXTO");
                m.setUrlAdjunto(rs.getString("url_adjunto"));
                m.setEditado(rs.getBoolean("editado"));
                m.setEstado(rs.getString("estado"));
                m.setFechaEnvio(rs.getTimestamp("fecha_envio"));
                
                lista.add(m);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            cerrar(rs, ps, con);
        }

        return lista;
    }

    public boolean editarMensaje(int idMensaje, int idUsuario, String nuevoTexto) {
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = Conexion.getConnection();

            String sql = "UPDATE mensajes_chat SET mensaje = ?, editado = 1 WHERE id_mensaje = ? AND id_usuario = ?";
            ps = con.prepareStatement(sql);
            ps.setString(1, nuevoTexto);
            ps.setInt(2, idMensaje);
            ps.setInt(3, idUsuario);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            cerrar(null, ps, con);
        }
    }

    public boolean eliminarMensaje(int idMensaje, int idUsuario, boolean esAdmin) {
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = Conexion.getConnection();

            String sql;
            if (esAdmin) {
                sql = "DELETE FROM mensajes_chat WHERE id_mensaje = ?";
                ps = con.prepareStatement(sql);
                ps.setInt(1, idMensaje);
            } else {
                sql = "DELETE FROM mensajes_chat WHERE id_mensaje = ? AND id_usuario = ?";
                ps = con.prepareStatement(sql);
                ps.setInt(1, idMensaje);
                ps.setInt(2, idUsuario);
            }

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            cerrar(null, ps, con);
        }
    }

    private void cerrar(ResultSet rs, PreparedStatement ps, Connection con) {
        try { if (rs  != null) rs.close();  } catch (Exception e) { }
        try { if (ps  != null) ps.close();  } catch (Exception e) { }
        try { if (con != null) con.close(); } catch (Exception e) { }
    }
}