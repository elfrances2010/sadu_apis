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

    // Datos enviados por DocumentoRegistradoServlet
    List<Documento> listaDocumentos = (List<Documento>) request.getAttribute("listaDocumentos");
    Boolean busquedaActiva  = (Boolean) request.getAttribute("busquedaActiva");
    Integer totalResultados = (Integer) request.getAttribute("totalResultados");
    String  textoBusqueda   = (String)  request.getAttribute("textoBusqueda");

    if (busquedaActiva == null) busquedaActiva = false;
    if (textoBusqueda  == null) textoBusqueda  = "";
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Documentos Registrados - SADU</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { margin:0; background-color:#f4f6f9; font-family:Arial,sans-serif; }

        /* ── Topbar ── */
        .topbar { background:white; padding:14px 20px; border-radius:10px;
            margin-bottom:22px; box-shadow:0 2px 6px rgba(0,0,0,0.08); }

        /* ── Tarjeta general ── */
        .card-panel { background:white; border-radius:14px; padding:24px;
            box-shadow:0 3px 10px rgba(0,0,0,0.07); margin-bottom:22px; }
        .card-panel h5 { color:#1f3b57; font-weight:bold; margin-bottom:18px;
            padding-bottom:10px; border-bottom:2px solid #e2e8f0; font-size:16px; }

        /* ── Buscador rápido por código/QR ── */
        .buscador-rapido {
            background: linear-gradient(135deg, #1f3b57, #2f5579);
            border-radius:14px; padding:28px 30px; margin-bottom:22px;
            color:white;
        }
        .buscador-rapido h5 {
            color:white; border:none; padding:0; margin-bottom:6px; font-size:18px;
        }
        .buscador-rapido p {
            color:rgba(255,255,255,0.75); font-size:13px; margin-bottom:18px;
        }
        .form-busqueda-rapida { display:flex; gap:10px; }
        .form-busqueda-rapida input {
            flex:1; padding:13px 16px; border:none; border-radius:10px;
            font-size:15px; outline:none; font-family:monospace;
        }
        .form-busqueda-rapida input:focus {
            box-shadow:0 0 0 3px rgba(255,255,255,0.3);
        }
        .btn-buscar-rapido {
            background-color:#2d6a4f; color:white; border:none;
            padding:13px 26px; border-radius:10px; font-size:14px;
            cursor:pointer; font-weight:bold; white-space:nowrap;
            transition:background-color 0.3s;
        }
        .btn-buscar-rapido:hover { background-color:#1b4332; }

        .btn-ver-todos {
            display:inline-block; margin-top:12px; color:rgba(255,255,255,0.85);
            font-size:13px; text-decoration:underline;
        }
        .btn-ver-todos:hover { color:white; }

        /* ── Tabla ── */
        .tabla-documentos { width:100%; border-collapse:collapse; font-size:13px; }
        .tabla-documentos thead tr { background-color:#1f3b57; }
        .tabla-documentos thead th { color:white; padding:12px 10px; text-align:left; }
        .tabla-documentos tbody tr:nth-child(even) { background-color:#f8fafc; }
        .tabla-documentos tbody tr:hover { background-color:#eff6ff; }
        .tabla-documentos tbody td { padding:10px; border-bottom:1px solid #e2e8f0; vertical-align:middle; }

        /* ── Badges de estado ── */
        .badge-estado { padding:4px 10px; border-radius:20px; font-size:11px; font-weight:bold; }
        .badge-REGISTRADO { background:#dbeafe; color:#1e40af; }
        .badge-EN_PROCESO { background:#fef3c7; color:#92400e; }
        .badge-ARCHIVADO  { background:#d1fae5; color:#065f46; }

        /* ── Código QR badge ── */
        .qr-badge { background:#f0fdf4; color:#065f46; padding:3px 8px;
            border-radius:6px; font-size:11px; font-family:monospace; }

        /* ── Resultado de búsqueda destacado ── */
        .resultado-encontrado {
            background:#d1fae5; border:1px solid #6ee7b7; border-radius:10px;
            padding:13px 16px; margin-bottom:18px; font-size:14px; color:#065f46;
        }
        .resultado-no-encontrado {
            background:#fee2e2; border:1px solid #fca5a5; border-radius:10px;
            padding:13px 16px; margin-bottom:18px; font-size:14px; color:#b91c1c;
        }

        /* ── Sin datos ── */
        .sin-resultados { text-align:center; padding:40px; color:#9ca3af; }
    </style>
</head>
<body>

<%@ include file="sidebar.jsp" %>

<div class="content">

    <!-- Topbar -->
    <div class="topbar d-flex justify-content-between align-items-center">
        <div>
            <h4 class="mb-0">📋 Documentos Registrados</h4>
            <small class="text-muted">Vista de consulta — documentos archivados y verificación por código</small>
        </div>
        <div class="text-end">
            <strong><%= nombreUsuario %></strong><br>
            <small class="text-muted">Sesión activa</small>
        </div>
    </div>

    <!-- ══ BUSCADOR RÁPIDO POR CÓDIGO O QR ══ -->
    <div class="buscador-rapido">
        <h5>🔎 Verificación rápida por código o QR</h5>
        <p>Escanea o escribe el código del documento (ej: DOC-2025-001 o QR-DOC-2025-001) para verificarlo al instante.</p>

        <form action="documentosRegistrados" method="get" class="form-busqueda-rapida">
            <input type="hidden" name="accion" value="buscarQr">
            <input
                type="text"
                name="textoBusqueda"
                placeholder="Escribe o escanea el código del documento..."
                value="<%= textoBusqueda %>"
                autofocus
            >
            <button type="submit" class="btn-buscar-rapido">🔍 Verificar</button>
        </form>

        <% if (busquedaActiva) { %>
            <a href="documentosRegistrados?accion=listar" class="btn-ver-todos">
                ← Volver al listado de documentos archivados
            </a>
        <% } %>
    </div>

    <%-- Resultado de la búsqueda --%>
    <% if (busquedaActiva) { %>
        <% if (totalResultados != null && totalResultados > 0) { %>
            <div class="resultado-encontrado">
                ✅ Documento encontrado para: <strong>"<%= textoBusqueda %>"</strong>
            </div>
        <% } else { %>
            <div class="resultado-no-encontrado">
                ⚠️ No se encontró ningún documento con el código:
                <strong>"<%= textoBusqueda %>"</strong>. Verifica que esté escrito correctamente.
            </div>
        <% } %>
    <% } %>

    <!-- ══ TABLA DE RESULTADOS ══ -->
    <div class="card-panel">
        <h5>
            <% if (busquedaActiva) { %>
                🔍 Resultado de la búsqueda
            <% } else { %>
                📦 Documentos archivados
            <% } %>
            <% if (listaDocumentos != null) { %>
                <span style="font-size:13px; font-weight:normal; color:#6b7280;">
                    (<%= listaDocumentos.size() %> documento<%= listaDocumentos.size() != 1 ? "s" : "" %>)
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
                    <p>No se encontró ningún documento con ese código.</p>
                <% } else { %>
                    <p>Aún no hay documentos archivados en el sistema.</p>
                    <p style="font-size:13px;">
                        Los documentos aparecerán aquí cuando su estado cambie a
                        <span class="badge-estado badge-ARCHIVADO">ARCHIVADO</span>
                        desde el módulo de Documentos.
                    </p>
                <% } %>
            </div>
        <% } %>
    </div>

</div><!-- fin content -->

</body>
</html>
