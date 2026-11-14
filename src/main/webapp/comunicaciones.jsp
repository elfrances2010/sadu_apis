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

    Object rolObj = sesion.getAttribute("rolUsuario");
    int rolUsuario = 0;
    if (rolObj instanceof Integer) {
        rolUsuario = (Integer) rolObj;
    } else if (rolObj != null) {
        try { rolUsuario = Integer.parseInt(rolObj.toString()); } catch (Exception e) {}
    }

    if (rolUsuario != 1 && rolUsuario != 2) {
        response.sendRedirect("acceso_denegado.jsp");
        return;
    }

    String nombreUsuario = (String) sesion.getAttribute("nombreUsuario");

    List<Comunicacion> listaComunicaciones = (List<Comunicacion>) request.getAttribute("listaComunicaciones");
    if (listaComunicaciones == null) {
        response.sendRedirect("comunicaciones");
        return;
    }

    String radicadoSugerido = (String)  request.getAttribute("radicadoSugerido");
    String error            = (String)  request.getAttribute("error");
    Boolean busquedaActiva  = (Boolean) request.getAttribute("busquedaActiva");
    Integer totalResultados = (Integer) request.getAttribute("totalResultados");

    String busAsunto      = (String) request.getAttribute("busAsunto");
    String busTipo        = (String) request.getAttribute("busTipo");
    String busEstado      = (String) request.getAttribute("busEstado");
    String busDependencia = (String) request.getAttribute("busDependencia");

    String exito = request.getParameter("exito");

    if (busquedaActiva  == null) busquedaActiva  = false;
    if (totalResultados == null) totalResultados = 0;
    if (busAsunto       == null) busAsunto       = "";
    if (busTipo         == null) busTipo         = "";
    if (busEstado       == null) busEstado       = "";
    if (busDependencia  == null) busDependencia  = "";
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

    <%
        int countTotal = listaComunicaciones != null ? listaComunicaciones.size() : 0;
        int countAtiempo = 0;
        int countPorVencer = 0;
        int countVencidas = 0;
        int countRespondidas = 0;
        long hoyMillis = new java.util.Date().getTime();

        if (listaComunicaciones != null) {
            for (Comunicacion c : listaComunicaciones) {
                if ("RESPONDIDA".equalsIgnoreCase(c.getEstado())) {
                    countRespondidas++;
                } else if (c.getFechaComunicacion() != null) {
                    long dias = (hoyMillis - c.getFechaComunicacion().getTime()) / (1000L * 60 * 60 * 24);
                    long restantes = 15 - dias;
                    if (restantes < 0) countVencidas++;
                    else if (restantes <= 5) countPorVencer++;
                    else countAtiempo++;
                } else {
                    countAtiempo++;
                }
            }
        }
    %>

    <!-- ══ DASHBOARD SEMÁFORO DE VENCIMIENTOS (LEY 1755 DE 2015) ══ -->
    <div style="display:grid; grid-template-columns:repeat(auto-fit, minmax(210px, 1fr)); gap:14px; margin-bottom:20px;">
        <div style="background:white; border-radius:12px; padding:16px; border-left:4px solid #1f3b57; box-shadow:0 2px 6px rgba(0,0,0,0.05);">
            <small style="color:#64748b; font-size:11px; font-weight:bold; text-transform:uppercase;">Total Comunicaciones</small>
            <div style="font-size:24px; font-weight:bold; color:#1f3b57;"><%= countTotal %></div>
            <small style="color:#10b981; font-size:11.5px;"><i class="bi bi-check2-circle"></i> <%= countRespondidas %> respondidas</small>
        </div>
        <div style="background:white; border-radius:12px; padding:16px; border-left:4px solid #10b981; box-shadow:0 2px 6px rgba(0,0,0,0.05);">
            <small style="color:#065f46; font-size:11px; font-weight:bold; text-transform:uppercase;">🟢 A Tiempo (&gt; 5 días)</small>
            <div style="font-size:24px; font-weight:bold; color:#10b981;"><%= countAtiempo %></div>
            <small style="color:#64748b; font-size:11.5px;">En término legal ordinario</small>
        </div>
        <div style="background:white; border-radius:12px; padding:16px; border-left:4px solid #f59e0b; box-shadow:0 2px 6px rgba(0,0,0,0.05);">
            <small style="color:#92400e; font-size:11px; font-weight:bold; text-transform:uppercase;">🟡 Alerta: Por Vencer (≤ 5 días)</small>
            <div style="font-size:24px; font-weight:bold; color:#f59e0b;"><%= countPorVencer %></div>
            <small style="color:#92400e; font-size:11.5px;">Requiere atención prioritaria</small>
        </div>
        <div style="background:white; border-radius:12px; padding:16px; border-left:4px solid #ef4444; box-shadow:0 2px 6px rgba(0,0,0,0.05);">
            <small style="color:#991b1b; font-size:11px; font-weight:bold; text-transform:uppercase;">🔴 Vencidas (Término Expirado)</small>
            <div style="font-size:24px; font-weight:bold; color:#ef4444;"><%= countVencidas %></div>
            <small style="color:#ef4444; font-size:11.5px;">Incumplimiento legal PQRSD</small>
        </div>
    </div>

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
                    <select id="tipo" name="tipo" required onchange="toggleProcedenciaTerritorial()">
                        <option value="" disabled selected>-- Selecciona --</option>
                        <option value="INTERNA">📄 Interna</option>
                        <option value="EXTERNA">📬 Externa</option>
                    </select>
                </div>

                <!-- Procedencia Territorial (Ventanilla Única / Datos sincronizados locales) -->
                <div id="bloqueProcedencia" style="display:none;" class="full p-3 bg-light border rounded">
                    <label style="color:#1f3b57; margin-bottom:8px;">
                        <i class="bi bi-geo-alt-fill text-danger me-1"></i> Procedencia Geográfica del Remitente (Ventanilla Única AGN):
                    </label>
                    <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px;">
                        <div>
                            <small class="text-muted d-block mb-1">1. Departamento de Origen:</small>
                            <select id="selDeptoProcedencia" onchange="cargarMunicipiosProcedencia()">
                                <option value="">-- Selecciona Departamento --</option>
                            </select>
                        </div>
                        <div>
                            <small class="text-muted d-block mb-1">2. Municipio Remitente:</small>
                            <select id="selMunicipioProcedencia" onchange="fijarMunicipioProcedencia()">
                                <option value="">-- Primero selecciona departamento --</option>
                            </select>
                        </div>
                    </div>
                    <input type="hidden" id="municipioProcedencia" name="municipioProcedencia" value="">
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
                            <th>Procedencia</th>
                            <th>Asunto</th>
                            <th>Dependencia</th>
                            <th>Fecha</th>
                            <th>Semáforo SLA</th>
                            <th>Estado</th>
                            <th>Gestión</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Comunicacion com : listaComunicaciones) { 
                            long diasTrans = 0;
                            long diasRestantes = 15;
                            if (com.getFechaComunicacion() != null) {
                                diasTrans = (hoyMillis - com.getFechaComunicacion().getTime()) / (1000L * 60 * 60 * 24);
                                diasRestantes = 15 - diasTrans;
                            }
                        %>
                            <tr>
                                <td><strong style="color:#1f3b57;"><%= com.getRadicado() %></strong></td>
                                <td>
                                    <span class="badge-tipo-<%= com.getTipo() %>">
                                        <%= com.getTipo() %>
                                    </span>
                                </td>
                                <td>
                                    <% if (com.getMunicipioProcedencia() != null && !com.getMunicipioProcedencia().trim().isEmpty()) { %>
                                        <span class="badge bg-light text-dark border" style="font-size:11px;">
                                            <i class="bi bi-geo-alt-fill text-danger me-1"></i><%= com.getMunicipioProcedencia() %>
                                        </span>
                                    <% } else { %>
                                        <span class="text-muted" style="font-size:11px;">— Sede Interna —</span>
                                    <% } %>
                                </td>
                                <td style="max-width:200px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;"
                                    title="<%= com.getAsunto() %>">
                                    <%= com.getAsunto() %>
                                </td>
                                <td><%= com.getDependencia() %></td>
                                <td style="white-space:nowrap;">
                                    <%= com.getFechaComunicacion() != null ? com.getFechaComunicacion().toString() : "—" %>
                                </td>
                                <td>
                                    <% if ("RESPONDIDA".equalsIgnoreCase(com.getEstado())) { %>
                                        <span class="badge bg-success text-white" style="font-size:11px;">
                                            <i class="bi bi-check2-all"></i> Finalizada
                                        </span>
                                    <% } else if (diasRestantes < 0) { %>
                                        <span class="badge bg-danger text-white" style="font-size:11px;" title="Vencida hace <%= Math.abs(diasRestantes) %> días">
                                            <i class="bi bi-exclamation-octagon-fill me-1"></i> Vencida (+<%= Math.abs(diasRestantes) %>d)
                                        </span>
                                    <% } else if (diasRestantes <= 5) { %>
                                        <span class="badge bg-warning text-dark" style="font-size:11px;" title="Término próximo a vencer">
                                            <i class="bi bi-hourglass-split me-1"></i> Por vencer (<%= diasRestantes %>d)
                                        </span>
                                    <% } else { %>
                                        <span class="badge bg-success text-white" style="font-size:11px;" title="En término ordinario">
                                            <i class="bi bi-shield-check me-1"></i> A tiempo (<%= diasRestantes %>d)
                                        </span>
                                    <% } %>
                                </td>
                                <td>
                                    <span class="badge-estado badge-<%= com.getEstado() %>">
                                        <%= com.getEstado() %>
                                    </span>
                                </td>
                                <td>
                                    <div style="display:flex; gap:6px; align-items:center;">
                                        <!-- Formulario inline para cambiar el estado -->
                                        <form action="comunicaciones" method="post"
                                              style="display:flex; gap:4px; align-items:center; margin:0;">
                                            <input type="hidden" name="accion" value="cambiarEstado">
                                            <input type="hidden" name="idComunicacion" value="<%= com.getIdComunicacion() %>">
                                            <select name="nuevoEstado" class="select-estado" style="font-size:11.5px; padding:3px 6px;">
                                                <option value="RECIBIDA"   <%= "RECIBIDA".equals(com.getEstado())   ? "selected" : "" %>>Recibida</option>
                                                <option value="EN_TRAMITE" <%= "EN_TRAMITE".equals(com.getEstado()) ? "selected" : "" %>>En trámite</option>
                                                <option value="RESPONDIDA" <%= "RESPONDIDA".equals(com.getEstado()) ? "selected" : "" %>>Respondida</option>
                                            </select>
                                            <button type="submit" title="Guardar estado"
                                                style="background:#2d6a4f; color:white; border:none; padding:3px 8px; border-radius:6px; font-size:11px; cursor:pointer;">
                                                ✔
                                            </button>
                                        </form>

                                        <!-- Botón Sticker Oficial con QR -->
                                        <button type="button" class="btn btn-sm btn-outline-dark" style="padding:2px 7px; font-size:12px;"
                                                title="Ver e Imprimir Sticker Oficial con QR"
                                                onclick="mostrarSticker('<%= com.getRadicado() %>', '<%= com.getFechaComunicacion() %>', '<%= com.getTipo() %>', '<%= com.getMunicipioProcedencia() != null ? com.getMunicipioProcedencia().replace("'", "\\'") : "Sede Interna" %>', '<%= com.getDependencia() %>', '<%= com.getAsunto().replace("'", "\\'").replace("\"", "&quot;") %>')">
                                            <i class="bi bi-qr-code"></i>
                                        </button>
                                    </div>
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

