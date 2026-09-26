package com.sadu.controller;

import com.sadu.dao.LogAuditoriaDAO;
import com.sadu.modelo.LogAuditoria;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Servlet que gestiona el módulo de Auditoría del sistema SADU.
 *
 * Solo el Administrador (rol 1) puede acceder a este módulo.
 *
 * Métodos y acciones:
 *   GET  ?accion=listar  → Lista todos los logs y muestra auditoria.jsp
 *   GET  ?accion=buscar  → Filtra logs por acción, usuario y fechas
 *   GET  (sin accion)    → Redirige a listar por defecto
 *   POST ?accion=buscar  → También acepta búsqueda por POST
 */
@WebServlet(name = "AuditoriaServlet", urlPatterns = {"/auditoria"})
public class AuditoriaServlet extends HttpServlet {

    /**
     * Método GET: lista o busca logs según el parámetro accion.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Validar sesión activa
        HttpSession sesion = request.getSession(false);
        if (sesion == null || sesion.getAttribute("nombreUsuario") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // 2. Verificar que el usuario sea Administrador (rol 1)
        //    Solo el administrador puede ver los logs de auditoría
        int rolUsuario = (int) sesion.getAttribute("rolUsuario");
        if (rolUsuario != 1) {
            request.setAttribute("error",
                    "Acceso denegado. Solo el Administrador puede ver los logs de auditoría.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }

        // 3. Determinar acción
        String accion = request.getParameter("accion");
        if (accion == null) accion = "listar";

        switch (accion) {
            case "buscar":
                buscarLogs(request, response);
                break;
            case "listar":
            default:
                listarLogs(request, response);
                break;
        }
    }

    /**
     * Método POST: acepta búsqueda enviada desde formulario con method="post".
     * Delega al método GET para no duplicar lógica.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    // ════════════════════════════════════════════════════════════
    // MÉTODOS PRIVADOS
    // ════════════════════════════════════════════════════════════

    /**
     * Lista todos los logs de auditoría sin filtros.
     * También carga estadísticas generales para el panel superior.
     */
    private void listarLogs(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        LogAuditoriaDAO dao = new LogAuditoriaDAO();

        // Cargar todos los logs (últimos 500)
        List<LogAuditoria> listaLogs = dao.listarLogs();
        request.setAttribute("listaLogs", listaLogs);

        // Cargar estadísticas para las tarjetas del panel superior
        request.setAttribute("totalLogs",         dao.contarLogs());
        request.setAttribute("logsHoy",           dao.contarLogsHoy());
        request.setAttribute("usuariosActivos",   dao.contarUsuariosActivos());
        request.setAttribute("busquedaActiva",    false);

        request.getRequestDispatcher("auditoria.jsp").forward(request, response);
    }

    /**
     * Busca logs aplicando los filtros del formulario de búsqueda.
     */
    private void buscarLogs(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Capturar filtros del formulario
        String accionFiltro  = request.getParameter("busAccion");
        String idUsuarioStr  = request.getParameter("busIdUsuario");
        String fechaDesde    = request.getParameter("busFechaDesde");
        String fechaHasta    = request.getParameter("busFechaHasta");

        // Convertir idUsuario a entero (0 = todos)
        int idUsuario = 0;
        try {
            if (idUsuarioStr != null && !idUsuarioStr.trim().isEmpty()) {
                idUsuario = Integer.parseInt(idUsuarioStr.trim());
            }
        } catch (NumberFormatException e) {
            idUsuario = 0;
        }

        LogAuditoriaDAO dao = new LogAuditoriaDAO();

        // Ejecutar búsqueda con filtros
        List<LogAuditoria> listaLogs = dao.buscarLogs(
                accionFiltro, idUsuario, fechaDesde, fechaHasta);

        request.setAttribute("listaLogs",       listaLogs);
        request.setAttribute("totalLogs",       dao.contarLogs());
        request.setAttribute("logsHoy",         dao.contarLogsHoy());
        request.setAttribute("usuariosActivos", dao.contarUsuariosActivos());
        request.setAttribute("busquedaActiva",  true);
        request.setAttribute("totalResultados", listaLogs.size());

        // Reenviar valores de búsqueda para no limpiar los campos
        request.setAttribute("busAccion",      accionFiltro  != null ? accionFiltro  : "");
        request.setAttribute("busIdUsuario",   idUsuarioStr  != null ? idUsuarioStr  : "");
        request.setAttribute("busFechaDesde",  fechaDesde    != null ? fechaDesde    : "");
        request.setAttribute("busFechaHasta",  fechaHasta    != null ? fechaHasta    : "");

        request.getRequestDispatcher("auditoria.jsp").forward(request, response);
    }
}