package com.sadu.controller;

import com.sadu.config.Conexion;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * API REST de Usuarios — devuelve JSON puro para consumir desde Postman.
 *
 * ENDPOINTS:
 *   GET    /api/usuarios        → Listar todos los usuarios
 *   GET    /api/usuarios?id=1   → Obtener un usuario por ID
 *   POST   /api/usuarios        → Crear nuevo usuario (body JSON)
 *   PUT    /api/usuarios?id=1   → Actualizar usuario (body JSON)
 *   DELETE /api/usuarios?id=1   → Eliminar usuario
 */
@WebServlet(name = "UsuarioApiServlet", urlPatterns = {"/api/usuarios"})
public class UsuarioApiServlet extends HttpServlet {

    // ────────────────────────────────────────────────────────────
    // GET — Listar todos o buscar por ID
    // ────────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        configurarRespuestaJson(response);
        PrintWriter out = response.getWriter();

        String idParam = request.getParameter("id");

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConnection();

            if (idParam != null && !idParam.trim().isEmpty()) {
                // ── GET por ID ──────────────────────────────────
                int id = Integer.parseInt(idParam.trim());

                String sql = "SELECT u.id_usuario, u.nombre_completo, u.correo, " +
                             "u.username, u.estado, u.fecha_creacion, r.nombre AS rol " +
                             "FROM usuarios u " +
                             "INNER JOIN roles r ON u.id_rol = r.id_rol " +
                             "WHERE u.id_usuario = ?";

                ps = con.prepareStatement(sql);
                ps.setInt(1, id);
                rs = ps.executeQuery();

                if (rs.next()) {
                    out.print(usuarioToJson(rs));
                } else {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\":\"Usuario no encontrado con ID: " + id + "\"}");
                }

            } else {
                // ── GET todos ───────────────────────────────────
                String sql = "SELECT u.id_usuario, u.nombre_completo, u.correo, " +
                             "u.username, u.estado, u.fecha_creacion, r.nombre AS rol " +
                             "FROM usuarios u " +
                             "INNER JOIN roles r ON u.id_rol = r.id_rol " +
                             "ORDER BY u.id_usuario ASC";

                ps = con.prepareStatement(sql);
                rs = ps.executeQuery();

                StringBuilder json = new StringBuilder("[");
                boolean primero = true;

                while (rs.next()) {
                    if (!primero) json.append(",");
                    primero = false;
                    json.append(usuarioToJson(rs));
                }

                json.append("]");
                out.print(json.toString());
            }

        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"El ID debe ser un número entero válido.\"}");
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\":\"" + esc(e.getMessage()) + "\"}");
            e.printStackTrace();
        } finally {
            cerrar(rs, ps, con);
        }
    }

    // ────────────────────────────────────────────────────────────
    // POST — Crear nuevo usuario (recibe JSON en el body)
    // ────────────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        configurarRespuestaJson(response);
        PrintWriter out = response.getWriter();

        try {
            String body = leerBody(request);

            // Extraer campos del JSON
            String nombreCompleto = extraerCampo(body, "nombreCompleto");
            String correo         = extraerCampo(body, "correo");
            String username       = extraerCampo(body, "username");
            String password       = extraerCampo(body, "password");
            String estado         = extraerCampo(body, "estado");
            String rolIdStr       = extraerCampo(body, "rolId");

            // Validar campos obligatorios
            if (estaVacio(nombreCompleto) || estaVacio(correo) ||
                estaVacio(username)       || estaVacio(password)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"Campos obligatorios: nombreCompleto, correo, username, password\"}");
                return;
            }

            // Valores por defecto
            if (estaVacio(estado))   estado = "ACTIVO";
            int rolId = 2; // Gestor de Archivo por defecto
            if (!estaVacio(rolIdStr)) {
                try { rolId = Integer.parseInt(rolIdStr.trim()); }
                catch (NumberFormatException e) { rolId = 2; }
            }

            Connection con = null;
            PreparedStatement ps = null;

            try {
                con = Conexion.getConnection();

                // Verificar correo duplicado
                PreparedStatement psCheck = con.prepareStatement(
                    "SELECT COUNT(*) FROM usuarios WHERE correo = ? OR username = ?");
                psCheck.setString(1, correo.trim());
                psCheck.setString(2, username.trim().toLowerCase());
                ResultSet rsCheck = psCheck.executeQuery();
                rsCheck.next();
                if (rsCheck.getInt(1) > 0) {
                    psCheck.close();
                    response.setStatus(HttpServletResponse.SC_CONFLICT);
                    out.print("{\"error\":\"El correo o username ya están registrados.\"}");
                    return;
                }
                psCheck.close();

                // Insertar el nuevo usuario
                String sql = "INSERT INTO usuarios " +
                             "(nombre_completo, correo, username, password, estado, id_rol) " +
                             "VALUES (?, ?, ?, ?, ?, ?)";

                ps = con.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS);
                ps.setString(1, nombreCompleto.trim());
                ps.setString(2, correo.trim().toLowerCase());
                ps.setString(3, username.trim().toLowerCase());
                ps.setString(4, password);
                ps.setString(5, estado.trim());
                ps.setInt(6,    rolId);

                int filas = ps.executeUpdate();

                if (filas > 0) {
                    ResultSet rsKey = ps.getGeneratedKeys();
                    int idGenerado = 0;
                    if (rsKey.next()) idGenerado = rsKey.getInt(1);
                    rsKey.close();

                    response.setStatus(HttpServletResponse.SC_CREATED); // 201
                    out.print("{" +
                        "\"mensaje\":\"Usuario registrado correctamente\"," +
                        "\"id\":"          + idGenerado                              + "," +
                        "\"username\":\""  + esc(username.trim().toLowerCase())      + "\"," +
                        "\"correo\":\""    + esc(correo.trim().toLowerCase())        + "\"," +
                        "\"estado\":\""    + esc(estado.trim())                      + "\"," +
                        "\"rolId\":"       + rolId                                   +
                    "}");
                } else {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    out.print("{\"error\":\"No se pudo registrar el usuario.\"}");
                }

            } finally {
                cerrar(null, ps, con);
            }

        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\":\"" + esc(e.getMessage()) + "\"}");
            e.printStackTrace();
        }
    }

    // ────────────────────────────────────────────────────────────
    // PUT — Actualizar usuario por ID (?id=1)
    // ────────────────────────────────────────────────────────────
    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        configurarRespuestaJson(response);
        PrintWriter out = response.getWriter();

        String idParam = request.getParameter("id");

        if (estaVacio(idParam)) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Se requiere el parámetro ?id=N para actualizar.\"}");
            return;
        }

        try {
            int id = Integer.parseInt(idParam.trim());
            String body = leerBody(request);

            // Extraer campos del body JSON
            String nombreCompleto = extraerCampo(body, "nombreCompleto");
            String correo         = extraerCampo(body, "correo");
            String password       = extraerCampo(body, "password");
            String estado         = extraerCampo(body, "estado");
            String rolIdStr       = extraerCampo(body, "rolId");

            // Construir SQL dinámico con solo los campos enviados
            java.util.List<String> campos  = new java.util.ArrayList<>();
            java.util.List<Object> valores = new java.util.ArrayList<>();

            if (!estaVacio(nombreCompleto)) { campos.add("nombre_completo = ?"); valores.add(nombreCompleto.trim()); }
            if (!estaVacio(correo))         { campos.add("correo = ?");          valores.add(correo.trim().toLowerCase()); }
            if (!estaVacio(password))       { campos.add("password = ?");        valores.add(password); }
            if (!estaVacio(estado))         { campos.add("estado = ?");          valores.add(estado.trim()); }
            if (!estaVacio(rolIdStr)) {
                try {
                    campos.add("id_rol = ?");
                    valores.add(Integer.parseInt(rolIdStr.trim()));
                } catch (NumberFormatException e) { /* ignorar rolId inválido */ }
            }

            if (campos.isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"No se enviaron campos para actualizar.\"}");
                return;
            }

            StringBuilder sql = new StringBuilder("UPDATE usuarios SET ");
            for (int i = 0; i < campos.size(); i++) {
                sql.append(campos.get(i));
                if (i < campos.size() - 1) sql.append(", ");
            }
            sql.append(" WHERE id_usuario = ?");
            valores.add(id);

            Connection con = null;
            PreparedStatement ps = null;

            try {
                con = Conexion.getConnection();
                ps  = con.prepareStatement(sql.toString());

                for (int i = 0; i < valores.size(); i++) {
                    ps.setObject(i + 1, valores.get(i));
                }

                int filas = ps.executeUpdate();

                if (filas > 0) {
                    out.print("{\"mensaje\":\"Usuario actualizado correctamente.\",\"id\":" + id + "}");
                } else {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\":\"No se encontró usuario con ID: " + id + "\"}");
                }

            } finally {
                cerrar(null, ps, con);
            }

        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"El ID debe ser un número entero válido.\"}");
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\":\"" + esc(e.getMessage()) + "\"}");
            e.printStackTrace();
        }
    }

    // ────────────────────────────────────────────────────────────
    // DELETE — Eliminar usuario por ID (?id=1)
    // ────────────────────────────────────────────────────────────
    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        configurarRespuestaJson(response);
        PrintWriter out = response.getWriter();

        String idParam = request.getParameter("id");

        if (estaVacio(idParam)) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Se requiere el parámetro ?id=N para eliminar.\"}");
            return;
        }

        try {
            int id = Integer.parseInt(idParam.trim());

            Connection con = null;
            PreparedStatement ps = null;

            try {
                con = Conexion.getConnection();

                // Evitar eliminar el único administrador del sistema
                PreparedStatement psCheck = con.prepareStatement(
                    "SELECT COUNT(*) FROM usuarios WHERE id_rol = 1");
                ResultSet rsCheck = psCheck.executeQuery();
                rsCheck.next();
                int totalAdmins = rsCheck.getInt(1);
                psCheck.close();

                // Verificar si el usuario a eliminar es admin
                PreparedStatement psRol = con.prepareStatement(
                    "SELECT id_rol FROM usuarios WHERE id_usuario = ?");
                psRol.setInt(1, id);
                ResultSet rsRol = psRol.executeQuery();
                if (rsRol.next() && rsRol.getInt("id_rol") == 1 && totalAdmins <= 1) {
                    psRol.close();
                    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    out.print("{\"error\":\"No se puede eliminar el único administrador del sistema.\"}");
                    return;
                }
                psRol.close();

                // Eliminar el usuario
                ps = con.prepareStatement("DELETE FROM usuarios WHERE id_usuario = ?");
                ps.setInt(1, id);
                int filas = ps.executeUpdate();

                if (filas > 0) {
                    out.print("{\"mensaje\":\"Usuario eliminado correctamente.\",\"id\":" + id + "}");
                } else {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\":\"No se encontró usuario con ID: " + id + "\"}");
                }

            } finally {
                cerrar(null, ps, con);
            }

        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"El ID debe ser un número entero válido.\"}");
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\":\"" + esc(e.getMessage()) + "\"}");
            e.printStackTrace();
        }
    }

    // ════════════════════════════════════════════════════════════
    // MÉTODOS PRIVADOS DE APOYO
    // ════════════════════════════════════════════════════════════

    /** Configura la respuesta como JSON con UTF-8 y cabeceras CORS */
    private void configurarRespuestaJson(HttpServletResponse response) {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type");
    }

    /** Convierte una fila del ResultSet a un objeto JSON */
    private String usuarioToJson(ResultSet rs) throws Exception {
        return "{" +
            "\"id\":"               + rs.getInt("id_usuario")                   + "," +
            "\"nombreCompleto\":\"" + esc(rs.getString("nombre_completo"))       + "\"," +
            "\"correo\":\""         + esc(rs.getString("correo"))                + "\"," +
            "\"username\":\""       + esc(rs.getString("username"))              + "\"," +
            "\"estado\":\""         + esc(rs.getString("estado"))                + "\"," +
            "\"rol\":\""            + esc(rs.getString("rol"))                   + "\"," +
            "\"fechaCreacion\":\""  + (rs.getTimestamp("fecha_creacion") != null
                                       ? rs.getTimestamp("fecha_creacion").toString()
                                       : "")                                     + "\"" +
        "}";
    }

    /** Lee el body completo de la petición como String */
    private String leerBody(HttpServletRequest request) throws IOException {
        StringBuilder sb = new StringBuilder();
        String linea;
        java.io.BufferedReader reader = request.getReader();
        while ((linea = reader.readLine()) != null) sb.append(linea);
        return sb.toString();
    }

    /** Extrae el valor de un campo JSON de forma simple */
    private String extraerCampo(String json, String campo) {
        if (json == null || campo == null) return null;
        String clave = "\"" + campo + "\"";
        int idx = json.indexOf(clave);
        if (idx < 0) return null;

        int dospuntos = json.indexOf(":", idx + clave.length());
        if (dospuntos < 0) return null;

        int inicio = dospuntos + 1;
        while (inicio < json.length() && json.charAt(inicio) == ' ') inicio++;
        if (inicio >= json.length()) return null;

        if (json.charAt(inicio) == '"') {
            int fin = json.indexOf('"', inicio + 1);
            if (fin < 0) return null;
            return json.substring(inicio + 1, fin);
        } else {
            int fin = inicio;
            while (fin < json.length() &&
                   json.charAt(fin) != ',' &&
                   json.charAt(fin) != '}') fin++;
            return json.substring(inicio, fin).trim();
        }
    }

    /** Verifica si un String es nulo o vacío */
    private boolean estaVacio(String valor) {
        return valor == null || valor.trim().isEmpty();
    }

    /** Escapa caracteres especiales para JSON válido */
    private String esc(String texto) {
        if (texto == null) return "";
        return texto
            .replace("\\", "\\\\")
            .replace("\"", "\\\"")
            .replace("\n", "\\n")
            .replace("\r", "\\r")
            .replace("\t", "\\t");
    }

    /** Cierra recursos de BD de forma segura */
    private void cerrar(ResultSet rs, PreparedStatement ps, Connection con) {
        try { if (rs  != null) rs.close();  } catch (Exception e) { e.printStackTrace(); }
        try { if (ps  != null) ps.close();  } catch (Exception e) { e.printStackTrace(); }
        try { if (con != null) con.close(); } catch (Exception e) { e.printStackTrace(); }
    }
}
