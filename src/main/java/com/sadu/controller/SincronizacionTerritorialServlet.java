package com.sadu.controller;

import com.sadu.config.Conexion;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * SADU - Sincronización de datos maestros territoriales.
 *
 * Descarga departamentos y municipios desde API Colombia y los guarda en las
 * tablas locales territorio_departamento y territorio_municipio.
 *
 * A partir de esta sincronización, los formularios de radicación y los
 * reportes leen SIEMPRE de la base local. Si API Colombia se cae, el archivo
 * sigue funcionando.
 *
 * Responde JSON para poder llamarlo por AJAX desde sincronizacion.jsp.
 *
 * NOTAS DE ADAPTACIÓN
 * -------------------
 * 1. Paquete: cambia com.sadu.servlets por el que uses realmente.
 * 2. Conexión: reemplaza obtenerConexion() por tu clase de conexión
 *    (ConexionBD.getConnection(), DataSource JNDI, etc.).
 * 3. Servlet API: si tu Tomcat es 10 o superior, cambia los imports
 *    javax.servlet.* por jakarta.servlet.*.
 * 4. Dependencia Maven necesaria (pom.xml):
 *
 *      <dependency>
 *          <groupId>com.google.code.gson</groupId>
 *          <artifactId>gson</artifactId>
 *          <version>2.10.1</version>
 *      </dependency>
 */
@WebServlet(name = "SincronizacionTerritorialServlet",
            urlPatterns = {"/SincronizacionTerritorialServlet"})
public class SincronizacionTerritorialServlet extends HttpServlet {

    private static final String API_BASE = "https://api-colombia.com/api/v1";
    private static final int TIMEOUT_MS = 20000;

    // --- Ajusta estos datos o usa tu clase de conexión existente ---------
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
    // ---------------------------------------------------------------------

