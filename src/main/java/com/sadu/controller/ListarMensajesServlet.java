package com.sadu.controller;

import com.sadu.dao.MensajeDAO;
import com.sadu.modelo.Mensaje;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Servlet que carga y muestra todos los mensajes del chat interno.
 *
 * Métodos soportados:
 *   GET  → consulta los mensajes y los envía al JSP chat.jsp
 *   POST → delega al GET (cumple requisito de ambos métodos HTTP)
 */
@WebServlet(name = "ListarMensajesServlet", urlPatterns = {"/ListarMensajesServlet"})
public class ListarMensajesServlet extends HttpServlet {

    /**
     * Método GET: consulta todos los mensajes del chat usando MensajeDAO
     * y los envía al JSP chat.jsp para mostrarlos.
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

        // 2. Consultar todos los mensajes desde la base de datos
        MensajeDAO mensajeDAO = new MensajeDAO();
        List<Mensaje> listaMensajes = mensajeDAO.listarMensajes();

        // 3. Enviar la lista al JSP como atributo del request
        request.setAttribute("listaMensajes", listaMensajes);

        // 4. Redirigir a la vista del chat
        request.getRequestDispatcher("chat.jsp").forward(request, response);
    }

    /**
     * Método POST: delega al método GET.
     * Permite que formularios con method="post" también listen los mensajes.
     * Cumple el requisito de soportar ambos métodos HTTP en la tarea.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Servlet para listar mensajes del chat interno SADU";
    }
}