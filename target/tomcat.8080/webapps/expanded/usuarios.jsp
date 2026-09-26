<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.sadu.modelo.Usuario" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%
    /* ── Validar sesión activa ─────────────────────────────────── */
    HttpSession sesion = request.getSession(false);
    if (sesion == null || sesion.getAttribute("nombreUsuario") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    /* ── Validar que sea ADMINISTRADOR (rolUsuario = 1) ─────────── */
    Integer rolUsuario = (Integer) sesion.getAttribute("rolUsuario");
    if (rolUsuario == null || rolUsuario != 1) {
        response.sendRedirect("dashboard.jsp");
        return;
    }

    String nombreUsuario = (String) sesion.getAttribute("nombreUsuario");

    /* ── Datos enviados por UsuarioServlet ───────────────────────── */
    List<Usuario> listaUsuarios = (List<Usuario>) request.getAttribute("listaUsuarios");
    Usuario       usuarioEditar = (Usuario)        request.getAttribute("usuarioEditar");
    String        error         = (String)         request.getAttribute("error");
    Boolean       modoEdicion   = (Boolean)        request.getAttribute("modoEdicion");
    Boolean       busquedaActiva= (Boolean)        request.getAttribute("busquedaActiva");
    Integer       totalResultados = (Integer)      request.getAttribute("totalResultados");

    /* ── Valores previos del buscador ────────────────────────────── */
    String busNombre = (String) request.getAttribute("busNombre");
    String busRol    = (String) request.getAttribute("busRol");
    String busEstado = (String) request.getAttribute("busEstado");

    /* ── Mensaje de éxito desde la URL ──────────────────────────── */
    String exito = request.getParameter("exito");

    /* ── Null safety ─────────────────────────────────────────────── */
    if (busNombre     == null) busNombre     = "";
    if (busRol        == null) busRol        = "";
    if (busEstado     == null) busEstado     = "";
    if (modoEdicion   == null) modoEdicion   = false;
    if (busquedaActiva == null) busquedaActiva = false;
    
    // Compartir variables con el contexto de JSTL para el escape automático
    pageContext.setAttribute("busNombre", busNombre);
    pageContext.setAttribute("error", error);
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Usuarios - SADU</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

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
            border-bottom: 1px solid #eef1f4;
        }
        .tabla-usuarios tbody tr:hover { background-color: #f8fafc; }
        .tabla-vacia {
            text-align: center;
            padding: 40px;
            color: #999;
            font-size: 14px;
        }
        .badge-activo {
            background-color: #d1fae5;
            color: #065f46;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 11.5px;
            font-weight: 600;
            white-space: nowrap;
        }
        .badge-inactivo {
            background-color: #fee2e2;
            color: #b91c1c;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 11.5px;
            font-weight: 600;
            white-space: nowrap;
        }
        .badge-admin {
            background-color: #fff3cd;
            color: #856404;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 11.5px;
            font-weight: 600;
            white-space: nowrap;
        }
        .badge-gestor {
            background-color: #cfe2ff;
            color: #084298;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 11.5px;
            font-weight: 600;
            white-space: nowrap;
        }
        .badge-dependencia {
            background-color: #e2e3e5;
            color: #41464b;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 11.5px;
            font-weight: 600;
            white-space: nowrap;
        }
        .btn-editar, .btn-activar, .btn-desactivar {
            font-size: 11.5px;
            padding: 5px 10px;
            border-radius: 6px;
            text-decoration: none;
            white-space: nowrap;
            color: white;
            border: none;
            display: inline-block;
        }
        .btn-editar { background-color: #1f3b57; }
        .btn-editar:hover { background-color: #162d42; color: white; }
        .btn-activar { background-color: #2d6a4f; }
        .btn-activar:hover { background-color: #1b4332; color: white; }
        .btn-desactivar { background-color: #b91c1c; }
        .btn-desactivar:hover { background-color: #8f1414; color: white; }
        .select-rol-inline {
            font-size: 11.5px;
            padding: 4px 6px;
            border-radius: 6px;
            border: 1px solid #ced4da;
            max-width: 110px;
        }
        .form-inline-action { display: inline; margin: 0; padding: 0; }
    </style>
</head>
<body>

<%@ include file="sidebar.jsp" %>

<div class="content">

    <!-- Topbar -->
    <div class="topbar d-flex justify-content-between align-items-center">
        <div>
            <h6 class="mb-0 fw-bold" style="color:#1f3b57;">👥 Gestión de Usuarios</h6>
            <small class="text-muted">Registro, edición y control de acceso de usuarios</small>
        </div>
        <div class="text-end">
            <small class="text-muted">👤 <c:out value="<%= nombreUsuario %>"/> &nbsp;|&nbsp;
                <span class="badge" style="background:#fff3cd;color:#856404;">ADMINISTRADOR</span>
            </small>
        </div>
    </div>

    <!-- ── Alertas de éxito ── -->
    <% if ("1".equals(exito)) { %>
    <div class="alert alert-success alert-dismissible fade show">
        ✅ Usuario registrado exitosamente.
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <% } else if ("2".equals(exito)) { %>
    <div class="alert alert-success alert-dismissible fade show">
        ✏️ Usuario actualizado correctamente.
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <% } else if ("3".equals(exito)) { %>
    <div class="alert alert-info alert-dismissible fade show">
        🔄 Estado del usuario actualizado.
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <% } else if ("4".equals(exito)) { %>
    <div class="alert alert-info alert-dismissible fade show">
        🔄 Rol del usuario actualizado.
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <% } %>

    <!-- ── Alerta de error ── -->
    <c:if test="${not empty error}">
    <div class="alert alert-danger alert-dismissible fade show">
        ⚠️ <c:out value="${error}"/>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    </c:if>

    <!-- ══ FORMULARIO: REGISTRO o EDICIÓN ══ -->
    <div class="card-panel <%= modoEdicion ? "panel-edicion" : "" %>">
        <h5>
            <%= modoEdicion && usuarioEditar != null
                ? "✏️ Editar Usuario — " : "➕ Registrar Nuevo Usuario" %>
            <c:if test="<%= modoEdicion && usuarioEditar != null %>">
                <c:out value="<%= usuarioEditar.getNombreCompleto() %>"/>
            </c:if>
        </h5>

        <form action="usuarios" method="post">
            <input type="hidden" name="accion" value="<%= modoEdicion ? "actualizar" : "registrar" %>">

            <% if (modoEdicion && usuarioEditar != null) { %>
            <input type="hidden" name="idUsuario" value="<%= usuarioEditar.getIdUsuario() %>">
            <% } %>

            <div class="row g-3">
                <!-- Nombre completo -->
                <div class="col-md-4">
                    <label class="form-label">Nombre Completo *</label>
                    <input type="text" name="nombreCompleto" class="form-control"
                           placeholder="Ej: Diana Zamudio"
                           value="<c:out value='<%= modoEdicion && usuarioEditar != null ? usuarioEditar.getNombreCompleto() : "" %>'/>"
                           maxlength="120" required>
                </div>

                <!-- Correo electrónico -->
                <div class="col-md-4">
                    <label class="form-label">Correo Electrónico *</label>
                    <input type="email" name="correo" class="form-control"
                           placeholder="correo@sadu.com"
                           value="<c:out value='<%= modoEdicion && usuarioEditar != null ? usuarioEditar.getCorreo() : "" %>'/>"
                           maxlength="120" required>
                </div>

                <!-- Username -->
                <div class="col-md-4">
                    <label class="form-label">Username *</label>
                    <input type="text" name="username" class="form-control"
                           placeholder="Ej: dzamudio"
                           value="<c:out value='<%= modoEdicion && usuarioEditar != null ? usuarioEditar.getUsername() : "" %>'/>"
                           maxlength="50" required>
                </div>

                <!-- Contraseña (solo en registro) -->
                <% if (!modoEdicion) { %>
                <div class="col-md-4">
                    <label class="form-label">Contraseña *</label>
                    <input type="password" name="password" class="form-control"
                           placeholder="Contraseña de acceso"
                           maxlength="255" required>
                </div>
                <% } %>

                <!-- Rol -->
                <div class="col-md-3">
                    <label class="form-label">Rol *</label>
                    <select name="idRol" class="form-select" required>
                        <option value="">-- Selecciona --</option>
                        <option value="1" <%= modoEdicion && usuarioEditar != null && usuarioEditar.getRolId() == 1 ? "selected" : "" %>>👑 ADMINISTRADOR</option>
                        <option value="2" <%= modoEdicion && usuarioEditar != null && usuarioEditar.getRolId() == 2 ? "selected" : "" %>>📂 GESTOR DE ARCHIVO</option>
                        <option value="3" <%= modoEdicion && usuarioEditar != null && usuarioEditar.getRolId() == 3 ? "selected" : "" %>>🏢 DEPENDENCIA</option>
                    </select>
                </div>

                <!-- Estado (solo en registro) -->
                <% if (!modoEdicion) { %>
                <div class="col-md-2">
                    <label class="form-label">Estado</label>
                    <select name="estado" class="form-select">
                        <option value="ACTIVO">✅ ACTIVO</option>
                        <option value="INACTIVO">❌ INACTIVO</option>
                    </select>
                </div>
                <% } %>

                <!-- Botones -->
                <div class="col-12 d-flex gap-2 justify-content-end">
                    <% if (modoEdicion) { %>
                    <a href="usuarios?accion=listar" class="btn btn-limpiar">✕ Cancelar</a>
                    <button type="submit" class="btn btn-primary-sadu">💾 Guardar Cambios</button>
                    <% } else { %>
                    <button type="submit" class="btn btn-primary-sadu">👤 Registrar Usuario</button>
                    <% } %>
                </div>
            </div>
        </form>
    </div>

    <!-- ══ BUSCADOR ══ -->
    <div class="card-panel">
        <h5>🔍 Buscar Usuarios</h5>

        <form action="usuarios" method="get">
            <input type="hidden" name="accion" value="buscar">

            <div class="row g-3 align-items-end">
                <div class="col-md-4">
                    <label class="form-label">Nombre / Correo / Username</label>
                    <input type="text" name="busNombre" class="form-control"
                           placeholder="Buscar..."
                           value="<c:out value='${busNombre}'/>">
                </div>

                <div class="col-md-3">
                    <label class="form-label">Rol</label>
                    <select name="busRol" class="form-select">
                        <option value="">-- Todos --</option>
                        <option value="1" <%= "1".equals(busRol) ? "selected" : "" %>>👑 ADMINISTRADOR</option>
                        <option value="2" <%= "2".equals(busRol) ? "selected" : "" %>>📂 GESTOR DE ARCHIVO</option>
                        <option value="3" <%= "3".equals(busRol) ? "selected" : "" %>>🏢 DEPENDENCIA</option>
                    </select>
                </div>

                <div class="col-md-2">
                    <label class="form-label">Estado</label>
                    <select name="busEstado" class="form-select">
                        <option value="">-- Todos --</option>
                        <option value="ACTIVO"   <%= "ACTIVO".equals(busEstado)   ? "selected" : "" %>>✅ ACTIVO</option>
                        <option value="INACTIVO" <%= "INACTIVO".equals(busEstado) ? "selected" : "" %>>❌ INACTIVO</option>
                    </select>
                </div>

                <div class="col-md-3 d-flex gap-2">
                    <button type="submit" class="btn btn-buscar">🔍 Buscar</button>
                    <a href="usuarios?accion=listar" class="btn btn-limpiar">✕ Limpiar</a>
                </div>
            </div>
        </form>
    </div>

    <!-- ══ TABLA DE USUARIOS ══ -->
    <div class="card-panel">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h5 class="mb-0">
                <%= busquedaActiva ? "🔍 Resultados de búsqueda" : "📋 Usuarios del Sistema" %>
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
            📌 Búsqueda activa —
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
                        <td colspan="8" class="tabla-vacia">
                            👤 No hay usuarios <%= busquedaActiva ? "que coincidan con los filtros." : "registrados." %>
                        </td>
                    </tr>
                <%
                    } else {
                        int num = 1;
                        for (Usuario u : listaUsuarios) {
                            pageContext.setAttribute("uNombre", u.getNombreCompleto());
                            pageContext.setAttribute("uCorreo", u.getCorreo());
                            pageContext.setAttribute("uUsername", u.getUsername());
                            pageContext.setAttribute("uRolNombre", u.getNombreRol() != null ? u.getNombreRol() : "—");

                            String badgeEstado = "ACTIVO".equals(u.getEstado())
                                ? "<span class='badge-activo'>✅ ACTIVO</span>"
                                : "<span class='badge-inactivo'>❌ INACTIVO</span>";

                            String badgeRol;
                            if (u.getRolId() == 1) {
                                badgeRol = "<span class='badge-admin'>👑 " + pageContext.getAttribute("uRolNombre") + "</span>";
                            } else if (u.getRolId() == 2) {
                                badgeRol = "<span class='badge-gestor'>📂 " + pageContext.getAttribute("uRolNombre") + "</span>";
                            } else {
                                badgeRol = "<span class='badge-dependencia'>🏢 " + pageContext.getAttribute("uRolNombre") + "</span>";
                            }

                            String fechaStr = u.getFechaCreacion() != null
                                ? u.getFechaCreacion().toString().substring(0, 16)
                                : "—";
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
                                <a href="usuarios?accion=editar&id=<%= u.getIdUsuario() %>" class="btn-editar">✏️ Editar</a>

                                <!-- Envío Seguro de cambio de Estado mediante POST -->
                                <form action="usuarios" method="post" class="form-inline-action">
                                    <input type="hidden" name="accion" value="cambiarEstado">
                                    <input type="hidden" name="id" value="<%= u.getIdUsuario() %>">
                                    <% if ("ACTIVO".equals(u.getEstado())) { %>
                                        <input type="hidden" name="estado" value="INACTIVO">
                                        <button type="submit" class="btn-desactivar" onclick="return confirm('¿Desactivar al usuario <c:out value="${uUsername}"/>?')">❌ Desactivar</button>
                                    <% } else { %>
                                        <input type="hidden" name="estado" value="ACTIVO">
                                        <button type="submit" class="btn-activar" onclick="return confirm('¿Activar al usuario <c:out value="${uUsername}"/>?')">✅ Activar</button>
                                    <% } %>
                                </form>

                                <!-- Envío Seguro de cambio de Rol mediante POST -->
                                <form action="usuarios" method="post" class="form-inline-action">
                                    <input type="hidden" name="accion" value="cambiarRol">
                                    <input type="hidden" name="id" value="<%= u.getIdUsuario() %>">
                                    <select name="rol" class="select-rol-inline" onchange="if(confirm('¿Cambiar el rol de <c:out value="${uUsername}"/>?')) this.form.submit();">
                                        <option value="<%= u.getRolId() %>">🔄 Rol</option>
                                        <% if (u.getRolId() != 1) { %><option value="1">👑 Admin</option><% } %>
                                        <% if (u.getRolId() != 2) { %><option value="2">📂 Gestor</option><% } %>
                                        <% if (u.getRolId() != 3) { %><option value="3">🏢 Dependencia</option><% } %>
                                    </select>
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