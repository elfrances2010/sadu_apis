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
    List<String[]> departamentos = (List<String[]>) request.getAttribute("departamentos");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Departamentos - API Colombia - SADU</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body {
            margin: 0;
            background-color: #f4f6f9;
            font-family: Arial, sans-serif;
        }

        .content {
            margin-left: 250px;
            padding: 30px;
        }

        .contenedor {
            max-width: 1100px;
            background: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }

        h1 {
            color: #1b4332;
            margin-bottom: 5px;
            font-size: 1.6rem;
        }

        .subtitulo {
            color: #555;
            margin-bottom: 20px;
            font-size: 14px;
        }

        .btn-cargar {
            padding: 10px 20px;
            background-color: #2d6a4f;
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 14px;
            text-decoration: none;
            display: inline-block;
            margin-bottom: 20px;
        }

        .btn-cargar:hover {
            background-color: #1b4332;
            color: white;
        }

        .badge-total {
            background-color: #2d6a4f;
            color: white;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 13px;
        }

        .error-box {
            background-color: #fee2e2;
            color: #b91c1c;
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 20px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
            table-layout: fixed;
        }

        th {
            background-color: #2d6a4f;
            color: white;
            padding: 12px 10px;
            text-align: left;
            font-size: 13px;
        }

        td {
            padding: 10px;
            border-bottom: 1px solid #e2e8f0;
            vertical-align: top;
            font-size: 14px;
        }

        tr:hover td {
            background-color: #f0fdf4;
        }

        /* Columnas con ancho fijo para que no se desborde */
        th:nth-child(1), td:nth-child(1) { width: 50px; }
        th:nth-child(2), td:nth-child(2) { width: 150px; }
        th:nth-child(3), td:nth-child(3) { width: auto; }
        th:nth-child(4), td:nth-child(4) { width: 140px; }
        th:nth-child(5), td:nth-child(5) { width: 110px; text-align: right; }

        /* Descripción truncada con expandir al hacer clic */
        .descripcion {
            max-height: 3.2em;
            overflow: hidden;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            cursor: pointer;
            font-size: 13px;
            color: #444;
        }

        .descripcion.expandido {
            max-height: none;
            display: block;
            -webkit-line-clamp: unset;
        }

        .ver-mas {
            color: #2d6a4f;
            font-size: 12px;
            font-weight: 600;
            display: block;
            margin-top: 3px;
        }

        .vacio {
            text-align: center;
            padding: 40px;
            color: #999;
        }
    </style>
</head>
<body>
    <%@ include file="sidebar.jsp" %>

    <div class="content">
        <div class="contenedor">

            <h1>Departamentos - API Colombia</h1>
            <p class="subtitulo">Consulta en tiempo real los departamentos de Colombia desde la API pública.</p>

            <a class="btn-cargar" href="ApiColombiaServlet">🔄 Cargar departamentos</a>

            <% if (mensajeError != null) { %>
                <div class="error-box">⚠️ <%= mensajeError %></div>
            <% } %>

            <% if (departamentos != null && !departamentos.isEmpty()) { %>

                <div class="d-flex justify-content-between align-items-center mb-2">
                    <h6 style="color:#1b4332; margin:0;">Resultados</h6>
                    <span class="badge-total"><%= departamentos.size() %> departamentos</span>
                </div>

                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Nombre</th>
                            <th>Descripción</th>
                            <th>Capital</th>
                            <th>Población</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (String[] dep : departamentos) { %>
                            <tr>
                                <td><%= dep[0] %></td>
                                <td><%= dep[1] %></td>
                                <td>
                                    <div class="descripcion" onclick="this.classList.toggle('expandido')">
                                        <%= dep[2] %>
                                    </div>
                                    <span class="ver-mas" onclick="this.previousElementSibling.classList.toggle('expandido')">Ver más / menos</span>
                                </td>
                                <td><%= dep[3] %></td>
                                <td><%= Integer.parseInt(dep[4]) > 0
                                        ? String.format("%,d", Integer.parseInt(dep[4]))
                                        : "—" %></td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>

            <% } else if (mensajeError == null) { %>
                <div class="vacio">
                    No hay departamentos cargados. Haz clic en "Cargar departamentos" para consultarlos.
                </div>
            <% } %>

        </div>
    </div>
</body>
</html>