<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.sadu.modelo.Comunicacion" %>
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

    // Solo roles 1 y 2 pueden acceder
    if (rolUsuario != 1 && rolUsuario != 2) {
        response.sendRedirect("acceso_denegado.jsp");
        return;
    }

    // Datos enviados por ComunicacionServlet
    List<Comunicacion> listaComunicaciones = (List<Comunicacion>) request.getAttribute("listaComunicaciones");
    String radicadoSugerido = (String)  request.getAttribute("radicadoSugerido");
    String error            = (String)  request.getAttribute("error");
    Boolean busquedaActiva  = (Boolean) request.getAttribute("busquedaActiva");
    Integer totalResultados = (Integer) request.getAttribute("totalResultados");

    // Valores previos de búsqueda
    String busAsunto      = (String) request.getAttribute("busAsunto");
    String busTipo        = (String) request.getAttribute("busTipo");
    String busEstado      = (String) request.getAttribute("busEstado");
    String busDependencia = (String) request.getAttribute("busDependencia");

    // Mensaje de éxito desde URL
    String exito = request.getParameter("exito");

    // Null safety
    if (busAsunto      == null) busAsunto      = "";
    if (busTipo        == null) busTipo        = "";
    if (busEstado      == null) busEstado      = "";
    if (busDependencia == null) busDependencia = "";
    if (busquedaActiva == null) busquedaActiva = false;
    if (radicadoSugerido == null) radicadoSugerido = "";
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Comunicaciones - SADU</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    

    <style>
