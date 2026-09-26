package com.sadu.controller;

import com.sadu.config.Conexion;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Servlet que gestiona el paso 3 (último) de la recuperación de contraseña:
 * recibe la nueva contraseña, la actualiza en la base de datos y limpia
 * todos los datos de recuperación de la sesión.
 *
 * Métodos:
 *   GET  → muestra el formulario nueva_password.jsp
 *   POST → actualiza la contraseña en la BD
 *
 * Seguridad:
 *   Solo permite acceder si en sesión existe recuperacion_verificado = true,
 *   lo que garantiza que el usuario pasó por la verificación del código.
 */
@WebServlet(name = "NuevaPasswordServlet", urlPatterns = {"/nuevaPassword"})
public class NuevaPasswordServlet extends HttpServlet {

    /**
     * GET: muestra el formulario de nueva contraseña.
     * Verifica que el usuario pasó por la verificación del código.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession sesion = request.getSession(false);

        // Verificar que existe sesión con código verificado
        if (sesion == null || !Boolean.TRUE.equals(sesion.getAttribute("recuperacion_verificado"))) {
            response.sendRedirect("recuperar_password.jsp");
            return;
        }

        request.getRequestDispatcher("nueva_password.jsp").forward(request, response);
    }

    /**
     * POST: actualiza la contraseña del usuario en la base de datos.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession sesion = request.getSession(false);

        // 1. Verificar que el usuario pasó por la verificación del código
        if (sesion == null || !Boolean.TRUE.equals(sesion.getAttribute("recuperacion_verificado"))) {
            response.sendRedirect("recuperar_password.jsp");
            return;
        }

        // 2. Obtener el ID del usuario desde la sesión
        Integer idUsuario = (Integer) sesion.getAttribute("recuperacion_idUsuario");

        if (idUsuario == null) {
            request.setAttribute("error", "Sesión inválida. Por favor solicita un nuevo código.");
            request.getRequestDispatcher("recuperar_password.jsp").forward(request, response);
            return;
        }

        // 3. Capturar y validar la nueva contraseña
        String nuevaPassword    = request.getParameter("nuevaPassword");
        String confirmarPassword = request.getParameter("confirmarPassword");

        if (nuevaPassword == null || nuevaPassword.trim().isEmpty()) {
            request.setAttribute("error", "La contraseña no puede estar vacía.");
            request.getRequestDispatcher("nueva_password.jsp").forward(request, response);
            return;
        }

        if (nuevaPassword.length() < 6) {
            request.setAttribute("error", "La contraseña debe tener al menos 6 caracteres.");
            request.getRequestDispatcher("nueva_password.jsp").forward(request, response);
            return;
        }

        // 4. Verificar que ambas contraseñas coincidan
        if (!nuevaPassword.equals(confirmarPassword)) {
            request.setAttribute("error", "Las contraseñas no coinciden. Por favor verifica.");
            request.getRequestDispatcher("nueva_password.jsp").forward(request, response);
            return;
        }

        // 5. Actualizar la contraseña en la base de datos
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = Conexion.getConnection();

            // Actualizar la contraseña del usuario identificado por su ID
            String sql = "UPDATE usuarios SET password = ? WHERE id_usuario = ?";
            ps = con.prepareStatement(sql);
            ps.setString(1, nuevaPassword); // En producción: usar BCrypt aquí
            ps.setInt(2, idUsuario);

            int filas = ps.executeUpdate();

            if (filas > 0) {
                // 6. Contraseña actualizada — limpiar todos los datos de recuperación de sesión
                sesion.removeAttribute("recuperacion_codigo");
                sesion.removeAttribute("recuperacion_correo");
                sesion.removeAttribute("recuperacion_idUsuario");
                sesion.removeAttribute("recuperacion_expiracion");
                sesion.removeAttribute("recuperacion_verificado");

                // Redirigir al login con mensaje de éxito
                response.sendRedirect("login.jsp?recuperado=1");
            } else {
                request.setAttribute("error", "No se pudo actualizar la contraseña. Intenta de nuevo.");
                request.getRequestDispatcher("nueva_password.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error del sistema: " + e.getMessage());
            request.getRequestDispatcher("nueva_password.jsp").forward(request, response);
        } finally {
            try {
                if (ps  != null) ps.close();
                if (con != null) con.close();
            } catch (Exception e) { e.printStackTrace(); }
        }
    }
}