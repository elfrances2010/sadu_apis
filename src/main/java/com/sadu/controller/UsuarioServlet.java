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

@WebServlet(name = "UsuarioServlet", urlPatterns = {"/usuarios"})
public class UsuarioServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession sesion = request.getSession(false);
        if (sesion == null || sesion.getAttribute("nombreUsuario") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        Integer rolUsuario = (Integer) sesion.getAttribute("rolUsuario");
        if (rolUsuario == null || rolUsuario != 1) {
            response.sendRedirect("dashboard.jsp?accesoDenegado=1");
            return;
        }

        String accion = request.getParameter("accion");
        if (accion == null) accion = "listar";

        switch (accion) {
            case "buscar":
                buscarUsuarios(request, response);
                break;
            case "editar":
                cargarFormularioEdicion(request, response);
                break;
            case "cambiarEstado":
                cambiarEstado(request, response, sesion);
                break;
            case "cambiarRol":
                cambiarRol(request, response, sesion);
                break;
            case "forzarCambioClave":
                forzarCambioClave(request, response, sesion);
                break;
            case "listar":
            default:
                listarUsuarios(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession sesion = request.getSession(false);
        if (sesion == null || sesion.getAttribute("nombreUsuario") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        Integer rolUsuario = (Integer) sesion.getAttribute("rolUsuario");
        if (rolUsuario == null || rolUsuario != 1) {
            response.sendRedirect("dashboard.jsp?accesoDenegado=1");
            return;
        }

        String accion = request.getParameter("accion");

        if ("registrar".equals(accion)) {
            registrarUsuario(request, response, sesion);
        } else if ("actualizar".equals(accion)) {
            actualizarUsuario(request, response, sesion);
        } else if ("cambiarEstado".equals(accion)) {
            cambiarEstado(request, response, sesion);
        } else if ("cambiarRol".equals(accion)) {
            cambiarRol(request, response, sesion);
        } else if ("forzarCambioClave".equals(accion)) {
            forzarCambioClave(request, response, sesion);
        } else {
            response.sendRedirect("usuarios?accion=listar");
        }
    }

    private void listarUsuarios(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        UsuarioDAO dao = new UsuarioDAO();

        List<Usuario> lista = dao.listarUsuarios();
        request.setAttribute("listaUsuarios", lista);
        request.setAttribute("busquedaActiva", false);
        request.setAttribute("modoEdicion", false);

        request.getRequestDispatcher("usuarios.jsp").forward(request, response);
    }

    private void buscarUsuarios(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String nombre    = request.getParameter("busNombre");
        String idRolStr  = request.getParameter("busRol");
        String estado    = request.getParameter("busEstado");

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

        request.setAttribute("busNombre", nombre  != null ? nombre  : "");
        request.setAttribute("busRol",    idRolStr != null ? idRolStr : "");
        request.setAttribute("busEstado", estado   != null ? estado   : "");

        request.getRequestDispatcher("usuarios.jsp").forward(request, response);
    }

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
            Usuario u = dao.obtenerPorId(id);

            if (u != null) {
                request.setAttribute("usuarioEdicion", u);
                request.setAttribute("modoEdicion", true);

                List<Usuario> lista = dao.listarUsuarios();
                request.setAttribute("listaUsuarios", lista);
                request.setAttribute("busquedaActiva", false);

                request.getRequestDispatcher("usuarios.jsp").forward(request, response);
            } else {
                response.sendRedirect("usuarios?accion=listar");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect("usuarios?accion=listar");
        }
    }

    private void cambiarEstado(HttpServletRequest request, HttpServletResponse response, HttpSession sesion)
            throws ServletException, IOException {

        String idStr       = request.getParameter("id");
        if (idStr == null) idStr = request.getParameter("idUsuario");
        String nuevoEstado = request.getParameter("estado");
        String origen      = request.getParameter("origen");

        int idAdmin   = (int) sesion.getAttribute("idUsuario");
        String usernameAdmin = (String) sesion.getAttribute("username");

        if (idStr != null && nuevoEstado != null) {
            try {
                int idUsuario = Integer.parseInt(idStr);
                UsuarioDAO dao = new UsuarioDAO();

                boolean ok = dao.cambiarEstado(idUsuario, nuevoEstado);

                if (ok) {
                    Auditoria.registrar(
                        idAdmin,
                        "CAMBIAR_ESTADO_USUARIO",
                        "Admin '" + usernameAdmin + "' cambio el estado del usuario ID: " +
                            idUsuario + " a '" + nuevoEstado + "'"
                    );
                }

            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }

        if ("consultas".equals(origen)) {
            response.sendRedirect("consultas?tipo=usuarios&exito=1");
        } else {
            response.sendRedirect("usuarios?accion=listar&exito=1");
        }
    }

    private void cambiarRol(HttpServletRequest request, HttpServletResponse response, HttpSession sesion)
            throws ServletException, IOException {

        String idStr    = request.getParameter("id");
        if (idStr == null) idStr = request.getParameter("idUsuario");
        String rolStr   = request.getParameter("rol");
        if (rolStr == null) rolStr = request.getParameter("idRol");
        String origen   = request.getParameter("origen");

        int idAdmin   = (int) sesion.getAttribute("idUsuario");
        String usernameAdmin = (String) sesion.getAttribute("username");

        if (idStr != null && rolStr != null) {
            try {
                int idUsuario = Integer.parseInt(idStr);
                int nuevoRol  = Integer.parseInt(rolStr);

                UsuarioDAO dao = new UsuarioDAO();
                boolean ok = dao.cambiarRol(idUsuario, nuevoRol);

                if (ok) {
                    Auditoria.registrar(
                        idAdmin,
                        "CAMBIAR_ROL_USUARIO",
                        "Admin '" + usernameAdmin + "' cambio el rol del usuario ID: " +
                            idUsuario + " al nuevo rol ID: " + nuevoRol
                    );
                }

            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }

        if ("consultas".equals(origen)) {
            response.sendRedirect("consultas?tipo=usuarios&exito=2");
        } else {
            response.sendRedirect("usuarios?accion=listar&exito=2");
        }
    }

    private void forzarCambioClave(HttpServletRequest request, HttpServletResponse response, HttpSession sesion)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr == null) idStr = request.getParameter("idUsuario");
        String origen = request.getParameter("origen");

        int idAdmin   = (int) sesion.getAttribute("idUsuario");
        String usernameAdmin = (String) sesion.getAttribute("username");

        if (idStr != null && !idStr.trim().isEmpty()) {
            try {
                int idUsuario = Integer.parseInt(idStr);
                UsuarioDAO dao = new UsuarioDAO();
                boolean ok = dao.forzarCambioClave(idUsuario, true);

                if (ok) {
                    Auditoria.registrar(
                        idAdmin,
                        "FORZAR_CAMBIO_CLAVE",
                        "Admin '" + usernameAdmin + "' exigio cambio de clave al usuario ID: " + idUsuario
                    );
                }

            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }

        if ("consultas".equals(origen)) {
            response.sendRedirect("consultas?tipo=usuarios&exito=3");
        } else {
            response.sendRedirect("usuarios?accion=listar&exito=3");
        }
    }

    private void registrarUsuario(HttpServletRequest request, HttpServletResponse response,
                                   HttpSession sesion) throws ServletException, IOException {

        String nombre    = request.getParameter("nombreCompleto");
        String correo    = request.getParameter("correo");
        String username  = request.getParameter("username");
        String password  = request.getParameter("password");
        String rolStr    = request.getParameter("idRol");
        String estado    = request.getParameter("estado");
        int    idAdmin   = (int)    sesion.getAttribute("idUsuario");
        String usernameAdmin = (String) sesion.getAttribute("username");

        if (nombre == null || nombre.trim().isEmpty()
                || correo == null || correo.trim().isEmpty()
                || username == null || username.trim().isEmpty()
                || password == null || password.trim().isEmpty()
                || rolStr == null || rolStr.trim().isEmpty()) {

            request.setAttribute("error", "Todos los campos marcados con * son obligatorios.");
            listarUsuarios(request, response);
            return;
        }

        int idRol;
        try {
            idRol = Integer.parseInt(rolStr);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "El rol seleccionado no es v?lido.");
            listarUsuarios(request, response);
            return;
        }

        UsuarioDAO dao = new UsuarioDAO();

        if (dao.existeCorreo(correo.trim(), 0)) {
            request.setAttribute("error", "El correo '" + correo.trim() + "' ya est? registrado.");
            listarUsuarios(request, response);
            return;
        }

        if (dao.existeUsername(username.trim(), 0)) {
            request.setAttribute("error", "El username '" + username.trim() + "' ya est? en uso.");
            listarUsuarios(request, response);
            return;
        }

        Usuario u = new Usuario();
        u.setNombreCompleto(nombre.trim());
        u.setCorreo(correo.trim().toLowerCase());
        u.setUsername(username.trim().toLowerCase());
        u.setPassword(password);
        u.setRolId(idRol);
        u.setEstado(estado != null ? estado : "ACTIVO");

        boolean guardado = dao.registrarUsuario(u);

        if (guardado) {
            Auditoria.registrar(
                idAdmin,
                "REGISTRAR_USUARIO",
                "Admin '" + usernameAdmin + "' registro al usuario: '" +
                    username.trim() + "' | Correo: " + correo.trim() +
                    " | Rol ID: " + idRol
            );

            response.sendRedirect("usuarios?accion=listar&exito=1");
        } else {
            request.setAttribute("error", "No se pudo registrar el usuario. Intenta de nuevo.");
            listarUsuarios(request, response);
        }
    }

    private void actualizarUsuario(HttpServletRequest request, HttpServletResponse response,
                                    HttpSession sesion) throws ServletException, IOException {

        String idStr     = request.getParameter("idUsuario");
        String nombre    = request.getParameter("nombreCompleto");
        String correo    = request.getParameter("correo");
        String username  = request.getParameter("username");
        String rolStr    = request.getParameter("idRol");
        int    idAdmin   = (int)    sesion.getAttribute("idUsuario");
        String usernameAdmin = (String) sesion.getAttribute("username");

        if (idStr == null || nombre == null || nombre.trim().isEmpty()
                || correo == null || correo.trim().isEmpty()
                || username == null || username.trim().isEmpty()
                || rolStr == null || rolStr.trim().isEmpty()) {

            request.setAttribute("error", "Todos los campos son obligatorios.");
            listarUsuarios(request, response);
            return;
        }

        int idUsuario, idRol;
        try {
            idUsuario = Integer.parseInt(idStr);
            idRol     = Integer.parseInt(rolStr);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Datos inv?lidos.");
            listarUsuarios(request, response);
            return;
        }

        UsuarioDAO dao = new UsuarioDAO();

        if (dao.existeCorreo(correo.trim(), idUsuario)) {
            request.setAttribute("error", "El correo '" + correo.trim() + "' ya esta en uso por otro usuario.");
            cargarFormularioEdicion(request, response);
            return;
        }

        if (dao.existeUsername(username.trim(), idUsuario)) {
            request.setAttribute("error", "El username '" + username.trim() + "' ya esta en uso por otro usuario.");
            cargarFormularioEdicion(request, response);
            return;
        }

        Usuario u = new Usuario();
        u.setIdUsuario(idUsuario);
        u.setNombreCompleto(nombre.trim());
        u.setCorreo(correo.trim().toLowerCase());
        u.setUsername(username.trim().toLowerCase());
        u.setRolId(idRol);

        boolean actualizado = dao.editarUsuario(u);

        if (actualizado) {
            Auditoria.registrar(
                idAdmin,
                "EDITAR_USUARIO",
                "Admin '" + usernameAdmin + "' edit? al usuario ID: " + idUsuario +
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
