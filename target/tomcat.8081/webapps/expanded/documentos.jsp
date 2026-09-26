<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.sadu.modelo.Documento" %>
<%@ page import="javax.servlet.http.HttpSession" %>

<%
    /* Validar sesión activa */
    HttpSession sesion = request.getSession(false);
    if (sesion == null || sesion.getAttribute("nombreUsuario") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String nombreUsuario = (String) sesion.getAttribute("nombreUsuario");

    // Datos enviados por DocumentoServlet
    List<Documento> listaDocumentos = (List<Documento>) request.getAttribute("listaDocumentos");
    String codigoSugerido           = (String)  request.getAttribute("codigoSugerido");
    String error                    = (String)  request.getAttribute("error");
    Boolean busquedaActiva          = (Boolean) request.getAttribute("busquedaActiva");
    Integer totalResultados         = (Integer) request.getAttribute("totalResultados");

    // Valores previos de búsqueda para no limpiar los campos
    String busNombre      = (String) request.getAttribute("busNombre");
    String busTipo        = (String) request.getAttribute("busTipo");
    String busDependencia = (String) request.getAttribute("busDependencia");
    String busEstado      = (String) request.getAttribute("busEstado");

    // Mensaje de éxito desde URL (después de registrar)
    String exito = request.getParameter("exito");

    // Null safety
    if (busNombre      == null) busNombre      = "";
    if (busTipo        == null) busTipo        = "";
    if (busDependencia == null) busDependencia = "";
    if (busEstado      == null) busEstado      = "";
    if (busquedaActiva == null) busquedaActiva = false;
    if (codigoSugerido == null) codigoSugerido = "";
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Documentos - SADU</title>
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

        /* ── Formulario de registro ── */
        .form-grid { display:grid; grid-template-columns:1fr 1fr; gap:16px; }
        .form-grid .full { grid-column:1 / -1; }

        label { font-size:13px; font-weight:bold; color:#374151;
            display:block; margin-bottom:5px; }

        input[type="text"], input[type="date"], select, textarea {
            width:100%; padding:10px 14px; border:1px solid #d1d5db;
            border-radius:8px; font-size:13px; outline:none; box-sizing:border-box;
            transition:border-color 0.25s; background:white; }

        input:focus, select:focus, textarea:focus {
            border-color:#1f3b57; box-shadow:0 0 5px rgba(31,59,87,0.2); }

        .requerido { color:#dc2626; margin-left:2px; }

        .btn-registrar { background-color:#1f3b57; color:white; border:none;
            padding:11px 24px; border-radius:8px; font-size:14px; cursor:pointer;
            transition:background-color 0.3s; }
        .btn-registrar:hover { background-color:#162d42; }

        /* ── Buscador ── */
        .buscador { display:grid; grid-template-columns:2fr 1fr 1fr 1fr auto; gap:12px; align-items:end; }

        .btn-buscar { background-color:#2d6a4f; color:white; border:none;
            padding:10px 18px; border-radius:8px; font-size:13px; cursor:pointer;
            transition:background-color 0.3s; white-space:nowrap; height:40px; }
        .btn-buscar:hover { background-color:#1b4332; }

        .btn-limpiar { background-color:#f1f5f9; color:#374151; border:1px solid #d1d5db;
            padding:10px 16px; border-radius:8px; font-size:13px; cursor:pointer;
            text-decoration:none; display:inline-block; height:40px; line-height:1.4; }
        .btn-limpiar:hover { background-color:#e2e8f0; color:#374151; }

        /* ── Tabla de documentos ── */
        .tabla-documentos { width:100%; border-collapse:collapse; font-size:13px; }

        .tabla-documentos thead tr { background-color:#1f3b57; }
        .tabla-documentos thead th { color:white; padding:12px 10px;
            text-align:left; font-weight:bold; }

        .tabla-documentos tbody tr:nth-child(even) { background-color:#f8fafc; }
        .tabla-documentos tbody tr:hover { background-color:#eff6ff; }
        .tabla-documentos tbody td { padding:10px; border-bottom:1px solid #e2e8f0;
            vertical-align:middle; }

        /* ── Badges de estado ── */
        .badge-estado { padding:4px 10px; border-radius:20px; font-size:11px; font-weight:bold; }
        .badge-REGISTRADO  { background:#dbeafe; color:#1e40af; }
        .badge-EN_PROCESO  { background:#fef3c7; color:#92400e; }
        .badge-ARCHIVADO   { background:#d1fae5; color:#065f46; }

        /* ── Alertas ── */
        .alerta-error { background:#fee2e2; color:#b91c1c; border:1px solid #fca5a5;
            border-radius:10px; padding:13px 16px; margin-bottom:18px; font-size:14px; }
        .alerta-exito { background:#d1fae5; color:#065f46; border:1px solid #6ee7b7;
            border-radius:10px; padding:13px 16px; margin-bottom:18px; font-size:14px; }
        .alerta-info  { background:#dbeafe; color:#1e40af; border:1px solid #93c5fd;
            border-radius:10px; padding:10px 16px; margin-bottom:18px; font-size:13px; }

        /* ── Sin resultados ── */
        .sin-resultados { text-align:center; padding:40px; color:#9ca3af; }

        /* ── Código QR pequeño en tabla ── */
        .qr-badge { background:#f0fdf4; color:#065f46; padding:3px 8px;
            border-radius:6px; font-size:11px; font-family:monospace; }
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
            <h4 class="mb-0">📄 Gestión de Documentos</h4>
            <small class="text-muted">Registra, consulta y gestiona los documentos institucionales</small>
        </div>
        <div class="text-end">
            <strong><%= nombreUsuario %></strong><br>
            <small class="text-muted">Sesión activa</small>
        </div>
    </div>

    <%-- Alertas de error y éxito --%>
    <% if (error != null) { %>
        <div class="alerta-error">⚠️ <%= error %></div>
    <% } %>

    <% if ("1".equals(exito)) { %>
        <div class="alerta-exito">✅ Documento registrado correctamente en el sistema.</div>
    <% } %>

    <!-- ══ FORMULARIO DE REGISTRO ══ -->
    <div class="card-panel">
        <h5>➕ Registrar nuevo documento</h5>

        <!--
            Formulario de registro de documento.
            Envía por POST al DocumentoServlet con accion=registrar.
        -->
        <form action="documentos" method="post">
            <input type="hidden" name="accion" value="registrar">

            <div class="form-grid">

                <!-- Código del documento (sugerido automáticamente) -->
                <div>
                    <label for="codigo">Código <span class="requerido">*</span></label>
                    <input
                        type="text"
                        id="codigo"
                        name="codigo"
                        value="<%= codigoSugerido %>"
                        placeholder="Ej: DOC-2025-001"
                        maxlength="30"
                        required
                        style="text-transform:uppercase;"
                    >
                </div>

                <!-- Tipo de documento -->
                <div>
                    <label for="tipoDocumento">Tipo de documento <span class="requerido">*</span></label>
                    <select id="tipoDocumento" name="tipoDocumento" required>
                        <option value="" disabled selected>-- Selecciona --</option>
                        <option value="Oficio">Oficio</option>
                        <option value="Circular">Circular</option>
                        <option value="Resolución">Resolución</option>
                        <option value="Acta">Acta</option>
                        <option value="Contrato">Contrato</option>
                        <option value="Informe">Informe</option>
                        <option value="Memorando">Memorando</option>
                        <option value="Decreto">Decreto</option>
                        <option value="Certificado">Certificado</option>
                        <option value="Otro">Otro</option>
                    </select>
                </div>

                <!-- Nombre del documento (ocupa todo el ancho) -->
                <div class="full">
                    <label for="nombreDocumento">Nombre del documento <span class="requerido">*</span></label>
                    <input
                        type="text"
                        id="nombreDocumento"
                        name="nombreDocumento"
                        placeholder="Ej: Oficio de solicitud de materiales de oficina"
                        maxlength="150"
                        required
                    >
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

                <!-- Fecha del documento -->
                <div>
                    <label for="fechaDocumento">Fecha del documento <span class="requerido">*</span></label>
                    <input
                        type="date"
                        id="fechaDocumento"
                        name="fechaDocumento"
                        required
                    >
                </div>

                <!-- TRD -->
                <div>
                    <label for="trd">Tabla de Retención Documental (TRD)</label>
                    <input
                        type="text"
                        id="trd"
                        name="trd"
                        placeholder="Ej: TRD-100-01"
                        maxlength="100"
                    >
                </div>

                <!-- Estado -->
                <div>
                    <label for="estado">Estado</label>
                    <select id="estado" name="estado">
                        <option value="REGISTRADO" selected>📋 Registrado</option>
                        <option value="EN_PROCESO">⚙️ En proceso</option>
                        <option value="ARCHIVADO">📦 Archivado</option>
                    </select>
                </div>

                <!-- Ruta del archivo (ocupa todo el ancho) -->
                <div class="full">
                    <label for="rutaArchivo">Ruta del archivo digital</label>
                    <input
                        type="text"
                        id="rutaArchivo"
                        name="rutaArchivo"
                        placeholder="Ej: /archivos/2025/oficios/oficio-001.pdf"
                        maxlength="255"
                    >
                </div>

            </div><!-- fin form-grid -->

            <div style="margin-top:18px;">
                <button type="submit" class="btn-registrar">💾 Registrar documento</button>
            </div>
        </form>
    </div>

    <!-- ══ BUSCADOR ══ -->
    <div class="card-panel">
        <h5>🔍 Buscar documentos</h5>

        <!--
            Formulario de búsqueda.
            Envía por GET al DocumentoServlet con accion=buscar.
            Los campos vacíos se ignoran en la búsqueda.
        -->
        <form action="documentos" method="get">
            <input type="hidden" name="accion" value="buscar">
            <div class="buscador">

                <div>
                    <label for="busNombre">Nombre del documento</label>
                    <input type="text" id="busNombre" name="busNombre"
                        placeholder="Buscar por nombre..."
                        value="<%= busNombre %>">
                </div>

                <div>
                    <label for="busTipo">Tipo</label>
                    <select id="busTipo" name="busTipo">
                        <option value="">Todos los tipos</option>
                        <option value="Oficio"      <%= "Oficio".equals(busTipo)      ? "selected" : "" %>>Oficio</option>
                        <option value="Circular"    <%= "Circular".equals(busTipo)    ? "selected" : "" %>>Circular</option>
                        <option value="Resolución"  <%= "Resolución".equals(busTipo)  ? "selected" : "" %>>Resolución</option>
                        <option value="Acta"        <%= "Acta".equals(busTipo)        ? "selected" : "" %>>Acta</option>
                        <option value="Contrato"    <%= "Contrato".equals(busTipo)    ? "selected" : "" %>>Contrato</option>
                        <option value="Informe"     <%= "Informe".equals(busTipo)     ? "selected" : "" %>>Informe</option>
                        <option value="Memorando"   <%= "Memorando".equals(busTipo)   ? "selected" : "" %>>Memorando</option>
                        <option value="Decreto"     <%= "Decreto".equals(busTipo)     ? "selected" : "" %>>Decreto</option>
                        <option value="Certificado" <%= "Certificado".equals(busTipo) ? "selected" : "" %>>Certificado</option>
                        <option value="Otro"        <%= "Otro".equals(busTipo)        ? "selected" : "" %>>Otro</option>
                    </select>
                </div>

                <div>
                    <label for="busEstado">Estado</label>
                    <select id="busEstado" name="busEstado">
                        <option value="">Todos</option>
                        <option value="REGISTRADO" <%= "REGISTRADO".equals(busEstado) ? "selected" : "" %>>Registrado</option>
                        <option value="EN_PROCESO" <%= "EN_PROCESO".equals(busEstado) ? "selected" : "" %>>En proceso</option>
                        <option value="ARCHIVADO"  <%= "ARCHIVADO".equals(busEstado)  ? "selected" : "" %>>Archivado</option>
                    </select>
                </div>

                <div>
                    <label>&nbsp;</label>
                    <button type="submit" class="btn-buscar">🔍 Buscar</button>
                </div>

                <div>
                    <label>&nbsp;</label>
                    <a href="documentos?accion=listar" class="btn-limpiar">✖ Limpiar</a>
                </div>

            </div>
        </form>

        <%-- Mostrar cuántos resultados encontró la búsqueda --%>
        <% if (busquedaActiva && totalResultados != null) { %>
            <div class="alerta-info" style="margin-top:14px; margin-bottom:0;">
                🔎 Se encontraron <strong><%= totalResultados %></strong>
                documento<%= totalResultados != 1 ? "s" : "" %> con los filtros aplicados.
            </div>
        <% } %>
    </div>

    <!-- ══ LISTADO DE DOCUMENTOS ══ -->
    <div class="card-panel">
        <h5>
            📋 Documentos registrados
            <% if (listaDocumentos != null) { %>
                <span style="font-size:13px; font-weight:normal; color:#6b7280;">
                    (<%= listaDocumentos.size() %> en total)
                </span>
            <% } %>
        </h5>

        <% if (listaDocumentos != null && !listaDocumentos.isEmpty()) { %>
            <div style="overflow-x:auto;">
                <table class="tabla-documentos">
                    <thead>
                        <tr>
                            <th>Código</th>
                            <th>Nombre del documento</th>
                            <th>Tipo</th>
                            <th>Dependencia</th>
                            <th>Fecha doc.</th>
                            <th>TRD</th>
                            <th>QR</th>
                            <th>Estado</th>
                            <th>Registrado por</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Documento doc : listaDocumentos) { %>
                            <tr>
                                <td><strong style="color:#1f3b57;"><%= doc.getCodigo() %></strong></td>
                                <td><%= doc.getNombreDocumento() %></td>
                                <td><%= doc.getTipoDocumento() %></td>
                                <td><%= doc.getDependencia() %></td>
                                <td><%= doc.getFechaDocumento() != null ? doc.getFechaDocumento().toString() : "—" %></td>
                                <td><%= (doc.getTrd() != null && !doc.getTrd().isEmpty()) ? doc.getTrd() : "—" %></td>
                                <td>
                                    <% if (doc.getQrCodigo() != null && !doc.getQrCodigo().isEmpty()) { %>
                                        <span class="qr-badge"><%= doc.getQrCodigo() %></span>
                                    <% } else { %>
                                        <span style="color:#9ca3af;">—</span>
                                    <% } %>
                                </td>
                                <td>
                                    <span class="badge-estado badge-<%= doc.getEstado() %>">
                                        <%= doc.getEstado() %>
                                    </span>
                                </td>
                                <td><%= doc.getNombreUsuario() %></td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

        <% } else { %>
            <div class="sin-resultados">
                <p style="font-size:40px; margin-bottom:10px;">📭</p>
                <% if (busquedaActiva) { %>
                    <p>No se encontraron documentos con los filtros aplicados.</p>
                    <a href="documentos?accion=listar" style="color:#1f3b57;">Ver todos los documentos</a>
                <% } else { %>
                    <p>Aún no hay documentos registrados en el sistema.</p>
                    <p style="font-size:13px;">Usa el formulario de arriba para registrar el primer documento.</p>
                <% } %>
            </div>
        <% } %>
    </div>

</div><!-- fin content -->

</body>
</html>
