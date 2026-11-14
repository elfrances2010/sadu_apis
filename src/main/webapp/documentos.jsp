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

    List<Documento> listaDocumentos = (List<Documento>) request.getAttribute("listaDocumentos");
    if (listaDocumentos == null) {
        response.sendRedirect("documentos");
        return;
    }

    String codigoSugerido           = (String)  request.getAttribute("codigoSugerido");
    String error                    = (String)  request.getAttribute("error");
    Boolean busquedaActiva          = (Boolean) request.getAttribute("busquedaActiva");
    Integer totalResultados         = (Integer) request.getAttribute("totalResultados");

    String busNombre      = (String) request.getAttribute("busNombre");
    String busTipo        = (String) request.getAttribute("busTipo");
    String busDependencia = (String) request.getAttribute("busDependencia");
    String busEstado      = (String) request.getAttribute("busEstado");

    String exito = request.getParameter("exito");

    if (busquedaActiva  == null) busquedaActiva  = false;
    if (totalResultados == null) totalResultados = 0;
    if (busNombre       == null) busNombre       = "";
    if (busTipo         == null) busTipo         = "";
    if (busDependencia  == null) busDependencia  = "";
    if (busEstado       == null) busEstado       = "";
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
        <div class="text-end d-flex align-items-center gap-3">
            <a href="exportar-fuid" class="btn btn-success btn-sm fw-bold px-3 shadow-sm" title="Descargar Formato Único de Inventario Documental del AGN">
                <i class="bi bi-file-earmark-spreadsheet-fill me-1"></i> FUID Oficial (Excel / AGN)
            </a>
            <div>
                <strong><%= nombreUsuario %></strong><br>
                <small class="text-muted">Sesión activa</small>
            </div>
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

                <!-- Carga y Drag & Drop del Archivo Digital con Hash SHA-256 Automático -->
                <div class="full">
                    <label>Archivo Digital (PDF / Imagen) con Integridad SHA-256</label>
                    <div id="dropZoneArchivo" style="border: 2px dashed #3b82f6; border-radius: 10px; padding: 20px; text-align: center; background: #f8fafc; cursor: pointer; transition: all 0.2s;" onclick="document.getElementById('inputArchivoReal').click()">
                        <input type="file" id="inputArchivoReal" accept=".pdf,.png,.jpg,.jpeg,.tiff" style="display:none;" onchange="procesarArchivoSeleccionado(this.files[0])">
                        <i class="bi bi-cloud-arrow-up-fill text-primary" style="font-size: 30px;"></i>
                        <p class="mb-1 fw-bold text-dark" style="font-size: 13.5px;" id="dropTextoPrincipal">Arrastra y suelta tu archivo PDF aquí, o haz clic para seleccionarlo</p>
                        <small class="text-muted" id="dropTextoSecundario">Soporta PDF, PNG, JPG y TIFF (Máximo 25 MB). Se calculará automáticamente la firma SHA-256 de preservación.</small>
                        
                        <!-- Indicador de Archivo Cargado -->
                        <div id="infoArchivoCargado" style="display:none; margin-top:12px; padding:10px 14px; background:#dcfce7; border:1px solid #86efac; border-radius:8px; text-align:left;">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <strong class="text-success" id="nombreArchivoCargado"><i class="bi bi-file-earmark-check-fill me-1"></i> Documento cargado</strong>
                                    <span class="badge bg-success ms-2" id="tamanoArchivoCargado"></span>
                                </div>
                                <span class="badge bg-dark" style="font-size:10px;"><i class="bi bi-shield-check me-1"></i> SHA-256 CALCULADO</span>
                            </div>
                            <div class="mt-1" style="font-size:11px; color:#166534;">
                                <strong>Huella Digital SHA-256:</strong> <code id="hashSha256Badge" style="color:#14532d; font-size:10.5px;"></code>
                            </div>
                        </div>
                    </div>
                    <input type="hidden" id="rutaArchivo" name="rutaArchivo" value="">
                    <input type="hidden" id="hashSha256" name="hashSha256" value="">
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
                            <th>Expediente Digital</th>
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
                                <td>
                                    <% if (doc.getRutaArchivo() != null && !doc.getRutaArchivo().trim().isEmpty()) { %>
                                        <button type="button" class="btn btn-sm btn-outline-danger py-1 px-2 shadow-sm" style="font-size:11px; font-weight:600;"
                                                onclick="abrirVisorPdf('ver-archivo?ruta=<%= doc.getRutaArchivo() %>&codigo=<%= doc.getCodigo() %>', '<%= doc.getCodigo() %>', '<%= doc.getNombreDocumento().replace("'", "\\'").replace("\"", "&quot;") %>', '<%= doc.getHashSha256() != null ? doc.getHashSha256() : "SHA-256 Validado" %>')">
                                            <i class="bi bi-file-earmark-pdf-fill me-1"></i> Ver PDF
                                        </button>
                                    <% } else { %>
                                        <span class="text-muted" style="font-size:11px;">Sin archivo</span>
                                    <% } %>
                                </td>
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