<!-- MODAL STICKER OFICIAL DE RADICACIÓN CON QR -->
<div class="modal fade" id="modalStickerRadicado" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header bg-dark text-white" style="background:#1f3b57 !important;">
                <h5 class="modal-title" style="font-size:15px; font-weight:bold;">
                    <i class="bi bi-qr-code me-1"></i> Comprobante Oficial de Radicación
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4 text-center">
                <!-- Sticker Impreso (Estilo Etiqueta AGN) -->
                <div id="areaStickerImpresion" style="border:2px dashed #1f3b57; border-radius:10px; padding:18px; background:#fff; text-align:left; box-shadow:0 3px 10px rgba(0,0,0,0.06);">
                    <div style="display:flex; justify-content:space-between; align-items:center; border-bottom:2px solid #1f3b57; padding-bottom:8px; margin-bottom:12px;">
                        <div>
                            <strong style="color:#1f3b57; font-size:15px; letter-spacing:1px;">SADU ARCHIVO DIGITAL</strong><br>
                            <small style="color:#64748b; font-size:11px;">VENTANILLA ÚNICA DE CORRESPONDENCIA</small>
                        </div>
                        <span class="badge bg-dark text-white" id="stkTipo" style="font-size:11px;">EXTERNA</span>
                    </div>

                    <div style="display:flex; gap:14px; align-items:center;">
                        <div id="stkQrContainer" style="text-align:center;">
                            <img id="stkQrImg" src="" alt="QR Radicado" style="width:110px; height:110px; border:1px solid #cbd5e1; border-radius:6px; padding:3px;">
                            <small class="d-block text-muted" style="font-size:9.5px; margin-top:2px;">Verificación Digital</small>
                        </div>
                        <div style="flex:1; font-size:12px; line-height:1.45; color:#1e293b;">
                            <div><strong>RADICADO:</strong> <span id="stkRadicado" style="color:#1f3b57; font-size:14px; font-weight:bold;">RAD-2026-001</span></div>
                            <div><strong>FECHA / HORA:</strong> <span id="stkFecha">2026-11-14</span></div>
                            <div><strong>PROCEDENCIA:</strong> <span id="stkProcedencia" class="text-danger fw-bold">Pasto (Nariño)</span></div>
                            <div><strong>DESTINO:</strong> <span id="stkDependencia">Secretaría General</span></div>
                            <div style="margin-top:4px;"><strong>ASUNTO:</strong> <span id="stkAsunto" style="font-size:11px; color:#475569;">Petición ciudadana...</span></div>
                        </div>
                    </div>

                    <div style="border-top:1px solid #e2e8f0; margin-top:12px; padding-top:6px; font-size:9.5px; color:#94a3b8; text-align:center;">
                        Constancia de radicación oficial generada conforme a la Ley 1755 de 2015 y normas del AGN Colombia.
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cerrar</button>
                <button type="button" class="btn btn-primary btn-sm fw-bold" onclick="imprimirSticker()">
                    <i class="bi bi-printer me-1"></i> Imprimir Sticker
                </button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
