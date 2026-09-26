package com.sadu.controller;

import com.sadu.util.Auditoria;
import com.sadu.dao.UsuarioDAO;
import com.sadu.modelo.Usuario;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * ════════════════════════════════════════════════════════════════
 * UsuarioServlet — Controlador del módulo de Usuarios SADU
 * ════════════════════════════════════════════════════════════════
 *
 * Gestiona todas las operaciones del módulo de Gestión de Usuarios.
 * Solo los ADMINISTRADORES (id_rol = 1) pueden acceder a este módulo.
 *
 * Acciones GET:
 *   ?accion=listar         → Lista todos los usuarios con su rol
 *   ?accion=buscar         → Filtra usuarios por nombre, rol y estado
 *   ?accion=editar&id=X    → Carga el formulario de edición con datos del usuario X
 *   ?accion=cambiarEstado  → Activa o desactiva un usuario
 *   ?accion=cambiarRol     → Cambia el rol de un usuario
 *   (sin accion)           → Redirige a listar
 *
 * Acciones POST:
 *   ?accion=registrar      → Registra un nuevo usuario
 *   ?accion=actualizar     → Guarda los cambios de edición de un usuario
 *
 * Cada operación exitosa registra un log automático en logs_auditoria.
 *
 * URL de acceso: /usuarios
 */
@WebServlet(name = "UsuarioServlet", urlPatterns = {"/usuarios"})
public class UsuarioServlet extends HttpServlet {

    /**
     * Método GET: maneja todas las operaciones de lectura y cambios simples.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ── 1. Validar sesión activa ──────────────────────────────
        HttpSession sesion = request.getSession(false);
        if (sesion == null || sesion.getAttribute("nombreUsuario") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // ── 2. Validar que sea ADMINISTRADOR (id_rol = 1) ─────────
        Integer rolUsuario = (Integer) sesion.getAttribute("rolUsuario");
        if (rolUsuario == null || rolUsuario != 1) {
            // Sin permisos → redirigir al dashboard
            response.sendRedirect("dashboard.jsp?accesoDenegado=1");
            return;
        }

        // ── 3. Determinar acción ──────────────────────────────────
        String accion = request.getParameter("accion");
        if (accion == null) accion = "listar";

        switch (accion) {

            case "buscar":
                buscarUsuarios(request, response);
                break;

            case "editar":
                // Cargar el formulario de edición con los datos del usuario
                cargarFormularioEdicion(request, response);
                break;

            case "cambiarEstado":
                // Activar o desactivar un usuario directamente desde la tabla
                cambiarEstado(request, response, sesion);
                break;

            case "cambiarRol":
                // Cambiar el rol de un usuario directamente desde la tabla
                cambiarRol(request, response, sesion);
                break;

            case "listar":
            default:
                listarUsuarios(request, response);
                break;
        }
    }

    /**
     * Método POST: maneja el registro de nuevos usuarios y la edición.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ── 1. Validar sesión ─────────────────────────────────────
        HttpSession sesion = request.getSession(false);
        if (sesion == null || sesion.getAttribute("nombreUsuario") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // ── 2. Validar que sea ADMINISTRADOR ──────────────────────
        Integer rolUsuario = (Integer) sesion.getAttribute("rolUsuario");
        if (rolUsuario == null || rolUsuario != 1) {
            response.sendRedirect("dashboard.jsp?accesoDenegado=1");
            return;
        }

        // ── 3. Determinar acción POST ─────────────────────────────
        String accion = request.getParameter("accion");

        if ("registrar".equals(accion)) {
            registrarUsuario(request, response, sesion);
        } else if ("actualizar".equals(accion)) {
            actualizarUsuario(request, response, sesion);
        } else {
            response.sendRedirect("usuarios?accion=listar");
        }
    }

    // ════════════════════════════════════════════════════════════
    // MÉTODOS PRIVADOS — uno por cada operación
    // ════════════════════════════════════════════════════════════

    /**
     * Lista todos los usuarios del sistema con su nombre de rol.
     * Envía la lista al JSP usuarios.jsp para su visualización.
     */
    private void listarUsuarios(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        UsuarioDAO dao = new UsuarioDAO();

        List<Usuario> lista = dao.listarUsuarios();
        request.setAttribute("listaUsuarios", lista);
        request.setAttribute("busquedaActiva", false);
        request.setAttribute("modoEdicion", false);

        request.getRequestDispatcher("usuarios.jsp").forward(request, response);
    }

