package com.sadu.controller;

import com.sadu.config.Conexion;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Servlet que devuelve los mensajes del chat en formato JSON.
 *
 * Es usado por el chat flotante del dashboard mediante fetch() en JavaScript.
 * A diferencia de ListarMensajesServlet (que redirige a un JSP),
 * este servlet responde directamente con JSON para no recargar la página.
 *
 * Endpoint: GET /ChatJsonServlet
 * Respuesta: application/json — arreglo de mensajes
 */
@WebServlet(name = "ChatJsonServlet", urlPatterns = {"/ChatJsonServlet"})
public class ChatJsonServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // -------------------------------------------------------
        // 1. Validar sesión activa
        //    Si no hay sesión, responder con JSON de error 401
        // -------------------------------------------------------
        HttpSession sesion = request.getSession(false);

        if (sesion == null || sesion.getAttribute("nombreUsuario") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json");
            response.getWriter().write("{\"error\":\"Sin sesión activa\"}");
            return;
        }

        // -------------------------------------------------------
        // 2. Configurar respuesta como JSON con codificación UTF-8
        // -------------------------------------------------------
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // -------------------------------------------------------
        // 3. Consultar los últimos 30 mensajes del chat
        //    con JOIN a usuarios para obtener el nombre completo
        // -------------------------------------------------------
        Connection con        = null;
        PreparedStatement ps  = null;
        ResultSet rs          = null;
        StringBuilder json    = new StringBuilder();

        try {
            con = Conexion.getConnection();

            // Traer los últimos 30 mensajes ordenados del más antiguo al más nuevo
            // (ASC para que en el chat se lean de arriba hacia abajo en orden cronológico)
            String sql = "SELECT m.id_mensaje, m.id_usuario, u.nombre_completo, "
                       + "       m.asunto, m.mensaje, m.estado, m.fecha_envio "
                       + "FROM mensajes_chat m "
                       + "INNER JOIN usuarios u ON m.id_usuario = u.id_usuario "
                       + "ORDER BY m.fecha_envio DESC "
                       + "LIMIT 30";

            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();

            json.append("[");
            boolean primero = true;

            while (rs.next()) {
                if (!primero) {
                    json.append(",");
                }
                primero = false;

                int       idMensaje     = rs.getInt("id_mensaje");
                int       idUsuario     = rs.getInt("id_usuario");
                String    nombreUsu     = rs.getString("nombre_completo");
                String    asunto        = rs.getString("asunto");
                String    mensajeTxt    = rs.getString("mensaje");
                String    estado        = rs.getString("estado");
                Timestamp fechaEnvio    = rs.getTimestamp("fecha_envio");

                // Escapar caracteres especiales para JSON válido
                // Evita que comillas o saltos de línea en el mensaje rompan el JSON
                nombreUsu  = escaparJson(nombreUsu);
                asunto     = escaparJson(asunto);
                mensajeTxt = escaparJson(mensajeTxt);

                // Construir objeto JSON del mensaje
                json.append("{");
                json.append("\"idMensaje\":"  ).append(idMensaje).append(",");
                json.append("\"idUsuario\":"  ).append(idUsuario).append(",");
                json.append("\"nombreUsuario\":\"").append(nombreUsu).append("\",");
                json.append("\"asunto\":\""   ).append(asunto).append("\",");
                json.append("\"mensaje\":\""  ).append(mensajeTxt).append("\",");
                json.append("\"estado\":\""   ).append(estado).append("\",");
                json.append("\"fechaEnvio\":" ).append(
                        fechaEnvio != null ? fechaEnvio.getTime() : "null"
                );
                json.append("}");
            }

            json.append("]");

        } catch (Exception e) {
            // En caso de error de base de datos, devolver arreglo vacío
            e.printStackTrace();
            json = new StringBuilder("[]");
        } finally {
            try {
                if (rs  != null) rs.close();
                if (ps  != null) ps.close();
                if (con != null) con.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        // -------------------------------------------------------
        // 4. Escribir el JSON en la respuesta
        // -------------------------------------------------------
        PrintWriter out = response.getWriter();
        out.print(json.toString());
        out.flush();
    }

    /**
     * Escapa caracteres especiales para que el texto sea JSON válido.
     * Sin esto, si un mensaje contiene comillas o saltos de línea,
     * el JSON se rompe y el chat flotante no puede leerlo.
     *
     * @param texto Texto original del campo de la base de datos
     * @return Texto con caracteres especiales escapados
     */
    private String escaparJson(String texto) {
        if (texto == null) return "";
        return texto
                .replace("\\", "\\\\")   // barra invertida
                .replace("\"", "\\\"")   // comilla doble
                .replace("\n", "\\n")    // salto de línea
                .replace("\r", "\\r")    // retorno de carro
                .replace("\t", "\\t");   // tabulación
    }
}
