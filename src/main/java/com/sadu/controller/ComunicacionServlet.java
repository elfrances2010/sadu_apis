package com.sadu.controller;

import com.sadu.dao.ComunicacionDAO;
import com.sadu.modelo.Comunicacion;
import com.sadu.util.Auditoria;
import com.sadu.util.VerificadorRol;
import java.io.IOException;
import java.sql.Date;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Servlet que gestiona todas las operaciones del módulo de Comunicaciones SADU.
 *
 * ACCESO: Administrador (rol 1) y Gestor de Archivo (rol 2).
 *
 * Métodos y acciones:
 *   GET  ?accion=listar   → Lista todas las comunicaciones
 *   GET  ?accion=buscar   → Filtra por asunto, tipo, estado y dependencia
 *   GET  (sin accion)     → Redirige a listar por defecto
 *   POST ?accion=radicar  → Registra una nueva comunicación
 *   POST ?accion=cambiarEstado → Actualiza el estado de una comunicación
 */
@WebServlet(name = "ComunicacionServlet", urlPatterns = {"/comunicaciones"})
public class ComunicacionServlet extends HttpServlet {

    /**
     * Método GET: verifica rol y decide qué acción ejecutar.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // -------------------------------------------------------
        // CONTROL DE ACCESO: Solo roles 1 y 2 pueden gestionar comunicaciones
        // -------------------------------------------------------
        if (!VerificadorRol.verificar(request, response, 1, 2)) return;

        String accion = request.getParameter("accion");
        if (accion == null) accion = "listar";

        switch (accion) {
            case "buscar":
                buscarComunicaciones(request, response);
                break;
            case "listar":
            default:
                listarComunicaciones(request, response);
                break;
        }
    }

    /**
     * Método POST: verifica rol y ejecuta la acción indicada.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // -------------------------------------------------------
        // CONTROL DE ACCESO: Solo roles 1 y 2
        // -------------------------------------------------------
        if (!VerificadorRol.verificar(request, response, 1, 2)) return;

        String accion = request.getParameter("accion");

        if ("radicar".equals(accion)) {
            radicarComunicacion(request, response);
        } else if ("cambiarEstado".equals(accion)) {
            cambiarEstado(request, response);
        } else {
            response.sendRedirect("comunicaciones?accion=listar");
        }
    }

    // ════════════════════════════════════════════════════════════
    // MÉTODOS PRIVADOS
    // ════════════════════════════════════════════════════════════

    /**
     * Lista todas las comunicaciones sin filtros.
     * Genera un número de radicado sugerido para el formulario.
     */
    private void listarComunicaciones(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        ComunicacionDAO dao = new ComunicacionDAO();

        // Obtener todas las comunicaciones ordenadas por fecha descendente
        List<Comunicacion> lista = dao.listarComunicaciones();
        request.setAttribute("listaComunicaciones", lista);

        // Radicado automático sugerido para el formulario (ej: RAD-2025-007)
        request.setAttribute("radicadoSugerido", dao.generarRadicado());
        request.setAttribute("busquedaActiva",   false);

        request.getRequestDispatcher("comunicaciones.jsp").forward(request, response);
    }

    /**
     * Busca comunicaciones aplicando los filtros del formulario.
     * Los campos vacíos se ignoran.
     */
    private void buscarComunicaciones(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Capturar filtros del formulario
        String asunto      = request.getParameter("busAsunto");
        String tipo        = request.getParameter("busTipo");
        String estado      = request.getParameter("busEstado");
        String dependencia = request.getParameter("busDependencia");

        ComunicacionDAO dao = new ComunicacionDAO();
        List<Comunicacion> lista = dao.buscarComunicaciones(asunto, tipo, estado, dependencia);

        request.setAttribute("listaComunicaciones", lista);
        request.setAttribute("radicadoSugerido",    dao.generarRadicado());
        request.setAttribute("busquedaActiva",      true);
        request.setAttribute("totalResultados",     lista.size());

        // Reenviar valores de búsqueda para conservar los campos llenos
        request.setAttribute("busAsunto",      asunto      != null ? asunto      : "");
        request.setAttribute("busTipo",        tipo        != null ? tipo        : "");
        request.setAttribute("busEstado",      estado      != null ? estado      : "");
        request.setAttribute("busDependencia", dependencia != null ? dependencia : "");

        request.getRequestDispatcher("comunicaciones.jsp").forward(request, response);
    }

