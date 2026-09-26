package com.sadu.controller;

import com.sadu.dao.DocumentoDAO;
import com.sadu.modelo.Documento;
import com.sadu.util.Auditoria;   // ← Importación para registrar logs de auditoría
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
 * Servlet que gestiona todas las operaciones del módulo de Documentos SADU.
 *
 * Métodos y acciones:
 *   GET  ?accion=listar  → Lista todos los documentos y muestra documentos.jsp
 *   GET  ?accion=buscar  → Filtra documentos por criterios y muestra resultados
 *   GET  (sin accion)    → Redirige a listar por defecto
 *   POST ?accion=registrar → Registra un nuevo documento en la base de datos
 *
 * Cada operación registra automáticamente un log en logs_auditoria.
 */
@WebServlet(name = "DocumentoServlet", urlPatterns = {"/documentos"})
public class DocumentoServlet extends HttpServlet {

    /**
     * Método GET: decide qué acción ejecutar según el parámetro "accion".
     * Si no hay parámetro, lista todos los documentos por defecto.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // -------------------------------------------------------
        // 1. Validar sesión activa — si no hay sesión, ir al login
        // -------------------------------------------------------
        HttpSession sesion = request.getSession(false);
        if (sesion == null || sesion.getAttribute("nombreUsuario") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // -------------------------------------------------------
        // 2. Leer el parámetro "accion" para decidir qué hacer
        // -------------------------------------------------------
        String accion = request.getParameter("accion");
        if (accion == null) accion = "listar";

        switch (accion) {

            case "buscar":
                // Buscar documentos con filtros del formulario de búsqueda
                buscarDocumentos(request, response);
                break;

            case "listar":
            default:
                // Listar todos los documentos sin filtros
                listarDocumentos(request, response);
                break;
        }
    }

    /**
     * Método POST: recibe los datos del formulario y registra el documento.
     * Después de guardar, registra el log y redirige al listado actualizado.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // -------------------------------------------------------
        // 1. Validar sesión activa
        // -------------------------------------------------------
        HttpSession sesion = request.getSession(false);
        if (sesion == null || sesion.getAttribute("nombreUsuario") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // -------------------------------------------------------
        // 2. Leer acción del formulario
        // -------------------------------------------------------
        String accion = request.getParameter("accion");
        if ("registrar".equals(accion)) {
            registrarDocumento(request, response, sesion);
        } else {
            // Si no hay acción POST reconocida, redirigir al listado
            response.sendRedirect("documentos?accion=listar");
        }
    }

    // ════════════════════════════════════════════════════════════
    // MÉTODOS PRIVADOS — uno por cada operación del módulo
    // ════════════════════════════════════════════════════════════

    /**
     * Lista todos los documentos sin filtros y los envía al JSP.
     * También genera un código sugerido para el formulario de registro.
     */
    private void listarDocumentos(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        DocumentoDAO dao = new DocumentoDAO();

        // Obtener todos los documentos ordenados por fecha descendente
        List<Documento> lista = dao.listarDocumentos();
        request.setAttribute("listaDocumentos", lista);

        // Código automático sugerido para el formulario (ej: DOC-2025-007)
        request.setAttribute("codigoSugerido", dao.generarCodigo());

        // Indicar al JSP que no hay búsqueda activa
        request.setAttribute("busquedaActiva", false);

        request.getRequestDispatcher("documentos.jsp").forward(request, response);
    }

    /**
     * Busca documentos aplicando los filtros del formulario de búsqueda.
     * Los campos vacíos se ignoran — solo filtra por los que tengan valor.
     */
    private void buscarDocumentos(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // -------------------------------------------------------
        // Capturar filtros del formulario (pueden venir vacíos)
        // -------------------------------------------------------
        String nombre      = request.getParameter("busNombre");
        String tipo        = request.getParameter("busTipo");
        String dependencia = request.getParameter("busDependencia");
        String estado      = request.getParameter("busEstado");

        DocumentoDAO dao = new DocumentoDAO();

        // Ejecutar búsqueda con los filtros recibidos
        List<Documento> lista = dao.buscarDocumentos(nombre, tipo, dependencia, estado);
        request.setAttribute("listaDocumentos",  lista);
        request.setAttribute("codigoSugerido",   dao.generarCodigo());
        request.setAttribute("busquedaActiva",   true);
        request.setAttribute("totalResultados",  lista.size());

        // Reenviar los valores de búsqueda al JSP para no limpiar los campos
        request.setAttribute("busNombre",      nombre      != null ? nombre      : "");
        request.setAttribute("busTipo",        tipo        != null ? tipo        : "");
        request.setAttribute("busDependencia", dependencia != null ? dependencia : "");
        request.setAttribute("busEstado",      estado      != null ? estado      : "");

        request.getRequestDispatcher("documentos.jsp").forward(request, response);
    }

