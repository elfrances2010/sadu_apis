<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%
    HttpSession sesion = request.getSession(false);
    if (sesion == null || sesion.getAttribute("nombreUsuario") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String nombreUsuario = (String) sesion.getAttribute("nombreUsuario");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Sedes y Datos Territoriales - SADU</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        body { margin: 0; background-color: #f4f6f9; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; }
        .tt-wrap { padding: 25px 30px; }
        .topbar-sede {
            background: white; padding: 16px 24px; border-radius: 12px;
            margin-bottom: 24px; box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            display: flex; justify-content: space-between; align-items: center;
        }
        
        .card-panel {
            background: white; border-radius: 14px; padding: 22px;
            box-shadow: 0 3px 10px rgba(0,0,0,0.06); margin-bottom: 24px;
        }

        /* Tarjetas de Estadísticas */
        .tt-cards { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 16px; margin-bottom: 20px; }
        .tt-card {
            background: #fff; border: 1px solid #e2e8ed; border-radius: 12px;
            padding: 18px; box-shadow: 0 2px 6px rgba(0,0,0,0.04);
            border-left: 4px solid #1f3b57;
        }
        .tt-card.sedes { border-left-color: #3b82f6; }
        .tt-card.deptos { border-left-color: #10b981; }
        .tt-card.munis { border-left-color: #f59e0b; }
        .tt-card.sync { border-left-color: #6366f1; }
        .tt-card .tt-label { font-size: 11.5px; text-transform: uppercase; letter-spacing: .5px; color: #64748b; font-weight: bold; margin-bottom: 4px; }
        .tt-card .tt-valor { font-size: 26px; font-weight: 700; color: #1e293b; }
        .tt-card .tt-nota { font-size: 11.5px; color: #64748b; margin-top: 4px; }

        .btn-sync {
            background: #1f3b57; color: #fff; border: 0; border-radius: 8px;
            padding: 9px 18px; font-size: 13.5px; cursor: pointer; font-weight: bold;
            display: inline-flex; align-items: center; gap: 8px; transition: background 0.2s;
        }
        .btn-sync:hover { background: #162d42; color: #fff; }
        
        .table-custom th {
            background-color: #1f3b57; color: white; font-size: 12.5px; font-weight: 600;
            padding: 11px 10px; text-transform: uppercase;
        }
        .table-custom td { font-size: 13px; vertical-align: middle; padding: 10px; }

        .tt-aviso {
            margin-top: 14px; padding: 12px 16px; border-radius: 8px; font-size: 13.5px; display: none;
        }
        .tt-aviso.ok   { background: #e6f5ec; color: #1c5f40; border: 1px solid #bfe3cf; }
        .tt-aviso.err  { background: #fdecec; color: #8a2020; border: 1px solid #f3c4c4; }
        .tt-aviso.info { background: #eaf2fb; color: #1d4b7a; border: 1px solid #c5dbf2; }
    </style>
</head>
<%@ include file="sidebar.jsp" %>
<body>

<div class="content">
    <div class="tt-wrap">

        <!-- Topbar -->
        <div class="topbar-sede">
            <div>
                <h4 class="mb-1 text-dark fw-bold"><i class="bi bi-geo-alt-fill text-danger me-2"></i> Territorio, Sedes y Depósitos de Archivo</h4>
                <small class="text-muted">Articulación de la base territorial con las sedes universitarias, depósitos de custodia y procedencia de correspondencia</small>
            </div>
            <div>
                <button class="btn btn-primary btn-sm px-3 fw-bold" data-bs-toggle="modal" data-bs-target="#modalNuevaSede">
                    <i class="bi bi-plus-circle me-1"></i> Nueva Sede / Depósito
                </button>
            </div>
        </div>

        <!-- Tarjetas Resumen -->
        <div class="tt-cards">
            <div class="tt-card sedes">
                <div class="tt-label">Sedes y Depósitos Activos</div>
                <div class="tt-valor" id="totalSedes">3</div>
                <div class="tt-nota">Custodia de acervo físico y microfilmado</div>
            </div>
            <div class="tt-card deptos">
                <div class="tt-label">Departamentos Locales</div>
                <div class="tt-valor" id="ttDeptos">--</div>
                <div class="tt-nota">Base maestra normalizada</div>
            </div>
            <div class="tt-card munis">
                <div class="tt-label">Municipios para Radicación</div>
                <div class="tt-valor" id="ttMunis">--</div>
                <div class="tt-nota">Ventanilla única y procedencia</div>
            </div>
            <div class="tt-card sync">
                <div class="tt-label">Última Sincronización</div>
                <div class="tt-valor" id="ttFecha" style="font-size:16px;">Local Activa</div>
                <div class="tt-nota" id="ttEstado">Modo Offline garantizado</div>
            </div>
        </div>

        <!-- Panel 1: Sedes Universitarias y Depósitos de Custodia Física -->
        <div class="card-panel">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h5 class="fw-bold mb-0 text-dark">
                    <i class="bi bi-building me-2 text-primary"></i> Sedes Universitarias y Bóvedas de Archivo
                </h5>
                <small class="text-muted">Lugar de preservación física de expedientes, microfilminas y fotografías</small>
            </div>

            <div class="table-responsive">
                <table class="table table-hover table-bordered table-custom align-middle mb-0">
                    <thead>
                        <tr>
                            <th>Código</th>
                            <th>Sede Universitaria</th>
                            <th>Bóveda / Depósito Físico</th>
                            <th>Ubicación Territorial</th>
                            <th>Condiciones de Preservación</th>
                            <th>Capacidad</th>
                            <th>Responsable</th>
                        </tr>
                    </thead>
                    <tbody id="tablaSedesBody">
                        <tr>
                            <td colspan="7" class="text-center py-3 text-muted">Cargando sedes y depósitos...</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Panel 2: Base Maestra Territorial y Sincronización con API Colombia -->
        <div class="card-panel">
            <div class="d-flex justify-content-between align-items-center mb-2">
                <h5 class="fw-bold mb-0 text-dark">
                    <i class="bi bi-arrow-repeat me-2 text-success"></i> Sincronización de Base Territorial Maestra
                </h5>
                <button class="btn-sync" id="ttBoton" onclick="sincronizar()">
                    <i class="bi bi-arrow-repeat"></i> Actualizar desde API Colombia
                </button>
            </div>
            <p class="text-muted" style="font-size:13px;">
                Alimenta automáticamente los selectores de procedencia de la <strong>Ventanilla Única en Comunicaciones</strong> y la ubicación de las sedes. Opera 100% offline para que la radicación nunca se detenga.
            </p>

            <div class="tt-aviso" id="ttAviso"></div>
        </div>

    </div>
</div>

<!-- MODAL NUEVA SEDE / DEPÓSITO -->
<div class="modal fade" id="modalNuevaSede" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header bg-dark text-white" style="background:#1f3b57 !important;">
                <h5 class="modal-title fw-bold"><i class="bi bi-building-add me-1"></i> Registrar Sede o Depósito de Archivo</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <form id="formNuevaSede" onsubmit="guardarNuevaSede(event)">
                <div class="modal-body p-4">
                    <div class="row g-3">
                        <div class="col-md-8">
                            <label class="form-label fw-bold">Nombre de la Sede Universitaria <span class="text-danger">*</span></label>
                            <input type="text" id="nsNombreSede" class="form-control" placeholder="Ej: Sede Regional Ipiales o Campus Torobajo" required>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-bold">Código Sede <span class="text-danger">*</span></label>
                            <input type="text" id="nsCodigo" class="form-control" placeholder="Ej: SEDE-PAS-04" required style="text-transform:uppercase;">
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-bold">Departamento (Base Territorial)</label>
                            <select id="nsDepto" class="form-select" onchange="cargarMunicipiosModal()" required>
                                <option value="">-- Selecciona Departamento --</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Municipio de Ubicación <span class="text-danger">*</span></label>
                            <select id="nsMunicipio" class="form-select" required>
                                <option value="">-- Primero selecciona departamento --</option>
                            </select>
                        </div>

                        <div class="col-md-12">
                            <label class="form-label fw-bold">Nombre del Depósito / Bóveda <span class="text-danger">*</span></label>
                            <input type="text" id="nsDeposito" class="form-control" placeholder="Ej: Bóveda Climatizada de Microfilmación y Fondos Acumulados" required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-bold">Dirección de la Sede</label>
                            <input type="text" id="nsDireccion" class="form-control" placeholder="Ej: Carrera 25 No. 12-34">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Responsable de Custodia</label>
                            <input type="text" id="nsResponsable" class="form-control" placeholder="Ej: Profesional Universitario de Archivo">
                        </div>

                        <div class="col-md-8">
                            <label class="form-label fw-bold">Condiciones Ambientales (Preservación)</label>
                            <input type="text" id="nsCondiciones" class="form-control" value="Climatizado 18°C a 20°C / 45% a 50% Humedad Relativa">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-bold">Capacidad (Estantes / ML)</label>
                            <input type="number" id="nsCapacidad" class="form-control" value="100">
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn btn-primary fw-bold">Guardar Sede en SADU</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
const URL_SYNC  = 'SincronizacionTerritorialServlet';
const URL_LOCAL = 'TerritorioLocalServlet';

function aviso(texto, tipo) {
    const el = document.getElementById('ttAviso');
    el.className = 'tt-aviso ' + tipo;
    el.textContent = texto;
    el.style.display = 'block';
}

function numero(n) {
    return (n === null || n === undefined) ? '--' : Number(n).toLocaleString('es-CO');
}

async function cargarEstado() {
    try {
        const r = await fetch(URL_SYNC, { headers: { 'Accept': 'application/json' } });
        const d = await r.json();
        document.getElementById('ttDeptos').textContent = numero(d.departamentos);
        document.getElementById('ttMunis').textContent  = numero(d.municipios);

        if (d.ultimaSincronizacion && d.ultimaSincronizacion.fecha) {
            document.getElementById('ttFecha').textContent = d.ultimaSincronizacion.fecha;
            document.getElementById('ttEstado').textContent = d.ultimaSincronizacion.estado;
        }
    } catch (e) {
        console.error('Error al leer estado:', e);
    }
}

async function cargarSedes() {
    try {
        const r = await fetch('api/sedes-depositos');
        const lista = await r.json();
        const tbody = document.getElementById('tablaSedesBody');
        document.getElementById('totalSedes').textContent = lista.length;

        if (!lista || lista.length === 0) {
            tbody.innerHTML = '<tr><td colspan="7" class="text-center py-3 text-muted">No hay sedes registradas aún.</td></tr>';
            return;
        }

        let html = '';
        lista.forEach(s => {
            html += '<tr>' +
                '<td><strong class="text-primary">' + escapeHtml(s.codigoSede) + '</strong></td>' +
                '<td><strong>' + escapeHtml(s.nombreSede) + '</strong><br><small class="text-muted">' + escapeHtml(s.direccion || '') + '</small></td>' +
                '<td><i class="bi bi-archive-fill text-secondary me-1"></i> ' + escapeHtml(s.nombreDeposito) + '</td>' +
                '<td><span class="badge bg-light text-dark border"><i class="bi bi-geo-alt-fill text-danger me-1"></i>' + escapeHtml(s.nombreMunicipio) + ' (' + escapeHtml(s.nombreDepartamento) + ')</span></td>' +
                '<td><small class="text-secondary">' + escapeHtml(s.condicionesAmbientales || 'Normal') + '</small></td>' +
                '<td><span class="badge bg-info text-dark">' + s.capacidadEstanteria + ' estantes</span></td>' +
                '<td><small class="text-muted">' + escapeHtml(s.responsableCustodia || 'Sin asignar') + '</small></td>' +
            '</tr>';
        });
        tbody.innerHTML = html;
    } catch (e) {
        console.error('Error al cargar sedes:', e);
    }
}

async function cargarDeptosModal() {
    try {
        const r = await fetch(URL_LOCAL + '?accion=departamentos');
        const data = await r.json();
        const sel = document.getElementById('nsDepto');
        sel.innerHTML = '<option value="">-- Selecciona Departamento --</option>';
        data.forEach(d => {
            sel.innerHTML += '<option value="' + d.id + '">' + d.nombre + '</option>';
        });
    } catch(e) { console.error(e); }
}

async function cargarMunicipiosModal() {
    const deptoId = document.getElementById('nsDepto').value;
    const sel = document.getElementById('nsMunicipio');
    if (!deptoId) {
        sel.innerHTML = '<option value="">-- Primero selecciona departamento --</option>';
        return;
    }
    sel.innerHTML = '<option value="">Cargando municipios...</option>';
    try {
        const r = await fetch(URL_LOCAL + '?accion=municipios&departamentoId=' + encodeURIComponent(deptoId));
        const data = await r.json();
        sel.innerHTML = '<option value="">-- Selecciona Municipio --</option>';
        data.forEach(m => {
            sel.innerHTML += '<option value="' + m.id + '">' + m.nombre + '</option>';
        });
    } catch(e) { console.error(e); }
}

async function sincronizar() {
    const boton = document.getElementById('ttBoton');
    boton.disabled = true;
    boton.innerHTML = '<i class="bi bi-arrow-repeat spin"></i> Sincronizando...';
    aviso('Descargando departamentos y municipios desde API Colombia...', 'info');

    try {
        const r = await fetch(URL_SYNC, {
            method: 'POST',
            headers: { 'Accept': 'application/json' }
        });
        const d = await r.json();

        if (d.ok) {
            aviso(d.mensaje + ' (' + Math.round(d.duracionMs / 1000) + ' s)', 'ok');
        } else {
            aviso(d.mensaje || 'La sincronización no se completó.', 'err');
        }
    } catch (e) {
        aviso('Error de red o del servidor: ' + e.message, 'err');
    } finally {
        boton.disabled = false;
        boton.innerHTML = '<i class="bi bi-arrow-repeat"></i> Actualizar desde API Colombia';
        cargarEstado();
    }
}

function escapeHtml(text) {
    if (!text) return "";
    return String(text).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
}

document.addEventListener('DOMContentLoaded', function() {
    cargarEstado();
    cargarSedes();
    cargarDeptosModal();
});
</script>
</body>
</html>
