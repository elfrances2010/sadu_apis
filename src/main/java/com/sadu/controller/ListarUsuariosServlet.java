package com.sadu.controller;

import com.sadu.dao.UsuarioDAO;
import com.sadu.modelo.Usuario;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Servlet encargado de consultar y mostrar la lista de usuarios.
 */
@WebServlet("/listarUsuarios")
public class ListarUsuariosServlet extends HttpServlet {

    /**
     * Método GET para cargar la lista de usuarios.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Verificar que exista una sesión activa
        HttpSession sesion = request.getSession(false);

        if (sesion == null || sesion.getAttribute("nombreUsuario") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Crear objeto DAO para acceder a la base de datos
        UsuarioDAO usuarioDAO = new UsuarioDAO();

        // Obtener la lista de usuarios desde el DAO
        List<Usuario> listaUsuarios = usuarioDAO.listarUsuarios();

        // Enviar la lista al JSP
        request.setAttribute("listaUsuarios", listaUsuarios);

        // Redirigir al archivo usuarios.jsp
        request.getRequestDispatcher("usuarios.jsp").forward(request, response);
    }
}