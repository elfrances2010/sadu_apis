package com.sadu.controller;

import com.sadu.config.Conexion;
import com.sadu.util.Auditoria;   // ← Importación para registrar logs de auditoría
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Servlet encargado de autenticar usuarios en el sistema SADU.
 *
 * Flujo:
 *   1. Recibe correo y contraseña del formulario login.jsp por POST
 *   2. Consulta la tabla usuarios buscando un usuario ACTIVO con esas credenciales
 *   3. Si existe: crea la sesión, registra el log de LOGIN y redirige al dashboard
 *   4. Si no existe: vuelve al login con mensaje de error
 *
 * Métodos:
 *   POST /login → autenticación principal
 */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // -------------------------------------------------------
        // 1. Capturar los datos enviados desde el formulario login.jsp
        // -------------------------------------------------------
        String correo   = request.getParameter("username");
        String password = request.getParameter("password");

        Connection        con = null;
        PreparedStatement ps  = null;
        ResultSet         rs  = null;

        try {
            // -------------------------------------------------------
            // 2. Abrir conexión a la base de datos
            // -------------------------------------------------------
            con = Conexion.getConnection();

            // -------------------------------------------------------
            // 3. Consultar usuario activo con las credenciales recibidas
            //    Se usa PreparedStatement para evitar SQL Injection
            // -------------------------------------------------------
            String sql = "SELECT id_usuario, nombre_completo, correo, username, " +
                         "       password, estado, id_rol " +
                         "FROM usuarios " +
                         "WHERE correo = ? AND password = ? AND estado = 'ACTIVO'";

            ps = con.prepareStatement(sql);
            ps.setString(1, correo);
            ps.setString(2, password);

            rs = ps.executeQuery();

            if (rs.next()) {

                // -------------------------------------------------------
                // 4. Usuario encontrado — crear sesión con sus datos
                //    Estos atributos quedan disponibles en todos los JSP
                //    mientras dure la sesión
                // -------------------------------------------------------
                HttpSession session = request.getSession();
                session.setAttribute("idUsuario",     rs.getInt("id_usuario"));
                session.setAttribute("nombreUsuario", rs.getString("nombre_completo"));
                session.setAttribute("correoUsuario", rs.getString("correo"));
                session.setAttribute("username",      rs.getString("username"));
                session.setAttribute("rolUsuario",    rs.getInt("id_rol"));

                // -------------------------------------------------------
                // 5. Registrar el evento de LOGIN en la tabla logs_auditoria
                //    Esto llena el módulo de auditoría automáticamente
                //    Se hace DESPUÉS de crear la sesión para asegurar que
                //    el usuario quedó autenticado antes de registrar el log
                // -------------------------------------------------------
                Auditoria.registrar(
                    rs.getInt("id_usuario"),    // ID del usuario que inició sesión
                    "LOGIN",                    // Nombre de la acción
                    "Inicio de sesión exitoso. Usuario: " + rs.getString("username")
                                             + " | Correo: " + rs.getString("correo")
                );

                // -------------------------------------------------------
                // 6. Redirigir al panel principal (dashboard)
                // -------------------------------------------------------
                response.sendRedirect("dashboard.jsp");

            } else {

                // -------------------------------------------------------
                // 7. Credenciales incorrectas o usuario inactivo
                //    Se vuelve al login con mensaje de error
                //    NO se registra log aquí para evitar llenar la tabla
                //    con intentos fallidos de terceros
                // -------------------------------------------------------
                request.setAttribute("error", "Correo o contraseña incorrectos.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }

        } catch (Exception e) {
            // -------------------------------------------------------
            // 8. Error inesperado del sistema (ej: BD no disponible)
            // -------------------------------------------------------
            e.printStackTrace();
            request.setAttribute("error", "Error en el sistema: " + e.getMessage());
            request.getRequestDispatcher("login.jsp").forward(request, response);

        } finally {
            // -------------------------------------------------------
            // 9. Cerrar recursos de BD siempre, aunque ocurra un error
            // -------------------------------------------------------
            try { if (rs  != null) rs.close();  } catch (Exception e) { e.printStackTrace(); }
            try { if (ps  != null) ps.close();  } catch (Exception e) { e.printStackTrace(); }
            try { if (con != null) con.close(); } catch (Exception e) { e.printStackTrace(); }
        }
    }
}