<!-- MODAL VISOR INTEGRADO DE EXPEDIENTES DIGITALES (PDF.JS / BROWSER) -->
<div class="modal fade" id="modalVisorPdf" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered" style="max-width:92%;">
        <div class="modal-content shadow-lg border-0" style="border-radius:12px; overflow:hidden;">
            <div class="modal-header bg-dark text-white p-3" style="background:#1f3b57 !important;">
                <div class="d-flex align-items-center gap-2">
                    <i class="bi bi-file-earmark-pdf-fill text-danger" style="font-size:22px;"></i>
                    <div>
                        <h5 class="modal-title fw-bold mb-0" id="visorPdfTitulo" style="font-size:15px;">Expediente Digital</h5>
                        <small class="text-white-50" id="visorPdfSubtitulo" style="font-size:11px;"></small>
                    </div>
                </div>
                <div class="d-flex align-items-center gap-2">
                    <button type="button" class="btn btn-sm btn-outline-light" onclick="pantallaCompletaVisor()"><i class="bi bi-fullscreen"></i></button>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
            </div>
            <div class="modal-body p-0" style="background:#334155;">
                <iframe id="frameVisorPdf" src="" style="width:100%; height:620px; border:none; display:block;"></iframe>
            </div>
            <div class="modal-footer py-2 px-3 bg-light d-flex justify-content-between align-items-center" style="font-size:11.5px;">
                <div>
                    <span class="text-muted">Firma de Integridad Digital:</span>
                    <code id="visorPdfHash" class="ms-1" style="color:#0f766e; font-size:10.5px;"></code>
                </div>
                <div class="d-flex gap-2">
                    <a id="btnDescargarPdfDirecto" href="#" target="_blank" class="btn btn-sm btn-outline-secondary">
                        <i class="bi bi-download me-1"></i> Abrir en Pestaña
                    </a>
                    <button type="button" class="btn btn-sm btn-secondary" data-bs-dismiss="modal">Cerrar</button>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
// ========================================================
// CARGA REAL Y DRAG & DROP DE ARCHIVOS CON HASH SHA-256
// ========================================================
const dropZone = document.getElementById('dropZoneArchivo');

['dragenter', 'dragover'].forEach(eventName => {
    dropZone.addEventListener(eventName, (e) => {
        e.preventDefault();
        dropZone.style.borderColor = '#10b981';
        dropZone.style.background = '#f0fdf4';
    }, false);
});

['dragleave', 'drop'].forEach(eventName => {
    dropZone.addEventListener(eventName, (e) => {
        e.preventDefault();
        dropZone.style.borderColor = '#3b82f6';
        dropZone.style.background = '#f8fafc';
    }, false);
});

dropZone.addEventListener('drop', (e) => {
    const dt = e.dataTransfer;
    const files = dt.files;
    if (files.length > 0) {
        procesarArchivoSeleccionado(files[0]);
    }
});

function procesarArchivoSeleccionado(archivo) {
    if (!archivo) return;

    // Validación de peso (25 MB)
    if (archivo.size > 25 * 1024 * 1024) {
        alert("El archivo supera el límite máximo permitido de 25 MB.");
        return;
    }

    const principal = document.getElementById('dropTextoPrincipal');
    const secundario = document.getElementById('dropTextoSecundario');
    const info = document.getElementById('infoArchivoCargado');

    principal.innerHTML = '<div class="spinner-border spinner-border-sm text-primary me-2"></div> Subiendo y calculando Hash SHA-256...';
    secundario.innerText = 'Transfiriendo archivo al repositorio seguro de SADU...';

    const formData = new FormData();
    formData.append("archivo", archivo);

    fetch('api/subir-archivo', {
        method: 'POST',
        body: formData
    })
    .then(r => r.json())
    .then(res => {
        if (res.ok) {
            principal.innerText = "¡Archivo cargado y firmado con éxito!";
            secundario.innerText = "Puedes arrastrar otro si deseas reemplazarlo.";
            
            // Asignar a inputs ocultos
            document.getElementById('rutaArchivo').value = res.rutaArchivo;
            document.getElementById('hashSha256').value = res.hashSha256;

            // Mostrar caja de información de éxito
            document.getElementById('nombreArchivoCargado').innerHTML = '<i class="bi bi-file-earmark-check-fill me-1"></i> ' + res.nombreOriginal;
            document.getElementById('tamanoArchivoCargado').innerText = res.tamanoLegible;
            document.getElementById('hashSha256Badge').innerText = res.hashSha256;
            info.style.display = 'block';
        } else {
            alert("Error al subir archivo: " + (res.error || "No se pudo procesar"));
            resetDropZone();
        }
    })
    .catch(err => {
        alert("Error de comunicación con el servidor al subir el archivo.");
        resetDropZone();
    });
}

function resetDropZone() {
    document.getElementById('dropTextoPrincipal').innerText = "Arrastra y suelta tu archivo PDF aquí, o haz clic para seleccionarlo";
    document.getElementById('dropTextoSecundario').innerText = "Soporta PDF, PNG, JPG y TIFF (Máximo 25 MB). Se calculará automáticamente la firma SHA-256 de preservación.";
    document.getElementById('infoArchivoCargado').style.display = 'none';
}

// ========================================================
// VISOR INTEGRADO DE EXPEDIENTES DIGITALES (PDF)
// ========================================================
function abrirVisorPdf(url, codigo, nombre, hash) {
    document.getElementById('visorPdfTitulo').innerText = codigo + " - " + nombre;
    document.getElementById('visorPdfSubtitulo').innerText = "Identificador Único: " + codigo + " | Repositorio Oficial SADU";
    document.getElementById('visorPdfHash').innerText = hash;
    document.getElementById('frameVisorPdf').src = url;
    document.getElementById('btnDescargarPdfDirecto').href = url;

    const modal = new bootstrap.Modal(document.getElementById('modalVisorPdf'));
    modal.show();
}

function pantallaCompletaVisor() {
    const frame = document.getElementById('frameVisorPdf');
    if (frame.requestFullscreen) {
        frame.requestFullscreen();
    }
}
</script>

</body>
</html>
