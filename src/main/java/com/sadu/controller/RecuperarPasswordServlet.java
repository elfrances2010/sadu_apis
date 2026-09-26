package com.sadu.controller;

import com.sadu.config.Conexion;
import com.sadu.util.EnvioCorreo;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Random;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Servlet que gestiona el paso 1 de la recuperación de contraseña:
 * recibe el correo del usuario, verifica que exista en la BD,
 * genera un código de 6 dígitos, lo guarda en sesión con timestamp
 * y lo envía al correo registrado o en modo prueba.
 */
@WebServlet(name = "RecuperarPasswordServlet", urlPatterns = {"/recuperarPassword"})
public class RecuperarPasswordServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("recuperar_password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Capturar el correo enviado desde el formulario
        String correo = request.getParameter("correo");

        // Validar que el correo no venga vacío
        if (correo == null || correo.trim().isEmpty()) {
            request.setAttribute("error", "Por favor ingresa tu correo electrónico.");
            request.getRequestDispatcher("recuperar_password.jsp").forward(request, response);
            return;
        }

        correo = correo.trim().toLowerCase();

        Connection con        = null;
        PreparedStatement ps  = null;
        ResultSet rs          = null;

        try {
            con = Conexion.getConnection();

            // 2. Verificar que el correo exista en la tabla usuarios y esté ACTIVO
            String sql = "SELECT id_usuario, nombre_completo, correo " +
                         "FROM usuarios WHERE correo = ? AND estado = 'ACTIVO'";
            ps = con.prepareStatement(sql);
            ps.setString(1, correo);
            rs = ps.executeQuery();

            if (rs.next()) {
                // Usuario encontrado
                int    idUsuario      = rs.getInt("id_usuario");
                String nombreCompleto = rs.getString("nombre_completo");
                String correoUsuario  = rs.getString("correo");

                // 3. Generar código aleatorio de 6 dígitos
                String codigo = String.format("%06d", new Random().nextInt(999999));

                // 4. Guardar el código en sesión (expira en 15 minutos)
                HttpSession sesion = request.getSession(true);
                sesion.setAttribute("recuperacion_codigo",    codigo);
                sesion.setAttribute("recuperacion_correo",    correoUsuario);
                sesion.setAttribute("recuperacion_idUsuario", idUsuario);
                sesion.setAttribute("recuperacion_expiracion",
                        System.currentTimeMillis() + (15 * 60 * 1000));

                // Imprimir el código en la consola de NetBeans para las pruebas
                System.out.println("==================================================");
                System.out.println("  >>> SADU: CÓDIGO DE RECUPERACIÓN GENERADO: " + codigo);
                System.out.println("  >>> PARA EL CORREO: " + correoUsuario);
                System.out.println("==================================================");

                // 5. Intentar enviar correo (si no se envía, no bloquea las pruebas)
                try {
                    EnvioCorreo.enviarCodigoRecuperacion(correoUsuario, nombreCompleto, codigo);
                } catch (Exception ex) {
                    System.out.println("Aviso: No se pudo enviar por SMTP, continuando en modo pruebas.");
                }

                // 6. Redirigir a la pantalla de verificación del código
                request.setAttribute("correoOculto", ocultarCorreo(correoUsuario));
                request.getRequestDispatcher("verificar_codigo.jsp").forward(request, response);

            } else {
                // Correo no encontrado
                request.setAttribute("info",
                        "Si el correo está registrado, recibirás un código en los próximos minutos.");
                request.getRequestDispatcher("recuperar_password.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error del sistema: " + e.getMessage());
            request.getRequestDispatcher("recuperar_password.jsp").forward(request, response);
        } finally {
            try {
                if (rs  != null) rs.close();
                if (ps  != null) ps.close();
                if (con != null) con.close();
            } catch (Exception e) { e.printStackTrace(); }
        }
    }

    private String ocultarCorreo(String correo) {
        if (correo == null || !correo.contains("@")) return "****";
        String[] partes = correo.split("@");
        String nombre   = partes[0];
        String dominio  = partes[1];

        String nombreOculto = nombre.length() > 2
                ? nombre.substring(0, 2) + "****"
                : "****";

        return nombreOculto + "@" + dominio;
    }
}