    /**
     * Registra un nuevo documento en la base de datos.
     * Valida los campos obligatorios antes de guardar.
     * Si todo es correcto, registra el log y redirige al listado.
     */
    private void registrarDocumento(
            HttpServletRequest request,
            HttpServletResponse response,
            HttpSession sesion)
            throws ServletException, IOException {

        // -------------------------------------------------------
        // 1. Capturar datos del formulario de registro
        // -------------------------------------------------------
        String codigo      = request.getParameter("codigo");
        String nombreDoc   = request.getParameter("nombreDocumento");
        String tipoDoc     = request.getParameter("tipoDocumento");
        String dependencia = request.getParameter("dependencia");
        String fechaStr    = request.getParameter("fechaDocumento");
        String rutaArchivo = request.getParameter("rutaArchivo");
        String trd         = request.getParameter("trd");
        String estado      = request.getParameter("estado");

        // Obtener el ID del usuario desde la sesión activa
        int idUsuario = (int) sesion.getAttribute("idUsuario");

        // -------------------------------------------------------
        // 2. Validar campos obligatorios
        // -------------------------------------------------------
        if (codigo == null || codigo.trim().isEmpty()
                || nombreDoc   == null || nombreDoc.trim().isEmpty()
                || tipoDoc     == null || tipoDoc.trim().isEmpty()
                || dependencia == null || dependencia.trim().isEmpty()
                || fechaStr    == null || fechaStr.trim().isEmpty()) {

            request.setAttribute("error", "Todos los campos marcados con * son obligatorios.");
            listarDocumentos(request, response);
            return;
        }

        // -------------------------------------------------------
        // 3. Verificar que el código no esté duplicado en la BD
        // -------------------------------------------------------
        DocumentoDAO dao = new DocumentoDAO();
        if (dao.existeCodigo(codigo.trim())) {
            request.setAttribute("error",
                    "El código '" + codigo.trim() + "' ya está registrado. Usa otro código.");
            listarDocumentos(request, response);
            return;
        }

        // -------------------------------------------------------
        // 4. Convertir la fecha de String a java.sql.Date
        //    El campo date del HTML envía formato YYYY-MM-DD
        // -------------------------------------------------------
        Date fechaDocumento;
        try {
            fechaDocumento = Date.valueOf(fechaStr);
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", "El formato de la fecha no es válido.");
            listarDocumentos(request, response);
            return;
        }

        // -------------------------------------------------------
        // 5. Generar código QR automáticamente con el código del documento
        // -------------------------------------------------------
        String qrCodigo = "QR-" + codigo.trim().toUpperCase();

        // -------------------------------------------------------
        // 6. Construir el objeto Documento con todos los datos
        // -------------------------------------------------------
        Documento doc = new Documento();
        doc.setCodigo(codigo.trim().toUpperCase());
        doc.setNombreDocumento(nombreDoc.trim());
        doc.setTipoDocumento(tipoDoc.trim());
        doc.setDependencia(dependencia.trim());
        doc.setFechaDocumento(fechaDocumento);
        doc.setRutaArchivo(rutaArchivo != null ? rutaArchivo.trim() : "");
        doc.setQrCodigo(qrCodigo);
        doc.setTrd(trd != null ? trd.trim() : "");
        doc.setEstado(estado != null ? estado : "REGISTRADO");
        doc.setIdUsuario(idUsuario);

        // -------------------------------------------------------
        // 7. Guardar el documento en la base de datos
        // -------------------------------------------------------
        boolean guardado = dao.registrarDocumento(doc);

        if (guardado) {

            // -------------------------------------------------------
            // 8. Registro exitoso — guardar log de auditoría automáticamente
            //    Este log aparecerá en el módulo de Auditoría del Admin
            // -------------------------------------------------------
            Auditoria.registrar(
                idUsuario,                          // ID del usuario que registró
                "REGISTRO_DOCUMENTO",               // Nombre de la acción
                "Documento registrado. Código: " + codigo.trim().toUpperCase()
                + " | Tipo: " + tipoDoc.trim()
                + " | Dependencia: " + dependencia.trim()
            );

            // Redirigir al listado con parámetro de éxito visible en URL
            response.sendRedirect("documentos?accion=listar&exito=1");

        } else {
            // -------------------------------------------------------
            // 9. Error al guardar — mostrar mensaje en el formulario
            // -------------------------------------------------------
            request.setAttribute("error",
                    "No se pudo registrar el documento. Intenta de nuevo.");
            listarDocumentos(request, response);
        }
    }
}