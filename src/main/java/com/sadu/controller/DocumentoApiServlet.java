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
 * API REST de Documentos — devuelve JSON puro para consumir desde Postman.
 *
 * ENDPOINTS:
 *   GET    /api/documentos        → Listar todos los documentos
 *   GET    /api/documentos?id=1   → Obtener un documento por ID
 *   POST   /api/documentos        → Crear nuevo documento (body JSON)
 *   PUT    /api/documentos?id=1   → Actualizar documento (body JSON)
 *   DELETE /api/documentos?id=1   → Eliminar documento
 */
@WebServlet(name = "DocumentoApiServlet", urlPatterns = {"/api/documentos"})
public class DocumentoApiServlet extends HttpServlet {

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

                String sql = "SELECT d.id_documento, d.codigo, d.nombre_documento, " +
                             "d.tipo_documento, d.dependencia, d.fecha_documento, " +
                             "d.ruta_archivo, d.qr_codigo, d.trd, d.estado, " +
                             "u.nombre_completo, d.fecha_registro " +
                             "FROM documentos d " +
                             "INNER JOIN usuarios u ON d.id_usuario = u.id_usuario " +
                             "WHERE d.id_documento = ?";

                ps = con.prepareStatement(sql);
                ps.setInt(1, id);
                rs = ps.executeQuery();