    /** Contadores del proceso. */
    private static class Resumen {
        int deptoNuevos, deptoActualizados, muniNuevos, muniActualizados;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // GET devuelve el estado actual: cuántos registros hay y la última sincronización.
        response.setContentType("application/json;charset=UTF-8");
        try (Connection cn = obtenerConexion();
             PrintWriter out = response.getWriter()) {

            int totalDeptos = contar(cn, "territorio_departamento");
            int totalMunis  = contar(cn, "territorio_municipio");

            JsonObject json = new JsonObject();
            json.addProperty("ok", true);
            json.addProperty("departamentos", totalDeptos);
            json.addProperty("municipios", totalMunis);

            String sql = "SELECT fecha_inicio, estado, mensaje, duracion_ms "
                       + "FROM territorio_sincronizacion "
                       + "ORDER BY id DESC LIMIT 1";
            try (PreparedStatement ps = cn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    JsonObject ultima = new JsonObject();
                    ultima.addProperty("fecha", String.valueOf(rs.getTimestamp("fecha_inicio")));
                    ultima.addProperty("estado", rs.getString("estado"));
                    ultima.addProperty("mensaje", rs.getString("mensaje"));
                    ultima.addProperty("duracionMs", rs.getLong("duracion_ms"));
                    json.add("ultimaSincronizacion", ultima);
                }
            }
            out.print(json.toString());
        } catch (SQLException e) {
            responderError(response, "Error consultando la base de datos: " + e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");

        HttpSession session = request.getSession(false);
        String usuario = (session != null && session.getAttribute("usuario") != null)
                ? String.valueOf(session.getAttribute("usuario"))
                : "sistema";

        long inicio = System.currentTimeMillis();
        int idBitacora = -1;

        try (Connection cn = obtenerConexion()) {
            cn.setAutoCommit(false);
            idBitacora = abrirBitacora(cn, usuario);
            cn.commit();

            Resumen resumen = new Resumen();

            // 1. Departamentos
            JsonArray departamentos = leerArray(API_BASE + "/Department");
            for (JsonElement el : departamentos) {
                guardarDepartamento(cn, el.getAsJsonObject(), resumen);
            }
            cn.commit();

            // 2. Municipios de cada departamento
            for (JsonElement el : departamentos) {
                int deptoId = el.getAsJsonObject().get("id").getAsInt();
                try {
                    JsonArray ciudades = leerArray(API_BASE + "/Department/" + deptoId + "/cities");
                    for (JsonElement c : ciudades) {
                        guardarMunicipio(cn, c.getAsJsonObject(), deptoId, resumen);
                    }
                    cn.commit();
                } catch (IOException ex) {
                    // Un departamento que falle no debe abortar todo el proceso.
                    cn.rollback();
                    log("No se pudieron traer municipios del departamento " + deptoId, ex);
                }
            }

            long duracion = System.currentTimeMillis() - inicio;
            String mensaje = String.format(
                    "Departamentos: %d nuevos, %d actualizados. Municipios: %d nuevos, %d actualizados.",
                    resumen.deptoNuevos, resumen.deptoActualizados,
                    resumen.muniNuevos, resumen.muniActualizados);

            cerrarBitacora(cn, idBitacora, "EXITOSA", resumen, duracion, mensaje);
            cn.commit();

            JsonObject json = new JsonObject();
            json.addProperty("ok", true);
            json.addProperty("mensaje", mensaje);
            json.addProperty("duracionMs", duracion);
            json.addProperty("departamentosNuevos", resumen.deptoNuevos);
            json.addProperty("departamentosActualizados", resumen.deptoActualizados);
            json.addProperty("municipiosNuevos", resumen.muniNuevos);
            json.addProperty("municipiosActualizados", resumen.muniActualizados);
            response.getWriter().print(json.toString());

        } catch (Exception e) {
            log("Fallo la sincronizacion territorial", e);
            if (idBitacora > 0) {
                try (Connection cn2 = obtenerConexion()) {
                    cerrarBitacora(cn2, idBitacora, "FALLIDA", new Resumen(),
                            System.currentTimeMillis() - inicio,
                            recortar(e.getMessage(), 500));
                } catch (SQLException ignored) { }
            }
            responderError(response, "La sincronización falló: " + e.getMessage());
        }
    }

    // =====================================================================
    //  Persistencia
    // =====================================================================

    private void guardarDepartamento(Connection cn, JsonObject d, Resumen r) throws SQLException {
        String sql =
            "INSERT INTO territorio_departamento "
          + "(id, nombre, capital, poblacion, superficie, region, prefijo_telefonico, descripcion, activo) "
          + "VALUES (?,?,?,?,?,?,?,?,1) "
          + "ON DUPLICATE KEY UPDATE "
          + "  nombre = VALUES(nombre), capital = VALUES(capital), "
          + "  poblacion = VALUES(poblacion), superficie = VALUES(superficie), "
          + "  region = VALUES(region), prefijo_telefonico = VALUES(prefijo_telefonico), "
          + "  descripcion = VALUES(descripcion), activo = 1";

        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, d.get("id").getAsInt());
            ps.setString(2, texto(d, "name"));
            ps.setString(3, textoAnidado(d, "cityCapital", "name"));
            setLong(ps, 4, numeroLargo(d, "population"));
            setDouble(ps, 5, numeroDecimal(d, "surface"));
            ps.setString(6, textoAnidado(d, "region", "name"));
            ps.setString(7, texto(d, "phonePrefix"));
            ps.setString(8, texto(d, "description"));

            int filas = ps.executeUpdate();
            // MySQL devuelve 1 si insertó, 2 si actualizó, 0 si no hubo cambios.
            if (filas == 1) r.deptoNuevos++; else r.deptoActualizados++;
        }
    }

    private void guardarMunicipio(Connection cn, JsonObject m, int deptoId, Resumen r)
            throws SQLException {
        String sql =
            "INSERT INTO territorio_municipio "
          + "(id, departamento_id, nombre, poblacion, superficie, codigo_postal, descripcion, activo) "
          + "VALUES (?,?,?,?,?,?,?,1) "
          + "ON DUPLICATE KEY UPDATE "
          + "  departamento_id = VALUES(departamento_id), nombre = VALUES(nombre), "
          + "  poblacion = COALESCE(VALUES(poblacion), poblacion), "
          + "  superficie = COALESCE(VALUES(superficie), superficie), "
          + "  codigo_postal = COALESCE(VALUES(codigo_postal), codigo_postal), "
          + "  descripcion = COALESCE(NULLIF(VALUES(descripcion), ''), descripcion), "
          + "  activo = 1";

        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, m.get("id").getAsInt());
            ps.setInt(2, deptoId);
            ps.setString(3, texto(m, "name"));
            setLong(ps, 4, numeroLargo(m, "population"));
            setDouble(ps, 5, numeroDecimal(m, "surface"));
            ps.setString(6, texto(m, "postalCode"));
            ps.setString(7, texto(m, "description"));

            int filas = ps.executeUpdate();
            if (filas == 1) r.muniNuevos++; else r.muniActualizados++;
        }
    }

    private int abrirBitacora(Connection cn, String usuario) throws SQLException {
        String sql = "INSERT INTO territorio_sincronizacion (fecha_inicio, estado, usuario) "
                   + "VALUES (?, 'EN_PROCESO', ?)";
        try (PreparedStatement ps = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setTimestamp(1, new Timestamp(System.currentTimeMillis()));
            ps.setString(2, usuario);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                return rs.next() ? rs.getInt(1) : -1;
            }
        }
    }

    private void cerrarBitacora(Connection cn, int id, String estado, Resumen r,
                                long duracion, String mensaje) throws SQLException {
        String sql = "UPDATE territorio_sincronizacion SET "
                   + "fecha_fin = ?, estado = ?, departamentos_nuevos = ?, "
                   + "departamentos_actualizados = ?, municipios_nuevos = ?, "
                   + "municipios_actualizados = ?, duracion_ms = ?, mensaje = ? "
                   + "WHERE id = ?";
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setTimestamp(1, new Timestamp(System.currentTimeMillis()));
            ps.setString(2, estado);
            ps.setInt(3, r.deptoNuevos);
            ps.setInt(4, r.deptoActualizados);
            ps.setInt(5, r.muniNuevos);
            ps.setInt(6, r.muniActualizados);
            ps.setLong(7, duracion);
            ps.setString(8, recortar(mensaje, 500));
            ps.setInt(9, id);
            ps.executeUpdate();
        }
    }

    private int contar(Connection cn, String tabla) throws SQLException {
        try (Statement st = cn.createStatement();
             ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM " + tabla)) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    // =====================================================================
    //  Consumo de la API
    // =====================================================================

    private JsonArray leerArray(String urlStr) throws IOException {
        HttpURLConnection con = null;
        try {
            URL url = new URL(urlStr);
            con = (HttpURLConnection) url.openConnection();
            con.setRequestMethod("GET");
            con.setRequestProperty("Accept", "application/json");
            con.setConnectTimeout(TIMEOUT_MS);
            con.setReadTimeout(TIMEOUT_MS);

            int codigo = con.getResponseCode();
            if (codigo != 200) {
                throw new IOException("API Colombia respondió HTTP " + codigo + " en " + urlStr);
            }

            StringBuilder sb = new StringBuilder();
            try (BufferedReader br = new BufferedReader(
                    new InputStreamReader(con.getInputStream(), StandardCharsets.UTF_8))) {
                String linea;
                while ((linea = br.readLine()) != null) {
                    sb.append(linea);
                }
            }
            JsonElement raiz = JsonParser.parseString(sb.toString());
            if (!raiz.isJsonArray()) {
                throw new IOException("Se esperaba un arreglo JSON desde " + urlStr);
            }
            return raiz.getAsJsonArray();
        } finally {
            if (con != null) con.disconnect();
        }
    }

    // =====================================================================
    //  Utilidades de lectura defensiva del JSON
    //  (API Colombia deja muchos campos en null)
    // =====================================================================

    private String texto(JsonObject o, String campo) {
        JsonElement e = o.get(campo);
        if (e == null || e.isJsonNull()) return null;
        String v = e.getAsString().trim();
        return v.isEmpty() ? null : v;
    }

    private String textoAnidado(JsonObject o, String objeto, String campo) {
        JsonElement e = o.get(objeto);
        if (e == null || !e.isJsonObject()) return null;
        return texto(e.getAsJsonObject(), campo);
    }

    private Long numeroLargo(JsonObject o, String campo) {
        JsonElement e = o.get(campo);
        if (e == null || e.isJsonNull()) return null;
        try {
            long v = e.getAsLong();
            return v <= 0 ? null : v;
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private Double numeroDecimal(JsonObject o, String campo) {
        JsonElement e = o.get(campo);
        if (e == null || e.isJsonNull()) return null;
        try {
            double v = e.getAsDouble();
            return v <= 0 ? null : v;
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private void setLong(PreparedStatement ps, int idx, Long valor) throws SQLException {
        if (valor == null) ps.setNull(idx, java.sql.Types.BIGINT);
        else ps.setLong(idx, valor);
    }

    private void setDouble(PreparedStatement ps, int idx, Double valor) throws SQLException {
        if (valor == null) ps.setNull(idx, java.sql.Types.DECIMAL);
        else ps.setDouble(idx, valor);
    }

    private String recortar(String s, int max) {
        if (s == null) return null;
        return s.length() <= max ? s : s.substring(0, max);
    }

    private void responderError(HttpServletResponse response, String mensaje) throws IOException {
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        JsonObject json = new JsonObject();
        json.addProperty("ok", false);
        json.addProperty("mensaje", mensaje);
        response.getWriter().print(json.toString());
    }

    @Override
    public String getServletInfo() {
        return "SADU - Sincroniza departamentos y municipios desde API Colombia";
    }
}
