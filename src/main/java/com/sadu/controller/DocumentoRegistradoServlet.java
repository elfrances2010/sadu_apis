package com.sadu.controller;

import com.sadu.dao.DocumentoDAO;
import com.sadu.modelo.Documento;
import com.sadu.util.VerificadorRol;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet que gestiona la vista de SOLO CONSULTA de documentos registrados.
 *
 * Diferencia con DocumentoServlet (módulo de gestión):
 *   - DocumentoServlet  → permite REGISTRAR documentos, búsqueda por nombre/tipo/dependencia
 *   - DocumentoRegistradoServlet → SOLO consulta documentos ARCHIVADOS, búsqueda por código/QR
 *
 * No tiene opción de registrar — es una vista de verificación rápida,
 * pensada para que cualquier funcionario autorizado confirme la existencia
 * y datos de un documento ya finalizado, escaneando o tecleando su código.
 *
 * ACCESO: Todos los roles (1, 2, 3) pueden consultar.
 *
 * Métodos:
 *   GET  ?accion=listar   → Lista todos los documentos ARCHIVADOS
 *   GET  ?accion=buscarQr → Busca por código exacto o código QR
 *   GET  (sin accion)     → Redirige a listar por defecto
 *   POST → delega al GET (cumple requisito de ambos métodos HTTP)
 */
@WebServlet(name = "DocumentoRegistradoServlet", urlPatterns = {"/documentosRegistrados"})
public class DocumentoRegistradoServlet extends HttpServlet {

    /**
     * Método GET: decide qué acción ejecutar según el parámetro "accion".
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // -------------------------------------------------------
        // CONTROL DE ACCESO: todos los roles pueden consultar
        // -------------------------------------------------------
        if (!VerificadorRol.verificar(request, response, 1, 2, 3)) return;

        String accion = request.getParameter("accion");
        if (accion == null) accion = "listar";

        switch (accion) {

            case "buscarQr":
                buscarPorCodigoOQr(request, response);
                break;

            case "listar":
            default:
                listarArchivados(request, response);
                break;
        }
    }

    /**
     * Método POST: delega al método GET.
     * Cumple el requisito de soportar ambos métodos HTTP.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!VerificadorRol.verificar(request, response, 1, 2, 3)) return;
        doGet(request, response);
    }

    // ════════════════════════════════════════════════════════════
    // MÉTODOS PRIVADOS
    // ════════════════════════════════════════════════════════════

    /**
     * Lista únicamente los documentos con estado ARCHIVADO.
     * Esta es la vista por defecto de la página.
     */
    private void listarArchivados(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        DocumentoDAO dao = new DocumentoDAO();

        List<Documento> lista = dao.listarArchivados();
        request.setAttribute("listaDocumentos", lista);
        request.setAttribute("busquedaActiva",  false);

        request.getRequestDispatcher("documentos_registrados.jsp").forward(request, response);
    }

    /**
     * Busca un documento específico por su código o código QR.
     * No filtra por estado — encuentra el documento sin importar
     * si está REGISTRADO, EN_PROCESO o ARCHIVADO, ya que el objetivo
     * es la verificación rápida de cualquier documento existente.
     */
    private void buscarPorCodigoOQr(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Capturar el texto de búsqueda (código o QR escaneado/tecleado)
        String textoBusqueda = request.getParameter("textoBusqueda");

        DocumentoDAO dao = new DocumentoDAO();
        List<Documento> lista = dao.buscarPorCodigoOQr(textoBusqueda);

        request.setAttribute("listaDocumentos", lista);
        request.setAttribute("busquedaActiva",  true);
        request.setAttribute("totalResultados", lista.size());
        request.setAttribute("textoBusqueda",
                textoBusqueda != null ? textoBusqueda : "");

        request.getRequestDispatcher("documentos_registrados.jsp").forward(request, response);
    }
}