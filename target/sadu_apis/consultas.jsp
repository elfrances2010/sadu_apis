<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    HttpSession sesion = request.getSession(false);
    if (sesion == null || sesion.getAttribute("nombreUsuario") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Consultas - SADU</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { margin: 0; background-color: #f4f6f9; font-family: Arial, sans-serif; }
        .content { margin-left: 250px; padding: 30px; }
        .card-panel { border: none; border-radius: 12px; box-shadow: 0 3px 8px rgba(0,0,0,0.08); }
        .nav-tabs .nav-link.active { font-weight: 600; }
    </style>
</head>
<body>
    <%@ include file="sidebar.jsp" %>
    <div class="content">
        <div class="card card-panel p-4">
            <h2>Módulo de consultas</h2>
            <p class="text-muted">Realiza búsquedas específicas dentro del sistema SADU, con filtros por documento, fecha, usuario o dependencia.</p>

            <!-- Pestañas -->
            <ul class="nav nav-tabs mb-3">
                <li class="nav-item">
                    <a class="nav-link <c:if test='${tipo == "documentos" || empty tipo}'>active</c:if>"
                       href="consultas?tipo=documentos">📄 Documentos</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link <c:if test='${tipo == "usuarios"}'>active</c:if>"
                       href="consultas?tipo=usuarios">👥 Usuarios</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link <c:if test='${tipo == "comunicaciones"}'>active</c:if>"
                       href="consultas?tipo=comunicaciones">✉ Comunicaciones</a>
                </li>
            </ul>

            <!-- Formulario de filtros -->
            <form method="GET" action="consultas" class="row g-3 mb-4">
                <input type="hidden" name="tipo" value="${empty tipo ? 'documentos' : tipo}">

                <div class="col-md-3">
                    <label class="form-label">Buscar texto</label>
                    <input type="text" name="texto" value="${texto}" class="form-control"
                           placeholder="Nombre, código o asunto">
                </div>

                <c:if test="${tipo != 'usuarios'}">
                <div class="col-md-3">
                    <label class="form-label">Dependencia</label>
                    <select name="dependencia" class="form-select">
                        <option value="">Todas</option>
                        <c:forEach var="dep" items="${listaDependencias}">
                            <option value="${dep}" <c:if test="${dep == dependencia}">selected</c:if>>${dep}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="form-label">Fecha inicio</label>
                    <input type="date" name="fechaInicio" value="${fechaInicio}" class="form-control">
                </div>
                <div class="col-md-2">
                    <label class="form-label">Fecha fin</label>
                    <input type="date" name="fechaFin" value="${fechaFin}" class="form-control">
                </div>
                </c:if>

                <div class="col-md-2">
                    <label class="form-label">Usuario</label>
                    <select name="idUsuario" class="form-select">
                        <option value="">Todos</option>
                        <c:forEach var="u" items="${listaUsuarios}">
                            <option value="${u.id}" <c:if test="${u.id == idUsuario}">selected</c:if>>${u.nombre}</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="col-12">
                    <button type="submit" class="btn btn-dark">Buscar</button>
                    <a href="consultas?tipo=${empty tipo ? 'documentos' : tipo}" class="btn btn-outline-secondary">Limpiar</a>
                </div>
            </form>

            <c:if test="${not empty error}">
                <div class="alert alert-danger">${error}</div>
            </c:if>

            <!-- Resultados: Documentos -->
            <c:if test="${(tipo == 'documentos' || empty tipo) && not empty resultados}">
                <p class="text-muted">${totalResultados} resultado(s) encontrado(s)</p>
                <table class="table table-hover align-middle">
                    <thead class="table-dark">
                        <tr>
                            <th>Código</th><th>Nombre</th><th>Tipo</th><th>Dependencia</th>
                            <th>Fecha</th><th>TRD</th><th>Estado</th><th>Registrado por</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="r" items="${resultados}">
                        <tr>
                            <td>${r.codigo}</td>
                            <td>${r.nombre}</td>
                            <td>${r.tipo}</td>
                            <td>${r.dependencia}</td>
                            <td>${r.fecha}</td>
                            <td>${r.trd}</td>
                            <td><span class="badge bg-dark">${r.estado}</span></td>
                            <td>${r.usuario}</td>
                        </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:if>

            <!-- Resultados: Usuarios -->
            <c:if test="${tipo == 'usuarios' && not empty resultados}">
                <p class="text-muted">${totalResultados} resultado(s) encontrado(s)</p>
                <table class="table table-hover align-middle">
                    <thead class="table-dark">
                        <tr>
                            <th>Nombre</th><th>Correo</th><th>Username</th>
                            <th>Rol</th><th>Estado</th><th>Fecha registro</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="r" items="${resultados}">
                        <tr>
                            <td>${r.nombre}</td>
                            <td>${r.correo}</td>
                            <td>${r.username}</td>
                            <td><span class="badge bg-dark">${r.rol}</span></td>
                            <td>${r.estado}</td>
                            <td>${r.fecha}</td>
                        </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:if>

            <!-- Resultados: Comunicaciones -->
            <c:if test="${tipo == 'comunicaciones' && not empty resultados}">
                <p class="text-muted">${totalResultados} resultado(s) encontrado(s)</p>
                <table class="table table-hover align-middle">
                    <thead class="table-dark">
                        <tr>
                            <th>Radicado</th><th>Tipo</th><th>Dependencia</th>
                            <th>Asunto</th><th>Fecha</th><th>Estado</th><th>Registrado por</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="r" items="${resultados}">
                        <tr>
                            <td>${r.radicado}</td>
                            <td>${r.tipo}</td>
                            <td>${r.dependencia}</td>
                            <td>${r.asunto}</td>
                            <td>${r.fecha}</td>
                            <td><span class="badge bg-dark">${r.estado}</span></td>
                            <td>${r.usuario}</td>
                        </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:if>

            <c:if test="${not empty resultados ? false : (not empty tipo && empty error)}">
                <div class="text-center text-muted py-5">No se encontraron resultados con los filtros aplicados.</div>
            </c:if>
        </div>
    </div>
</body>
</html>