    /**
     * Busca usuarios aplicando filtros de nombre, rol y estado.
     * Mantiene los valores del formulario después de la búsqueda.
     */
    private void buscarUsuarios(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Capturar filtros del formulario
        String nombre    = request.getParameter("busNombre");
        String idRolStr  = request.getParameter("busRol");
        String estado    = request.getParameter("busEstado");

        // Convertir el rol a entero (0 = sin filtro)
        int idRol = 0;
        if (idRolStr != null && !idRolStr.trim().isEmpty()) {
            try { idRol = Integer.parseInt(idRolStr); } catch (NumberFormatException e) { idRol = 0; }
        }

        UsuarioDAO dao = new UsuarioDAO();

        List<Usuario> lista = dao.buscarUsuarios(nombre, idRol, estado);
        request.setAttribute("listaUsuarios", lista);
        request.setAttribute("busquedaActiva", true);
        request.setAttribute("totalResultados", lista.size());
        request.setAttribute("modoEdicion", false);

        // Reenviar valores para conservar los campos llenos
        request.setAttribute("busNombre", nombre  != null ? nombre  : "");
        request.setAttribute("busRol",    idRolStr != null ? idRolStr : "");
        request.setAttribute("busEstado", estado   != null ? estado   : "");

        request.getRequestDispatcher("usuarios.jsp").forward(request, response);
    }

    /**
     * Carga el formulario de edición con los datos del usuario seleccionado.
     * El ID del usuario viene por parámetro GET (?accion=editar&id=X).
     */
    private void cargarFormularioEdicion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");

        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect("usuarios?accion=listar");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            UsuarioDAO dao = new UsuarioDAO();

            // Obtener el usuario por ID para precargar el formulario
            Usuario usuario = dao.obtenerPorId(id);

            if (usuario == null) {
                // Usuario no encontrado → volver al listado con mensaje
                request.setAttribute("error", "No se encontró el usuario con ID: " + id);
                listarUsuarios(request, response);
                return;
            }

            // Enviar el usuario al JSP para precargar el formulario de edición
            request.setAttribute("usuarioEditar", usuario);
            request.setAttribute("listaUsuarios", dao.listarUsuarios());
            request.setAttribute("modoEdicion", true);
            request.setAttribute("busquedaActiva", false);

