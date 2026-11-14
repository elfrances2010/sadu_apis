<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page import="javax.servlet.http.HttpSession" %>

<%
    /*
        Validar si existe una sesión activa.
        Si no existe sesión, se redirige al login.
    */
    HttpSession sesion = request.getSession(false);

    if (sesion == null || sesion.getAttribute("nombreUsuario") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Obtener datos guardados en sesión por LoginServlet
    String nombreUsuario = (String) sesion.getAttribute("nombreUsuario");
    String correoUsuario = (String) sesion.getAttribute("correoUsuario");
    String rolUsuario    = String.valueOf(sesion.getAttribute("rolUsuario"));
    int    idUsuario     = (int) sesion.getAttribute("idUsuario");

    Object dependenciaObj = sesion.getAttribute("dependenciaUsuario");
    String dependenciaUsuario = (dependenciaObj != null) ? dependenciaObj.toString() : "No asignada";
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - SADU</title>

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

    <style>
        /* =============================================
           LAYOUT GENERAL
        ============================================= */
        body {
            margin: 0;
            background-color: #f4f6f9;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        }

        /* =============================================
           CONTENIDO PRINCIPAL
        ============================================= */
        .content {
            margin-left: 230px;
            padding: 25px 30px;
            min-height: 100vh;
        }

        /* Barra superior con nombre y rol */
        .topbar {
            background-color: white;
            padding: 14px 20px;
            border-radius: 10px;
            margin-bottom: 22px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.08);
        }

        /* Caja de bienvenida */
        .welcome-box {
            background: linear-gradient(135deg, #1f3b57, #2f5579);
            color: white;
            border-radius: 14px;
            padding: 25px;
            margin-bottom: 22px;
        }

        /* Tarjetas del dashboard */
        .card-panel {
            border: none;
            border-radius: 12px;
            box-shadow: 0 3px 8px rgba(0,0,0,0.08);
        }
    </style>
</head>
<body>

    <!-- =============================================
         SIDEBAR MENU Y CHAT EMPRESARIAL ICQ
    ============================================= -->
    <%@ include file="sidebar.jsp" %>

    <div class="content">

        <!-- Barra superior -->
        <div class="topbar d-flex justify-content-between align-items-center">
            <div>
                <h4 class="mb-0">Panel principal</h4>
                <small class="text-muted">Sistema de Administraci&oacute;n Documental Unificado</small>
            </div>
            <div class="text-end">
                <a href="manual_usuario.jsp" class="btn btn-outline-primary btn-sm me-2 fw-bold"><i class="bi bi-question-circle me-1"></i> Ayuda / Manual</a>
                <strong><%= nombreUsuario %></strong><br>
                <small>Rol: <%= rolUsuario %> &mdash; Dependencia: <%= dependenciaUsuario %></small>
            </div>
        </div>

        <!-- Bienvenida -->
        <div class="welcome-box">
            <h3>Bienvenido, <%= nombreUsuario %> &#128075;</h3>
            <p class="mb-1">Has iniciado sesi&oacute;n correctamente en el sistema SADU.</p>
            <p class="mb-0">Correo: <%= correoUsuario %></p>
        </div>

        <!-- Tarjetas de acceso rápido -->
        <div class="row g-4">
            <div class="col-md-4">
                <div class="card card-panel p-4">
                    <h5><i class="bi bi-people-fill text-primary me-2"></i> Usuarios registrados</h5>
                    <p class="text-muted">Consulta, administra y controla los usuarios del sistema.</p>
                    <a href="listarUsuarios" class="btn btn-primary">Ver usuarios</a>
                </div>
            </div>

            <div class="col-md-4">
                <div class="card card-panel p-4">
                    <h5><i class="bi bi-person-plus-fill text-success me-2"></i> Registrar usuario</h5>
                    <p class="text-muted">Crea nuevos accesos seg&uacute;n el rol correspondiente.</p>
                    <a href="registrar_usuario.jsp" class="btn btn-success">Registrar</a>
                </div>
            </div>

            <div class="col-md-4">
                <div class="card card-panel p-4">
                    <h5><i class="bi bi-check-circle-fill text-danger me-2"></i> Estado de sesi&oacute;n</h5>
                    <p class="text-muted">Tu sesi&oacute;n est&aacute; activa y lista para seguir trabajando.</p>
                    <a href="logout.jsp" class="btn btn-danger">Cerrar sesi&oacute;n</a>
                </div>
            </div>
        </div>

        <!-- Información del sistema -->
        <div class="card card-panel mt-4 p-4">
            <h4>Informaci&oacute;n del sistema</h4>
            <p>
                Este panel corresponde al proyecto SADU y sirve como punto de acceso
                a los m&oacute;dulos administrativos del sistema.
            </p>
        </div>
    </div>

</body>
</html>
