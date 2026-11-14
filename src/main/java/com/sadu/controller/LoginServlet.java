package com.sadu.controller;

import com.sadu.config.Conexion;
import com.sadu.util.Auditoria;
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

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String correo   = request.getParameter("username");
        String password = request.getParameter("password");

        Connection        con = null;
        PreparedStatement ps  = null;
        ResultSet         rs  = null;

        try {
            con = Conexion.getConnection();

            String sql = "SELECT id_usuario, nombre_completo, correo, username, " +
                         "       password, estado, id_rol, requiere_cambio_clave " +
                         "FROM usuarios " +
                         "WHERE (correo = ? OR username = ?) AND password = ? AND estado = 'ACTIVO'";

            ps = con.prepareStatement(sql);
            ps.setString(1, correo);
            ps.setString(2, correo);
            ps.setString(3, password);

            rs = ps.executeQuery();

            if (rs.next()) {

                HttpSession session = request.getSession();
                session.setAttribute("idUsuario",     rs.getInt("id_usuario"));
                session.setAttribute("nombreUsuario", rs.getString("nombre_completo"));
                session.setAttribute("correoUsuario", rs.getString("correo"));
                session.setAttribute("username",      rs.getString("username"));
                session.setAttribute("rolUsuario",    rs.getInt("id_rol"));

                boolean requiereCambio = rs.getBoolean("requiere_cambio_clave");

                if (requiereCambio) {
                    session.setAttribute("cambioClaveObligatorio", true);

                    Auditoria.registrar(
                        rs.getInt("id_usuario"),
                        "LOGIN_CAMBIO_CLAVE_REQUERIDO",
                        "Inicio de sesi?n exitoso con cambio de clave pendiente. Usuario: " + rs.getString("username")
                    );

                    response.sendRedirect("nueva_password.jsp?obligatorio=true");
                    return;
                }

                Auditoria.registrar(
                    rs.getInt("id_usuario"),
                    "LOGIN",
                    "Inicio de sesi?n exitoso. Usuario: " + rs.getString("username")
                                             + " | Correo: " + rs.getString("correo")
                );

                response.sendRedirect("dashboard.jsp");

            } else {
                request.setAttribute("error", "Correo / Usuario o contrase?a incorrectos.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error en el sistema: " + e.getMessage());
            request.getRequestDispatcher("login.jsp").forward(request, response);

        } finally {
            try { if (rs  != null) rs.close();  } catch (Exception e) { e.printStackTrace(); }
            try { if (ps  != null) ps.close();  } catch (Exception e) { e.printStackTrace(); }
            try { if (con != null) con.close(); } catch (Exception e) { e.printStackTrace(); }
        }
    }
}
