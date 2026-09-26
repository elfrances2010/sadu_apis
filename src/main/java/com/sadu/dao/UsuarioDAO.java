package com.sadu.dao;

import com.sadu.config.Conexion;
import com.sadu.modelo.Usuario;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 * ════════════════════════════════════════════════════════════════
 * UsuarioDAO — Capa de acceso a datos para la tabla usuarios
 * ════════════════════════════════════════════════════════════════
 *
 * Maneja todas las operaciones sobre la tabla usuarios del sistema SADU.
 *
 * Operaciones disponibles:
 *   registrarUsuario()    → INSERT de un nuevo usuario
 *   listarUsuarios()      → SELECT todos los usuarios con nombre de rol (JOIN)
 *   buscarUsuarios()      → SELECT con filtros por nombre, rol y estado
 *   obtenerPorId()        → SELECT un usuario específico por su ID
 *   editarUsuario()       → UPDATE nombre, correo, username y rol
 *   cambiarEstado()       → UPDATE estado ACTIVO ↔ INACTIVO
 *   cambiarRol()          → UPDATE id_rol de un usuario
 *   existeCorreo()        → Verifica si un correo ya está registrado
 *   existeUsername()      → Verifica si un username ya está registrado
 */
public class UsuarioDAO {

    // ════════════════════════════════════════════════════════════
    // REGISTRAR NUEVO USUARIO
    // ════════════════════════════════════════════════════════════

