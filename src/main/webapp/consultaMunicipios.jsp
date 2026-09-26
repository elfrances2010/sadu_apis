<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="javax.servlet.http.HttpSession"%>

<%
    HttpSession sesion = request.getSession(false);
    if (sesion == null || sesion.getAttribute("nombreUsuario") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String mensajeError = (String) request.getAttribute("mensajeError");
    String idDepartamento = (String) request.getAttribute("idDepartamento");
    List<String[]> municipios = (List<String[]>) request.getAttribute("municipios");
    List<String[]> listaDepartamentos = (List<String[]>) request.getAttribute("listaDepartamentos");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Municipios por Departamento - API Colombia - SADU</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body { margin: 0; background-color: #f4f6f9; font-family: Arial, sans-serif; }
        .content { margin-left: 250px; padding: 30px; }
        .contenedor {
            max-width: 1200px; background: white; padding: 30px;
            border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        h1 { color: #1b4332; margin-bottom: 5px; font-size: 1.6rem; }
        .subtitulo { color: #555; margin-bottom: 20px; font-size: 14px; }

        /* --- Formulario de búsqueda (select en vez de input numérico) --- */
        .form-busqueda { display: flex; gap: 10px; margin-bottom: 20px; flex-wrap: wrap; }
        .form-busqueda select {
            padding: 10px 14px; border: 1px solid #ccc; border-radius: 8px;
            font-size: 14px; width: 280px; background-color: white;
        }
        .btn-buscar {
            padding: 10px 20px; background-color: #2d6a4f; color: white;
            border: none; border-radius: 8px; font-size: 14px; cursor: pointer;
        }
        .btn-buscar:hover { background-color: #1b4332; }

        .error-box {
            background-color: #fee2e2; color: #b91c1c; padding: 12px 16px;
            border-radius: 8px; margin-bottom: 20px;
        }
        .vacio { text-align: center; padding: 40px; color: #999; }

        /* --- Barra de herramientas de resultados: contador + buscador + orden --- */
        .barra-resultados {
            display: flex; justify-content: space-between; align-items: center;
            flex-wrap: wrap; gap: 12px; margin-bottom: 18px;
        }
        .badge-total {
            background-color: #2d6a4f; color: white; padding: 5px 12px;
            border-radius: 20px; font-size: 13px; font-weight: 600;
        }
        .herramientas { display: flex; gap: 8px; flex-wrap: wrap; }
        #filtro-nombre {
            padding: 8px 12px; border: 1px solid #ccc; border-radius: 8px;
            font-size: 13px; width: 200px;
        }
        .btn-orden {
            padding: 8px 12px; background: white; color: #2d6a4f;
            border: 1px solid #2d6a4f; border-radius: 8px;
            font-size: 12px; cursor: pointer; font-weight: 600;
        }
        .btn-orden:hover, .btn-orden.activo { background: #2d6a4f; color: white; }

        /* --- Tarjetas de municipios --- */
        .grid-municipios {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 16px;
        }
        .tarjeta-municipio {
            border: 1px solid #e2e8f0; border-radius: 12px; padding: 16px;
            background: #fafcfa; transition: box-shadow 0.15s, transform 0.15s;
        }
        .tarjeta-municipio:hover { box-shadow: 0 4px 14px rgba(0,0,0,0.1); transform: translateY(-2px); }
        .tarjeta-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 8px; }
        .tarjeta-nombre { font-size: 16px; font-weight: 700; color: #1b4332; margin: 0; }
        .badge-capital {
            background-color: #f0ad4e; color: white; font-size: 11px;
            padding: 3px 8px; border-radius: 12px; font-weight: 600; white-space: nowrap;
        }
        .tarjeta-descripcion {
            font-size: 13px; color: #555; margin: 8px 0 12px; line-height: 1.4;
            max-height: 3.4em; overflow: hidden; display: -webkit-box;
            -webkit-line-clamp: 2; -webkit-box-orient: vertical; cursor: pointer;
        }
        .tarjeta-descripcion.expandido { max-height: none; display: block; -webkit-line-clamp: unset; }
        .tarjeta-datos { display: flex; gap: 14px; font-size: 12px; color: #2d6a4f; font-weight: 600; flex-wrap: wrap; }
        .dato-icono { display: flex; align-items: center; gap: 4px; }
    </style>
</head>
<body>
    <%@ include file="sidebar.jsp" %>

    <div class="content">
        <div class="contenedor">

            <h1>Municipios por Departamento - API Colombia</h1>
            <p class="subtitulo">Elige un departamento para consultar sus municipios en tiempo real.</p>

            <form class="form-busqueda" action="MunicipiosApiColombiaServlet" method="post">
                <select name="idDepartamento" required>
                    <option value="">Selecciona un departamento...</option>
                    <%
                        if (listaDepartamentos != null) {
                            for (String[] depto : listaDepartamentos) {
                                boolean seleccionado = depto[0].equals(idDepartamento);
                    %>
                        <option value="<%= depto[0] %>" <%= seleccionado ? "selected" : "" %>>
                            <%= depto[1] %>
                        </option>
                    <%
                            }
                        }
                    %>
                </select>
                <button type="submit" class="btn-buscar">🔍 Consultar municipios</button>
            </form>

            <% if (mensajeError != null) { %>
                <div class="error-box">⚠️ <%= mensajeError %></div>
            <% } %>

            <% if (municipios != null && !municipios.isEmpty()) { %>

                <div class="barra-resultados">
                    <div>
                        <span class="badge-total" id="contador-resultados"><%= municipios.size() %> municipios</span>
                    </div>
                    <div class="herramientas">
                        <input type="text" id="filtro-nombre" placeholder="🔎 Filtrar por nombre...">
                        <button type="button" class="btn-orden activo" id="btn-orden-az" onclick="ordenarPor('nombre')">A-Z</button>
                        <button type="button" class="btn-orden" id="btn-orden-pob" onclick="ordenarPor('poblacion')">Mayor población</button>
                    </div>
                </div>

                <div class="grid-municipios" id="grid-municipios">
                    <% for (String[] mun : municipios) {
                        int poblacionNum = Integer.parseInt(mun[4]);
                        String poblacionTexto = poblacionNum > 0 ? String.format("%,d", poblacionNum) : "—";
                        String superficieTexto = (mun.length > 5 && !mun[5].isEmpty()) ? mun[5] + " km²" : "";
                    %>
                        <div class="tarjeta-municipio"
                             data-nombre="<%= mun[1].toLowerCase() %>"
                             data-poblacion="<%= poblacionNum %>">
                            <div class="tarjeta-header">
                                <p class="tarjeta-nombre"><%= mun[1] %></p>
                                <% if ("Sí".equals(mun[3])) { %>
                                    <span class="badge-capital">⭐ Capital</span>
                                <% } %>
                            </div>
                            <div class="tarjeta-descripcion" onclick="this.classList.toggle('expandido')">
                                <%= mun[2] %>
                            </div>
                            <div class="tarjeta-datos">
                                <span class="dato-icono">👥 <%= poblacionTexto %></span>
                                <% if (!superficieTexto.isEmpty()) { %>
                                    <span class="dato-icono">📐 <%= superficieTexto %></span>
                                <% } %>
                            </div>
                        </div>
                    <% } %>
                </div>

                <div class="vacio" id="sin-resultados-filtro" style="display:none;">
                    Ningún municipio coincide con ese filtro.
                </div>

            <% } else if (mensajeError == null && idDepartamento == null) { %>
                <div class="vacio">
                    Selecciona un departamento arriba para ver sus municipios.
                </div>
            <% } %>

        </div>
    </div>

    <script>
        // ─── Filtro por nombre (sin recargar la página) ───────────────────
        var campoFiltro = document.getElementById('filtro-nombre');
        if (campoFiltro) {
            campoFiltro.addEventListener('input', function () {
                var texto = this.value.trim().toLowerCase();
                var tarjetas = document.querySelectorAll('.tarjeta-municipio');
                var visibles = 0;

                tarjetas.forEach(function (tarjeta) {
                    var coincide = tarjeta.dataset.nombre.indexOf(texto) !== -1;
                    tarjeta.style.display = coincide ? '' : 'none';
                    if (coincide) visibles++;
                });

                document.getElementById('contador-resultados').textContent = visibles + ' municipios';
                document.getElementById('sin-resultados-filtro').style.display = visibles === 0 ? 'block' : 'none';
            });
        }

        // ─── Orden A-Z / por población ─────────────────────────────────────
        function ordenarPor(criterio) {
            var grid = document.getElementById('grid-municipios');
            var tarjetas = Array.prototype.slice.call(grid.querySelectorAll('.tarjeta-municipio'));

            tarjetas.sort(function (a, b) {
                if (criterio === 'poblacion') {
                    return parseInt(b.dataset.poblacion) - parseInt(a.dataset.poblacion);
                }
                return a.dataset.nombre.localeCompare(b.dataset.nombre);
            });

            tarjetas.forEach(function (tarjeta) { grid.appendChild(tarjeta); });

            document.getElementById('btn-orden-az').classList.toggle('activo', criterio === 'nombre');
            document.getElementById('btn-orden-pob').classList.toggle('activo', criterio === 'poblacion');
        }
    </script>
</body>
</html>
