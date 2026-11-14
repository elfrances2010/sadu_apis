package com.sadu.controller;

import com.sadu.config.Conexion;
import com.sadu.util.Auditoria;
import com.sadu.util.VerificadorRol;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "ConsultaServlet", urlPatterns = {"/consultas", "/ConsultaServlet"})
public class ConsultaServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!VerificadorRol.verificarSesion(request, response)) return;

        String tipo        = request.getParameter("tipo");
        String texto       = request.getParameter("texto");
        String dependencia = request.getParameter("dependencia");
        String fechaInicio = request.getParameter("fechaInicio");
        String fechaFin    = request.getParameter("fechaFin");
        String idUsuario   = request.getParameter("idUsuario");

        if (tipo == null || tipo.trim().isEmpty()) tipo = "documentos";

        try {
            List<java.util.Map<String, Object>> resultados = new ArrayList<>();

            switch (tipo) {
                case "documentos":
                    resultados = consultarDocumentos(texto, dependencia, fechaInicio, fechaFin, idUsuario);
                    break;
                case "usuarios":
                    resultados = consultarUsuarios(texto, idUsuario);
                    break;
                case "comunicaciones":
                    resultados = consultarComunicaciones(texto, dependencia, fechaInicio, fechaFin, idUsuario);
                    break;
            }

            request.setAttribute("tipo", tipo);
            request.setAttribute("texto", texto);
            request.setAttribute("dependencia", dependencia);
            request.setAttribute("fechaInicio", fechaInicio);
            request.setAttribute("fechaFin", fechaFin);
            request.setAttribute("idUsuario", idUsuario);
            request.setAttribute("resultados", resultados);
            request.setAttribute("totalResultados", resultados.size());

            request.setAttribute("listaUsuarios", obtenerUsuarios());
            request.setAttribute("listaDependencias", obtenerDependencias());

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error consultando los datos: " + e.getMessage());
        }

        request.getRequestDispatcher("/consultas.jsp").forward(request, response);
    }

    private List<java.util.Map<String, Object>> consultarDocumentos(
            String texto, String dependencia, String fechaInicio, String fechaFin, String idUsuario)
            throws Exception {

        StringBuilder sql = new StringBuilder(
            "SELECT d.id_documento, d.codigo, d.nombre, d.tipo, d.dependencia, " +
            "d.fecha_creacion, d.trd, d.estado, u.nombre_completo AS usuario " +
            "FROM documentos d " +
            "INNER JOIN usuarios u ON d.id_usuario = u.id_usuario WHERE 1=1");

        List<Object> params = new ArrayList<>();

        if (texto != null && !texto.trim().isEmpty()) {
            sql.append(" AND (d.nombre LIKE ? OR d.codigo LIKE ? OR d.asunto LIKE ?)");
            params.add("%" + texto.trim() + "%");
            params.add("%" + texto.trim() + "%");
            params.add("%" + texto.trim() + "%");
        }
        if (dependencia != null && !dependencia.trim().isEmpty()) {
            sql.append(" AND d.dependencia = ?");
            params.add(dependencia.trim());
        }
        if (fechaInicio != null && !fechaInicio.trim().isEmpty()) {
            sql.append(" AND d.fecha_creacion >= ?");
            params.add(fechaInicio.trim());
        }
        if (fechaFin != null && !fechaFin.trim().isEmpty()) {
            sql.append(" AND d.fecha_creacion <= ?");
            params.add(fechaFin.trim());
        }
        if (idUsuario != null && !idUsuario.trim().isEmpty()) {
            sql.append(" AND d.id_usuario = ?");
            params.add(Integer.parseInt(idUsuario.trim()));
        }
        sql.append(" ORDER BY d.fecha_creacion DESC");

        List<java.util.Map<String, Object>> lista = new ArrayList<>();

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> fila = new java.util.HashMap<>();
                    fila.put("id", rs.getInt("id_documento"));
                    fila.put("codigo", rs.getString("codigo"));
                    fila.put("nombre", rs.getString("nombre"));
                    fila.put("tipo", rs.getString("tipo"));
                    fila.put("dependencia", rs.getString("dependencia"));
                    fila.put("fecha", rs.getDate("fecha_creacion"));
                    fila.put("trd", rs.getString("trd"));
                    fila.put("estado", rs.getString("estado"));
                    fila.put("usuario", rs.getString("usuario"));
                    lista.add(fila);
                }
            }
        }
        return lista;
    }

    private List<java.util.Map<String, Object>> consultarUsuarios(String texto, String idUsuario)
            throws Exception {

        StringBuilder sql = new StringBuilder(
            "SELECT u.id_usuario, u.nombre_completo, u.correo, u.username, " +
            "u.estado, u.id_rol, u.requiere_cambio_clave, u.fecha_creacion, r.nombre AS rol " +
            "FROM usuarios u INNER JOIN roles r ON u.id_rol = r.id_rol WHERE 1=1");

        List<Object> params = new ArrayList<>();

        if (texto != null && !texto.trim().isEmpty()) {
            sql.append(" AND (u.nombre_completo LIKE ? OR u.correo LIKE ? OR u.username LIKE ?)");
            params.add("%" + texto.trim() + "%");
            params.add("%" + texto.trim() + "%");
            params.add("%" + texto.trim() + "%");
        }
        if (idUsuario != null && !idUsuario.trim().isEmpty()) {
            sql.append(" AND u.id_usuario = ?");
            params.add(Integer.parseInt(idUsuario.trim()));
        }
        sql.append(" ORDER BY u.nombre_completo ASC");

        List<java.util.Map<String, Object>> lista = new ArrayList<>();

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> fila = new java.util.HashMap<>();
                    fila.put("id", rs.getInt("id_usuario"));
                    fila.put("nombre", rs.getString("nombre_completo"));
                    fila.put("correo", rs.getString("correo"));
                    fila.put("username", rs.getString("username"));
                    fila.put("estado", rs.getString("estado"));
                    fila.put("rol", rs.getString("rol"));
                    fila.put("rolId", rs.getInt("id_rol"));
                    boolean req = false;
                    try { req = rs.getBoolean("requiere_cambio_clave"); } catch(Exception e){}
                    fila.put("requiereCambioClave", req);
                    fila.put("fecha", rs.getTimestamp("fecha_creacion"));
                    lista.add(fila);
                }
            }
        }
        return lista;
    }

    private List<java.util.Map<String, Object>> consultarComunicaciones(
            String texto, String dependencia, String fechaInicio, String fechaFin, String idUsuario)
            throws Exception {

        StringBuilder sql = new StringBuilder(
            "SELECT c.id_comunicacion, c.radicado, c.tipo, c.dependencia, c.asunto, " +
            "c.fecha_comunicacion, c.estado, u.nombre_completo AS usuario " +
            "FROM comunicaciones c " +
            "INNER JOIN usuarios u ON c.id_usuario = u.id_usuario WHERE 1=1");

        List<Object> params = new ArrayList<>();

        if (texto != null && !texto.trim().isEmpty()) {
            sql.append(" AND (c.asunto LIKE ? OR c.radicado LIKE ?)");
            params.add("%" + texto.trim() + "%");
            params.add("%" + texto.trim() + "%");
        }
        if (dependencia != null && !dependencia.trim().isEmpty()) {
            sql.append(" AND c.dependencia = ?");
            params.add(dependencia.trim());
        }
        if (fechaInicio != null && !fechaInicio.trim().isEmpty()) {
            sql.append(" AND c.fecha_comunicacion >= ?");
            params.add(fechaInicio.trim());
        }
        if (fechaFin != null && !fechaFin.trim().isEmpty()) {
            sql.append(" AND c.fecha_comunicacion <= ?");
            params.add(fechaFin.trim());
        }
        if (idUsuario != null && !idUsuario.trim().isEmpty()) {
            sql.append(" AND c.id_usuario = ?");
            params.add(Integer.parseInt(idUsuario.trim()));
        }
        sql.append(" ORDER BY c.fecha_comunicacion DESC");

        List<java.util.Map<String, Object>> lista = new ArrayList<>();

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> fila = new java.util.HashMap<>();
                    fila.put("id", rs.getInt("id_comunicacion"));
                    fila.put("radicado", rs.getString("radicado"));
                    fila.put("tipo", rs.getString("tipo"));
                    fila.put("dependencia", rs.getString("dependencia"));
                    fila.put("asunto", rs.getString("asunto"));
                    fila.put("fecha", rs.getDate("fecha_comunicacion"));
                    fila.put("estado", rs.getString("estado"));
                    fila.put("usuario", rs.getString("usuario"));
                    lista.add(fila);
                }
            }
        }
        return lista;
    }

    private List<java.util.Map<String, Object>> obtenerUsuarios() {
        List<java.util.Map<String, Object>> lista = new ArrayList<>();
        String sql = "SELECT id_usuario, nombre_completo FROM usuarios ORDER BY nombre_completo ASC";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                java.util.Map<String, Object> fila = new java.util.HashMap<>();
                fila.put("id", rs.getInt("id_usuario"));
                fila.put("nombre", rs.getString("nombre_completo"));
                lista.add(fila);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return lista;
    }

    private List<String> obtenerDependencias() {
        List<String> lista = new ArrayList<>();
        String sql = "SELECT DISTINCT dependencia FROM documentos " +
                     "UNION SELECT DISTINCT dependencia FROM comunicaciones " +
                     "ORDER BY dependencia ASC";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) lista.add(rs.getString("dependencia"));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return lista;
    }
}
