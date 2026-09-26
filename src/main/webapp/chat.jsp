<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.sadu.modelo.Mensaje"%>
<%@page import="javax.servlet.http.HttpSession"%>

<%
    /*
        Validar sesión activa.
        Si no hay sesión, redirigir al login.
    */
    HttpSession sesion = request.getSession(false);
    if (sesion == null || sesion.getAttribute("nombreUsuario") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Datos del usuario en sesión
    String nombreUsuario = (String) sesion.getAttribute("nombreUsuario");
    int idUsuario        = (int)    sesion.getAttribute("idUsuario");

    // Lista de mensajes enviada por ListarMensajesServlet
    List<Mensaje> listaMensajes = (List<Mensaje>) request.getAttribute("listaMensajes");

    // Mensaje de error enviado por EnviarMensajeServlet (si ocurrió alguno)
    String error = (String) request.getAttribute("error");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chat Interno - SADU</title>

    <!-- Bootstrap para estilos responsivos -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body {
            background-color: #f4f6f9;
            font-family: Arial, sans-serif;
        }

        /* Contenedor principal centrado */
        .contenedor {
            max-width: 900px;
            margin: 40px auto;
            padding: 0 15px;
        }

        /* Encabezado de la sección */
        .encabezado {
            background: linear-gradient(135deg, #1f3b57, #2f5579);
            color: white;
            border-radius: 12px;
            padding: 20px 25px;
            margin-bottom: 25px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .encabezado h2 {
            margin: 0;
            font-size: 22px;
        }

        .encabezado small {
            opacity: 0.8;
        }

        /* Formulario para enviar mensaje */
        .formulario-chat {
            background: white;
            border-radius: 12px;
            padding: 25px;
            margin-bottom: 25px;
            box-shadow: 0 3px 10px rgba(0,0,0,0.08);
        }

        .formulario-chat h5 {
            color: #1f3b57;
            margin-bottom: 18px;
            border-bottom: 2px solid #e2e8f0;
            padding-bottom: 10px;
        }

        .formulario-chat input,
        .formulario-chat textarea {
            width: 100%;
            padding: 11px 14px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            font-size: 14px;
            outline: none;
            margin-bottom: 14px;
            resize: vertical;
        }

        .formulario-chat input:focus,
        .formulario-chat textarea:focus {
            border-color: #1f3b57;
            box-shadow: 0 0 5px rgba(31, 59, 87, 0.25);
        }

        .btn-enviar {
            background-color: #1f3b57;
            color: white;
            border: none;
            padding: 11px 25px;
            border-radius: 8px;
            font-size: 15px;
            cursor: pointer;
            transition: background-color 0.3s;
        }

        .btn-enviar:hover {
            background-color: #162d42;
        }

        /* Tarjetas de mensajes */
        .mensaje-card {
            background: white;
            border-radius: 10px;
            padding: 18px 20px;
            margin-bottom: 15px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.07);
            border-left: 5px solid #1f3b57;
        }

        /* Color del borde según estado del mensaje */
        .mensaje-card.PENDIENTE  { border-left-color: #f59e0b; }
        .mensaje-card.LEIDO      { border-left-color: #10b981; }
        .mensaje-card.RESPONDIDO { border-left-color: #3b82f6; }

        .mensaje-card .remitente {
            font-weight: bold;
            color: #1f3b57;
            font-size: 15px;
        }

        .mensaje-card .asunto {
            color: #374151;
            font-size: 14px;
            margin: 5px 0;
        }

        .mensaje-card .contenido {
            color: #555;
            font-size: 14px;
            margin-top: 8px;
            line-height: 1.5;
        }

        .mensaje-card .pie {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 10px;
        }

        .mensaje-card .fecha {
            font-size: 12px;
            color: #9ca3af;
        }

        /* Badge de estado */
        .badge-estado {
            padding: 3px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
        }

        .badge-PENDIENTE  { background-color: #fef3c7; color: #92400e; }
        .badge-LEIDO      { background-color: #d1fae5; color: #065f46; }
        .badge-RESPONDIDO { background-color: #dbeafe; color: #1e40af; }

        /* Sección de listado */
        .seccion-mensajes h5 {
            color: #1f3b57;
            margin-bottom: 15px;
            font-size: 17px;
        }

        /* Error */
        .error-box {
            background-color: #fee2e2;
            color: #b91c1c;
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 18px;
        }

        /* Sin mensajes */
        .sin-mensajes {
            text-align: center;
            padding: 30px;
            color: #9ca3af;
            background: white;
            border-radius: 10px;
        }

        .btn-volver {
            background-color: #374151;
            color: white;
            padding: 8px 16px;
            border-radius: 8px;
            text-decoration: none;
            font-size: 14px;
            transition: background-color 0.3s;
        }

        .btn-volver:hover {
            background-color: #1f2937;
            color: white;
        }
    </style>
</head>
<%@ include file="sidebar.jsp" %>

<body>

<div class="contenedor">

    <!-- Encabezado del módulo -->
    <div class="encabezado">
        <div>
            <h2>💬 Chat Interno</h2>
            <small>Mensajes del sistema SADU</small>
        </div>
        <a href="dashboard.jsp" class="btn-volver">← Volver</a>
    </div>

    <!-- Mostrar error si lo hay -->
    <% if (error != null) { %>
        <div class="error-box">
            ⚠️ <%= error %>
        </div>
    <% } %>

    <!-- Formulario para enviar un nuevo mensaje -->
    <div class="formulario-chat">
        <h5>✉️ Enviar nuevo mensaje</h5>

        <!--
            El formulario envía los datos por POST al EnviarMensajeServlet.
            Al guardar exitosamente, el servlet redirige a ListarMensajesServlet.
        -->
        <form action="EnviarMensajeServlet" method="post">

            <label style="font-weight:bold; font-size:14px;">Asunto:</label>
            <input
                type="text"
                name="asunto"
                placeholder="Escribe el asunto del mensaje"
                maxlength="120"
                required
            >

            <label style="font-weight:bold; font-size:14px;">Mensaje:</label>
            <textarea
                name="mensaje"
                rows="4"
                placeholder="Escribe tu mensaje aquí..."
                required
            ></textarea>

            <button type="submit" class="btn-enviar">Enviar mensaje</button>
        </form>
    </div>

    <!-- Listado de mensajes existentes -->
    <div class="seccion-mensajes">
        <h5>📋 Mensajes recientes</h5>

        <%
            if (listaMensajes != null && !listaMensajes.isEmpty()) {
                for (Mensaje m : listaMensajes) {
        %>
            <!-- Tarjeta de un mensaje individual -->
            <!-- La clase CSS cambia según el estado: PENDIENTE, LEIDO o RESPONDIDO -->
            <div class="mensaje-card <%= m.getEstado() %>">

                <div class="remitente">👤 <%= m.getNombreUsuario() %></div>

                <div class="asunto"><strong>Asunto:</strong> <%= m.getAsunto() %></div>

                <div class="contenido"><%= m.getMensaje() %></div>

                <div class="pie">
                    <span class="fecha">🕐 <%= m.getFechaEnvio() %></span>
                    <span class="badge-estado badge-<%= m.getEstado() %>">
                        <%= m.getEstado() %>
                    </span>
                </div>
            </div>
        <%
                }
            } else {
        %>
            <!-- Si no hay mensajes, mostrar mensaje informativo -->
            <div class="sin-mensajes">
                <p style="font-size:16px;">📭 No hay mensajes aún.</p>
                <p>Sé el primero en enviar un mensaje usando el formulario de arriba.</p>
            </div>
        <% } %>
    </div>

</div>

</body>
</html>
