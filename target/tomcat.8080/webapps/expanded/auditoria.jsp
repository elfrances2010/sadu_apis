<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.sadu.modelo.LogAuditoria" %>
<%@ page import="javax.servlet.http.HttpSession" %>

<%
    /* Validar sesión activa */
    HttpSession sesion = request.getSession(false);
    if (sesion == null || sesion.getAttribute("nombreUsuario") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String nombreUsuario = (String) sesion.getAttribute("nombreUsuario");
    int    rolUsuario    = (int)    sesion.getAttribute("rolUsuario");

    // Solo el Administrador (rol 1) puede ver este módulo
    if (rolUsuario != 1) {
        response.sendRedirect("dashboard.jsp");
        return;
    }

    // Datos enviados por AuditoriaServlet
    List<LogAuditoria> listaLogs    = (List<LogAuditoria>) request.getAttribute("listaLogs");
    Integer totalLogs               = (Integer) request.getAttribute("totalLogs");
    Integer logsHoy                 = (Integer) request.getAttribute("logsHoy");
    Integer usuariosActivos         = (Integer) request.getAttribute("usuariosActivos");
    Boolean busquedaActiva          = (Boolean) request.getAttribute("busquedaActiva");
    Integer totalResultados         = (Integer) request.getAttribute("totalResultados");
    String  error                   = (String)  request.getAttribute("error");

    // Valores previos de búsqueda
    String busAccion     = (String) request.getAttribute("busAccion");
    String busIdUsuario  = (String) request.getAttribute("busIdUsuario");
    String busFechaDesde = (String) request.getAttribute("busFechaDesde");
    String busFechaHasta = (String) request.getAttribute("busFechaHasta");

    // Null safety
    if (busAccion     == null) busAccion     = "";
    if (busIdUsuario  == null) busIdUsuario  = "";
    if (busFechaDesde == null) busFechaDesde = "";
    if (busFechaHasta == null) busFechaHasta = "";
    if (busquedaActiva == null) busquedaActiva = false;
    if (totalLogs       == null) totalLogs       = 0;
    if (logsHoy         == null) logsHoy         = 0;
    if (usuariosActivos == null) usuariosActivos  = 0;
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Auditoría - SADU</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    

    <style>
body { margin:0; background-color:#f4f6f9; font-family:Arial,sans-serif; }

        /* ── Contenido ── */
        .content { margin-left:230px; padding:25px 30px; min-height:100vh; }

        .topbar { background:white; padding:14px 20px; border-radius:10px;
            margin-bottom:22px; box-shadow:0 2px 6px rgba(0,0,0,0.08); }

        /* ── Tarjetas de estadísticas ── */
        .stat-card {
            background:white; border-radius:14px; padding:22px 24px;
            box-shadow:0 3px 10px rgba(0,0,0,0.07);
            display:flex; align-items:center; gap:18px;
        }
        .stat-icono {
            font-size:36px; width:60px; height:60px; border-radius:14px;
            display:flex; align-items:center; justify-content:center;
            flex-shrink:0;
        }
        .stat-icono.azul   { background:#dbeafe; }
        .stat-icono.verde  { background:#d1fae5; }
        .stat-icono.naranja{ background:#fef3c7; }
        .stat-numero { font-size:28px; font-weight:bold; color:#1f3b57; line-height:1; }
        .stat-label  { font-size:13px; color:#6b7280; margin-top:4px; }

        /* ── Tarjeta general ── */
        .card-panel { background:white; border-radius:14px; padding:24px;
            box-shadow:0 3px 10px rgba(0,0,0,0.07); margin-bottom:22px; }
        .card-panel h5 { color:#1f3b57; font-weight:bold; margin-bottom:18px;
            padding-bottom:10px; border-bottom:2px solid #e2e8f0; font-size:16px; }

        /* ── Buscador ── */
        .buscador { display:grid; grid-template-columns:2fr 1fr 1fr 1fr auto auto; gap:12px; align-items:end; }

        label { font-size:13px; font-weight:bold; color:#374151; display:block; margin-bottom:5px; }

        input[type="text"], input[type="date"], input[type="number"], select {
            width:100%; padding:10px 14px; border:1px solid #d1d5db;
            border-radius:8px; font-size:13px; outline:none; box-sizing:border-box;
            transition:border-color 0.25s; }
        input:focus, select:focus { border-color:#1f3b57; box-shadow:0 0 5px rgba(31,59,87,0.2); }

        .btn-buscar { background-color:#1f3b57; color:white; border:none;
            padding:10px 18px; border-radius:8px; font-size:13px; cursor:pointer;
            transition:background-color 0.3s; white-space:nowrap; height:40px; }
        .btn-buscar:hover { background-color:#162d42; }

        .btn-limpiar { background-color:#f1f5f9; color:#374151; border:1px solid #d1d5db;
            padding:10px 16px; border-radius:8px; font-size:13px; cursor:pointer;
            text-decoration:none; display:inline-block; height:40px; line-height:1.4; }
        .btn-limpiar:hover { background-color:#e2e8f0; color:#374151; }

        /* ── Tabla de logs ── */
        .tabla-logs { width:100%; border-collapse:collapse; font-size:13px; }
        .tabla-logs thead tr { background-color:#1f3b57; }
        .tabla-logs thead th { color:white; padding:12px 10px; text-align:left; }
        .tabla-logs tbody tr:nth-child(even) { background-color:#f8fafc; }
        .tabla-logs tbody tr:hover { background-color:#eff6ff; }
        .tabla-logs tbody td { padding:10px; border-bottom:1px solid #e2e8f0; vertical-align:middle; }

        /* ── Badges de acción ── */
        .badge-accion { padding:3px 10px; border-radius:20px; font-size:11px; font-weight:bold; }
        .badge-LOGIN               { background:#dbeafe; color:#1e40af; }
        .badge-LOGOUT              { background:#f3f4f6; color:#374151; }
        .badge-REGISTRO_USUARIO    { background:#d1fae5; color:#065f46; }
        .badge-REGISTRO_DOCUMENTO  { background:#fef3c7; color:#92400e; }
        .badge-REGISTRO_COMUNICACION { background:#ede9fe; color:#5b21b6; }
        .badge-ENVIO_MENSAJE       { background:#fce7f3; color:#9d174d; }
        .badge-RECUPERACION_PASSWORD { background:#fee2e2; color:#b91c1c; }
        .badge-OTRO                { background:#f3f4f6; color:#374151; }

        /* ── Alertas ── */
        .alerta-error { background:#fee2e2; color:#b91c1c; border:1px solid #fca5a5;
            border-radius:10px; padding:13px 16px; margin-bottom:18px; font-size:14px; }
        .alerta-info  { background:#dbeafe; color:#1e40af; border:1px solid #93c5fd;
            border-radius:10px; padding:10px 16px; margin-top:14px; margin-bottom:0; font-size:13px; }

        /* ── Sin resultados ── */
        .sin-resultados { text-align:center; padding:40px; color:#9ca3af; }

        /* ── Detalle del log (texto largo) ── */
        .detalle-log { max-width:280px; overflow:hidden; text-overflow:ellipsis;
            white-space:nowrap; color:#6b7280; }
    </style>
</head>
<body>

<!-- ══════════════════ SIDEBAR ══════════════════ -->

<!-- ══════════════════ CONTENIDO ══════════════════ -->
<%@ include file="sidebar.jsp" %>

<div class="content">

    <!-- Topbar -->
    <div class="topbar d-flex justify-content-between align-items-center">
        <div>
            <h4 class="mb-0">🔍 Auditoría del Sistema</h4>
            <small class="text-muted">Registro de eventos y acciones de los usuarios</small>
        </div>
        <div class="text-end">
            <strong><%= nombreUsuario %></strong><br>
            <small class="text-muted">Administrador</small>
        </div>
    </div>

    <%-- Alerta de error --%>
    <% if (error != null) { %>
        <div class="alerta-error">⚠️ <%= error %></div>
    <% } %>

    <!-- ══ TARJETAS DE ESTADÍSTICAS ══ -->
    <div class="row g-3 mb-4">

        <div class="col-md-4">
            <div class="stat-card">
                <div class="stat-icono azul">📋</div>
                <div>
                    <div class="stat-numero"><%= totalLogs %></div>
                    <div class="stat-label">Total de eventos registrados</div>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="stat-card">
                <div class="stat-icono verde">📅</div>
                <div>
                    <div class="stat-numero"><%= logsHoy %></div>
                    <div class="stat-label">Eventos registrados hoy</div>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="stat-card">
                <div class="stat-icono naranja">👥</div>
                <div>
                    <div class="stat-numero"><%= usuariosActivos %></div>
                    <div class="stat-label">Usuarios con actividad registrada</div>
                </div>
            </div>
        </div>

    </div>

    <!-- ══ BUSCADOR ══ -->
    <div class="card-panel">
        <h5>🔍 Filtrar eventos de auditoría</h5>

        <!--
            Formulario de búsqueda de logs.
            Envía por GET al AuditoriaServlet con accion=buscar.
        -->
        <form action="auditoria" method="get">
            <input type="hidden" name="accion" value="buscar">
            <div class="buscador">

                <div>
                    <label for="busAccion">Acción</label>
                    <select id="busAccion" name="busAccion">
                        <option value="">Todas las acciones</option>
                        <option value="LOGIN"                <%= "LOGIN".equals(busAccion)                ? "selected" : "" %>>🔑 Login</option>
                        <option value="LOGOUT"               <%= "LOGOUT".equals(busAccion)               ? "selected" : "" %>>🚪 Logout</option>
                        <option value="REGISTRO_USUARIO"     <%= "REGISTRO_USUARIO".equals(busAccion)     ? "selected" : "" %>>👤 Registro usuario</option>
                        <option value="REGISTRO_DOCUMENTO"   <%= "REGISTRO_DOCUMENTO".equals(busAccion)   ? "selected" : "" %>>📄 Registro documento</option>
                        <option value="REGISTRO_COMUNICACION"<%= "REGISTRO_COMUNICACION".equals(busAccion)? "selected" : "" %>>📨 Registro comunicación</option>
                        <option value="ENVIO_MENSAJE"        <%= "ENVIO_MENSAJE".equals(busAccion)        ? "selected" : "" %>>💬 Envío mensaje</option>
                        <option value="RECUPERACION_PASSWORD"<%= "RECUPERACION_PASSWORD".equals(busAccion)? "selected" : "" %>>🔐 Recuperación contraseña</option>
                    </select>
                </div>

                <div>
                    <label for="busIdUsuario">ID de usuario</label>
                    <input type="number" id="busIdUsuario" name="busIdUsuario"
                        placeholder="Ej: 3" min="1"
                        value="<%= busIdUsuario %>">
                </div>

                <div>
                    <label for="busFechaDesde">Desde</label>
                    <input type="date" id="busFechaDesde" name="busFechaDesde"
                        value="<%= busFechaDesde %>">
                </div>

                <div>
                    <label for="busFechaHasta">Hasta</label>
                    <input type="date" id="busFechaHasta" name="busFechaHasta"
                        value="<%= busFechaHasta %>">
                </div>

                <div>
                    <label>&nbsp;</label>
                    <button type="submit" class="btn-buscar">🔍 Filtrar</button>
                </div>

                <div>
                    <label>&nbsp;</label>
                    <a href="auditoria?accion=listar" class="btn-limpiar">✖ Limpiar</a>
                </div>

            </div>
        </form>

        <%-- Total de resultados al buscar --%>
        <% if (busquedaActiva && totalResultados != null) { %>
            <div class="alerta-info">
                🔎 Se encontraron <strong><%= totalResultados %></strong>
                evento<%= totalResultados != 1 ? "s" : "" %> con los filtros aplicados.
            </div>
        <% } %>
    </div>

    <!-- ══ TABLA DE LOGS ══ -->
    <div class="card-panel">
        <h5>
            📋 Eventos registrados
            <% if (listaLogs != null) { %>
                <span style="font-size:13px; font-weight:normal; color:#6b7280;">
                    (<%= listaLogs.size() %> mostrados — máximo 500 por consulta)
                </span>
            <% } %>
        </h5>

        <% if (listaLogs != null && !listaLogs.isEmpty()) { %>
            <div style="overflow-x:auto;">
                <table class="tabla-logs">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Fecha y hora</th>
                            <th>Usuario</th>
                            <th>Acción</th>
                            <th>Detalle</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (LogAuditoria log : listaLogs) {
                            // Determinar clase CSS del badge según la acción
                            String badgeClase = "badge-OTRO";
                            String accionLog = log.getAccion() != null ? log.getAccion() : "";
                            if (accionLog.equals("LOGIN"))                badgeClase = "badge-LOGIN";
                            else if (accionLog.equals("LOGOUT"))          badgeClase = "badge-LOGOUT";
                            else if (accionLog.equals("REGISTRO_USUARIO")) badgeClase = "badge-REGISTRO_USUARIO";
                            else if (accionLog.equals("REGISTRO_DOCUMENTO")) badgeClase = "badge-REGISTRO_DOCUMENTO";
                            else if (accionLog.equals("REGISTRO_COMUNICACION")) badgeClase = "badge-REGISTRO_COMUNICACION";
                            else if (accionLog.equals("ENVIO_MENSAJE"))   badgeClase = "badge-ENVIO_MENSAJE";
                            else if (accionLog.equals("RECUPERACION_PASSWORD")) badgeClase = "badge-RECUPERACION_PASSWORD";
                        %>
                            <tr>
                                <td style="color:#9ca3af; font-size:12px;"><%= log.getIdLog() %></td>
                                <td style="white-space:nowrap; font-size:12px; color:#374151;">
                                    <%= log.getFechaLog() != null ? log.getFechaLog().toString().substring(0, 19) : "—" %>
                                </td>
                                <td>
                                    <strong style="color:#1f3b57;"><%= log.getNombreUsuario() %></strong><br>
                                    <small style="color:#9ca3af;">ID: <%= log.getIdUsuario() %></small>
                                </td>
                                <td>
                                    <span class="badge-accion <%= badgeClase %>">
                                        <%= accionLog %>
                                    </span>
                                </td>
                                <td class="detalle-log" title="<%= log.getDetalle() != null ? log.getDetalle() : "" %>">
                                    <%= log.getDetalle() != null && !log.getDetalle().isEmpty()
                                        ? log.getDetalle() : "—" %>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

        <% } else { %>
            <div class="sin-resultados">
                <p style="font-size:40px; margin-bottom:10px;">📭</p>
                <% if (busquedaActiva) { %>
                    <p>No se encontraron eventos con los filtros aplicados.</p>
                    <a href="auditoria?accion=listar" style="color:#1f3b57;">Ver todos los eventos</a>
                <% } else { %>
                    <p>Aún no hay eventos registrados en el sistema.</p>
                    <p style="font-size:13px;">
                        Los eventos se registran automáticamente cuando los usuarios
                        realizan acciones en el sistema.
                    </p>
                <% } %>
            </div>
        <% } %>
    </div>

</div><!-- fin content -->

</body>
</html>
