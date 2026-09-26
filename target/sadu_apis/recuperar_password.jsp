<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%
    String error = (String) request.getAttribute("error");
    String info  = (String) request.getAttribute("info");
    String recuperado = request.getParameter("recuperado");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Recuperar Contraseña - SADU</title>
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
            padding: 40px 44px;
            width: 100%;
            max-width: 440px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        }

        .logo {
            text-align: center;
            margin-bottom: 28px;
        }

        .logo .icono {
            font-size: 52px;
            display: block;
            margin-bottom: 8px;
        }

        .logo h2 {
            color: #1f3b57;
            font-size: 26px;
            font-weight: bold;
            margin: 0;
        }

        .logo p {
            color: #9ca3af;
            font-size: 13px;
            margin: 6px 0 0;
        }

        label {
            font-size: 13px;
            font-weight: bold;
            color: #374151;
            display: block;
            margin-bottom: 6px;
        }

        input[type="email"] {
            width: 100%;
            padding: 12px 14px;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            font-size: 14px;
            outline: none;
            box-sizing: border-box;
            margin-bottom: 20px;
            transition: border-color 0.25s;
        }

        input[type="email"]:focus {
            border-color: #1f3b57;
            box-shadow: 0 0 6px rgba(31,59,87,0.2);
        }

        .btn-enviar {
            width: 100%;
            background-color: #1f3b57;
            color: white;
            border: none;
            padding: 13px;
            border-radius: 8px;
            font-size: 15px;
            cursor: pointer;
            transition: background-color 0.3s;
            margin-bottom: 14px;
        }

        .btn-enviar:hover { background-color: #162d42; }

        .enlace-volver {
            display: block;
            text-align: center;
            color: #6b7280;
            font-size: 13px;
            text-decoration: none;
            transition: color 0.25s;
        }

        .enlace-volver:hover { color: #1f3b57; }

        .alerta-error {
            background: #fee2e2;
            color: #b91c1c;
            border: 1px solid #fca5a5;
            border-radius: 8px;
            padding: 12px 16px;
            font-size: 13px;
            margin-bottom: 18px;
        }

        .alerta-info {
            background: #dbeafe;
            color: #1e40af;
            border: 1px solid #93c5fd;
            border-radius: 8px;
            padding: 12px 16px;
            font-size: 13px;
            margin-bottom: 18px;
        }

        /* Pasos del proceso */
        .pasos {
            display: flex;
            justify-content: center;
            gap: 8px;
            margin-bottom: 28px;
        }

        .paso {
            width: 32px;
            height: 6px;
            border-radius: 4px;
            background-color: #e2e8f0;
        }

        .paso.activo { background-color: #1f3b57; }
    </style>
</head>
<body>

<div class="caja">

    <!-- Logo -->
    <div class="logo">
        <span class="icono">🔐</span>
        <h2>Recuperar contraseña</h2>
        <p>Ingresa tu correo registrado en SADU</p>
    </div>

    <!-- Indicador de pasos: paso 1 de 3 -->
    <div class="pasos">
        <div class="paso activo"></div>
        <div class="paso"></div>
        <div class="paso"></div>
    </div>

    <%-- Alertas --%>
    <% if (error != null) { %>
        <div class="alerta-error">⚠️ <%= error %></div>
    <% } %>

    <% if (info != null) { %>
        <div class="alerta-info">📧 <%= info %></div>
    <% } %>

    <!--
        Formulario paso 1: ingreso del correo.
        Envía por POST al RecuperarPasswordServlet.
    -->
    <form action="recuperarPassword" method="post">
        <label for="correo">Correo electrónico registrado</label>
        <input
            type="email"
            id="correo"
            name="correo"
            placeholder="tu@correo.com"
            required
            autofocus
        >

        <button type="submit" class="btn-enviar">📨 Enviar código de recuperación</button>
        <a href="login.jsp" class="enlace-volver">← Volver al inicio de sesión</a>
    </form>
</div>

</body>
</html>
