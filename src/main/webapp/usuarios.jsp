<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.sadu.modelo.Usuario" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%
    HttpSession sesion = request.getSession(false);
    if (sesion == null || sesion.getAttribute("nombreUsuario") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Object rolObj = sesion.getAttribute("rolUsuario");
    int rolUsuario = 0;
    if (rolObj instanceof Integer) {
        rolUsuario = (Integer) rolObj;
    } else if (rolObj != null) {
        try { rolUsuario = Integer.parseInt(rolObj.toString()); } catch (Exception e) {}
    }

    if (rolUsuario != 1) {
        response.sendRedirect("dashboard.jsp");
        return;
    }

    String nombreUsuario = (String) sesion.getAttribute("nombreUsuario");

    List<Usuario> listaUsuarios = (List<Usuario>) request.getAttribute("listaUsuarios");
    if (listaUsuarios == null) {
        response.sendRedirect("usuarios");
        return;
    }

    Usuario       usuarioEditar = (Usuario)        request.getAttribute("usuarioEdicion");
    if (usuarioEditar == null) {
        usuarioEditar = (Usuario) request.getAttribute("usuarioEditar");
    }
    String        error         = (String)         request.getAttribute("error");
    Boolean       modoEdicion   = (Boolean)        request.getAttribute("modoEdicion");
    Boolean       busquedaActiva= (Boolean)        request.getAttribute("busquedaActiva");
    Integer       totalResultados = (Integer)      request.getAttribute("totalResultados");

    String busNombre = (String) request.getAttribute("busNombre");
    String busRol    = (String) request.getAttribute("busRol");
    String busEstado = (String) request.getAttribute("busEstado");

    String exito = request.getParameter("exito");

    if (busNombre     == null) busNombre     = "";
    if (busRol        == null) busRol        = "";
    if (busEstado     == null) busEstado     = "";
    if (modoEdicion   == null) modoEdicion   = false;
    if (busquedaActiva == null) busquedaActiva = false;
    
    pageContext.setAttribute("busNombre", busNombre);
    pageContext.setAttribute("error", error);
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestion de Usuarios - SADU</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">

    <style>
        body {
            margin: 0;
            background-color: #f4f6f9;
            font-family: Arial, sans-serif;
        }
        .content {
            margin-left: 250px;
            padding: 25px 30px;
        }
        .topbar {
            background: white;
            padding: 14px 22px;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            margin-bottom: 20px;
        }
        .card-panel {
            background: white;
            border-radius: 12px;
            padding: 24px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            margin-bottom: 20px;
            border-left: 4px solid #1f3b57;
        }
        .card-panel.panel-edicion {
            border-left: 4px solid #f0ad4e;
            background: #fffdf7;
        }
        .card-panel h5 {
            color: #1f3b57;
            font-weight: 600;
            margin-bottom: 18px;
            font-size: 16px;
        }
        .form-label {
            font-size: 13px;
            font-weight: 600;
            color: #495057;
        }
        .btn-primary-sadu {
            background-color: #1f3b57;
            color: white;
            border: none;
            padding: 9px 22px;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 500;
        }
        .btn-primary-sadu:hover { background-color: #162d42; color: white; }
        .btn-buscar {
            background-color: #2d6a4f;
            color: white;
            border: none;
            padding: 9px 20px;
            border-radius: 8px;
            font-size: 14px;
        }
        .btn-buscar:hover { background-color: #1b4332; color: white; }
        .btn-limpiar {
            background-color: #e9ecef;
            color: #495057;
            border: none;
            padding: 9px 18px;
            border-radius: 8px;
            font-size: 14px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
        }
        .btn-limpiar:hover { background-color: #dee2e6; color: #333; }
        .alerta-busqueda {
            background-color: #e7f1ff;
            color: #1f3b57;
            padding: 10px 16px;
            border-radius: 8px;
            font-size: 13px;
            margin-bottom: 14px;
        }
        .tabla-usuarios thead th {
            background-color: #1f3b57;
            color: white;
            font-size: 12.5px;
            font-weight: 600;
            padding: 12px 10px;
            border: none;
            white-space: nowrap;
        }
        .tabla-usuarios tbody td {
            padding: 11px 10px;
            font-size: 13.5px;
            vertical-align: middle;
        }
        .badge-activo { background-color: #d1e7dd; color: #0f5132; padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 600; }
        .badge-inactivo { background-color: #f8d7da; color: #842029; padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 600; }
        .badge-admin { background-color: #cfe2ff; color: #084298; padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 600; }
        .badge-gestor { background-color: #e2d9f3; color: #432874; padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 600; }
        .badge-dependencia { background-color: #e2e3e5; color: #41464b; padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 600; }
        
        .btn-editar { background-color: #ffc107; color: #212529; padding: 5px 12px; border-radius: 6px; font-size: 12px; font-weight: 600; text-decoration: none; border: none; }
        .btn-editar:hover { background-color: #e0a800; color: #212529; }
        .btn-activar { background-color: #198754; color: white; padding: 5px 12px; border-radius: 6px; font-size: 12px; font-weight: 600; border: none; }
        .btn-activar:hover { background-color: #146c43; }
        .btn-desactivar { background-color: #dc3545; color: white; padding: 5px 12px; border-radius: 6px; font-size: 12px; font-weight: 600; border: none; }
        .btn-desactivar:hover { background-color: #bb2d3b; }
        .select-rol-inline { font-size: 12px; padding: 4px 8px; border-radius: 6px; border: 1px solid #ced4da; background: white; }
        .form-inline-action { display: inline-block; margin: 0; }
    </style>
</head>
<body>

<%@ include file="sidebar.jsp" %>

<div class="content">

    <div class="topbar d-flex justify-content-between align-items-center">
        <div>
            <h4 class="mb-0" style="color:#1f3b57; font-weight:700;">Gestión de Usuarios</h4>
            <small class="text-muted">Administracion y privilegios de acceso SADU</small>
        </div>
        <div>
            <span class="badge bg-secondary p-2 me-2">Administrador: <%= nombreUsuario %></span>
        </div>
    </div>

    <% if ("1".equals(exito)) { %>
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="bi bi-check-circle-fill me-2"></i>Operación completada con exito.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } else if ("2".equals(exito)) { %>
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="bi bi-check-circle-fill me-2"></i>Los cambios del usuario han sido guardados.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } else if ("3".equals(exito)) { %>
        <div class="alert alert-warning alert-dismissible fade show text-dark fw-bold" role="alert">
            <i class="bi bi-key-fill me-2"></i>?Configurado! La prixima vez que el usuario ingrese al sistema, se le solicitara obligatoriamente cambiar su contraseña.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>

    <c:if test="${not empty error}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i><c:out value="${error}"/>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <!-- FORMULARIO: REGISTRAR O EDITAR USUARIO -->
    <div class="card-panel <%= modoEdicion ? "panel-edicion" : "" %>">
        <h5>
            <%= modoEdicion ? " Editando Usuario ID: " + usuarioEditar.getIdUsuario() : "? Registrar Nuevo Usuario" %>
        </h5>

        <form action="usuarios" method="post">
            <input type="hidden" name="accion" value="<%= modoEdicion ? "actualizar" : "registrar" %>">
            <% if (modoEdicion) { %>
                <input type="hidden" name="idUsuario" value="<%= usuarioEditar.getIdUsuario() %>">
            <% } %>

            <div class="row g-3">
                <div class="col-md-4">
                    <label class="form-label">Nombre Completo *</label>
                    <input type="text" name="nombreCompleto" class="form-control" required
                           value="<%= modoEdicion ? usuarioEditar.getNombreCompleto() : "" %>"
                           placeholder="Ej: Diana Zamudio">
                </div>

                <div class="col-md-4">
                    <label class="form-label">Correo Electronico *</label>
                    <input type="email" name="correo" class="form-control" required
                           value="<%= modoEdicion ? usuarioEditar.getCorreo() : "" %>"
                           placeholder="usuario@municipio.gov.co">
                </div>

                <div class="col-md-4">
                    <label class="form-label">Nombre de Usuario (Username) *</label>
                    <input type="text" name="username" class="form-control" required
                           value="<%= modoEdicion ? usuarioEditar.getUsername() : "" %>"
                           placeholder="ej: dzamudio">
                </div>

                <% if (!modoEdicion) { %>
                <div class="col-md-4">
                    <label class="form-label">Contraseña Inicial *</label>
                    <input type="password" name="password" class="form-control" required placeholder="Minimo 6 caracteres">
                </div>
                <% } %>

                <div class="col-md-4">
                    <label class="form-label">Rol / Privilegios *</label>
                    <select name="idRol" class="form-select" required>
                        <option value="">-- Seleccionar Rol --</option>
                        <option value="1" <%= modoEdicion && usuarioEditar.getRolId() == 1 ? "selected" : "" %>> Administrador (Acceso total)</option>
                        <option value="2" <%= modoEdicion && usuarioEditar.getRolId() == 2 ? "selected" : "" %>> Gestor de Archivo (Gestion documental)</option>
                        <option value="3" <%= modoEdicion && usuarioEditar.getRolId() == 3 ? "selected" : "" %>> Dependencia Municipal (Consulta y recepción)</option>
                    </select>
                </div>

                <% if (!modoEdicion) { %>
                <div class="col-md-4">
                    <label class="form-label">Estado Inicial</label>
                    <select name="estado" class="form-select">
                        <option value="ACTIVO">ACTIVO</option>
                        <option value="INACTIVO">INACTIVO</option>
                    </select>
                </div>
                <% } %>

                <div class="col-12 mt-4 d-flex gap-2">
                    <button type="submit" class="btn btn-primary-sadu">
                        <%= modoEdicion ? " Guardar Cambios" : " Crear Usuario" %>
                    </button>
                    <% if (modoEdicion) { %>
                        <a href="usuarios?accion=listar" class="btn btn-limpiar">Cancelar Edicion</a>
                    <% } %>
                </div>
            </div>
        </form>
    </div>

    <!-- BUSCADOR / FILTROS DE USUARIOS -->
    <div class="card-panel">
        <h5> Filtrar y Buscar Usuarios</h5>
        <form action="usuarios" method="get">
            <input type="hidden" name="accion" value="buscar">
            <div class="row g-3 align-items-end">
                <div class="col-md-4">
                    <label class="form-label">Nombre, Correo o Username</label>
                    <input type="text" name="busNombre" class="form-control"
                           value="<c:out value="${busNombre}"/>"
                           placeholder="Buscar...">
                </div>

                <div class="col-md-3">
                    <label class="form-label">Rol</label>
                    <select name="busRol" class="form-select">
                        <option value="">-- Todos los roles --</option>
                        <option value="1" <%= "1".equals(busRol) ? "selected" : "" %>>Administrador</option>
                        <option value="2" <%= "2".equals(busRol) ? "selected" : "" %>>Gestor de Archivo</option>
                        <option value="3" <%= "3".equals(busRol) ? "selected" : "" %>>Dependencia Municipal</option>
                    </select>
                </div>

                <div class="col-md-2">
                    <label class="form-label">Estado</label>
                    <select name="busEstado" class="form-select">
                        <option value="">-- Todos --</option>
                        <option value="ACTIVO"   <%= "ACTIVO".equals(busEstado)   ? "selected" : "" %>>ACTIVO</option>
                        <option value="INACTIVO" <%= "INACTIVO".equals(busEstado) ? "selected" : "" %>>INACTIVO</option>
                    </select>
                </div>

                <div class="col-md-3 d-flex gap-2">
                    <button type="submit" class="btn btn-buscar"><i class="bi bi-search me-1"></i> Buscar</button>
                    <a href="usuarios?accion=listar" class="btn btn-limpiar">Limpiar</a>
                </div>
            </div>
        </form>
    </div>

    <!-- TABLA DE USUARIOS -->
    <div class="card-panel">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h5 class="mb-0">
                <%= busquedaActiva ? "Resultados de b?squeda" : "Usuarios del Sistema" %>
            </h5>
            <% if (busquedaActiva && totalResultados != null) { %>
            <span class="badge bg-primary" style="font-size:13px;padding:6px 14px;border-radius:20px;">
                <%= totalResultados %> resultado<%= totalResultados != 1 ? "s" : "" %>
            </span>
            <% } else if (listaUsuarios != null) { %>
            <span class="text-muted" style="font-size:13px;">
                Total: <strong><%= listaUsuarios.size() %></strong> usuarios
            </span>
            <% } %>
        </div>

        <% if (busquedaActiva) { %>
        <div class="alerta-busqueda">
            B?squeda activa ?
            <a href="usuarios?accion=listar" style="color:#1f3b57;font-weight:600;">Ver todos los usuarios</a>
        </div>
        <% } %>

        <div class="table-responsive">
            <table class="table tabla-usuarios mb-0">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Nombre Completo</th>
                        <th>Correo</th>
                        <th>Username</th>
                        <th>Rol</th>
                        <th>Estado</th>
                        <th>Fecha Creación</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    if (listaUsuarios == null || listaUsuarios.isEmpty()) {
                %>
                    <tr>
                        <td colspan="8" class="text-center py-4 text-muted">
                            No hay usuarios <%= busquedaActiva ? "que coincidan con los filtros." : "registrados." %>
                        </td>
                    </tr>
                <%
                    } else {
                        int num = 1;
                        for (Usuario u : listaUsuarios) {
                            pageContext.setAttribute("uNombre", u.getNombreCompleto());
                            pageContext.setAttribute("uCorreo", u.getCorreo());
                            pageContext.setAttribute("uUsername", u.getUsername());
                            pageContext.setAttribute("uRolNombre", u.getNombreRol() != null ? u.getNombreRol() : "?");

                            String badgeEstado = "ACTIVO".equals(u.getEstado())
                                ? "<span class='badge-activo'>ACTIVO</span>"
                                : "<span class='badge-inactivo'>INACTIVO</span>";

                            if (u.isRequiereCambioClave()) {
                                badgeEstado += " <span class='badge bg-warning text-dark ms-1' title='El usuario deber? cambiar su clave al ingresar'><i class='bi bi-key-fill'></i> Clave pendiente</span>";
                            }

                            String badgeRol;
                            if (u.getRolId() == 1) {
                                badgeRol = "<span class='badge-admin'> " + pageContext.getAttribute("uRolNombre") + "</span>";
                            } else if (u.getRolId() == 2) {
                                badgeRol = "<span class='badge-gestor'> " + pageContext.getAttribute("uRolNombre") + "</span>";
                            } else {
                                badgeRol = "<span class='badge-dependencia'> " + pageContext.getAttribute("uRolNombre") + "</span>";
                            }

                            String fechaStr = u.getFechaCreacion() != null
                                ? u.getFechaCreacion().toString().substring(0, 16)
                                : "?";
                %>
                    <tr>
                        <td><%= num++ %></td>
                        <td><strong><c:out value="${uNombre}"/></strong></td>
                        <td style="font-size:12px;color:#6c757d;"><c:out value="${uCorreo}"/></td>
                        <td><code style="background:#f0f4f8;padding:2px 7px;border-radius:5px;font-size:12px;"><c:out value="${uUsername}"/></code></td>
                        <td><%= badgeRol %></td>
                        <td><%= badgeEstado %></td>
                        <td style="font-size:12px;color:#6c757d;"><%= fechaStr %></td>
                        <td>
                            <div class="d-flex gap-1 flex-wrap align-items-center">
                                <a href="usuarios?accion=editar&id=<%= u.getIdUsuario() %>" class="btn-editar"><i class="bi bi-pencil-square"></i> Editar</a>

                                <!-- Cambio de Estado mediante POST -->
                                <form action="usuarios" method="post" class="form-inline-action">
                                    <input type="hidden" name="accion" value="cambiarEstado">
                                    <input type="hidden" name="id" value="<%= u.getIdUsuario() %>">
                                    <% if ("ACTIVO".equals(u.getEstado())) { %>
                                        <input type="hidden" name="estado" value="INACTIVO">
                                        <button type="submit" class="btn-desactivar" onclick="return confirm('?Deshabilitar al usuario <c:out value="${uUsername}"/>?')"><i class="bi bi-person-x-fill"></i> Deshabilitar</button>
                                    <% } else { %>
                                        <input type="hidden" name="estado" value="ACTIVO">
                                        <button type="submit" class="btn-activar" onclick="return confirm('?Activar al usuario <c:out value="${uUsername}"/>?')"><i class="bi bi-person-check-fill"></i> Activar</button>
                                    <% } %>
                                </form>

                                <!-- Cambio de Rol mediante POST -->
                                <form action="usuarios" method="post" class="form-inline-action">
                                    <input type="hidden" name="accion" value="cambiarRol">
                                    <input type="hidden" name="id" value="<%= u.getIdUsuario() %>">
                                    <select name="rol" class="select-rol-inline" onchange="if(confirm('?Cambiar el rol de <c:out value="${uUsername}"/>?')) this.form.submit();">
                                        <option value="<%= u.getRolId() %>">Cambiar Rol...</option>
                                        <% if (u.getRolId() != 1) { %><option value="1"> Admin</option><% } %>
                                        <% if (u.getRolId() != 2) { %><option value="2"> Gestor</option><% } %>
                                        <% if (u.getRolId() != 3) { %><option value="3"> Dependencia</option><% } %>
                                    </select>
                                </form>

                                <!-- Forzar Cambio de Clave mediante POST -->
                                <form action="usuarios" method="post" class="form-inline-action">
                                    <input type="hidden" name="accion" value="forzarCambioClave">
                                    <input type="hidden" name="id" value="<%= u.getIdUsuario() %>">
                                    <button type="submit" class="btn btn-sm btn-warning text-dark" style="font-size:12px;font-weight:600;padding:5px 10px;" title="La pr?xima vez que ingrese se le pedir? cambiar su contrase?a" onclick="return confirm('?Exigir cambio de clave a <c:out value="${uUsername}"/> la pr?xima vez que ingrese?')">
                                        <i class="bi bi-key-fill"></i> Forzar clave
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                <%
                        }
                    }
                %>
                </tbody>
            </table>
        </div>
    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
