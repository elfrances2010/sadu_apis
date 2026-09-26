package com.sadu.controller;

import com.sadu.config.Conexion;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * SADU - Consulta de datos maestros territoriales desde la base LOCAL.
 *
 * Este es el servlet que deben usar los formularios de radicación y los
 * reportes. Nunca sale a Internet: lee las tablas que llenó
 * SincronizacionTerritorialServlet.
 *
 * Uso desde el navegador:
 *   GET /TerritorioLocalServlet?accion=departamentos
 *   GET /TerritorioLocalServlet?accion=municipios&departamentoId=20
 *   GET /TerritorioLocalServlet?accion=detalleMunicipio&id=1234
 *   GET /TerritorioLocalServlet?accion=topPoblacion&departamentoId=20&limite=10
 *
 * Adapta el paquete, la conexión y los imports javax/jakarta igual que en
 * SincronizacionTerritorialServlet.
 */
@WebServlet(name = "TerritorioLocalServlet", urlPatterns = {"/TerritorioLocalServlet"})
public class TerritorioLocalServlet extends HttpServlet {

    private static final String DB_URL =
            "jdbc:mysql://localhost:3306/sadu?useSSL=false&serverTimezone=UTC&characterEncoding=UTF-8";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "";

    private Connection obtenerConexion() throws SQLException {
        try {
            return Conexion.getConnection();
        } catch (SQLException e) {
            throw e;
        } catch (Exception e) {
            throw new SQLException("Error al obtener conexión con la base de datos: " + e.getMessage(), e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Cache-Control", "public, max-age=3600"); // los datos casi no cambian

        String accion = request.getParameter("accion");
        if (accion == null || accion.isEmpty()) accion = "departamentos";

        try (Connection cn = obtenerConexion();
             PrintWriter out = response.getWriter()) {

            switch (accion) {
                case "departamentos":
                    out.print(departamentos(cn).toString());
                    break;
                case "municipios":
                    out.print(municipios(cn, entero(request, "departamentoId", 0)).toString());
                    break;
                case "detalleMunicipio":
                    out.print(detalleMunicipio(cn, entero(request, "id", 0)).toString());
                    break;
                case "topPoblacion":
                    out.print(topPoblacion(cn,
                            entero(request, "departamentoId", 0),
                            entero(request, "limite", 10)).toString());
                    break;
                default:
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    JsonObject error = new JsonObject();
                    error.addProperty("ok", false);
                    error.addProperty("mensaje", "Acción no reconocida: " + accion);
                    out.print(error.toString());
            }
        } catch (SQLException e) {
            log("Error consultando datos territoriales", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            JsonObject error = new JsonObject();
            error.addProperty("ok", false);
            error.addProperty("mensaje", "Error de base de datos: " + e.getMessage());
            response.getWriter().print(error.toString());
        }
    }

    // ---------------------------------------------------------------------

    private JsonArray departamentos(Connection cn) throws SQLException {
        String sql = "SELECT id, nombre, capital, poblacion, superficie, region, prefijo_telefonico "
                   + "FROM territorio_departamento WHERE activo = 1 ORDER BY nombre";
        JsonArray arr = new JsonArray();
        try (PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                JsonObject o = new JsonObject();
                o.addProperty("id", rs.getInt("id"));
                o.addProperty("nombre", rs.getString("nombre"));
                o.addProperty("capital", rs.getString("capital"));
                o.addProperty("poblacion", (Number) rs.getObject("poblacion"));
                o.addProperty("superficie", (Number) rs.getObject("superficie"));
                o.addProperty("region", rs.getString("region"));
                o.addProperty("prefijoTelefonico", rs.getString("prefijo_telefonico"));
                arr.add(o);
            }
        }
        return arr;
    }

    private JsonArray municipios(Connection cn, int departamentoId) throws SQLException {
        String sql = "SELECT id, nombre, poblacion, superficie, codigo_postal "
                   + "FROM territorio_municipio "
                   + "WHERE activo = 1 AND (? = 0 OR departamento_id = ?) "
                   + "ORDER BY nombre";
        JsonArray arr = new JsonArray();
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, departamentoId);
            ps.setInt(2, departamentoId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    JsonObject o = new JsonObject();
                    o.addProperty("id", rs.getInt("id"));
                    o.addProperty("nombre", rs.getString("nombre"));
                    o.addProperty("poblacion", (Number) rs.getObject("poblacion"));
                    o.addProperty("superficie", (Number) rs.getObject("superficie"));
                    o.addProperty("codigoPostal", rs.getString("codigo_postal"));
                    arr.add(o);
                }
            }
        }
        return arr;
    }

    private JsonObject detalleMunicipio(Connection cn, int id) throws SQLException {
        String sql = "SELECT m.id, m.nombre, m.poblacion, m.superficie, m.codigo_postal, "
                   + "       m.descripcion, d.id AS depto_id, d.nombre AS depto_nombre, "
                   + "       d.capital AS depto_capital, d.region AS depto_region "
                   + "FROM territorio_municipio m "
                   + "JOIN territorio_departamento d ON d.id = m.departamento_id "
                   + "WHERE m.id = ?";
        JsonObject o = new JsonObject();
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    o.addProperty("ok", false);
                    o.addProperty("mensaje", "Municipio no encontrado");
                    return o;
                }
                o.addProperty("ok", true);
                o.addProperty("id", rs.getInt("id"));
                o.addProperty("nombre", rs.getString("nombre"));
                o.addProperty("descripcion", rs.getString("descripcion"));
                o.addProperty("codigoPostal", rs.getString("codigo_postal"));

                Object pobObj = rs.getObject("poblacion");
                Object supObj = rs.getObject("superficie");
                o.addProperty("poblacion", (Number) pobObj);
                o.addProperty("superficie", (Number) supObj);

                // Densidad: solo se calcula si hay ambos datos.
                if (pobObj != null && supObj != null && rs.getDouble("superficie") > 0) {
                    double densidad = rs.getLong("poblacion") / rs.getDouble("superficie");
                    o.addProperty("densidad", Math.round(densidad * 100.0) / 100.0);
                }

                JsonObject depto = new JsonObject();
                depto.addProperty("id", rs.getInt("depto_id"));
                depto.addProperty("nombre", rs.getString("depto_nombre"));
                depto.addProperty("capital", rs.getString("depto_capital"));
                depto.addProperty("region", rs.getString("depto_region"));
                o.add("departamento", depto);
            }
        }
        return o;
    }

    /** Datos listos para alimentar una gráfica de Chart.js. */
    private JsonObject topPoblacion(Connection cn, int departamentoId, int limite)
            throws SQLException {
        if (limite <= 0 || limite > 50) limite = 10;

        String sql = "SELECT nombre, poblacion FROM territorio_municipio "
                   + "WHERE departamento_id = ? AND poblacion IS NOT NULL "
                   + "ORDER BY poblacion DESC LIMIT ?";
        JsonArray etiquetas = new JsonArray();
        JsonArray valores = new JsonArray();
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, departamentoId);
            ps.setInt(2, limite);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    etiquetas.add(rs.getString("nombre"));
                    valores.add(rs.getLong("poblacion"));
                }
            }
        }
        JsonObject o = new JsonObject();
        o.addProperty("ok", true);
        o.add("labels", etiquetas);
        o.add("data", valores);
        return o;
    }

    private int entero(HttpServletRequest request, String nombre, int porDefecto) {
        String v = request.getParameter(nombre);
        if (v == null || v.trim().isEmpty()) return porDefecto;
        try {
            return Integer.parseInt(v.trim());
        } catch (NumberFormatException e) {
            return porDefecto;
        }
    }

    @Override
    public String getServletInfo() {
        return "SADU - Consulta local de departamentos y municipios";
    }
}
