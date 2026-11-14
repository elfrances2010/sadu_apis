package com.sadu.controller;

import com.sadu.config.Conexion;
import com.sadu.util.VerificadorRol;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Genera y descarga el Formato Único de Inventario Documental (FUID)
 * conforme a los estándares de la Ley 594 de 2000 (Ley General de Archivos)
 * y el Archivo General de la Nación (AGN) de Colombia.
 *
 * Salida: Archivo CSV compatible directamente con Microsoft Excel (UTF-8 con BOM y separador ';')
 */
@WebServlet(name = "FuidExportServlet", urlPatterns = {"/exportar-fuid", "/FuidExportServlet"})
public class FuidExportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Control de acceso: solo usuarios con sesión activa
        if (!VerificadorRol.verificar(request, response, 1, 2)) return;

        String fechaHoy = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
        String nombreArchivo = "FUID_Inventario_Documental_SADU_" + fechaHoy + ".csv";

        response.setContentType("text/csv; charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + nombreArchivo + "\"");
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        PrintWriter out = response.getWriter();

        // 1. Escribir BOM UTF-8 (\uFEFF) para que Excel detecte tildes y caracteres especiales automáticamente
        out.write('\uFEFF');

        // 2. Encabezado Institucional del Formato Único de Inventario Documental (FUID)
        out.println("FORMATO ÚNICO DE INVENTARIO DOCUMENTAL - FUID (ARCHIVO GENERAL DE LA NACIÓN - AGN);;;;;;;;;;");
        out.println("SISTEMA DE ADMINISTRACIÓN Y ARCHIVO DIGITAL UNIVERSITARIO (SADU);;;;;;;;;;");
        out.println("ENTIDAD REMITENTE:;UNIVERSIDAD / ALCALDÍA MUNICIPAL;;;;;;;;;");
        out.println("UNIDAD ADMINISTRATIVA:;ARCHIVO CENTRAL E HISTÓRICO;;;;;;;;;");
        out.println("FECHA DE CORTE Y GENERACIÓN:;" + fechaHoy + ";;;;;;;;;");
        out.println(";;;;;;;;;;");

        // 3. Nombres de Columnas Oficiales del FUID
        out.println("No. ORDEN;CÓDIGO DEL EXPEDIENTE;SERIE, SUBSERIE O ASUNTO;DEPENDENCIA PRODUCTORA;FECHA EXTREMA DOCUMENTO;UNIDAD CONSERVACIÓN (CAJA/ROLLO);POSICIÓN (CARPETA/FRAME);TIPO DE SOPORTE;SEDE / DEPÓSITO FÍSICO;ESTADO / DISPOSICIÓN;NOTAS Y DIAGNÓSTICO DE CONSERVACIÓN");

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = Conexion.getConnection();

            // Consulta que combina documentos tradicionales con sus soportes especiales y sedes físicas
            String sql = "SELECT d.id_documento, d.codigo, d.nombre_documento, d.tipo_documento, " +
                         "       d.dependencia, d.fecha_documento, d.trd, d.estado, " +
                         "       COALESCE(s.rollo_caja, 'CAJA-GEN-01') AS caja_rollo, " +
                         "       COALESCE(s.numero_fotograma, 'CARPETA-01') AS carpeta_frame, " +
                         "       COALESCE(s.tipo_soporte, 'PAPEL / DIGITAL') AS soporte, " +
                         "       COALESCE(dep.nombre_sede, 'Sede Central Pasto') AS sede_custodia, " +
                         "       COALESCE(s.observaciones_conservacion, 'Documento en soporte estándar de archivo.') AS diagnostico " +
                         "FROM documentos d " +
                         "LEFT JOIN documento_soporte_especial s ON d.id_documento = s.id_documento " +
                         "LEFT JOIN sedes_depositos dep ON s.id_deposito = dep.id_deposito " +
                         "ORDER BY d.id_documento ASC";

            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();

            int orden = 1;
            while (rs.next()) {
                String codigo      = esc(rs.getString("codigo"));
                String nombre      = esc(rs.getString("nombre_documento"));
                String dependencia = esc(rs.getString("dependencia"));
                String fechaDoc    = rs.getDate("fecha_documento") != null ? rs.getDate("fecha_documento").toString() : "";
                String cajaRollo   = esc(rs.getString("caja_rollo"));
                String carpetaFrame= esc(rs.getString("carpeta_frame"));
                String soporte     = esc(rs.getString("soporte"));
                String sede        = esc(rs.getString("sede_custodia"));
                String estado      = esc(rs.getString("estado"));
                String diagnostico = esc(rs.getString("diagnostico"));

                // Escribir fila separada por punto y coma
                out.println(orden + ";" +
                            codigo + ";" +
                            nombre + ";" +
                            dependencia + ";" +
                            fechaDoc + ";" +
                            cajaRollo + ";" +
                            carpetaFrame + ";" +
                            soporte + ";" +
                            sede + ";" +
                            estado + ";" +
                            diagnostico);
                orden++;
            }

            out.println(";;;;;;;;;;");
            out.println("TOTAL REGISTROS INVENTARIADOS:;" + (orden - 1) + ";;;;;;;;;");
            out.println("ELABORADO POR:;GESTOR DE ARCHIVO - SADU;;ENTREGADO POR:;RESPONSABLE DE CUSTODIA;;RECIBIDO POR:;ARCHIVO CENTRAL;;");

        } catch (Exception e) {
            e.printStackTrace();
            out.println("ERROR AL CONSULTAR LA BASE DE DATOS: " + e.getMessage());
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignored) {}
            try { if (ps != null) ps.close(); } catch (Exception ignored) {}
            try { if (con != null) con.close(); } catch (Exception ignored) {}
        }
    }

    private String esc(String valor) {
        if (valor == null) return "";
        // Reemplazar punto y coma por coma para no romper las columnas del CSV
        String limpio = valor.replace(";", ", ").replace("\r", " ").replace("\n", " ").trim();
        // Si contiene comillas dobles, escaparlas
        if (limpio.contains("\"")) {
            limpio = limpio.replace("\"", "\"\"");
        }
        return "\"" + limpio + "\"";
    }
}