let deptosCargados = false;

function mostrarSticker(radicado, fecha, tipo, procedencia, dependencia, asunto) {
    document.getElementById("stkRadicado").innerText = radicado;
    document.getElementById("stkFecha").innerText = fecha;
    document.getElementById("stkTipo").innerText = tipo;
    document.getElementById("stkProcedencia").innerText = procedencia;
    document.getElementById("stkDependencia").innerText = dependencia;
    document.getElementById("stkAsunto").innerText = asunto;

    // Generar Código QR de verificación oficial
    const qrData = encodeURIComponent("SADU-RADICADO:" + radicado + "|FECHA:" + fecha + "|PROCEDENCIA:" + procedencia + "|SADU-VERIFIED");
    document.getElementById("stkQrImg").src = "https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=" + qrData;

    const modal = new bootstrap.Modal(document.getElementById("modalStickerRadicado"));
    modal.show();
}

function imprimirSticker() {
    const contenido = document.getElementById("areaStickerImpresion").innerHTML;
    const ventana = window.open('', '_blank', 'width=500,height=400');
    ventana.document.write('<html><head><title>Sticker Radicado</title>');
    ventana.document.write('<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">');
    ventana.document.write('</head><body style="padding:20px; font-family:sans-serif;" onload="window.print(); window.close();">');
    ventana.document.write(contenido);
    ventana.document.write('</body></html>');
    ventana.document.close();
}
let deptosCargados = false;