                if (rs.next()) {
                    out.print(documentoToJson(rs));
                } else {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\":\"Documento no encontrado con ID: " + id + "\"}");
                }

            } else {
                // ── GET todos ───────────────────────────────────
                String sql = "SELECT d.id_documento, d.codigo, d.nombre_documento, " +
                             "d.tipo_documento, d.dependencia, d.fecha_documento, " +
                             "d.ruta_archivo, d.qr_codigo, d.trd, d.estado, " +
                             "u.nombre_completo, d.fecha_registro " +
                             "FROM documentos d " +
                             "INNER JOIN usuarios u ON d.id_usuario = u.id_usuario " +
                             "ORDER BY d.fecha_registro DESC";

                ps = con.prepareStatement(sql);
                rs = ps.executeQuery();

                StringBuilder json = new StringBuilder("[");
                boolean primero = true;

                while (rs.next()) {
                    if (!primero) json.append(",");
                    primero = false;
                    json.append(documentoToJson(rs));
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
    // POST — Crear nuevo documento (recibe JSON en el body)
    // ────────────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        configurarRespuestaJson(response);
        PrintWriter out = response.getWriter();

        try {
            // Leer el body JSON de la petición
            String body = leerBody(request);

            // Extraer campos del JSON manualmente (sin librería extra)
            String codigo          = extraerCampo(body, "codigo");
            String nombreDocumento = extraerCampo(body, "nombreDocumento");
            String tipoDocumento   = extraerCampo(body, "tipoDocumento");
            String dependencia     = extraerCampo(body, "dependencia");
            String fechaDocumento  = extraerCampo(body, "fechaDocumento");
            String trd             = extraerCampo(body, "trd");
            String estado          = extraerCampo(body, "estado");
            String rutaArchivo     = extraerCampo(body, "rutaArchivo");

            // Validar campos obligatorios
            if (estaVacio(codigo) || estaVacio(nombreDocumento) ||
                estaVacio(tipoDocumento) || estaVacio(dependencia) ||
                estaVacio(fechaDocumento)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"Campos obligatorios: codigo, nombreDocumento, tipoDocumento, dependencia, fechaDocumento\"}");
                return;
            }

            // Valor por defecto para estado
            if (estaVacio(estado)) estado = "REGISTRADO";

            // QR automático
            String qrCodigo = "QR-" + codigo.trim().toUpperCase();

            Connection con = null;
            PreparedStatement ps = null;

            try {
                con = Conexion.getConnection();

                // Verificar si el código ya existe
                PreparedStatement psCheck = con.prepareStatement(
                    "SELECT COUNT(*) FROM documentos WHERE codigo = ?");
                psCheck.setString(1, codigo.trim().toUpperCase());
                ResultSet rsCheck = psCheck.executeQuery();
                rsCheck.next();
                if (rsCheck.getInt(1) > 0) {
                    psCheck.close();
                    response.setStatus(HttpServletResponse.SC_CONFLICT);
                    out.print("{\"error\":\"El código " + esc(codigo) + " ya está registrado.\"}");
                    return;
                }
                psCheck.close();

                // Insertar el nuevo documento
                // id_usuario = 1 por defecto para peticiones desde API
                String sql = "INSERT INTO documentos " +
                             "(codigo, nombre_documento, tipo_documento, dependencia, " +
                             " fecha_documento, ruta_archivo, qr_codigo, trd, estado, id_usuario) " +
                             "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 1)";

                ps = con.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS);
                ps.setString(1, codigo.trim().toUpperCase());
                ps.setString(2, nombreDocumento.trim());
                ps.setString(3, tipoDocumento.trim());
                ps.setString(4, dependencia.trim());
                ps.setString(5, fechaDocumento.trim());
                ps.setString(6, rutaArchivo != null ? rutaArchivo.trim() : "");
                ps.setString(7, qrCodigo);
                ps.setString(8, trd != null ? trd.trim() : "");
                ps.setString(9, estado.trim());

                int filas = ps.executeUpdate();

                if (filas > 0) {
                    // Obtener el ID generado
                    ResultSet rsKey = ps.getGeneratedKeys();
                    int idGenerado = 0;
                    if (rsKey.next()) idGenerado = rsKey.getInt(1);
                    rsKey.close();

                    response.setStatus(HttpServletResponse.SC_CREATED); // 201
                    out.print("{" +
                        "\"mensaje\":\"Documento registrado correctamente\"," +
                        "\"id\":" + idGenerado + "," +
                        "\"codigo\":\"" + esc(codigo.trim().toUpperCase()) + "\"," +
                        "\"qrCodigo\":\"" + esc(qrCodigo) + "\"" +
                    "}");
                } else {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    out.print("{\"error\":\"No se pudo registrar el documento.\"}");
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
    // PUT — Actualizar documento por ID (?id=1)
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
            String nombreDocumento = extraerCampo(body, "nombreDocumento");
            String tipoDocumento   = extraerCampo(body, "tipoDocumento");
            String dependencia     = extraerCampo(body, "dependencia");
            String fechaDocumento  = extraerCampo(body, "fechaDocumento");
            String trd             = extraerCampo(body, "trd");
            String estado          = extraerCampo(body, "estado");
            String rutaArchivo     = extraerCampo(body, "rutaArchivo");

            // Construir SQL dinámico con solo los campos enviados
            StringBuilder sql = new StringBuilder("UPDATE documentos SET ");
            java.util.List<String> campos   = new java.util.ArrayList<>();
            java.util.List<Object> valores  = new java.util.ArrayList<>();

            if (!estaVacio(nombreDocumento)) { campos.add("nombre_documento = ?"); valores.add(nombreDocumento.trim()); }
            if (!estaVacio(tipoDocumento))   { campos.add("tipo_documento = ?");   valores.add(tipoDocumento.trim()); }
            if (!estaVacio(dependencia))     { campos.add("dependencia = ?");      valores.add(dependencia.trim()); }
            if (!estaVacio(fechaDocumento))  { campos.add("fecha_documento = ?");  valores.add(fechaDocumento.trim()); }
            if (!estaVacio(trd))             { campos.add("trd = ?");              valores.add(trd.trim()); }
            if (!estaVacio(estado))          { campos.add("estado = ?");           valores.add(estado.trim()); }
            if (!estaVacio(rutaArchivo))     { campos.add("ruta_archivo = ?");     valores.add(rutaArchivo.trim()); }

            if (campos.isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"No se enviaron campos para actualizar.\"}");
                return;
            }

            for (int i = 0; i < campos.size(); i++) {
                sql.append(campos.get(i));
                if (i < campos.size() - 1) sql.append(", ");
            }
            sql.append(" WHERE id_documento = ?");
            valores.add(id);

            Connection con = null;
            PreparedStatement ps = null;

            try {
                con = Conexion.getConnection();
                ps = con.prepareStatement(sql.toString());

                for (int i = 0; i < valores.size(); i++) {
                    ps.setObject(i + 1, valores.get(i));
                }

                int filas = ps.executeUpdate();

                if (filas > 0) {
                    out.print("{\"mensaje\":\"Documento actualizado correctamente.\",\"id\":" + id + "}");
                } else {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\":\"No se encontró documento con ID: " + id + "\"}");
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
    // DELETE — Eliminar documento por ID (?id=1)
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
                ps  = con.prepareStatement("DELETE FROM documentos WHERE id_documento = ?");
                ps.setInt(1, id);

                int filas = ps.executeUpdate();

                if (filas > 0) {
                    out.print("{\"mensaje\":\"Documento eliminado correctamente.\",\"id\":" + id + "}");
                } else {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\":\"No se encontró documento con ID: " + id + "\"}");
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
    private String documentoToJson(ResultSet rs) throws Exception {
        return "{" +
            "\"id\":"                + rs.getInt("id_documento")                   + "," +
            "\"codigo\":\""          + esc(rs.getString("codigo"))                  + "\"," +
            "\"nombreDocumento\":\"" + esc(rs.getString("nombre_documento"))        + "\"," +
            "\"tipoDocumento\":\""   + esc(rs.getString("tipo_documento"))          + "\"," +
            "\"dependencia\":\""     + esc(rs.getString("dependencia"))             + "\"," +
            "\"fechaDocumento\":\""  + (rs.getDate("fecha_documento") != null
                                        ? rs.getDate("fecha_documento").toString()
                                        : "")                                       + "\"," +
            "\"rutaArchivo\":\""     + esc(rs.getString("ruta_archivo"))            + "\"," +
            "\"qrCodigo\":\""        + esc(rs.getString("qr_codigo"))              + "\"," +
            "\"trd\":\""             + esc(rs.getString("trd"))                     + "\"," +
            "\"estado\":\""          + esc(rs.getString("estado"))                  + "\"," +
            "\"registradoPor\":\""   + esc(rs.getString("nombre_completo"))         + "\"," +
            "\"fechaRegistro\":\""   + (rs.getTimestamp("fecha_registro") != null
                                        ? rs.getTimestamp("fecha_registro").toString()
                                        : "")                                       + "\"" +
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

    /**
     * Extrae el valor de un campo JSON de forma simple.
     * Soporta: "campo": "valor" y "campo": 123
     * No usa librerías externas para no depender de org.json en la API.
     */
    private String extraerCampo(String json, String campo) {
        if (json == null || campo == null) return null;
        String clave = "\"" + campo + "\"";
        int idx = json.indexOf(clave);
        if (idx < 0) return null;

        int dospuntos = json.indexOf(":", idx + clave.length());
        if (dospuntos < 0) return null;

        // Saltar espacios después de los dos puntos
        int inicio = dospuntos + 1;
        while (inicio < json.length() && json.charAt(inicio) == ' ') inicio++;

        if (inicio >= json.length()) return null;

        if (json.charAt(inicio) == '"') {
            // Valor de tipo String — buscar la comilla de cierre
            int fin = json.indexOf('"', inicio + 1);
            if (fin < 0) return null;
            return json.substring(inicio + 1, fin);
        } else {
            // Valor numérico o booleano — buscar coma o llave de cierre
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