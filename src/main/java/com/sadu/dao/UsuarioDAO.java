package com.sadu.dao;

import com.sadu.config.Conexion;
import com.sadu.modelo.Usuario;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class UsuarioDAO {

    public boolean registrarUsuario(Usuario usuario) {
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = Conexion.getConnection();
            String sql = "INSERT INTO usuarios " +
                         "(nombre_completo, correo, username, password, estado, id_rol, requiere_cambio_clave) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?)";

            ps = con.prepareStatement(sql);
            ps.setString(1, usuario.getNombreCompleto());
            ps.setString(2, usuario.getCorreo());
            ps.setString(3, usuario.getUsername());
            ps.setString(4, usuario.getPassword());
            ps.setString(5, usuario.getEstado());
            ps.setInt(6,    usuario.getRolId());
            ps.setBoolean(7, usuario.isRequiereCambioClave());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            cerrarRecursos(null, ps, con);
        }
    }

    public List<Usuario> listarUsuarios() {
        List<Usuario> lista = new ArrayList<>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConnection();
            String sql = "SELECT u.id_usuario, u.nombre_completo, u.correo, u.username, " +
                         "       u.password, u.estado, u.id_rol, u.requiere_cambio_clave, " +
                         "       r.nombre AS nombre_rol, u.fecha_creacion " +
                         "FROM usuarios u " +
                         "INNER JOIN roles r ON u.id_rol = r.id_rol " +
                         "ORDER BY u.fecha_creacion DESC";

            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                lista.add(mapearUsuario(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            cerrarRecursos(rs, ps, con);
        }

        return lista;
    }

    public List<Usuario> buscarUsuarios(String nombre, int idRol, String estado) {
        List<Usuario> lista = new ArrayList<>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConnection();

            StringBuilder sql = new StringBuilder(
                "SELECT u.id_usuario, u.nombre_completo, u.correo, u.username, " +
                "       u.password, u.estado, u.id_rol, u.requiere_cambio_clave, " +
                "       r.nombre AS nombre_rol, u.fecha_creacion " +
                "FROM usuarios u " +
                "INNER JOIN roles r ON u.id_rol = r.id_rol " +
                "WHERE 1=1 "
            );

            List<Object> parametros = new ArrayList<>();

            if (nombre != null && !nombre.trim().isEmpty()) {
                sql.append("AND (u.nombre_completo LIKE ? OR u.correo LIKE ? OR u.username LIKE ?) ");
                parametros.add("%" + nombre.trim() + "%");
                parametros.add("%" + nombre.trim() + "%");
                parametros.add("%" + nombre.trim() + "%");
            }

            if (idRol > 0) {
                sql.append("AND u.id_rol = ? ");
                parametros.add(idRol);
            }

            if (estado != null && !estado.trim().isEmpty()) {
                sql.append("AND u.estado = ? ");
                parametros.add(estado.trim());
            }

            sql.append("ORDER BY u.fecha_creacion DESC");

            ps = con.prepareStatement(sql.toString());

            for (int i = 0; i < parametros.size(); i++) {
                ps.setObject(i + 1, parametros.get(i));
            }

            rs = ps.executeQuery();

            while (rs.next()) {
                lista.add(mapearUsuario(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            cerrarRecursos(rs, ps, con);
        }

        return lista;
    }

    public Usuario obtenerPorId(int idUsuario) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConnection();
            String sql = "SELECT u.id_usuario, u.nombre_completo, u.correo, u.username, " +
                         "       u.password, u.estado, u.id_rol, u.requiere_cambio_clave, " +
                         "       r.nombre AS nombre_rol, u.fecha_creacion " +
                         "FROM usuarios u " +
                         "INNER JOIN roles r ON u.id_rol = r.id_rol " +
                         "WHERE u.id_usuario = ?";

            ps = con.prepareStatement(sql);
            ps.setInt(1, idUsuario);
            rs = ps.executeQuery();

            if (rs.next()) {
                return mapearUsuario(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            cerrarRecursos(rs, ps, con);
        }

        return null;
    }

    public boolean editarUsuario(Usuario usuario) {
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = Conexion.getConnection();

            String sql = "UPDATE usuarios SET " +
                         "nombre_completo = ?, correo = ?, username = ?, id_rol = ? " +
                         "WHERE id_usuario = ?";

            ps = con.prepareStatement(sql);
            ps.setString(1, usuario.getNombreCompleto());
            ps.setString(2, usuario.getCorreo());
            ps.setString(3, usuario.getUsername());
            ps.setInt(4,    usuario.getRolId());
            ps.setInt(5,    usuario.getIdUsuario());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            cerrarRecursos(null, ps, con);
        }
    }

    public boolean cambiarEstado(int idUsuario, String nuevoEstado) {
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = Conexion.getConnection();
            String sql = "UPDATE usuarios SET estado = ? WHERE id_usuario = ?";
            ps = con.prepareStatement(sql);
            ps.setString(1, nuevoEstado);
            ps.setInt(2,    idUsuario);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            cerrarRecursos(null, ps, con);
        }
    }

    public boolean cambiarRol(int idUsuario, int nuevoRol) {
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = Conexion.getConnection();
            String sql = "UPDATE usuarios SET id_rol = ? WHERE id_usuario = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, nuevoRol);
            ps.setInt(2, idUsuario);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            cerrarRecursos(null, ps, con);
        }
    }

    public boolean forzarCambioClave(int idUsuario, boolean requiere) {
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = Conexion.getConnection();
            String sql = "UPDATE usuarios SET requiere_cambio_clave = ? WHERE id_usuario = ?";
            ps = con.prepareStatement(sql);
            ps.setBoolean(1, requiere);
            ps.setInt(2, idUsuario);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            cerrarRecursos(null, ps, con);
        }
    }

    public boolean cambiarPassword(int idUsuario, String nuevaPassword) {
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = Conexion.getConnection();
            String sql = "UPDATE usuarios SET password = ?, requiere_cambio_clave = 0 WHERE id_usuario = ?";
            ps = con.prepareStatement(sql);
            ps.setString(1, nuevaPassword);
            ps.setInt(2, idUsuario);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            cerrarRecursos(null, ps, con);
        }
    }

    public boolean existeCorreo(String correo, int idExcluir) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConnection();
            String sql = "SELECT COUNT(*) FROM usuarios WHERE correo = ? AND id_usuario != ?";
            ps = con.prepareStatement(sql);
            ps.setString(1, correo);
            ps.setInt(2, idExcluir);
            rs = ps.executeQuery();

            if (rs.next()) return rs.getInt(1) > 0;

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            cerrarRecursos(rs, ps, con);
        }

        return false;
    }

    public boolean existeUsername(String username, int idExcluir) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConnection();
            String sql = "SELECT COUNT(*) FROM usuarios WHERE username = ? AND id_usuario != ?";
            ps = con.prepareStatement(sql);
            ps.setString(1, username);
            ps.setInt(2, idExcluir);
            rs = ps.executeQuery();

            if (rs.next()) return rs.getInt(1) > 0;

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            cerrarRecursos(rs, ps, con);
        }

        return false;
    }

    private Usuario mapearUsuario(ResultSet rs) throws Exception {
        Usuario u = new Usuario();
        u.setIdUsuario(rs.getInt("id_usuario"));
        u.setNombreCompleto(rs.getString("nombre_completo"));
        u.setCorreo(rs.getString("correo"));
        u.setUsername(rs.getString("username"));
        u.setPassword(rs.getString("password"));
        u.setEstado(rs.getString("estado"));
        u.setRolId(rs.getInt("id_rol"));
        try {
            u.setRequiereCambioClave(rs.getBoolean("requiere_cambio_clave"));
        } catch (Exception e) {
            u.setRequiereCambioClave(false);
        }
        u.setNombreRol(rs.getString("nombre_rol"));
        u.setFechaCreacion(rs.getTimestamp("fecha_creacion"));
        return u;
    }

    private void cerrarRecursos(ResultSet rs, PreparedStatement ps, Connection con) {
        try { if (rs  != null) rs.close();  } catch (Exception e) { e.printStackTrace(); }
        try { if (ps  != null) ps.close();  } catch (Exception e) { e.printStackTrace(); }
        try { if (con != null) con.close(); } catch (Exception e) { e.printStackTrace(); }
    }
}
