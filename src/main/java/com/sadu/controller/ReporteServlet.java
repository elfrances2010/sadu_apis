package com.sadu.controller;

import com.sadu.dao.ReporteDAO;
import com.sadu.util.VerificadorRol;
import java.io.IOException;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet que gestiona el módulo de Reportes del sistema SADU.
 *
 * ACCESO: Administrador (rol 1) y Gestor de Archivo (rol 2).
 *
 * Prepara los datos de todos los gráficos en formato JSON simple
 * (arreglos de etiquetas y valores) para ser consumidos por Chart.js
 * directamente en el JSP.
 *
 * Métodos:
 *   GET  → carga todos los datos y muestra reportes.jsp
 *   POST → delega al GET (cumple requisito de ambos métodos HTTP)
 */
@WebServlet(name = "ReporteServlet", urlPatterns = {"/reportes"})
public class ReporteServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // -------------------------------------------------------
        // CONTROL DE ACCESO: roles 1 (Admin) y 2 (Gestor)
        // -------------------------------------------------------
        if (!VerificadorRol.verificar(request, response, 1, 2)) return;

        ReporteDAO dao = new ReporteDAO();

        // -------------------------------------------------------
        // 1. Estadísticas generales para las tarjetas resumen
        // -------------------------------------------------------
        Map<String, Integer> stats = dao.estadisticasGenerales();
        request.setAttribute("totalDocumentos",     stats.get("totalDocumentos"));
        request.setAttribute("totalComunicaciones", stats.get("totalComunicaciones"));
        request.setAttribute("totalUsuarios",       stats.get("totalUsuarios"));
        request.setAttribute("totalMensajes",       stats.get("totalMensajes"));

        // -------------------------------------------------------
        // 2. Documentos por estado (gráfico de pastel)
        // -------------------------------------------------------
        Map<String, Integer> docPorEstado = dao.documentosPorEstado();
        request.setAttribute("docEstadoLabels", construirArrayJson(docPorEstado.keySet()));
        request.setAttribute("docEstadoValues", construirArrayNumerico(docPorEstado.values()));

        // -------------------------------------------------------
        // 3. Documentos por tipo (gráfico de barras)
        // -------------------------------------------------------
        Map<String, Integer> docPorTipo = dao.documentosPorTipo();
        request.setAttribute("docTipoLabels", construirArrayJson(docPorTipo.keySet()));
        request.setAttribute("docTipoValues", construirArrayNumerico(docPorTipo.values()));

        // -------------------------------------------------------
        // 4. Documentos por dependencia (gráfico de barras horizontales)
        // -------------------------------------------------------
        Map<String, Integer> docPorDependencia = dao.documentosPorDependencia();
        request.setAttribute("docDependenciaLabels", construirArrayJson(docPorDependencia.keySet()));
        request.setAttribute("docDependenciaValues", construirArrayNumerico(docPorDependencia.values()));

        // -------------------------------------------------------
        // 5. Documentos por mes (gráfico de línea — tendencia anual)
        // -------------------------------------------------------
        Map<String, Integer> docPorMes = dao.documentosPorMes();
        request.setAttribute("docMesLabels", construirArrayJson(docPorMes.keySet()));
        request.setAttribute("docMesValues", construirArrayNumerico(docPorMes.values()));

        // -------------------------------------------------------
        // 6. Comunicaciones por estado (gráfico de dona)
        // -------------------------------------------------------
        Map<String, Integer> comPorEstado = dao.comunicacionesPorEstado();
        request.setAttribute("comEstadoLabels", construirArrayJson(comPorEstado.keySet()));
        request.setAttribute("comEstadoValues", construirArrayNumerico(comPorEstado.values()));

        // -------------------------------------------------------
        // 7. Comunicaciones por tipo (gráfico de pastel)
        // -------------------------------------------------------
        Map<String, Integer> comPorTipo = dao.comunicacionesPorTipo();
        request.setAttribute("comTipoLabels", construirArrayJson(comPorTipo.keySet()));
        request.setAttribute("comTipoValues", construirArrayNumerico(comPorTipo.values()));

        // -------------------------------------------------------
        // 8. Usuarios por rol (gráfico de pastel)
        // -------------------------------------------------------
        Map<String, Integer> usuPorRol = dao.usuariosPorRol();
        request.setAttribute("usuRolLabels", construirArrayJson(usuPorRol.keySet()));
        request.setAttribute("usuRolValues", construirArrayNumerico(usuPorRol.values()));

        // -------------------------------------------------------
        // 9. Usuarios por estado (gráfico de dona)
        // -------------------------------------------------------
        Map<String, Integer> usuPorEstado = dao.usuariosPorEstado();
        request.setAttribute("usuEstadoLabels", construirArrayJson(usuPorEstado.keySet()));
        request.setAttribute("usuEstadoValues", construirArrayNumerico(usuPorEstado.values()));

        // -------------------------------------------------------
        // 10. Auditoría por acción (gráfico de barras horizontales)
        // -------------------------------------------------------
        Map<String, Integer> audPorAccion = dao.auditoriaPorAccion();
        request.setAttribute("audAccionLabels", construirArrayJson(audPorAccion.keySet()));
        request.setAttribute("audAccionValues", construirArrayNumerico(audPorAccion.values()));

        request.getRequestDispatcher("reportes.jsp").forward(request, response);
    }

    /**
     * Método POST: delega al método GET.
     * Cumple el requisito de soportar ambos métodos HTTP.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    // ════════════════════════════════════════════════════════════
    // MÉTODOS PRIVADOS — construcción de arrays JSON para Chart.js
    // ════════════════════════════════════════════════════════════

    /**
     * Convierte una colección de Strings en un array JSON de texto.
     * Ejemplo: ["REGISTRADO", "EN_PROCESO"] → '["REGISTRADO","EN_PROCESO"]'
     *
     * Escapa comillas dobles para evitar romper el JSON si una categoría
     * contiene caracteres especiales.
     *
     * @param valores Colección de etiquetas (nombres de categorías)
     * @return String con formato de array JSON listo para insertar en JS
     */
    private String construirArrayJson(Iterable<String> valores) {
        StringBuilder sb = new StringBuilder("[");
        boolean primero = true;

        for (String valor : valores) {
            if (!primero) sb.append(",");
            primero = false;

            // Escapar comillas dobles dentro del valor
            String valorEscapado = valor.replace("\"", "\\\"");
            sb.append("\"").append(valorEscapado).append("\"");
        }

        sb.append("]");
        return sb.toString();
    }

    /**
     * Convierte una colección de Integer en un array JSON numérico.
     * Ejemplo: [5, 3, 8] → '[5,3,8]'
     *
     * @param valores Colección de valores numéricos
     * @return String con formato de array JSON numérico
     */
    private String construirArrayNumerico(Iterable<Integer> valores) {
        StringBuilder sb = new StringBuilder("[");
        boolean primero = true;

        for (Integer valor : valores) {
            if (!primero) sb.append(",");
            primero = false;
            sb.append(valor);
        }

        sb.append("]");
        return sb.toString();
    }
}