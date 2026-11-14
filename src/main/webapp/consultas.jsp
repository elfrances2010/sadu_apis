<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Consultas - SADU</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <style>
        body { margin: 0; background-color: #f4f6f9; font-family: Arial, sans-serif; }
        .content { margin-left: 250px; padding: 30px; }
        .card-panel { border: none; border-radius: 12px; box-shadow: 0 3px 8px rgba(0,0,0,0.08); }
        .nav-tabs .nav-link.active { font-weight: 600; }
        .action-form { display: inline-block; margin-right: 4px; }
    </style>
</head>
<body>
    <%@ include file="sidebar.jsp" %>
    <div class="content">
        <div class="card card-panel p-4">
            <h2><i class="bi bi-search me-2"></i>M?dulo de Consultas</h2>
            <p class="text-muted">Realiza b?squedas espec?ficas dentro del sistema SADU, con filtros por documento, fecha, usuario o dependencia.</p>

            <c:if test="${param.exito == '1'}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i>Estado del usuario actualizado correctamente.
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            <c:if test="${param.exito == '2'}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i>Privilegios / Rol del usuario actualizados correctamente.
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            <c:if test="${param.exito == '3'}">
                <div class="alert alert-warning alert-dismissible fade show text-dark fw-bold" role="alert">
                    <i class="bi bi-key-fill me-2"></i>?Configurado! La pr?xima vez que el usuario ingrese al sistema, se le solicitar? obligatoriamente cambiar su contrase?a.
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <!-- Pesta?as -->
            <ul class="nav nav-tabs mb-3">
                <li class="nav-item">
                    <a class="nav-link <c:if test='${tipo == "documentos" || empty tipo}'>active</c:if>'"
                       href="consultas?tipo=documentos"><i class="bi bi-file-earmark-text me-1"></i> Documentos</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link <c:if test='${tipo == "usuarios"}'>active</c:if>'"
                       href="consultas?tipo=usuarios"><i class="bi bi-people-fill me-1"></i> Usuarios</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link <c:if test='${tipo == "comunicaciones"}'>active</c:if>'"
                       href="consultas?tipo=comunicaciones"><i class="bi bi-envelope-paper me-1"></i> Comunicaciones</a>
                </li>
            </ul>

            <!-- Formulario de filtros -->
            <form method="GET" action="consultas" class="row g-3 mb-4">
                <input type="hidden" name="tipo" value="${empty tipo ? 'documentos' : tipo}">

                <div class="col-md-3">
                    <label class="form-label">Buscar texto</label>
                    <input type="text" name="texto" value="${texto}" class="form-control"
                           placeholder="Nombre, c?digo o asunto">
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
                    <button type="submit" class="btn btn-dark"><i class="bi bi-search me-1"></i> Buscar</button>
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
                            <th>C?digo</th><th>Nombre</th><th>Tipo</th><th>Dependencia</th>
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
                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead class="table-dark">
                            <tr>
                                <th>Nombre</th>
                                <th>Correo</th>
                                <th>Username</th>
                                <th>Rol / Privilegios</th>
                                <th>Estado</th>
                                <th>Fecha registro</th>
                                <c:if test="${sessionScope.rolUsuario == 1}">
                                    <th class="text-center">Acciones / Administraci?n</th>
                                </c:if>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="r" items="${resultados}">
                            <tr>
                                <td><strong><c:out value="${r.nombre}"/></strong></td>
                                <td><c:out value="${r.correo}"/></td>
                                <td><code><c:out value="${r.username}"/></code></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${r.rolId == 1}"><span class="badge bg-danger"><i class="bi bi-shield-lock-fill me-1"></i> ${r.rol}</span></c:when>
                                        <c:when test="${r.rolId == 2}"><span class="badge bg-primary"><i class="bi bi-folder-fill me-1"></i> ${r.rol}</span></c:when>
                                        <c:otherwise><span class="badge bg-secondary"><i class="bi bi-building me-1"></i> ${r.rol}</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${r.estado == 'ACTIVO'}"><span class="badge bg-success">ACTIVO</span></c:when>
                                        <c:otherwise><span class="badge bg-danger">INACTIVO</span></c:otherwise>
                                    </c:choose>
                                    <c:if test="${r.requiereCambioClave}">
                                        <span class="badge bg-warning text-dark ms-1" title="Deber? cambiar su clave al ingresar"><i class="bi bi-key-fill"></i> Clave pendiente</span>
                                    </c:if>
                                </td>
                                <td style="font-size:12px;color:#6c757d;">${r.fecha}</td>
                                <c:if test="${sessionScope.rolUsuario == 1}">
                                    <td>
                                        <div class="d-flex gap-1 flex-wrap align-items-center justify-content-center">
                                            <!-- Administrar / Editar -->
                                            <a href="usuarios?accion=editar&id=${r.id}" class="btn btn-sm btn-outline-primary" title="Editar datos del usuario">
                                                <i class="bi bi-pencil-square"></i> Editar
                                            </a>

                                            <!-- Deshabilitar / Habilitar -->
                                            <form action="usuarios" method="post" class="action-form">
                                                <input type="hidden" name="accion" value="cambiarEstado">
                                                <input type="hidden" name="id" value="${r.id}">
                                                <input type="hidden" name="origen" value="consultas">
                                                <c:choose>
                                                    <c:when test="${r.estado == 'ACTIVO'}">
                                                        <input type="hidden" name="estado" value="INACTIVO">
                                                        <button type="submit" class="btn btn-sm btn-outline-danger" title="Deshabilitar temporalmente" onclick="return confirm('?Deshabilitar temporalmente al usuario ${r.username}?')">
                                                            <i class="bi bi-person-x-fill"></i> Deshabilitar
                                                        </button>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <input type="hidden" name="estado" value="ACTIVO">
                                                        <button type="submit" class="btn btn-sm btn-outline-success" title="Habilitar usuario" onclick="return confirm('?Activar al usuario ${r.username}?')">
                                                            <i class="bi bi-person-check-fill"></i> Habilitar
                                                        </button>
                                                    </c:otherwise>
                                                </c:choose>
                                            </form>

                                            <!-- Cambiar Privilegios / Rol -->
                                            <form action="usuarios" method="post" class="action-form">
                                                <input type="hidden" name="accion" value="cambiarRol">
                                                <input type="hidden" name="id" value="${r.id}">
                                                <input type="hidden" name="origen" value="consultas">
                                                <select name="rol" class="form-select form-select-sm d-inline-block w-auto" onchange="if(confirm('?Cambiar los privilegios / rol del usuario ${r.username}?')) this.form.submit();">
                                                    <option value="${r.rolId}">Cambiar Rol...</option>
                                                    <c:if test="${r.rolId != 1}"><option value="1">?? Admin</option></c:if>
                                                    <c:if test="${r.rolId != 2}"><option value="2">?? Gestor</option></c:if>
                                                    <c:if test="${r.rolId != 3}"><option value="3">??? Dependencia</option></c:if>
                                                </select>
                                            </form>

                                            <!-- Forzar Cambio de Clave al pr?ximo ingreso -->
                                            <form action="usuarios" method="post" class="action-form">
                                                <input type="hidden" name="accion" value="forzarCambioClave">
                                                <input type="hidden" name="id" value="${r.id}">
                                                <input type="hidden" name="origen" value="consultas">
                                                <button type="submit" class="btn btn-sm btn-warning text-dark" title="Al hacer clic, la pr?xima vez que el usuario ingrese se le exigir? cambiar su contrase?a" onclick="return confirm('?Exigir cambio de clave a ${r.username} la pr?xima vez que ingrese?')">
                                                    <i class="bi bi-key-fill"></i> Forzar clave
                                                </button>
                                            </form>
                                        </div>
                                    </td>
                                </c:if>
                            </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
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
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
