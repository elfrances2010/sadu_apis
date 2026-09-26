<%@ page contentType="text/html" pageEncoding="UTF-8" %>
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

    if (rolUsuario != 1 && rolUsuario != 2) {
        response.sendRedirect("acceso_denegado.jsp");
        return;
    }

    Integer totalDocumentos     = (Integer) request.getAttribute("totalDocumentos");
    Integer totalComunicaciones = (Integer) request.getAttribute("totalComunicaciones");
    Integer totalUsuarios       = (Integer) request.getAttribute("totalUsuarios");
    Integer totalMensajes       = (Integer) request.getAttribute("totalMensajes");

    if (totalDocumentos     == null) totalDocumentos     = 0;
    if (totalComunicaciones == null) totalComunicaciones = 0;
    if (totalUsuarios       == null) totalUsuarios       = 0;
    if (totalMensajes       == null) totalMensajes       = 0;

    String docEstadoLabels      = (String) request.getAttribute("docEstadoLabels");
    String docEstadoValues      = (String) request.getAttribute("docEstadoValues");
    String docTipoLabels        = (String) request.getAttribute("docTipoLabels");
    String docTipoValues        = (String) request.getAttribute("docTipoValues");
    String docDependenciaLabels = (String) request.getAttribute("docDependenciaLabels");
    String docDependenciaValues = (String) request.getAttribute("docDependenciaValues");
    String docMesLabels         = (String) request.getAttribute("docMesLabels");
    String docMesValues         = (String) request.getAttribute("docMesValues");
    String comEstadoLabels      = (String) request.getAttribute("comEstadoLabels");
    String comEstadoValues      = (String) request.getAttribute("comEstadoValues");
    String comTipoLabels        = (String) request.getAttribute("comTipoLabels");
    String comTipoValues        = (String) request.getAttribute("comTipoValues");
    String usuRolLabels         = (String) request.getAttribute("usuRolLabels");
    String usuRolValues         = (String) request.getAttribute("usuRolValues");
    String usuEstadoLabels      = (String) request.getAttribute("usuEstadoLabels");
    String usuEstadoValues      = (String) request.getAttribute("usuEstadoValues");
    String audAccionLabels      = (String) request.getAttribute("audAccionLabels");
    String audAccionValues      = (String) request.getAttribute("audAccionValues");

    if (docEstadoLabels      == null) docEstadoLabels      = "[]";
    if (docEstadoValues      == null) docEstadoValues      = "[]";
    if (docTipoLabels        == null) docTipoLabels        = "[]";
    if (docTipoValues        == null) docTipoValues        = "[]";
    if (docDependenciaLabels == null) docDependenciaLabels = "[]";
    if (docDependenciaValues == null) docDependenciaValues = "[]";
    if (docMesLabels         == null) docMesLabels         = "[]";
    if (docMesValues         == null) docMesValues         = "[]";
    if (comEstadoLabels      == null) comEstadoLabels      = "[]";
    if (comEstadoValues      == null) comEstadoValues      = "[]";
    if (comTipoLabels        == null) comTipoLabels        = "[]";
    if (comTipoValues        == null) comTipoValues        = "[]";
    if (usuRolLabels         == null) usuRolLabels         = "[]";
    if (usuRolValues         == null) usuRolValues         = "[]";
    if (usuEstadoLabels      == null) usuEstadoLabels      = "[]";
    if (usuEstadoValues      == null) usuEstadoValues      = "[]";
    if (audAccionLabels      == null) audAccionLabels      = "[]";
    if (audAccionValues      == null) audAccionValues      = "[]";
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reportes - SADU</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
    <style>
        body { margin:0; background-color:#f4f6f9; font-family:Arial,sans-serif; }

        .topbar { background:white; padding:14px 20px; border-radius:10px;
            margin-bottom:22px; box-shadow:0 2px 6px rgba(0,0,0,0.08); }

        .stat-card {
            background:white; border-radius:14px; padding:20px 22px;
            box-shadow:0 3px 10px rgba(0,0,0,0.07);
            display:flex; align-items:center; gap:16px; height:100%;
        }
        .stat-icono {
            font-size:32px; width:54px; height:54px; border-radius:14px;
            display:flex; align-items:center; justify-content:center; flex-shrink:0;
        }
        .stat-icono.azul   { background:#dbeafe; }
        .stat-icono.verde  { background:#d1fae5; }
        .stat-icono.morado { background:#ede9fe; }
        .stat-icono.rosa   { background:#fce7f3; }
        .stat-numero { font-size:26px; font-weight:bold; color:#1f3b57; line-height:1; }
        .stat-label  { font-size:12px; color:#6b7280; margin-top:4px; }

        .chart-card {
            background:white; border-radius:14px; padding:22px;
            box-shadow:0 3px 10px rgba(0,0,0,0.07); margin-bottom:22px; height:100%;
        }
        .chart-card h6 {
            color:#1f3b57; font-weight:bold; font-size:14px; margin-bottom:14px;
            padding-bottom:8px; border-bottom:2px solid #e2e8f0;
        }
        .chart-container { position:relative; height:280px; }

        .sin-datos-chart {
            display:flex; align-items:center; justify-content:center;
            height:280px; color:#9ca3af; font-size:13px; text-align:center;
            flex-direction:column; gap:8px;
        }
    </style>
</head>
<body>

<%@ include file="sidebar.jsp" %>

<div class="content">

    <div class="topbar d-flex justify-content-between align-items-center">
        <div>
            <h4 class="mb-0">📊 Reportes y Estadísticas</h4>
            <small class="text-muted">Resumen visual del estado del sistema SADU</small>
        </div>
        <div class="text-end">
            <strong><%= nombreUsuario %></strong><br>
            <small class="text-muted">Sesión activa</small>
        </div>
    </div>

    <!-- ══ TARJETAS DE ESTADÍSTICAS GENERALES ══ -->
    <div class="row g-3 mb-3">
        <div class="col-md-3 col-6">
            <div class="stat-card">
                <div class="stat-icono azul">📄</div>
                <div>
                    <div class="stat-numero"><%= totalDocumentos %></div>
                    <div class="stat-label">Documentos registrados</div>
                </div>
            </div>
        </div>
        <div class="col-md-3 col-6">
            <div class="stat-card">
                <div class="stat-icono verde">📨</div>
                <div>
                    <div class="stat-numero"><%= totalComunicaciones %></div>
                    <div class="stat-label">Comunicaciones radicadas</div>
                </div>
            </div>
        </div>
        <div class="col-md-3 col-6">
            <div class="stat-card">
                <div class="stat-icono morado">👥</div>
                <div>
                    <div class="stat-numero"><%= totalUsuarios %></div>
                    <div class="stat-label">Usuarios del sistema</div>
                </div>
            </div>
        </div>
        <div class="col-md-3 col-6">
            <div class="stat-card">
                <div class="stat-icono rosa">💬</div>
                <div>
                    <div class="stat-numero"><%= totalMensajes %></div>
                    <div class="stat-label">Mensajes en el chat</div>
                </div>
            </div>
        </div>
    </div>

    <!-- ══ FILA 1: Documentos por estado y tipo ══ -->
    <div class="row g-3 mb-1">
        <div class="col-md-4">
            <div class="chart-card">
                <h6>📄 Documentos por estado</h6>
                <div class="chart-container"><canvas id="chartDocEstado"></canvas></div>
            </div>
        </div>
        <div class="col-md-8">
            <div class="chart-card">
                <h6>📂 Documentos por tipo</h6>
                <div class="chart-container"><canvas id="chartDocTipo"></canvas></div>
            </div>
        </div>
    </div>

    <!-- ══ FILA 2: Tendencia mensual y dependencias ══ -->
    <div class="row g-3 mb-1">
        <div class="col-md-7">
            <div class="chart-card">
                <h6>📈 Documentos registrados por mes (año actual)</h6>
                <div class="chart-container"><canvas id="chartDocMes"></canvas></div>
            </div>
        </div>
        <div class="col-md-5">
            <div class="chart-card">
                <h6>🏛️ Documentos por dependencia</h6>
                <div class="chart-container"><canvas id="chartDocDependencia"></canvas></div>
            </div>
        </div>
    </div>

    <!-- ══ FILA 3: Comunicaciones ══ -->
    <div class="row g-3 mb-1">
        <div class="col-md-6">
            <div class="chart-card">
                <h6>📨 Comunicaciones por estado</h6>
                <div class="chart-container"><canvas id="chartComEstado"></canvas></div>
            </div>
        </div>
        <div class="col-md-6">
            <div class="chart-card">
                <h6>📬 Comunicaciones por tipo</h6>
                <div class="chart-container"><canvas id="chartComTipo"></canvas></div>
            </div>
        </div>
    </div>

    <!-- ══ FILA 4: Usuarios y Auditoría ══ -->
    <div class="row g-3 mb-1">
        <div class="col-md-3">
            <div class="chart-card">
                <h6>👥 Usuarios por rol</h6>
                <div class="chart-container"><canvas id="chartUsuRol"></canvas></div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="chart-card">
                <h6>✅ Usuarios por estado</h6>
                <div class="chart-container"><canvas id="chartUsuEstado"></canvas></div>
            </div>
        </div>
        <% if (rolUsuario == 1) { %>
        <div class="col-md-6">
            <div class="chart-card">
                <h6>🔐 Eventos de auditoría más frecuentes</h6>
                <div class="chart-container"><canvas id="chartAudAccion"></canvas></div>
            </div>
        </div>
        <% } %>
    </div>

</div><!-- fin content -->

<script>
    const PALETA = ['#1f3b57','#2d6a4f','#5b9bd5','#f59e0b','#dc2626','#6d28d9','#0d9488','#ea580c'];

    function hayDatos(canvasId, valores) {
        if (!valores || valores.length === 0 || valores.every(v => v === 0)) {
            const canvas = document.getElementById(canvasId);
            const contenedor = canvas.parentElement;
            contenedor.innerHTML =
                '<div class="sin-datos-chart">' +
                '  <span style="font-size:32px;">📭</span>' +
                '  <span>Aún no hay datos suficientes para este gráfico.</span>' +
                '</div>';
            return false;
        }
        return true;
    }

    // 1. Documentos por estado — pastel
    const docEstadoLabels = <%= docEstadoLabels %>;
    const docEstadoValues = <%= docEstadoValues %>;
    if (hayDatos('chartDocEstado', docEstadoValues)) {
        new Chart(document.getElementById('chartDocEstado'), {
            type: 'pie',
            data: { labels: docEstadoLabels, datasets: [{ data: docEstadoValues, backgroundColor: PALETA }] },
            options: { responsive: true, maintainAspectRatio: false,
                plugins: { legend: { position: 'bottom', labels: { font: { size: 11 } } } } }
        });
    }

    // 2. Documentos por tipo — barras verticales
    const docTipoLabels = <%= docTipoLabels %>;
    const docTipoValues = <%= docTipoValues %>;
    if (hayDatos('chartDocTipo', docTipoValues)) {
        new Chart(document.getElementById('chartDocTipo'), {
            type: 'bar',
            data: { labels: docTipoLabels, datasets: [{ label: 'Documentos', data: docTipoValues, backgroundColor: '#1f3b57', borderRadius: 6 }] },
            options: { responsive: true, maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: { y: { beginAtZero: true, ticks: { stepSize: 1 } } } }
        });
    }

    // 3. Documentos por mes — línea
    const docMesLabels = <%= docMesLabels %>;
    const docMesValues = <%= docMesValues %>;
    if (hayDatos('chartDocMes', docMesValues)) {
        new Chart(document.getElementById('chartDocMes'), {
            type: 'line',
            data: { labels: docMesLabels, datasets: [{ label: 'Documentos registrados', data: docMesValues,
                borderColor: '#2d6a4f', backgroundColor: 'rgba(45,106,79,0.15)', fill: true, tension: 0.35,
                pointBackgroundColor: '#2d6a4f', pointRadius: 4 }] },
            options: { responsive: true, maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: { y: { beginAtZero: true, ticks: { stepSize: 1 } } } }
        });
    }

    // 4. Documentos por dependencia — barras horizontales
    const docDependenciaLabels = <%= docDependenciaLabels %>;
    const docDependenciaValues = <%= docDependenciaValues %>;
    if (hayDatos('chartDocDependencia', docDependenciaValues)) {
        new Chart(document.getElementById('chartDocDependencia'), {
            type: 'bar',
            data: { labels: docDependenciaLabels, datasets: [{ label: 'Documentos', data: docDependenciaValues, backgroundColor: '#5b9bd5', borderRadius: 6 }] },
            options: { indexAxis: 'y', responsive: true, maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: { x: { beginAtZero: true, ticks: { stepSize: 1 } } } }
        });
    }

    // 5. Comunicaciones por estado — dona
    const comEstadoLabels = <%= comEstadoLabels %>;
    const comEstadoValues = <%= comEstadoValues %>;
    if (hayDatos('chartComEstado', comEstadoValues)) {
        new Chart(document.getElementById('chartComEstado'), {
            type: 'doughnut',
            data: { labels: comEstadoLabels, datasets: [{ data: comEstadoValues, backgroundColor: PALETA }] },
            options: { responsive: true, maintainAspectRatio: false,
                plugins: { legend: { position: 'bottom', labels: { font: { size: 11 } } } } }
        });
    }

    // 6. Comunicaciones por tipo — pastel
    const comTipoLabels = <%= comTipoLabels %>;
    const comTipoValues = <%= comTipoValues %>;
    if (hayDatos('chartComTipo', comTipoValues)) {
        new Chart(document.getElementById('chartComTipo'), {
            type: 'pie',
            data: { labels: comTipoLabels, datasets: [{ data: comTipoValues, backgroundColor: ['#1f3b57','#f59e0b'] }] },
            options: { responsive: true, maintainAspectRatio: false,
                plugins: { legend: { position: 'bottom', labels: { font: { size: 11 } } } } }
        });
    }

    // 7. Usuarios por rol — pastel
    const usuRolLabels = <%= usuRolLabels %>;
    const usuRolValues = <%= usuRolValues %>;
    if (hayDatos('chartUsuRol', usuRolValues)) {
        new Chart(document.getElementById('chartUsuRol'), {
            type: 'pie',
            data: { labels: usuRolLabels, datasets: [{ data: usuRolValues, backgroundColor: PALETA }] },
            options: { responsive: true, maintainAspectRatio: false,
                plugins: { legend: { position: 'bottom', labels: { font: { size: 10 } } } } }
        });
    }

    // 8. Usuarios por estado — dona
    const usuEstadoLabels = <%= usuEstadoLabels %>;
    const usuEstadoValues = <%= usuEstadoValues %>;
    if (hayDatos('chartUsuEstado', usuEstadoValues)) {
        new Chart(document.getElementById('chartUsuEstado'), {
            type: 'doughnut',
            data: { labels: usuEstadoLabels, datasets: [{ data: usuEstadoValues, backgroundColor: ['#2d6a4f','#dc2626'] }] },
            options: { responsive: true, maintainAspectRatio: false,
                plugins: { legend: { position: 'bottom', labels: { font: { size: 10 } } } } }
        });
    }

    // 9. Auditoría por acción — barras horizontales (solo Admin)
    const audAccionLabels = <%= audAccionLabels %>;
    const audAccionValues = <%= audAccionValues %>;
    const canvasAuditoria = document.getElementById('chartAudAccion');
    if (canvasAuditoria && hayDatos('chartAudAccion', audAccionValues)) {
        new Chart(canvasAuditoria, {
            type: 'bar',
            data: { labels: audAccionLabels, datasets: [{ label: 'Eventos', data: audAccionValues, backgroundColor: '#6d28d9', borderRadius: 6 }] },
            options: { indexAxis: 'y', responsive: true, maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: { x: { beginAtZero: true, ticks: { stepSize: 1 } } } }
        });
    }
</script>

</body>
</html>
