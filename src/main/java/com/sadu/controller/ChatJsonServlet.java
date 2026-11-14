package com.sadu.controller;

import com.sadu.dao.MensajeDAO;
import com.sadu.dao.UsuarioDAO;
import com.sadu.modelo.Mensaje;
import com.sadu.modelo.Usuario;
import com.sadu.util.Auditoria;
import com.sadu.util.UserPresenceManager;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

/**
 * Servlet central para el Chat Empresarial SADU (ICQ Style).
 * Soporta tanto peticiones application/x-www-form-urlencoded como multipart/form-data.
 */
@WebServlet(name = "ChatJsonServlet", urlPatterns = {"/ChatJsonServlet"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB en memoria
    maxFileSize = 1024 * 1024 * 15,      // 15MB max por archivo
    maxRequestSize = 1024 * 1024 * 30    // 30MB max request
)
public class ChatJsonServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession sesion = request.getSession(false);
        if (sesion == null || sesion.getAttribute("idUsuario") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json");
            response.getWriter().write("{\"error\":\"Sin sesion activa\"}");
            return;
        }

        int idUsuarioActual = (int) sesion.getAttribute("idUsuario");
        UserPresenceManager.registrarHeartbeat(idUsuarioActual);

        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            action = "mensajes";
        }

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        if ("usuarios".equalsIgnoreCase(action)) {
            UsuarioDAO uDao = new UsuarioDAO();
            List<Usuario> listaUsuarios = uDao.listarUsuarios();
            
            StringBuilder json = new StringBuilder("[");
            boolean primero = true;
            for (Usuario u : listaUsuarios) {
                if (!primero) json.append(",");
                primero = false;

                boolean isOnline = UserPresenceManager.isOnline(u.getIdUsuario());
                boolean isTyping = UserPresenceManager.isTyping(u.getIdUsuario());

                if (u.getIdUsuario() == idUsuarioActual) {
                    isOnline = true;
                }

                json.append("{");
                json.append("\"idUsuario\":").append(u.getIdUsuario()).append(",");
                json.append("\"nombreCompleto\":\"").append(escaparJson(u.getNombreCompleto())).append("\",");
                json.append("\"correo\":\"").append(escaparJson(u.getCorreo())).append("\",");
                json.append("\"username\":\"").append(escaparJson(u.getUsername())).append("\",");
                json.append("\"nombreRol\":\"").append(escaparJson(u.getNombreRol())).append("\",");
                json.append("\"online\":").append(isOnline).append(",");
                json.append("\"typing\":").append(isTyping);
                json.append("}");
            }
            json.append("]");
            out.print(json.toString());

        } else {
            String receptorStr = request.getParameter("receptorId");
            Integer receptorId = null;
            if (receptorStr != null && !receptorStr.trim().isEmpty()) {
                try {
                    receptorId = Integer.parseInt(receptorStr.trim());
                } catch (NumberFormatException ignored) {}
            }

            MensajeDAO mDao = new MensajeDAO();
            List<Mensaje> lista = mDao.listarMensajes(idUsuarioActual, receptorId);

            StringBuilder json = new StringBuilder("[");
            boolean primero = true;
            for (Mensaje m : lista) {
                if (!primero) json.append(",");
                primero = false;

                json.append("{");
                json.append("\"idMensaje\":").append(m.getIdMensaje()).append(",");
                json.append("\"idUsuario\":").append(m.getIdUsuario()).append(",");
                json.append("\"nombreUsuario\":\"").append(escaparJson(m.getNombreUsuario())).append("\",");
                json.append("\"idReceptor\":").append(m.getIdReceptor() != null ? m.getIdReceptor() : "null").append(",");
                json.append("\"nombreReceptor\":\"").append(escaparJson(m.getNombreReceptor())).append("\",");
                json.append("\"asunto\":\"").append(escaparJson(m.getAsunto())).append("\",");
                json.append("\"mensaje\":\"").append(escaparJson(m.getMensaje())).append("\",");
                json.append("\"tipo\":\"").append(escaparJson(m.getTipo())).append("\",");
                json.append("\"urlAdjunto\":\"").append(escaparJson(m.getUrlAdjunto())).append("\",");
                json.append("\"editado\":").append(m.isEditado()).append(",");
                json.append("\"estado\":\"").append(escaparJson(m.getEstado())).append("\",");
                json.append("\"fechaEnvio\":").append(m.getFechaEnvio() != null ? m.getFechaEnvio().getTime() : "null");
                json.append("}");
            }
            json.append("]");
            out.print(json.toString());
        }
        out.flush();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession sesion = request.getSession(false);
        if (sesion == null || sesion.getAttribute("idUsuario") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json");
            response.getWriter().write("{\"error\":\"Sin sesion activa\"}");
            return;
        }

        int idUsuarioActual = (int) sesion.getAttribute("idUsuario");
        UserPresenceManager.registrarHeartbeat(idUsuarioActual);

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String action = obtenerParametro(request, "action");
        if (action == null || action.trim().isEmpty()) {
            action = "enviar";
        }

        MensajeDAO mDao = new MensajeDAO();

        if ("typing".equalsIgnoreCase(action)) {
            UserPresenceManager.registrarEscritura(idUsuarioActual);
            out.print("{\"success\":true}");
        } else if ("heartbeat".equalsIgnoreCase(action)) {
            out.print("{\"success\":true}");
        } else if ("editar".equalsIgnoreCase(action)) {
            int idMensaje = Integer.parseInt(obtenerParametro(request, "idMensaje"));
            String nuevoTexto = obtenerParametro(request, "nuevoTexto");
            
            boolean editado = mDao.editarMensaje(idMensaje, idUsuarioActual, nuevoTexto);
            if (editado) {
                Auditoria.registrar(idUsuarioActual, "EDITAR_MENSAJE", "Edito mensaje ID: " + idMensaje);
            }
            out.print("{\"success\":" + editado + "}");
        } else if ("eliminar".equalsIgnoreCase(action)) {
            int idMensaje = Integer.parseInt(obtenerParametro(request, "idMensaje"));
            Object rolObj = sesion.getAttribute("rolUsuario");
            boolean esAdmin = "1".equals(String.valueOf(rolObj)) || "ADMINISTRADOR".equalsIgnoreCase(String.valueOf(rolObj));

            boolean eliminado = mDao.eliminarMensaje(idMensaje, idUsuarioActual, esAdmin);
            if (eliminado) {
                Auditoria.registrar(idUsuarioActual, "ELIMINAR_MENSAJE", "Elimino mensaje ID: " + idMensaje);
            }
            out.print("{\"success\":" + eliminado + "}");
        } else {
            String asunto = obtenerParametro(request, "asunto");
            String texto = obtenerParametro(request, "mensaje");
            String tipo = obtenerParametro(request, "tipo");
            String urlAdjunto = obtenerParametro(request, "urlAdjunto");
            String receptorStr = obtenerParametro(request, "idReceptor");

            if (tipo == null || tipo.trim().isEmpty()) tipo = "TEXTO";
            if (asunto == null || asunto.trim().isEmpty()) asunto = "Chat";

            Integer receptorId = null;
            if (receptorStr != null && !receptorStr.trim().isEmpty()) {
                try {
                    receptorId = Integer.parseInt(receptorStr.trim());
                } catch (NumberFormatException ignored) {}
            }

            Mensaje nuevo = new Mensaje();
            nuevo.setIdUsuario(idUsuarioActual);
            nuevo.setIdReceptor(receptorId);
            nuevo.setAsunto(asunto.trim());
            nuevo.setMensaje(texto != null ? texto.trim() : "");
            nuevo.setTipo(tipo);
            nuevo.setUrlAdjunto(urlAdjunto);

            boolean guardado = mDao.enviarMensaje(nuevo);
            if (guardado) {
                Auditoria.registrar(idUsuarioActual, "ENVIO_MENSAJE", "Mensaje (" + tipo + ") enviado en chat.");
            }
            out.print("{\"success\":" + guardado + "}");
        }
        out.flush();
    }

    /**
     * Obtiene el parámetro de la petición de forma segura, ya sea que venga
     * en formato estándar de formulario o como parte de un multipart/form-data.
     */
    private String obtenerParametro(HttpServletRequest request, String nombre) {
        String valor = request.getParameter(nombre);
        if (valor != null) {
            return valor;
        }

        String contentType = request.getContentType();
        if (contentType != null && contentType.toLowerCase().startsWith("multipart/")) {
            try {
                Part part = request.getPart(nombre);
                if (part != null) {
                    try (InputStream is = part.getInputStream();
                         BufferedReader reader = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
                        StringBuilder sb = new StringBuilder();
                        String linea;
                        while ((linea = reader.readLine()) != null) {
                            if (sb.length() > 0) sb.append("\n");
                            sb.append(linea);
                        }
                        valor = sb.toString();
                    }
                }
            } catch (Exception ignored) {}
        }
        return valor;
    }

    private String escaparJson(String texto) {
        if (texto == null) return "";
        return texto
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
