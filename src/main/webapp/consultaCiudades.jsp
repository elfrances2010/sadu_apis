<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.sadu.util.VerificadorRol"%>
<%
    if (!VerificadorRol.verificar(request, response, 1, 2, 3)) return;
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Consulta de Ciudades - SADU</title>
    <style>
        body { margin: 0; font-family: system-ui, -apple-system, "Segoe UI", Arial, sans-serif; background: #f4f6f9; }
        .page-wrap { display: flex; min-height: 100vh; }
        .content { flex: 1; padding: 28px 32px; }
        h1 { font-size: 24px; color: #17324a; margin: 0 0 4px; }
        .sub { color: #5b6b7a; margin: 0 0 24px; font-size: 14px; }
        .filtros {
            background: #fff; border-radius: 10px; padding: 20px 24px;
            box-shadow: 0 1px 4px rgba(0,0,0,.08); margin-bottom: 20px;
            display: flex; gap: 16px; flex-wrap: wrap; align-items: flex-end;
        }
        .filtros label { display: block; font-size: 12px; font-weight: 600;
            color: #5b6b7a; text-transform: uppercase; letter-spacing: .5px; margin-bottom: 6px; }
        .filtros select, .filtros input {
            border: 1px solid #d6dde3; border-radius: 6px;
            padding: 9px 12px; font-size: 14px; min-width: 220px; background: #fff; color: #17324a;
        }
        .btn-buscar {
            background: #1f7a52; color: #fff; border: none; border-radius: 6px;
            padding: 10px 22px; font-size: 14px; cursor: pointer; font-weight: 600;
        }
        .btn-buscar:hover { background: #196344; }
        .tabla-wrap { background: #fff; border-radius: 10px; box-shadow: 0 1px 4px rgba(0,0,0,.08); overflow: hidden; }
        table { width: 100%; border-collapse: collapse; font-size: 14px; }
        thead th { background: #17324a; color: #fff; padding: 12px 16px; text-align: left; font-weight: 600; font-size: 13px; }
        tbody tr:nth-child(even) { background: #f7f9fb; }
        tbody tr:hover { background: #e8f5ef; }
        tbody td { padding: 10px 16px; color: #2d3d4e; border-bottom: 1px solid #edf0f2; }
        .badge { display: inline-block; padding: 2px 8px; border-radius: 12px; font-size: 12px; font-weight: 600; }
        .badge-region { background: #e0f2fe; color: #0369a1; }
        .num { text-align: right; font-variant-numeric: tabular-nums; }
        .total-bar { padding: 10px 16px; font-size: 13px; color: #5b6b7a; border-top: 1px solid #edf0f2; }
        .aviso { padding: 14px 18px; border-radius: 8px; margin-bottom: 16px; font-size: 14px; }
        .aviso-info { background: #eaf2fb; color: #1d4b7a; border: 1px solid #c5dbf2; }
        .aviso-vacio { background: #fff8e1; color: #7c5c00; border: 1px solid #f5d77b; }
    </style>
</head>
<body>
<div class="page-wrap">
    <%@ include file="sidebar.jsp" %>
    <div class="content">
        <h1>&#127757; Consulta de Ciudades</h1>
        <p class="sub">Filtra y consulta los municipios de Colombia almacenados en el sistema.</p>
        <div class="filtros">
            <div>
                <label for="selDepto">Departamento</label>
                <select id="selDepto" onchange="cargarMunicipios()">
                    <option value="">- Todos -</option>
                </select>
            </div>
            <div>
                <label for="txtBuscar">Buscar municipio</label>
                <input type="text" id="txtBuscar" placeholder="Nombre del municipio..." oninput="filtrarTabla()">
            </div>
            <div>
                <label>&nbsp;</label>
                <button class="btn-buscar" onclick="mostrarTodos()">Ver todos</button>
            </div>
        </div>
        <div id="aviso" class="aviso aviso-info" style="display:none;"></div>
        <div class="tabla-wrap">
            <table>
                <thead>
                    <tr>
                        <th>Municipio</th>
                        <th>Departamento</th>
                        <th>Region</th>
                        <th class="num">Poblacion</th>
                        <th class="num">Superficie km2</th>
                        <th>Codigo Postal</th>
                    </tr>
                </thead>
                <tbody id="cuerpo">
                    <tr><td colspan="6" style="text-align:center;padding:24px;color:#7b8a99;">Cargando datos...</td></tr>
                </tbody>
            </table>
            <div class="total-bar" id="totalBar">-</div>
        </div>
    </div>
</div>
<script>
const URL_LOCAL = 'TerritorioLocalServlet';
let todosLosDatos = [];
let deptos = [];

async function iniciar() {
    try {
        const r = await fetch(URL_LOCAL + '?accion=departamentos');
        deptos = await r.json();
        const sel = document.getElementById('selDepto');
        deptos.forEach(function(d) {
            const op = document.createElement('option');
            op.value = d.id;
            op.textContent = d.nombre;
            sel.appendChild(op);
        });
        await mostrarTodos();
    } catch (e) {
        mostrarAviso('No se pudieron cargar los datos territoriales. Ejecute la sincronizacion territorial primero.', true);
    }
}

async function cargarMunicipios() {
    const deptoId = document.getElementById('selDepto').value;
    if (!deptoId) { mostrarTodos(); return; }
    try {
        const r = await fetch(URL_LOCAL + '?accion=municipios&departamentoId=' + deptoId);
        const municipios = await r.json();
        const depto = deptos.find(function(d) { return d.id == deptoId; }) || {};
        todosLosDatos = municipios.map(function(m) {
            return Object.assign({}, m, { departamento: depto.nombre || '', region: depto.region || '' });
        });
        renderizar(todosLosDatos);
    } catch (e) {
        mostrarAviso('Error al cargar los municipios.', true);
    }
}

async function mostrarTodos() {
    document.getElementById('selDepto').value = '';
    document.getElementById('txtBuscar').value = '';
    todosLosDatos = [];
    const lote = 5;
    for (let i = 0; i < deptos.length; i += lote) {
        const grupo = deptos.slice(i, i + lote);
        const promesas = grupo.map(function(d) {
            return fetch(URL_LOCAL + '?accion=municipios&departamentoId=' + d.id)
                .then(function(r) { return r.json(); })
                .then(function(munis) {
                    return munis.map(function(m) {
                        return Object.assign({}, m, { departamento: d.nombre, region: d.region || '' });
                    });
                }).catch(function() { return []; });
        });
        const resultados = await Promise.all(promesas);
        resultados.forEach(function(lista) { todosLosDatos = todosLosDatos.concat(lista); });
    }
    todosLosDatos.sort(function(a, b) { return a.nombre.localeCompare(b.nombre, 'es'); });
    renderizar(todosLosDatos);
}

function filtrarTabla() {
    const texto = document.getElementById('txtBuscar').value.trim().toLowerCase();
    if (!texto) { renderizar(todosLosDatos); return; }
    renderizar(todosLosDatos.filter(function(m) {
        return m.nombre.toLowerCase().includes(texto) || (m.departamento && m.departamento.toLowerCase().includes(texto));
    }));
}

function renderizar(lista) {
    const cuerpo = document.getElementById('cuerpo');
    const totalBar = document.getElementById('totalBar');
    if (!lista || lista.length === 0) {
        cuerpo.innerHTML = '<tr><td colspan="6" style="text-align:center;padding:24px;color:#7b8a99;">Sin resultados</td></tr>';
        totalBar.textContent = '0 municipios';
        return;
    }
    let html = '';
    lista.forEach(function(m) {
        html += '<tr>';
        html += '<td>' + esc(m.nombre) + '</td>';
        html += '<td>' + esc(m.departamento) + '</td>';
        html += '<td><span class="badge badge-region">' + esc(m.region || '-') + '</span></td>';
        html += '<td class="num">' + numFmt(m.poblacion) + '</td>';
        html += '<td class="num">' + numFmt(m.superficie) + '</td>';
        html += '<td>' + (m.codigoPostal || '-') + '</td>';
        html += '</tr>';
    });
    cuerpo.innerHTML = html;
    totalBar.textContent = lista.length.toLocaleString('es-CO') + ' municipios';
}

function numFmt(v) {
    if (v === null || v === undefined) return '-';
    return Number(v).toLocaleString('es-CO');
}

function esc(str) {
    if (!str) return '-';
    return str.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#039;');
}

function mostrarAviso(msg, esError) {
    const el = document.getElementById('aviso');
    el.textContent = msg;
    el.className = 'aviso ' + (esError ? 'aviso-vacio' : 'aviso-info');
    el.style.display = 'block';
}

iniciar();
</script>
</body>
</html>