function toggleProcedenciaTerritorial() {
    const tipo = document.getElementById("tipo").value;
    const bloque = document.getElementById("bloqueProcedencia");
    if (tipo === "EXTERNA") {
        bloque.style.display = "block";
        if (!deptosCargados) {
            cargarDepartamentos();
        }
    } else {
        bloque.style.display = "none";
        document.getElementById("municipioProcedencia").value = "";
    }
}

function cargarDepartamentos() {
    fetch("TerritorioLocalServlet?accion=departamentos")
        .then(r => r.json())
        .then(data => {
            const sel = document.getElementById("selDeptoProcedencia");
            sel.innerHTML = '<option value="">-- Selecciona Departamento --</option>';
            data.forEach(d => {
                sel.innerHTML += '<option value="' + d.id + '">' + d.nombre + '</option>';
            });
            deptosCargados = true;
        })
        .catch(err => console.error("Error al cargar departamentos:", err));
}

function cargarMunicipiosProcedencia() {
    const deptoId = document.getElementById("selDeptoProcedencia").value;
    const selMuni = document.getElementById("selMunicipioProcedencia");
    if (!deptoId) {
        selMuni.innerHTML = '<option value="">-- Primero selecciona departamento --</option>';
        document.getElementById("municipioProcedencia").value = "";
        return;
    }
    selMuni.innerHTML = '<option value="">Cargando municipios...</option>';
    fetch("TerritorioLocalServlet?accion=municipios&departamentoId=" + encodeURIComponent(deptoId))
        .then(r => r.json())
        .then(data => {
            selMuni.innerHTML = '<option value="">-- Selecciona Municipio --</option>';
            data.forEach(m => {
                selMuni.innerHTML += '<option value="' + m.nombre + '">' + m.nombre + '</option>';
            });
        })
        .catch(err => console.error("Error al cargar municipios:", err));
}

function fijarMunicipioProcedencia() {
    const selMuni = document.getElementById("selMunicipioProcedencia");
    const selDepto = document.getElementById("selDeptoProcedencia");
    if (selMuni.value) {
        const nomDepto = selDepto.options[selDepto.selectedIndex].text;
        document.getElementById("municipioProcedencia").value = selMuni.value + " (" + nomDepto + ")";
    } else {
        document.getElementById("municipioProcedencia").value = "";
    }
}
</script>

</body>
</html>