            request.getRequestDispatcher("usuarios.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect("usuarios?accion=listar");
        }
    }

    /**
     * Cambia el estado de un usuario entre ACTIVO e INACTIVO.
     * Se llama desde un botón en la tabla de usuarios.
     *
     * AUDITORÍA: registra log con el cambio de estado realizado.
     */
    private void cambiarEstado(HttpServletRequest request, HttpServletResponse response,
                                HttpSession sesion) throws IOException {

        String idStr       = request.getParameter("id");
        String nuevoEstado = request.getParameter("estado");

        if (idStr != null && nuevoEstado != null) {
            try {
                int id          = Integer.parseInt(idStr);
                int idAdmin     = (int)    sesion.getAttribute("idUsuario");
                String username = (String) sesion.getAttribute("username");

                UsuarioDAO dao = new UsuarioDAO();

                // Obtener el nombre del usuario que se modifica (para el log)
                Usuario u = dao.obtenerPorId(id);
                boolean actualizado = dao.cambiarEstado(id, nuevoEstado);

                if (actualizado && u != null) {
                    // ── AUDITORÍA — Cambio de estado ──────────────
                    
                    Auditoria.registrar(
                        idAdmin,
                        "CAMBIAR_ESTADO_USUARIO",
                        "Admin '" + username + "' cambió estado del usuario '" +
                            u.getUsername() + "' → " + nuevoEstado
                    );
                }

            } catch (NumberFormatException e) {
                // ID inválido, ignorar
            }
        }

        response.sendRedirect("usuarios?accion=listar&exito=3");
    }

    /**
     * Cambia el rol de un usuario directamente desde la tabla.
     * Solo el administrador puede hacer esto.
     *
     * AUDITORÍA: registra log con el cambio de rol realizado.
     */
    private void cambiarRol(HttpServletRequest request, HttpServletResponse response,
                             HttpSession sesion) throws IOException {

        String idStr     = request.getParameter("id");
        String nuevoRolStr = request.getParameter("rol");

        if (idStr != null && nuevoRolStr != null) {
            try {
                int id          = Integer.parseInt(idStr);
                int nuevoRol    = Integer.parseInt(nuevoRolStr);
                int idAdmin     = (int)    sesion.getAttribute("idUsuario");
                String username = (String) sesion.getAttribute("username");

                UsuarioDAO dao = new UsuarioDAO();

                Usuario u = dao.obtenerPorId(id);
                boolean actualizado = dao.cambiarRol(id, nuevoRol);

                if (actualizado && u != null) {
                    // ── AUDITORÍA — Cambio de rol ─────────────────
                    String[] roles = {"", "ADMINISTRADOR", "GESTOR_ARCHIVO", "DEPENDENCIA"};
                    String nombreNuevoRol = (nuevoRol >= 1 && nuevoRol <= 3) ? roles[nuevoRol] : "ROL-" + nuevoRol;

                    
                    Auditoria.registrar(
                        idAdmin,
                        "CAMBIAR_ROL_USUARIO",
                        "Admin '" + username + "' cambió rol del usuario '" +
                            u.getUsername() + "' → " + nombreNuevoRol
                    );
                }

            } catch (NumberFormatException e) {
                // Valores inválidos, ignorar
            }
        }

        response.sendRedirect("usuarios?accion=listar&exito=4");
    }

    /**
     * Registra un nuevo usuario en la base de datos.
     * Valida campos obligatorios y verifica duplicados antes de guardar.
     *
     * AUDITORÍA: registra log con el nombre del usuario creado.
     */
    private void registrarUsuario(HttpServletRequest request, HttpServletResponse response,
                                   HttpSession sesion) throws ServletException, IOException {

        // ── 1. Capturar datos del formulario ──────────────────────
        String nombre    = request.getParameter("nombreCompleto");
        String correo    = request.getParameter("correo");
        String username  = request.getParameter("username");
        String password  = request.getParameter("password");
        String rolStr    = request.getParameter("idRol");
        String estado    = request.getParameter("estado");
        int    idAdmin   = (int)    sesion.getAttribute("idUsuario");
        String usernameAdmin = (String) sesion.getAttribute("username");

        // ── 2. Validar campos obligatorios ────────────────────────
        if (nombre == null || nombre.trim().isEmpty()
                || correo == null || correo.trim().isEmpty()
                || username == null || username.trim().isEmpty()
                || password == null || password.trim().isEmpty()
                || rolStr == null || rolStr.trim().isEmpty()) {

            request.setAttribute("error", "Todos los campos marcados con * son obligatorios.");
            listarUsuarios(request, response);
            return;
        }

        // ── 3. Convertir el rol a entero ──────────────────────────
        int idRol;
        try {
            idRol = Integer.parseInt(rolStr);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "El rol seleccionado no es válido.");
            listarUsuarios(request, response);
            return;
        }

        UsuarioDAO dao = new UsuarioDAO();

        // ── 4. Verificar que correo y username no estén duplicados ─
        if (dao.existeCorreo(correo.trim(), 0)) {
            request.setAttribute("error", "El correo '" + correo.trim() + "' ya está registrado.");
            listarUsuarios(request, response);
            return;
        }

        if (dao.existeUsername(username.trim(), 0)) {
            request.setAttribute("error", "El username '" + username.trim() + "' ya está en uso.");
            listarUsuarios(request, response);
            return;
        }

        // ── 5. Construir el objeto Usuario ────────────────────────
        Usuario u = new Usuario();
        u.setNombreCompleto(nombre.trim());
        u.setCorreo(correo.trim().toLowerCase());
        u.setUsername(username.trim().toLowerCase());
        u.setPassword(password); // En producción se debería hashear
        u.setRolId(idRol);
        u.setEstado(estado != null ? estado : "ACTIVO");

        // ── 6. Guardar en la base de datos ────────────────────────
        boolean guardado = dao.registrarUsuario(u);

        if (guardado) {
            // ── AUDITORÍA — Usuario registrado ────────────────────
            
            Auditoria.registrar(
                idAdmin,
                "REGISTRAR_USUARIO",
                "Admin '" + usernameAdmin + "' registró al usuario: '" +
                    username.trim() + "' | Correo: " + correo.trim() +
                    " | Rol ID: " + idRol
            );

            response.sendRedirect("usuarios?accion=listar&exito=1");
        } else {
            request.setAttribute("error", "No se pudo registrar el usuario. Intenta de nuevo.");
            listarUsuarios(request, response);
        }
    }

    /**
     * Actualiza los datos de un usuario existente (edición).
     * Valida duplicados de correo y username excluyendo al usuario actual.
     *
     * AUDITORÍA: registra log con los campos actualizados.
     */
    private void actualizarUsuario(HttpServletRequest request, HttpServletResponse response,
                                    HttpSession sesion) throws ServletException, IOException {

        // ── 1. Capturar datos del formulario de edición ───────────
        String idStr     = request.getParameter("idUsuario");
        String nombre    = request.getParameter("nombreCompleto");
        String correo    = request.getParameter("correo");
        String username  = request.getParameter("username");
        String rolStr    = request.getParameter("idRol");
        int    idAdmin   = (int)    sesion.getAttribute("idUsuario");
        String usernameAdmin = (String) sesion.getAttribute("username");

        // ── 2. Validar campos obligatorios ────────────────────────
        if (idStr == null || nombre == null || nombre.trim().isEmpty()
                || correo == null || correo.trim().isEmpty()
                || username == null || username.trim().isEmpty()
                || rolStr == null || rolStr.trim().isEmpty()) {

            request.setAttribute("error", "Todos los campos son obligatorios.");
            listarUsuarios(request, response);
            return;
        }

        // ── 3. Convertir IDs a enteros ────────────────────────────
        int idUsuario, idRol;
        try {
            idUsuario = Integer.parseInt(idStr);
            idRol     = Integer.parseInt(rolStr);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Datos inválidos.");
            listarUsuarios(request, response);
            return;
        }

        UsuarioDAO dao = new UsuarioDAO();

        // ── 4. Verificar duplicados excluyendo al usuario actual ───
        if (dao.existeCorreo(correo.trim(), idUsuario)) {
            request.setAttribute("error", "El correo '" + correo.trim() + "' ya está en uso por otro usuario.");
            cargarFormularioEdicion(request, response);
            return;
        }

        if (dao.existeUsername(username.trim(), idUsuario)) {
            request.setAttribute("error", "El username '" + username.trim() + "' ya está en uso por otro usuario.");
            cargarFormularioEdicion(request, response);
            return;
        }

        // ── 5. Construir el objeto con los nuevos datos ───────────
        Usuario u = new Usuario();
        u.setIdUsuario(idUsuario);
        u.setNombreCompleto(nombre.trim());
        u.setCorreo(correo.trim().toLowerCase());
        u.setUsername(username.trim().toLowerCase());
        u.setRolId(idRol);

        // ── 6. Ejecutar la actualización ──────────────────────────
        boolean actualizado = dao.editarUsuario(u);

        if (actualizado) {
            // ── AUDITORÍA — Usuario editado ───────────────────────
            
            Auditoria.registrar(
                idAdmin,
                "EDITAR_USUARIO",
                "Admin '" + usernameAdmin + "' editó al usuario ID: " + idUsuario +
                    " | Nuevo username: '" + username.trim() + "'" +
                    " | Nuevo correo: " + correo.trim() +
                    " | Nuevo rol ID: " + idRol
            );

            response.sendRedirect("usuarios?accion=listar&exito=2");
        } else {
            request.setAttribute("error", "No se pudo actualizar el usuario. Intenta de nuevo.");
            listarUsuarios(request, response);
        }
    }
}