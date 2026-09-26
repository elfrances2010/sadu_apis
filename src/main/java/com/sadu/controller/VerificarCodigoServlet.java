package com.sadu.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Servlet que gestiona el paso 2 de la recuperación de contraseña:
 * verifica que el código ingresado por el usuario coincida con el
 * código generado y guardado en sesión, y que no haya expirado.
 *
 * Métodos:
 *   GET  → muestra el formulario verificar_codigo.jsp
 *   POST → verifica el código e indica si es correcto
 */
@WebServlet(name = "VerificarCodigoServlet", urlPatterns = {"/verificarCodigo"})
public class VerificarCodigoServlet extends HttpServlet {

    /**
     * GET: muestra el formulario de verificación del código.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("verificar_codigo.jsp").forward(request, response);
    }

    /**
     * POST: verifica el código ingresado contra el guardado en sesión.
     * Si es correcto y no expiró, permite avanzar al formulario de nueva contraseña.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Obtener la sesión actual (sin crear una nueva)
        HttpSession sesion = request.getSession(false);

        // Verificar que existe una sesión con datos de recuperación
        if (sesion == null
                || sesion.getAttribute("recuperacion_codigo") == null
                || sesion.getAttribute("recuperacion_expiracion") == null) {

            request.setAttribute("error",
                    "La sesión de recuperación expiró o no es válida. Solicita un nuevo código.");
            request.getRequestDispatcher("recuperar_password.jsp").forward(request, response);
            return;
        }

        // 2. Recuperar datos guardados en sesión
        String codigoGuardado  = (String) sesion.getAttribute("recuperacion_codigo");
        long   expiracion      = (long)   sesion.getAttribute("recuperacion_expiracion");
        String correoOculto    = ocultarCorreo((String) sesion.getAttribute("recuperacion_correo"));

        // 3. Verificar que el código no haya expirado (15 minutos)
        if (System.currentTimeMillis() > expiracion) {
            // Limpiar datos de sesión para que no se pueda reutilizar
            sesion.removeAttribute("recuperacion_codigo");
            sesion.removeAttribute("recuperacion_correo");
            sesion.removeAttribute("recuperacion_idUsuario");
            sesion.removeAttribute("recuperacion_expiracion");

            request.setAttribute("error",
                    "El código ha expirado. Por favor solicita uno nuevo.");
            request.getRequestDispatcher("recuperar_password.jsp").forward(request, response);
            return;
        }

        // 4. Capturar el código ingresado por el usuario
        String codigoIngresado = request.getParameter("codigo");

        if (codigoIngresado == null || codigoIngresado.trim().isEmpty()) {
            request.setAttribute("error", "Por favor ingresa el código de 6 dígitos.");
            request.setAttribute("correoOculto", correoOculto);
            request.getRequestDispatcher("verificar_codigo.jsp").forward(request, response);
            return;
        }

        // 5. Comparar el código ingresado con el guardado en sesión
        if (codigoIngresado.trim().equals(codigoGuardado)) {
            // Código correcto — marcar en sesión que el código fue verificado
            // Esto permite que NuevaPasswordServlet sepa que el usuario pasó la verificación
            sesion.setAttribute("recuperacion_verificado", true);

            // Redirigir al formulario de nueva contraseña
            request.getRequestDispatcher("nueva_password.jsp").forward(request, response);

        } else {
            // Código incorrecto
            request.setAttribute("error",
                    "El código ingresado no es correcto. Verifica el correo y vuelve a intentarlo.");
            request.setAttribute("correoOculto", correoOculto);
            request.getRequestDispatcher("verificar_codigo.jsp").forward(request, response);
        }
    }

    /**
     * Oculta parcialmente el correo para mostrarlo al usuario.
     */
    private String ocultarCorreo(String correo) {
        if (correo == null || !correo.contains("@")) return "****";
        String[] partes = correo.split("@");
        String nombre = partes[0];
        String dominio = partes[1];
        String nombreOculto = nombre.length() > 2
                ? nombre.substring(0, 2) + "****"
                : "****";
        return nombreOculto + "@" + dominio;
    }
}