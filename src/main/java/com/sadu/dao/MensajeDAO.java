package com.sadu.dao;

import com.sadu.config.Conexion;
import com.sadu.modelo.Mensaje;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 * Clase DAO encargada de todas las operaciones de base de datos
 * relacionadas con la tabla mensajes_chat.
 *
 * Operaciones disponibles:
 *   - enviarMensaje()   → INSERT de un nuevo mensaje
 *   - listarMensajes()  → SELECT de todos los mensajes con nombre del usuario
 *   - marcarLeido()     → UPDATE del estado a LEIDO
 */
public class MensajeDAO {

    /**
     * Guarda un nuevo mensaje en la tabla mensajes_chat.
     *
     * @param mensaje Objeto Mensaje con los datos a insertar
     * @return true si se insertó correctamente, false si ocurrió un error
     */
    public boolean enviarMensaje(Mensaje mensaje) {
        Connection con = null;
        PreparedStatement ps = null;

        try {
            // Obtener conexión a la base de datos
            con = Conexion.getConnection();

            // SQL para insertar el mensaje
            // Estado por defecto es PENDIENTE (definido en la tabla)
            String sql = "INSERT INTO mensajes_chat (id_usuario, asunto, mensaje) "
                       + "VALUES (?, ?, ?)";

            ps = con.prepareStatement(sql);
            ps.setInt(1, mensaje.getIdUsuario());
            ps.setString(2, mensaje.getAsunto());
            ps.setString(3, mensaje.getMensaje());

            // Ejecutar inserción y verificar si afectó alguna fila
            int filas = ps.executeUpdate();
            return filas > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            // Cerrar recursos siempre, aunque ocurra un error
            try {
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * Obtiene todos los mensajes del chat ordenados del más reciente al más antiguo.
     * Hace un JOIN con la tabla usuarios para obtener el nombre completo del remitente.
     *
     * @return Lista de objetos Mensaje con todos los datos
     */
    public List<Mensaje> listarMensajes() {
        List<Mensaje> lista = new ArrayList<>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConnection();

            // JOIN con usuarios para traer el nombre completo del remitente
            String sql = "SELECT m.id_mensaje, m.id_usuario, u.nombre_completo, "
                       + "       m.asunto, m.mensaje, m.estado, m.fecha_envio "
                       + "FROM mensajes_chat m "
                       + "INNER JOIN usuarios u ON m.id_usuario = u.id_usuario "
                       + "ORDER BY m.fecha_envio DESC";

            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();

            // Recorrer resultados y llenar la lista
            while (rs.next()) {
                Mensaje m = new Mensaje();
                m.setIdMensaje(rs.getInt("id_mensaje"));
                m.setIdUsuario(rs.getInt("id_usuario"));
                m.setNombreUsuario(rs.getString("nombre_completo"));
                m.setAsunto(rs.getString("asunto"));
                m.setMensaje(rs.getString("mensaje"));
                m.setEstado(rs.getString("estado"));
                m.setFechaEnvio(rs.getTimestamp("fecha_envio"));
                lista.add(m);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        return lista;
    }

    /**
     * Actualiza el estado de un mensaje a LEIDO.
     * Se llama cuando un usuario abre o visualiza el mensaje.
     *
     * @param idMensaje ID del mensaje a marcar como leído
     * @return true si se actualizó correctamente, false si ocurrió un error
     */
    public boolean marcarLeido(int idMensaje) {
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = Conexion.getConnection();

            String sql = "UPDATE mensajes_chat SET estado = 'LEIDO' WHERE id_mensaje = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, idMensaje);

            int filas = ps.executeUpdate();
            return filas > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}