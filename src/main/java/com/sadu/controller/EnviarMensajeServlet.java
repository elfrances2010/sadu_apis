package com.sadu.controller;

import com.sadu.dao.MensajeDAO;
import com.sadu.modelo.Mensaje;
import com.sadu.util.Auditoria;   // ← Importación para registrar logs de auditoría
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Servlet encargado de recibir y guardar un nuevo mensaje del chat interno.
 *
 * Flujo:
 *   1. Valida sesión activa
 *   2. Captura asunto y mensaje del formulario
 *   3. Obtiene el ID del usuario desde la sesión
 *   4. Guarda el mensaje en la BD usando MensajeDAO
 *   5. Registra el log de auditoría ENVIO_MENSAJE
 *   6. Redirige al listado de mensajes
 *
 * Método: POST /EnviarMensajeServlet
 */
@WebServlet(name = "EnviarMensajeServlet", urlPatterns = {"/EnviarMensajeServlet"})
public class EnviarMensajeServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // -------------------------------------------------------
        // 1. Validar sesión activa
        // -------------------------------------------------------
        HttpSession sesion = request.getSession(false);
        if (sesion == null || sesion.getAttribute("nombreUsuario") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // -------------------------------------------------------
        // 2. Obtener el ID del usuario desde la sesión
        //    (guardado al hacer login en LoginServlet)
        // -------------------------------------------------------
        int idUsuario = (int) sesion.getAttribute("idUsuario");

        // -------------------------------------------------------
        // 3. Capturar los datos enviados desde el formulario del chat
        // -------------------------------------------------------
        String asunto  = request.getParameter("asunto");
        String mensaje = request.getParameter("mensaje");

        // Validar que los campos no estén vacíos
        if (asunto == null || asunto.trim().isEmpty()
                || mensaje == null || mensaje.trim().isEmpty()) {
            request.setAttribute("error", "El asunto y el mensaje son obligatorios.");
            request.getRequestDispatcher("chat.jsp").forward(request, response);
            return;
        }

        // -------------------------------------------------------
        // 4. Crear el objeto Mensaje y asignar los valores
        // -------------------------------------------------------
        Mensaje nuevoMensaje = new Mensaje();
        nuevoMensaje.setIdUsuario(idUsuario);
        nuevoMensaje.setAsunto(asunto.trim());
        nuevoMensaje.setMensaje(mensaje.trim());
        // El estado PENDIENTE lo asigna la base de datos por defecto

        // -------------------------------------------------------
        // 5. Guardar el mensaje usando el DAO
        // -------------------------------------------------------
        MensajeDAO mensajeDAO = new MensajeDAO();
        boolean guardado = mensajeDAO.enviarMensaje(nuevoMensaje);

        if (guardado) {

            // -------------------------------------------------------
            // 6. Mensaje guardado — registrar log de auditoría
            //    Este log aparece en el módulo de Auditoría del Admin
            // -------------------------------------------------------
            Auditoria.registrar(
                idUsuario,                              // ID del usuario remitente
                "ENVIO_MENSAJE",                        // Nombre de la acción
                "Mensaje enviado en chat interno. Asunto: " + asunto.trim()
            );

            // Redirigir al listado de mensajes actualizado
            response.sendRedirect("ListarMensajesServlet");

        } else {
            // -------------------------------------------------------
            // 7. Error al guardar — volver al formulario con mensaje de error
            // -------------------------------------------------------
            request.setAttribute("error",
                    "No se pudo enviar el mensaje. Intenta de nuevo.");
            request.getRequestDispatcher("chat.jsp").forward(request, response);
        }
    }
}