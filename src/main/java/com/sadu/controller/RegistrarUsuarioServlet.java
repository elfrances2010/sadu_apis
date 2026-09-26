package com.sadu.controller;

import com.sadu.dao.UsuarioDAO;
import com.sadu.modelo.Usuario;
import com.sadu.util.Auditoria;   // ← Importación para registrar logs de auditoría
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Servlet encargado de registrar nuevos usuarios en el sistema SADU.
 *
 * Métodos:
 *   GET  /registrarUsuario → Muestra el formulario registrar_usuario.jsp
 *   POST /registrarUsuario → Recibe datos del formulario, guarda en BD
 *                            y registra log de auditoría REGISTRO_USUARIO
 */
@WebServlet("/registrarUsuario")
public class RegistrarUsuarioServlet extends HttpServlet {

    /**
     * Método GET: muestra el formulario de registro de usuario.
     * Se llama cuando el usuario hace clic en "Registrar usuario" del menú.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // -------------------------------------------------------
        // Validar sesión activa — solo usuarios autenticados pueden
        // acceder al formulario de registro
        // -------------------------------------------------------
        HttpSession sesion = request.getSession(false);
        if (sesion == null || sesion.getAttribute("nombreUsuario") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Mostrar el formulario de registro de usuario
        request.getRequestDispatcher("registrar_usuario.jsp").forward(request, response);
    }

    /**
     * Método POST: recibe los datos del formulario y registra el usuario.
     * Valida campos, guarda en BD, registra log y redirige al listado.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // -------------------------------------------------------
        // 1. Verificar que exista una sesión activa
        // -------------------------------------------------------
        HttpSession sesion = request.getSession(false);
        if (sesion == null || sesion.getAttribute("nombreUsuario") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // ID del administrador que está registrando el nuevo usuario
        int idAdministrador = (int) sesion.getAttribute("idUsuario");

        // -------------------------------------------------------
        // 2. Capturar los datos enviados desde el formulario
        // -------------------------------------------------------
        String nombreCompleto = request.getParameter("nombreCompleto");
        String correo         = request.getParameter("correo");
        String username       = request.getParameter("username");
        String password       = request.getParameter("password");
        String estado         = request.getParameter("estado");

        // -------------------------------------------------------
        // 3. Convertir rolId a entero con manejo de error
        // -------------------------------------------------------
        int rolId = 1; // valor por defecto: Administrador
        try {
            rolId = Integer.parseInt(request.getParameter("rolId"));
        } catch (NumberFormatException e) {
            request.setAttribute("error", "El rol seleccionado no es válido.");
            request.getRequestDispatcher("registrar_usuario.jsp").forward(request, response);
            return;
        }

        // -------------------------------------------------------
        // 4. Validar que los campos obligatorios no estén vacíos
        // -------------------------------------------------------
        if (nombreCompleto == null || nombreCompleto.trim().isEmpty()
                || correo    == null || correo.trim().isEmpty()
                || username  == null || username.trim().isEmpty()
                || password  == null || password.trim().isEmpty()) {

            request.setAttribute("error", "Todos los campos son obligatorios.");
            request.getRequestDispatcher("registrar_usuario.jsp").forward(request, response);
            return;
        }

        // -------------------------------------------------------
        // 5. Construir el objeto Usuario con los datos del formulario
        // -------------------------------------------------------
        Usuario usuario = new Usuario();
        usuario.setNombreCompleto(nombreCompleto.trim());
        usuario.setCorreo(correo.trim());
        usuario.setUsername(username.trim().toLowerCase());
        usuario.setPassword(password);
        usuario.setEstado(estado != null ? estado : "ACTIVO");
        usuario.setRolId(rolId);

        // -------------------------------------------------------
        // 6. Guardar el usuario en la base de datos usando el DAO
        // -------------------------------------------------------
        UsuarioDAO usuarioDAO = new UsuarioDAO();
        boolean registrado = usuarioDAO.registrarUsuario(usuario);

        if (registrado) {

            // -------------------------------------------------------
            // 7. Registro exitoso — guardar log de auditoría
            //    El log muestra quién registró el usuario y con qué datos
            // -------------------------------------------------------
            Auditoria.registrar(
                idAdministrador,                        // ID del admin que registró
                "REGISTRO_USUARIO",                     // Nombre de la acción
                "Nuevo usuario registrado. Username: " + username.trim().toLowerCase()
                + " | Correo: " + correo.trim()
                + " | Rol ID: " + rolId
            );

            // Redirigir al listado de usuarios
            response.sendRedirect("listarUsuarios");

        } else {
            // -------------------------------------------------------
            // 8. Error al guardar (correo o username duplicado, etc.)
            // -------------------------------------------------------
            request.setAttribute("error",
                    "No se pudo registrar el usuario. " +
                    "Verifica que el correo y username no estén ya registrados.");
            request.getRequestDispatcher("registrar_usuario.jsp").forward(request, response);
        }
    }
}