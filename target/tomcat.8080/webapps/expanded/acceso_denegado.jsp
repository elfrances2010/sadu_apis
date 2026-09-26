<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page import="javax.servlet.http.HttpSession" %>

<%
    HttpSession sesion = request.getSession(false);
    if (sesion == null || sesion.getAttribute("nombreUsuario") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String nombreUsuario = (String) sesion.getAttribute("nombreUsuario");
    int    rolUsuario    = (int)    sesion.getAttribute("rolUsuario");

    // Obtener mensaje personalizado si viene de VerificadorRol
    String mensaje = (String) sesion.getAttribute("mensajeAccesoDenegado");
    if (mensaje != null) {
        // Limpiar el mensaje de sesión después de mostrarlo
        sesion.removeAttribute("mensajeAccesoDenegado");
    } else {
        mensaje = "No tienes permisos para acceder a esta sección.";
    }

    // Nombre del rol para mostrar al usuario
    String nombreRol = "Usuario";
    if (rolUsuario == 1) nombreRol = "Administrador";
    else if (rolUsuario == 2) nombreRol = "Gestor de Archivo";
    else if (rolUsuario == 3) nombreRol = "Dependencia Municipal";
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Acceso Denegado - SADU</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            margin: 0;
            background: linear-gradient(135deg, #1f3b57 0%, #2f5579 50%, #1b4332 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: Arial, sans-serif;
        }

        .caja {
            background: white;
            border-radius: 18px;
            padding: 50px 44px;
            width: 100%;
            max-width: 480px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            text-align: center;
        }

        /* Icono grande de acceso denegado */
        .icono-grande {
            font-size: 72px;
            display: block;
            margin-bottom: 16px;
        }

        h2 {
            color: #dc2626;
            font-size: 26px;
            font-weight: bold;
            margin-bottom: 10px;
        }

        .subtitulo {
            color: #6b7280;
            font-size: 14px;
            margin-bottom: 24px;
            line-height: 1.6;
        }

        /* Caja con información del usuario actual */
        .info-usuario {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 16px 20px;
            margin-bottom: 28px;
            text-align: left;
        }

        .info-usuario p {
            margin: 0 0 6px;
            font-size: 13px;
            color: #374151;
        }

        .info-usuario p:last-child { margin-bottom: 0; }

        .info-usuario strong { color: #1f3b57; }

        /* Badge del rol */
        .badge-rol {
            display: inline-block;
            background: #dbeafe;
            color: #1e40af;
            padding: 3px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
        }

        /* Botones de navegación */
        .btn-dashboard {
            display: block;
            background-color: #1f3b57;
            color: white;
            padding: 13px;
            border-radius: 8px;
            text-decoration: none;
            font-size: 15px;
            margin-bottom: 12px;
            transition: background-color 0.3s;
        }

        .btn-dashboard:hover {
            background-color: #162d42;
            color: white;
        }

        .btn-volver {
            display: block;
            background-color: #f1f5f9;
            color: #374151;
            padding: 13px;
            border-radius: 8px;
            text-decoration: none;
            font-size: 15px;
            border: 1px solid #d1d5db;
            transition: background-color 0.3s;
        }

        .btn-volver:hover {
            background-color: #e2e8f0;
            color: #374151;
        }

        /* Mensaje de error */
        .alerta-error {
            background: #fee2e2;
            color: #b91c1c;
            border: 1px solid #fca5a5;
            border-radius: 10px;
            padding: 13px 16px;
            margin-bottom: 22px;
            font-size: 13px;
            text-align: left;
        }
    </style>
</head>
<body>

<div class="caja">

    <!-- Icono y título -->
    <span class="icono-grande">🚫</span>
    <h2>Acceso denegado</h2>
    <p class="subtitulo">
        No tienes los permisos necesarios para ver esta sección del sistema SADU.
    </p>

    <!-- Mensaje personalizado -->
    <div class="alerta-error">
        ⚠️ <%= mensaje %>
    </div>

    <!-- Información del usuario actual -->
    <div class="info-usuario">
        <p><strong>Usuario:</strong> <%= nombreUsuario %></p>
        <p><strong>Rol asignado:</strong>
            <span class="badge-rol"><%= nombreRol %></span>
        </p>
        <p style="margin-top:10px; color:#9ca3af; font-size:12px;">
            Si necesitas acceso a esta sección, contacta al Administrador del sistema.
        </p>
    </div>

    <!-- Botones de navegación -->
    <a href="dashboard.jsp" class="btn-dashboard">🏠 Ir al Panel Principal</a>
    <a href="javascript:history.back()" class="btn-volver">← Volver a la página anterior</a>

</div>

</body>
</html>
