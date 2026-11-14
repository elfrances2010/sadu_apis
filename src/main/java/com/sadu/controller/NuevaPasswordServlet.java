package com.sadu.controller;

import com.sadu.dao.UsuarioDAO;
import com.sadu.util.Auditoria;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "NuevaPasswordServlet", urlPatterns = {"/nuevaPassword"})
public class NuevaPasswordServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession sesion = request.getSession(false);

        boolean esObligatorio = sesion != null && Boolean.TRUE.equals(sesion.getAttribute("cambioClaveObligatorio"));
        boolean esRecuperacion = sesion != null && Boolean.TRUE.equals(sesion.getAttribute("recuperacion_verificado"));
        boolean tieneUsuario = sesion != null && sesion.getAttribute("idUsuario") != null;

        if (!esObligatorio && !esRecuperacion && !tieneUsuario) {
            response.sendRedirect("recuperar_password.jsp");
            return;
        }

        request.getRequestDispatcher("nueva_password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession sesion = request.getSession(false);

        boolean esObligatorio = sesion != null && Boolean.TRUE.equals(sesion.getAttribute("cambioClaveObligatorio"));
        boolean esRecuperacion = sesion != null && Boolean.TRUE.equals(sesion.getAttribute("recuperacion_verificado"));

        Integer idUsuario = null;
        if (sesion != null) {
            idUsuario = (Integer) sesion.getAttribute("idUsuario");
            if (idUsuario == null) {
                idUsuario = (Integer) sesion.getAttribute("recuperacion_idUsuario");
            }
        }

        if (idUsuario == null && !esRecuperacion && !esObligatorio) {
            response.sendRedirect("login.jsp");
            return;
        }

        String nuevaPassword    = request.getParameter("nuevaPassword");
        String confirmarPassword = request.getParameter("confirmarPassword");

        if (nuevaPassword == null || nuevaPassword.trim().isEmpty()) {
            request.setAttribute("error", "La contrase?a no puede estar vac?a.");
            request.getRequestDispatcher("nueva_password.jsp").forward(request, response);
            return;
        }

        if (nuevaPassword.length() < 6) {
            request.setAttribute("error", "La contrase?a debe tener al menos 6 caracteres.");
            request.getRequestDispatcher("nueva_password.jsp").forward(request, response);
            return;
        }

        if (!nuevaPassword.equals(confirmarPassword)) {
            request.setAttribute("error", "Las contrase?as no coinciden. Por favor verifica.");
            request.getRequestDispatcher("nueva_password.jsp").forward(request, response);
            return;
        }

        UsuarioDAO dao = new UsuarioDAO();
        boolean actualizado = dao.cambiarPassword(idUsuario, nuevaPassword);

        if (actualizado) {
            if (sesion != null) {
                sesion.removeAttribute("cambioClaveObligatorio");
                sesion.removeAttribute("recuperacion_codigo");
                sesion.removeAttribute("recuperacion_correo");
                sesion.removeAttribute("recuperacion_idUsuario");
                sesion.removeAttribute("recuperacion_expiracion");
                sesion.removeAttribute("recuperacion_verificado");
            }

            Auditoria.registrar(
                idUsuario,
                "CAMBIO_PASSWORD",
                "Actualizaci?n de contrase?a completada con ?xito."
            );

            if (sesion != null && sesion.getAttribute("nombreUsuario") != null) {
                response.sendRedirect("dashboard.jsp?claveActualizada=1");
            } else {
                response.sendRedirect("login.jsp?recuperado=1");
            }
        } else {
            request.setAttribute("error", "No se pudo actualizar la contrase?a. Intenta de nuevo.");
            request.getRequestDispatcher("nueva_password.jsp").forward(request, response);
        }
    }
}
