package com.sadu.controller;

import com.google.gson.Gson;
import com.sadu.config.Conexion;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Endpoint de Búsqueda Global Unificada (Omnibar / Ctrl + K).
 * Realiza búsquedas transversales e instantáneas en toda la base de datos de SADU:
 *   - Documentos (Código, Nombre, TRD)
 *   - Comunicaciones Oficiales (Radicado, Asunto, Municipio Remitente)
 *   - Microfilminas y Fotos (Texto OCR, Rollo, Frame)
 *   - Sedes y Depósitos Físicos (Nombre sede, Municipio, Bóveda)
 */
@WebServlet(name = "BusquedaGlobalServlet", urlPatterns = {"/api/busqueda-global"})
public class BusquedaGlobalServlet extends HttpServlet {

    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Access-Control-Allow-Origin", "*");
        PrintWriter out = response.getWriter();

        String q = request.getParameter("q");
        if (q == null || q.trim().isEmpty() || q.trim().length() < 2) {
            out.print("{\"documentos\":[],\"comunicaciones\":[],\"microfilmes\":[],\"sedes\":[]}");
            return;
        }

        String termino = "%" + q.trim() + "%";
        Map<String, Object> resultados = new HashMap<>();

        Connection con = null;
        try {
            con = Conexion.getConnection();

            // 1. Buscar en Documentos
            List<Map<String, String>> docs = new ArrayList<>();
            String sqlDocs = "SELECT id_documento, codigo, nombre_documento, tipo_documento, dependencia " +
                             "FROM documentos " +
                             "WHERE codigo LIKE ? OR nombre_documento LIKE ? OR trd LIKE ? OR dependencia LIKE ? " +
                             "LIMIT 5";
            try (PreparedStatement ps = con.prepareStatement(sqlDocs)) {
                ps.setString(1, termino);
                ps.setString(2, termino);
                ps.setString(3, termino);
                ps.setString(4, termino);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, String> item = new HashMap<>();
                        item.put("id", String.valueOf(rs.getInt("id_documento")));
                        item.put("titulo", rs.getString("codigo") + " - " + rs.getString("nombre_documento"));
                        item.put("subtitulo", rs.getString("tipo_documento") + " | " + rs.getString("dependencia"));
                        item.put("url", "documentosRegistrados?busCodigo=" + rs.getString("codigo"));
                        docs.add(item);
                    }
                }
            }
            resultados.put("documentos", docs);

            // 2. Buscar en Comunicaciones
            List<Map<String, String>> coms = new ArrayList<>();
            String sqlComs = "SELECT id_comunicacion, radicado, asunto, tipo, COALESCE(municipio_procedencia, 'Sede Interna') AS procedencia " +
                             "FROM comunicaciones " +
                             "WHERE radicado LIKE ? OR asunto LIKE ? OR municipio_procedencia LIKE ? " +
                             "LIMIT 5";
            try (PreparedStatement ps = con.prepareStatement(sqlComs)) {
                ps.setString(1, termino);
                ps.setString(2, termino);
                ps.setString(3, termino);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, String> item = new HashMap<>();
                        item.put("id", String.valueOf(rs.getInt("id_comunicacion")));
                        item.put("titulo", rs.getString("radicado") + " (" + rs.getString("tipo") + ")");
                        item.put("subtitulo", rs.getString("asunto") + " • Procedencia: " + rs.getString("procedencia"));
                        item.put("url", "comunicaciones?busAsunto=" + rs.getString("radicado"));
                        coms.add(item);
                    }
                }
            }
            resultados.put("comunicaciones", coms);

            // 3. Buscar en Microfilminas y Fotografías (Texto OCR y Rollos)
            List<Map<String, String>> micros = new ArrayList<>();
            String sqlMicros = "SELECT s.id_soporte, s.tipo_soporte, s.rollo_caja, s.numero_fotograma, " +
                               "       SUBSTRING(COALESCE(s.texto_ocr, 'Sin texto'), 1, 90) AS texto_corto, d.codigo " +
                               "FROM documento_soporte_especial s " +
                               "INNER JOIN documentos d ON s.id_documento = d.id_documento " +
                               "WHERE s.texto_ocr LIKE ? OR s.rollo_caja LIKE ? OR s.numero_fotograma LIKE ? OR s.tipo_soporte LIKE ? " +
                               "LIMIT 5";
            try (PreparedStatement ps = con.prepareStatement(sqlMicros)) {
                ps.setString(1, termino);
                ps.setString(2, termino);
                ps.setString(3, termino);
                ps.setString(4, termino);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, String> item = new HashMap<>();
                        item.put("id", String.valueOf(rs.getInt("id_soporte")));
                        item.put("titulo", rs.getString("tipo_soporte") + ": " + rs.getString("rollo_caja") + " (" + rs.getString("numero_fotograma") + ")");
                        item.put("subtitulo", "OCR: \"" + rs.getString("texto_corto") + "...\"");
                        item.put("url", "microfilminas_fotos.jsp");
                        micros.add(item);
                    }
                }
            }
            resultados.put("microfilmes", micros);

            // 4. Buscar en Sedes y Depósitos Físicos
            List<Map<String, String>> sedes = new ArrayList<>();
            String sqlSedes = "SELECT s.id_deposito, s.codigo_sede, s.nombre_sede, s.nombre_deposito, m.nombre AS mpio " +
                              "FROM sedes_depositos s " +
                              "INNER JOIN territorio_municipio m ON s.id_municipio = m.id " +
                              "WHERE s.nombre_sede LIKE ? OR s.nombre_deposito LIKE ? OR s.codigo_sede LIKE ? OR m.nombre LIKE ? " +
                              "LIMIT 4";
            try (PreparedStatement ps = con.prepareStatement(sqlSedes)) {
                ps.setString(1, termino);
                ps.setString(2, termino);
                ps.setString(3, termino);
                ps.setString(4, termino);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, String> item = new HashMap<>();
                        item.put("id", String.valueOf(rs.getInt("id_deposito")));
                        item.put("titulo", rs.getString("nombre_sede") + " (" + rs.getString("codigo_sede") + ")");
                        item.put("subtitulo", rs.getString("nombre_deposito") + " • Municipio: " + rs.getString("mpio"));
                        item.put("url", "sincronizacion_territorial.jsp");
                        sedes.add(item);
                    }
                }
            }
            resultados.put("sedes", sedes);

            out.print(gson.toJson(resultados));

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\":\"Error en búsqueda global: " + e.getMessage() + "\"}");
        } finally {
            try { if (con != null) con.close(); } catch (Exception ignored) {}
        }
    }
}