    /**
     * Radica una nueva comunicación en la base de datos.
     * Valida campos obligatorios, verifica radicado duplicado
     * y registra el log de auditoría.
     */
    private void radicarComunicacion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession sesion = request.getSession(false);
        int idUsuario = (int) sesion.getAttribute("idUsuario");

        // -------------------------------------------------------
        // 1. Capturar datos del formulario
        // -------------------------------------------------------
        String radicado    = request.getParameter("radicado");
        String tipo        = request.getParameter("tipo");
        String dependencia = request.getParameter("dependencia");
        String asunto      = request.getParameter("asunto");
        String fechaStr    = request.getParameter("fechaComunicacion");
        String estado      = request.getParameter("estado");

        // -------------------------------------------------------
        // 2. Validar campos obligatorios
        // -------------------------------------------------------
        if (radicado    == null || radicado.trim().isEmpty()
                || tipo       == null || tipo.trim().isEmpty()
                || dependencia == null || dependencia.trim().isEmpty()
                || asunto     == null || asunto.trim().isEmpty()
                || fechaStr   == null || fechaStr.trim().isEmpty()) {

            request.setAttribute("error", "Todos los campos marcados con * son obligatorios.");
            listarComunicaciones(request, response);
            return;
        }

        // -------------------------------------------------------
        // 3. Verificar radicado duplicado
        // -------------------------------------------------------
        ComunicacionDAO dao = new ComunicacionDAO();
        if (dao.existeRadicado(radicado.trim())) {
            request.setAttribute("error",
                    "El radicado '" + radicado.trim() + "' ya está registrado. Usa otro número.");
            listarComunicaciones(request, response);
            return;
        }

        // -------------------------------------------------------
        // 4. Convertir fecha de String a java.sql.Date
        // -------------------------------------------------------
        Date fechaComunicacion;
        try {
            fechaComunicacion = Date.valueOf(fechaStr);
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", "El formato de la fecha no es válido.");
            listarComunicaciones(request, response);
            return;
        }

        // -------------------------------------------------------
        // 5. Construir objeto Comunicacion
        // -------------------------------------------------------
        Comunicacion com = new Comunicacion();
        com.setRadicado(radicado.trim().toUpperCase());
        com.setTipo(tipo.trim());
        com.setDependencia(dependencia.trim());
        com.setAsunto(asunto.trim());
        com.setFechaComunicacion(fechaComunicacion);
        com.setEstado(estado != null ? estado : "RECIBIDA");
        com.setIdUsuario(idUsuario);

        // -------------------------------------------------------
        // 6. Guardar en la base de datos
        // -------------------------------------------------------
        boolean guardado = dao.registrarComunicacion(com);

        if (guardado) {

            // -------------------------------------------------------
            // 7. Registrar log de auditoría automáticamente
            // -------------------------------------------------------
            Auditoria.registrar(
                idUsuario,
                "REGISTRO_COMUNICACION",
                "Comunicación radicada. Radicado: " + radicado.trim().toUpperCase()
                + " | Tipo: " + tipo.trim()
                + " | Asunto: " + asunto.trim()
            );

            response.sendRedirect("comunicaciones?accion=listar&exito=1");

        } else {
            request.setAttribute("error",
                    "No se pudo radicar la comunicación. Intenta de nuevo.");
            listarComunicaciones(request, response);
        }
    }

    /**
     * Actualiza el estado de una comunicación existente.
     * Permite pasar de RECIBIDA → EN_TRAMITE → RESPONDIDA.
     */
    private void cambiarEstado(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession sesion = request.getSession(false);
        int idUsuario = (int) sesion.getAttribute("idUsuario");

        // Capturar ID y nuevo estado del formulario
        String idStr      = request.getParameter("idComunicacion");
        String nuevoEstado = request.getParameter("nuevoEstado");

        if (idStr == null || nuevoEstado == null) {
            response.sendRedirect("comunicaciones?accion=listar");
            return;
        }

        try {
            int idComunicacion = Integer.parseInt(idStr);
            ComunicacionDAO dao = new ComunicacionDAO();
            boolean actualizado = dao.cambiarEstado(idComunicacion, nuevoEstado);

            if (actualizado) {
                // Registrar log de cambio de estado
                Auditoria.registrar(
                    idUsuario,
                    "CAMBIO_ESTADO_COMUNICACION",
                    "Estado cambiado a: " + nuevoEstado
                    + " | ID comunicación: " + idComunicacion
                );
            }

        } catch (NumberFormatException e) {
            // ID inválido — simplemente redirigir al listado
        }

        response.sendRedirect("comunicaciones?accion=listar");
    }
}