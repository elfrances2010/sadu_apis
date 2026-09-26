<%--
    SADU - Panel de sincronización de datos maestros territoriales

    Reemplaza los comentarios de include por los que uses en tus otras
    páginas (cabecera, menú lateral, pie), para que herede el mismo estilo.
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Datos territoriales - SADU</title>

    <%-- <jsp:include page="includes/head.jsp" /> --%>

    <style>
        .tt-wrap { padding: 24px; font-family: system-ui, -apple-system, "Segoe UI", Arial, sans-serif; }
        .tt-wrap h1 { font-size: 26px; margin: 0 0 6px; color: #17324a; }
        .tt-wrap .tt-sub { color: #5b6b7a; margin: 0 0 22px; }

        .tt-cards { display: flex; flex-wrap: wrap; gap: 16px; margin-bottom: 22px; }
        .tt-card {
            flex: 1 1 200px; background: #fff; border: 1px solid #e2e8ed;
            border-radius: 10px; padding: 16px 18px;
        }
        .tt-card .tt-label { font-size: 12px; text-transform: uppercase;
            letter-spacing: .5px; color: #7b8a99; margin-bottom: 6px; }
        .tt-card .tt-valor { font-size: 28px; font-weight: 600; color: #17324a; }
        .tt-card .tt-nota { font-size: 12px; color: #7b8a99; margin-top: 4px; }

        .tt-btn {
            background: #1f7a52; color: #fff; border: 0; border-radius: 8px;
            padding: 11px 20px; font-size: 15px; cursor: pointer;
        }
        .tt-btn:hover { background: #196344; }
        .tt-btn:disabled { background: #9db5aa; cursor: not-allowed; }

        .tt-aviso {
            margin-top: 16px; padding: 12px 16px; border-radius: 8px;
            font-size: 14px; display: none;
        }
        .tt-aviso.ok   { background: #e6f5ec; color: #1c5f40; border: 1px solid #bfe3cf; }
        .tt-aviso.err  { background: #fdecec; color: #8a2020; border: 1px solid #f3c4c4; }
        .tt-aviso.info { background: #eaf2fb; color: #1d4b7a; border: 1px solid #c5dbf2; }

        .tt-ayuda {
            margin-top: 26px; background: #f7f9fb; border-left: 4px solid #1f7a52;
            padding: 14px 18px; border-radius: 6px; font-size: 14px; color: #44586a;
            line-height: 1.6;
        }
    </style>
</head>
<body>

<%-- <jsp:include page="includes/menu.jsp" /> --%>

<div class="tt-wrap">

    <h1>Datos territoriales</h1>
    <p class="tt-sub">
        Departamentos y municipios almacenados localmente. El archivo usa
        estos datos para normalizar el origen y el destino de los documentos,
        sin depender de servicios externos.
    </p>

    <div class="tt-cards">
        <div class="tt-card">
            <div class="tt-label">Departamentos</div>
            <div class="tt-valor" id="ttDeptos">—</div>
        </div>
        <div class="tt-card">
            <div class="tt-label">Municipios</div>
            <div class="tt-valor" id="ttMunis">—</div>
        </div>
        <div class="tt-card">
            <div class="tt-label">Última sincronización</div>
            <div class="tt-valor" id="ttFecha" style="font-size:17px;">Nunca</div>
            <div class="tt-nota" id="ttEstado"></div>
        </div>
    </div>

    <button class="tt-btn" id="ttBoton" onclick="sincronizar()">
        Sincronizar desde API Colombia
    </button>

    <div class="tt-aviso" id="ttAviso"></div>

    <div class="tt-ayuda">
        <strong>¿Qué hace este proceso?</strong><br>
        Consulta api-colombia.com y guarda los 33 departamentos y sus municipios
        en la base de datos de SADU. Basta ejecutarlo una vez; después, solo
        cuando quieras refrescar la información. Mientras tanto, los formularios
        de radicación siguen funcionando aunque la API esté caída.
    </div>

</div>

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
    return (n === null || n === undefined) ? '—' : Number(n).toLocaleString('es-CO');
}

async function cargarEstado() {
    try {
        const r = await fetch(URL_SYNC, { headers: { 'Accept': 'application/json' } });
        const d = await r.json();
        document.getElementById('ttDeptos').textContent = numero(d.departamentos);
        document.getElementById('ttMunis').textContent  = numero(d.municipios);

        if (d.ultimaSincronizacion) {
            document.getElementById('ttFecha').textContent = d.ultimaSincronizacion.fecha;
            document.getElementById('ttEstado').textContent = d.ultimaSincronizacion.estado;
        }
    } catch (e) {
        aviso('No se pudo leer el estado actual: ' + e.message, 'err');
    }
}

async function sincronizar() {
    const boton = document.getElementById('ttBoton');
    boton.disabled = true;
    boton.textContent = 'Sincronizando…';
    aviso('Descargando departamentos y municipios. Puede tardar entre 30 y 90 segundos.', 'info');

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
        boton.textContent = 'Sincronizar desde API Colombia';
        cargarEstado();
    }
}

cargarEstado();
</script>

<%-- <jsp:include page="includes/footer.jsp" /> --%>

</body>
</html>
