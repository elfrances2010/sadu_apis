<%--
    SADU - Fragmento reutilizable: selects encadenados Departamento / Municipio

    Pégalo dentro del formulario de radicación de documentos o comunicaciones.
    Lee de la base LOCAL (TerritorioLocalServlet), nunca de Internet.

    Envía al servidor dos campos:
        departamento_id  -> territorio_departamento.id
        municipio_id     -> territorio_municipio.id

    Si necesitas origen y destino en la misma página, duplica el bloque
    cambiando el prefijo: initTerritorio('origen') y initTerritorio('destino').
--%>

<div class="campo-territorio" data-prefijo="origen">
    <label for="origen_departamento_id">Departamento</label>
    <select id="origen_departamento_id" name="departamento_id" required>
        <option value="">Cargando?</option>
    </select>

    <label for="origen_municipio_id">Municipio</label>
    <select id="origen_municipio_id" name="municipio_id" required disabled>
        <option value="">Seleccione primero un departamento</option>
    </select>
</div>

<script>
/**
 * Inicializa un par de selects encadenados.
 * @param {string} prefijo      prefijo de los ids en el HTML ('origen', 'destino'?)
 * @param {number} deptoPreSel  id de departamento a preseleccionar (modo edición)
 * @param {number} muniPreSel   id de municipio a preseleccionar (modo edición)
 */
async function initTerritorio(prefijo, deptoPreSel, muniPreSel) {
    const URL_LOCAL = 'TerritorioLocalServlet';
    const selDepto = document.getElementById(prefijo + '_departamento_id');
    const selMuni  = document.getElementById(prefijo + '_municipio_id');

    if (!selDepto || !selMuni) return;

    function opciones(select, lista, textoVacio) {
        select.innerHTML = '';
        const vacia = document.createElement('option');
        vacia.value = '';
        vacia.textContent = textoVacio;
        select.appendChild(vacia);

        lista.forEach(function (item) {
            const op = document.createElement('option');
            op.value = item.id;
            op.textContent = item.nombre;
            select.appendChild(op);
        });
    }

    async function cargarMunicipios(deptoId, preSel) {
        if (!deptoId) {
            selMuni.disabled = true;
            opciones(selMuni, [], 'Seleccione primero un departamento');
            return;
        }
        selMuni.disabled = true;
        opciones(selMuni, [], 'Cargando?');
        try {
            const r = await fetch(URL_LOCAL + '?accion=municipios&departamentoId=' + deptoId);
            const lista = await r.json();
            opciones(selMuni, lista, 'Seleccione un municipio');
            selMuni.disabled = false;
            if (preSel) selMuni.value = preSel;
        } catch (e) {
            opciones(selMuni, [], 'Error al cargar municipios');
        }
    }

    // 1. Departamentos
    try {
        const r = await fetch(URL_LOCAL + '?accion=departamentos');
        const lista = await r.json();

        if (!lista.length) {
            opciones(selDepto, [], 'Sin datos: ejecute la sincronización territorial');
            return;
        }
        opciones(selDepto, lista, 'Seleccione un departamento');
        if (deptoPreSel) {
            selDepto.value = deptoPreSel;
            await cargarMunicipios(deptoPreSel, muniPreSel);
        }
    } catch (e) {
        opciones(selDepto, [], 'Error al cargar departamentos');
        return;
    }

    // 2. Encadenado
    selDepto.addEventListener('change', function () {
        cargarMunicipios(this.value, null);
    });
}

// Llamada por defecto. En modo edición pásale los ids guardados:
//   initTerritorio('origen', ${documento.departamentoId}, ${documento.municipioId});
initTerritorio('origen');
</script>