body { margin:0; background-color:#f4f6f9; font-family:Arial,sans-serif; }

        /* ── Contenido ── */
        .content { margin-left:230px; padding:25px 30px; min-height:100vh; }

        .topbar { background:white; padding:14px 20px; border-radius:10px;
            margin-bottom:22px; box-shadow:0 2px 6px rgba(0,0,0,0.08); }

        /* ── Tarjeta general ── */
        .card-panel { background:white; border-radius:14px; padding:24px;
            box-shadow:0 3px 10px rgba(0,0,0,0.07); margin-bottom:22px; }
        .card-panel h5 { color:#1f3b57; font-weight:bold; margin-bottom:18px;
            padding-bottom:10px; border-bottom:2px solid #e2e8f0; font-size:16px; }

        /* ── Formulario ── */
        .form-grid { display:grid; grid-template-columns:1fr 1fr; gap:16px; }
        .form-grid .full { grid-column:1 / -1; }

        label { font-size:13px; font-weight:bold; color:#374151; display:block; margin-bottom:5px; }

        input[type="text"], input[type="date"], select, textarea {
            width:100%; padding:10px 14px; border:1px solid #d1d5db;
            border-radius:8px; font-size:13px; outline:none; box-sizing:border-box;
            transition:border-color 0.25s; background:white; }
        input:focus, select:focus, textarea:focus {
            border-color:#1f3b57; box-shadow:0 0 5px rgba(31,59,87,0.2); }

        .requerido { color:#dc2626; margin-left:2px; }

        .btn-radicar { background-color:#1f3b57; color:white; border:none;
            padding:11px 24px; border-radius:8px; font-size:14px; cursor:pointer;
            transition:background-color 0.3s; }
        .btn-radicar:hover { background-color:#162d42; }

        /* ── Buscador ── */
        .buscador { display:grid; grid-template-columns:2fr 1fr 1fr 1fr auto auto; gap:12px; align-items:end; }

        .btn-buscar { background-color:#2d6a4f; color:white; border:none;
            padding:10px 18px; border-radius:8px; font-size:13px; cursor:pointer;
            height:40px; white-space:nowrap; }
        .btn-buscar:hover { background-color:#1b4332; }

        .btn-limpiar { background-color:#f1f5f9; color:#374151; border:1px solid #d1d5db;
            padding:10px 16px; border-radius:8px; font-size:13px; text-decoration:none;
            display:inline-block; height:40px; line-height:1.4; }
        .btn-limpiar:hover { background-color:#e2e8f0; color:#374151; }

        /* ── Tabla ── */
        .tabla-comunicaciones { width:100%; border-collapse:collapse; font-size:13px; }
        .tabla-comunicaciones thead tr { background-color:#1f3b57; }
        .tabla-comunicaciones thead th { color:white; padding:12px 10px; text-align:left; }
        .tabla-comunicaciones tbody tr:nth-child(even) { background-color:#f8fafc; }
        .tabla-comunicaciones tbody tr:hover { background-color:#eff6ff; }
        .tabla-comunicaciones tbody td { padding:10px; border-bottom:1px solid #e2e8f0; vertical-align:middle; }

        /* ── Badges ── */
        .badge-tipo-INTERNA  { background:#dbeafe; color:#1e40af; padding:3px 10px; border-radius:20px; font-size:11px; font-weight:bold; }
        .badge-tipo-EXTERNA  { background:#fef3c7; color:#92400e; padding:3px 10px; border-radius:20px; font-size:11px; font-weight:bold; }
        .badge-estado { padding:3px 10px; border-radius:20px; font-size:11px; font-weight:bold; }
        .badge-RECIBIDA   { background:#d1fae5; color:#065f46; }
        .badge-EN_TRAMITE { background:#fef3c7; color:#92400e; }
        .badge-RESPONDIDA { background:#dbeafe; color:#1e40af; }

        /* ── Selector de estado en tabla ── */
        .select-estado { padding:4px 8px; border:1px solid #d1d5db; border-radius:6px;
            font-size:12px; cursor:pointer; outline:none; background:white; }

        /* ── Alertas ── */
        .alerta-error  { background:#fee2e2; color:#b91c1c; border:1px solid #fca5a5;
            border-radius:10px; padding:13px 16px; margin-bottom:18px; font-size:14px; }
        .alerta-exito  { background:#d1fae5; color:#065f46; border:1px solid #6ee7b7;
            border-radius:10px; padding:13px 16px; margin-bottom:18px; font-size:14px; }
        .alerta-info   { background:#dbeafe; color:#1e40af; border:1px solid #93c5fd;
            border-radius:10px; padding:10px 16px; margin-top:14px; margin-bottom:0; font-size:13px; }

        /* ── Sin resultados ── */
        .sin-resultados { text-align:center; padding:40px; color:#9ca3af; }
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
            <h4 class="mb-0">📨 Gestión de Comunicaciones</h4>
            <small class="text-muted">Radica y gestiona las comunicaciones oficiales internas y externas</small>
        </div>
        <div class="text-end">
            <strong><%= nombreUsuario %></strong><br>
            <small class="text-muted">Sesión activa</small>
        </div>
    </div>

    <%-- Alertas --%>
    <% if (error != null) { %>
        <div class="alerta-error">⚠️ <%= error %></div>
    <% } %>
    <% if ("1".equals(exito)) { %>
        <div class="alerta-exito">✅ Comunicación radicada correctamente en el sistema.</div>
    <% } %>

    <!-- ══ FORMULARIO DE RADICACIÓN ══ -->
    <div class="card-panel">
        <h5>📋 Radicar nueva comunicación</h5>

        <form action="comunicaciones" method="post">
            <input type="hidden" name="accion" value="radicar">

            <div class="form-grid">

                <!-- Número de radicado -->
                <div>
                    <label for="radicado">Número de radicado <span class="requerido">*</span></label>
                    <input type="text" id="radicado" name="radicado"
                        value="<%= radicadoSugerido %>"
                        placeholder="Ej: RAD-2025-001"
                        maxlength="30" required
                        style="text-transform:uppercase;">
                </div>

                <!-- Tipo de comunicación -->
                <div>
                    <label for="tipo">Tipo <span class="requerido">*</span></label>
                    <select id="tipo" name="tipo" required>
                        <option value="" disabled selected>-- Selecciona --</option>
                        <option value="INTERNA">📄 Interna</option>
                        <option value="EXTERNA">📬 Externa</option>
                    </select>
                </div>

                <!-- Asunto (ancho completo) -->
                <div class="full">
                    <label for="asunto">Asunto <span class="requerido">*</span></label>
                    <input type="text" id="asunto" name="asunto"
                        placeholder="Ej: Solicitud de información sobre contrato 2025-001"
                        maxlength="200" required>
                </div>

                <!-- Dependencia -->
                <div>
                    <label for="dependencia">Dependencia <span class="requerido">*</span></label>
                    <select id="dependencia" name="dependencia" required>
                        <option value="" disabled selected>-- Selecciona --</option>
                        <option value="Alcaldía">Alcaldía</option>
                        <option value="Secretaría General">Secretaría General</option>
                        <option value="Secretaría de Hacienda">Secretaría de Hacienda</option>
                        <option value="Secretaría de Planeación">Secretaría de Planeación</option>
                        <option value="Secretaría de Educación">Secretaría de Educación</option>
                        <option value="Secretaría de Salud">Secretaría de Salud</option>
                        <option value="Secretaría de Obras">Secretaría de Obras</option>
                        <option value="Personería">Personería</option>
                        <option value="Contraloría">Contraloría</option>
                        <option value="Concejo Municipal">Concejo Municipal</option>
                        <option value="Otra">Otra</option>
                    </select>
                </div>

                <!-- Fecha -->
                <div>
                    <label for="fechaComunicacion">Fecha de la comunicación <span class="requerido">*</span></label>
                    <input type="date" id="fechaComunicacion" name="fechaComunicacion" required>
                </div>

                <!-- Estado inicial -->
                <div>
                    <label for="estado">Estado inicial</label>
                    <select id="estado" name="estado">
                        <option value="RECIBIDA" selected>📥 Recibida</option>
                        <option value="EN_TRAMITE">⚙️ En trámite</option>
                        <option value="RESPONDIDA">✅ Respondida</option>
                    </select>
                </div>

            </div>

            <div style="margin-top:18px;">
                <button type="submit" class="btn-radicar">📨 Radicar comunicación</button>
            </div>
        </form>
    </div>

    <!-- ══ BUSCADOR ══ -->
    <div class="card-panel">
        <h5>🔍 Buscar comunicaciones</h5>

        <form action="comunicaciones" method="get">
            <input type="hidden" name="accion" value="buscar">
            <div class="buscador">

                <div>
                    <label for="busAsunto">Asunto</label>
                    <input type="text" id="busAsunto" name="busAsunto"
                        placeholder="Buscar por asunto..."
                        value="<%= busAsunto %>">
                </div>

                <div>
                    <label for="busTipo">Tipo</label>
                    <select id="busTipo" name="busTipo">
                        <option value="">Todos</option>
                        <option value="INTERNA" <%= "INTERNA".equals(busTipo) ? "selected" : "" %>>Interna</option>
                        <option value="EXTERNA" <%= "EXTERNA".equals(busTipo) ? "selected" : "" %>>Externa</option>
                    </select>
                </div>

                <div>
                    <label for="busEstado">Estado</label>
                    <select id="busEstado" name="busEstado">
                        <option value="">Todos</option>
                        <option value="RECIBIDA"   <%= "RECIBIDA".equals(busEstado)   ? "selected" : "" %>>Recibida</option>
                        <option value="EN_TRAMITE" <%= "EN_TRAMITE".equals(busEstado) ? "selected" : "" %>>En trámite</option>
                        <option value="RESPONDIDA" <%= "RESPONDIDA".equals(busEstado) ? "selected" : "" %>>Respondida</option>
                    </select>
                </div>

                <div>
                    <label>&nbsp;</label>
                    <button type="submit" class="btn-buscar">🔍 Buscar</button>
                </div>

                <div>
                    <label>&nbsp;</label>
                    <a href="comunicaciones?accion=listar" class="btn-limpiar">✖ Limpiar</a>
                </div>

            </div>
        </form>

        <% if (busquedaActiva && totalResultados != null) { %>
            <div class="alerta-info">
                🔎 Se encontraron <strong><%= totalResultados %></strong>
                comunicación<%= totalResultados != 1 ? "es" : "" %> con los filtros aplicados.
            </div>
        <% } %>
    </div>

    <!-- ══ LISTADO DE COMUNICACIONES ══ -->
    <div class="card-panel">
        <h5>
            📋 Comunicaciones registradas
            <% if (listaComunicaciones != null) { %>
                <span style="font-size:13px; font-weight:normal; color:#6b7280;">
                    (<%= listaComunicaciones.size() %> en total)
                </span>
            <% } %>
        </h5>

        <% if (listaComunicaciones != null && !listaComunicaciones.isEmpty()) { %>
            <div style="overflow-x:auto;">
                <table class="tabla-comunicaciones">
                    <thead>
                        <tr>
                            <th>Radicado</th>
                            <th>Tipo</th>
                            <th>Asunto</th>
                            <th>Dependencia</th>
                            <th>Fecha</th>
                            <th>Estado</th>
                            <th>Radicado por</th>
                            <th>Cambiar estado</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Comunicacion com : listaComunicaciones) { %>
                            <tr>
                                <td><strong style="color:#1f3b57;"><%= com.getRadicado() %></strong></td>
                                <td>
                                    <span class="badge-tipo-<%= com.getTipo() %>">
                                        <%= com.getTipo() %>
                                    </span>
                                </td>
                                <td style="max-width:220px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;"
                                    title="<%= com.getAsunto() %>">
                                    <%= com.getAsunto() %>
                                </td>
                                <td><%= com.getDependencia() %></td>
                                <td style="white-space:nowrap;">
                                    <%= com.getFechaComunicacion() != null ? com.getFechaComunicacion().toString() : "—" %>
                                </td>
                                <td>
                                    <span class="badge-estado badge-<%= com.getEstado() %>">
                                        <%= com.getEstado() %>
                                    </span>
                                </td>
                                <td><%= com.getNombreUsuario() %></td>
                                <td>
                                    <!--
                                        Formulario inline para cambiar el estado
                                        directamente desde la tabla sin salir de la página
                                    -->
                                    <form action="comunicaciones" method="post"
                                          style="display:flex; gap:6px; align-items:center;">
                                        <input type="hidden" name="accion" value="cambiarEstado">
                                        <input type="hidden" name="idComunicacion" value="<%= com.getIdComunicacion() %>">
                                        <select name="nuevoEstado" class="select-estado">
                                            <option value="RECIBIDA"   <%= "RECIBIDA".equals(com.getEstado())   ? "selected" : "" %>>📥 Recibida</option>
                                            <option value="EN_TRAMITE" <%= "EN_TRAMITE".equals(com.getEstado()) ? "selected" : "" %>>⚙️ En trámite</option>
                                            <option value="RESPONDIDA" <%= "RESPONDIDA".equals(com.getEstado()) ? "selected" : "" %>>✅ Respondida</option>
                                        </select>
                                        <button type="submit"
                                            style="background:#2d6a4f; color:white; border:none;
                                                   padding:4px 10px; border-radius:6px; font-size:12px; cursor:pointer;">
                                            ✔
                                        </button>
                                    </form>
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
                    <p>No se encontraron comunicaciones con los filtros aplicados.</p>
                    <a href="comunicaciones?accion=listar" style="color:#1f3b57;">Ver todas las comunicaciones</a>
                <% } else { %>
                    <p>Aún no hay comunicaciones radicadas en el sistema.</p>
                    <p style="font-size:13px;">Usa el formulario de arriba para radicar la primera comunicación.</p>
                <% } %>
            </div>
        <% } %>
    </div>

</div>

</body>
</html>