    /**
     * Inserta un nuevo usuario en la base de datos.
     *
     * @param usuario Objeto Usuario con todos los datos a guardar
     * @return true si se insertó correctamente, false si hubo error
     */
    public boolean registrarUsuario(Usuario usuario) {
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = Conexion.getConnection();

            String sql = "INSERT INTO usuarios " +
                         "(nombre_completo, correo, username, password, estado, id_rol) " +
                         "VALUES (?, ?, ?, ?, ?, ?)";

            ps = con.prepareStatement(sql);
            ps.setString(1, usuario.getNombreCompleto());
            ps.setString(2, usuario.getCorreo());
            ps.setString(3, usuario.getUsername());
            ps.setString(4, usuario.getPassword());
            ps.setString(5, usuario.getEstado());
            ps.setInt(6,    usuario.getRolId());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            cerrarRecursos(null, ps, con);
        }
    }

    // ════════════════════════════════════════════════════════════
    // LISTAR TODOS LOS USUARIOS
    // ════════════════════════════════════════════════════════════

    /**
     * Lista todos los usuarios del sistema con el nombre de su rol.
     * Usa JOIN con la tabla roles para obtener el nombre del rol.
     * Ordenados por fecha de creación descendente (más recientes primero).
     *
     * @return Lista de objetos Usuario con todos sus datos
     */
    public List<Usuario> listarUsuarios() {
        List<Usuario> lista = new ArrayList<>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConnection();

            // JOIN con roles para obtener el nombre del rol (ADMINISTRADOR, GESTOR_ARCHIVO, DEPENDENCIA)
            String sql = "SELECT u.id_usuario, u.nombre_completo, u.correo, u.username, " +
                         "       u.password, u.estado, u.id_rol, r.nombre AS nombre_rol, " +
                         "       u.fecha_creacion " +
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

    // ════════════════════════════════════════════════════════════
    // BUSCAR USUARIOS CON FILTROS
    // ════════════════════════════════════════════════════════════

    /**
     * Busca usuarios aplicando filtros combinados.
     * Los parámetros vacíos o con valor 0 se ignoran en la búsqueda.
     *
     * @param nombre  Texto a buscar en nombre_completo o correo (búsqueda parcial)
     * @param idRol   ID del rol a filtrar (0 = todos los roles)
     * @param estado  Estado ACTIVO o INACTIVO (vacío = todos)
     * @return Lista de usuarios que coinciden con los filtros
     */
    public List<Usuario> buscarUsuarios(String nombre, int idRol, String estado) {
        List<Usuario> lista = new ArrayList<>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConnection();

            // Construcción dinámica del SQL
            StringBuilder sql = new StringBuilder(
                "SELECT u.id_usuario, u.nombre_completo, u.correo, u.username, " +
                "       u.password, u.estado, u.id_rol, r.nombre AS nombre_rol, " +
                "       u.fecha_creacion " +
                "FROM usuarios u " +
                "INNER JOIN roles r ON u.id_rol = r.id_rol " +
                "WHERE 1=1 "
            );

            List<Object> parametros = new ArrayList<>();

            // Filtro por nombre o correo — búsqueda parcial con LIKE
            if (nombre != null && !nombre.trim().isEmpty()) {
                sql.append("AND (u.nombre_completo LIKE ? OR u.correo LIKE ? OR u.username LIKE ?) ");
                parametros.add("%" + nombre.trim() + "%");
                parametros.add("%" + nombre.trim() + "%");
                parametros.add("%" + nombre.trim() + "%");
            }

            // Filtro por rol específico
            if (idRol > 0) {
                sql.append("AND u.id_rol = ? ");
                parametros.add(idRol);
            }

            // Filtro por estado ACTIVO o INACTIVO
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

    // ════════════════════════════════════════════════════════════
    // OBTENER UN USUARIO POR ID
    // ════════════════════════════════════════════════════════════

    /**
     * Obtiene un usuario específico buscando por su ID.
     * Se usa para precargar el formulario de edición.
     *
     * @param idUsuario ID del usuario a obtener
     * @return Objeto Usuario con sus datos, o null si no se encontró
     */
    public Usuario obtenerPorId(int idUsuario) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConnection();

            String sql = "SELECT u.id_usuario, u.nombre_completo, u.correo, u.username, " +
                         "       u.password, u.estado, u.id_rol, r.nombre AS nombre_rol, " +
                         "       u.fecha_creacion " +
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

        return null; // Usuario no encontrado
    }

    // ════════════════════════════════════════════════════════════
    // EDITAR USUARIO
    // ════════════════════════════════════════════════════════════

    /**
     * Actualiza los datos de un usuario existente.
     * No actualiza la contraseña (se hace por separado) ni el estado.
     *
     * @param usuario Objeto Usuario con los nuevos datos (debe tener idUsuario)
     * @return true si se actualizó correctamente
     */
    public boolean editarUsuario(Usuario usuario) {
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = Conexion.getConnection();

            String sql = "UPDATE usuarios SET " +
                         "nombre_completo = ?, " +
                         "correo = ?, " +
                         "username = ?, " +
                         "id_rol = ? " +
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

    // ════════════════════════════════════════════════════════════
    // CAMBIAR ESTADO (ACTIVO ↔ INACTIVO)
    // ════════════════════════════════════════════════════════════

    /**
     * Cambia el estado de un usuario entre ACTIVO e INACTIVO.
     * Un usuario INACTIVO no puede iniciar sesión en el sistema.
     *
     * @param idUsuario   ID del usuario a modificar
     * @param nuevoEstado "ACTIVO" o "INACTIVO"
     * @return true si se actualizó correctamente
     */
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

    // ════════════════════════════════════════════════════════════
    // CAMBIAR ROL
    // ════════════════════════════════════════════════════════════

    /**
     * Cambia el rol asignado a un usuario.
     * Roles disponibles: 1=ADMINISTRADOR, 2=GESTOR_ARCHIVO, 3=DEPENDENCIA
     *
     * @param idUsuario ID del usuario a modificar
     * @param nuevoRol  Nuevo ID de rol a asignar
     * @return true si se actualizó correctamente
     */
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

    // ════════════════════════════════════════════════════════════
    // VERIFICAR DUPLICADOS
    // ════════════════════════════════════════════════════════════

    /**
     * Verifica si un correo electrónico ya está registrado en la BD.
     * Se usa para evitar duplicados al registrar o editar un usuario.
     *
     * @param correo      Correo a verificar
     * @param idExcluir   ID a excluir de la búsqueda (útil al editar; 0 al registrar)
     * @return true si el correo ya existe (en otro usuario)
     */
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

    /**
     * Verifica si un username ya está registrado en la BD.
     *
     * @param username   Username a verificar
     * @param idExcluir  ID a excluir de la búsqueda (0 al registrar)
     * @return true si el username ya existe en otro usuario
     */
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

    // ════════════════════════════════════════════════════════════
    // MÉTODO PRIVADO: mapear ResultSet → objeto Usuario
    // ════════════════════════════════════════════════════════════

    /**
     * Convierte una fila del ResultSet en un objeto Usuario.
     * Centraliza el mapeo para no repetirlo en cada método.
     */
    private Usuario mapearUsuario(ResultSet rs) throws Exception {
        Usuario u = new Usuario();
        u.setIdUsuario(rs.getInt("id_usuario"));
        u.setNombreCompleto(rs.getString("nombre_completo"));
        u.setCorreo(rs.getString("correo"));
        u.setUsername(rs.getString("username"));
        u.setPassword(rs.getString("password"));
        u.setEstado(rs.getString("estado"));
        u.setRolId(rs.getInt("id_rol"));
        u.setNombreRol(rs.getString("nombre_rol")); // Viene del JOIN con roles
        u.setFechaCreacion(rs.getTimestamp("fecha_creacion"));
        return u;
    }

    // ════════════════════════════════════════════════════════════
    // UTILIDAD: cerrar recursos de BD de forma segura
    // ════════════════════════════════════════════════════════════

    /**
     * Cierra ResultSet, PreparedStatement y Connection de forma segura.
     * Siempre llamado en el bloque finally para evitar fugas de conexión.
     */
    private void cerrarRecursos(ResultSet rs, PreparedStatement ps, Connection con) {
        try { if (rs  != null) rs.close();  } catch (Exception e) { e.printStackTrace(); }
        try { if (ps  != null) ps.close();  } catch (Exception e) { e.printStackTrace(); }
        try { if (con != null) con.close(); } catch (Exception e) { e.printStackTrace(); }
    }
}