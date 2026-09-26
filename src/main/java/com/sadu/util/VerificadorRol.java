package com.sadu.util;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Clase utilitaria para verificar el control de acceso por rol en el sistema SADU.
 *
 * ═══════════════════════════════════════════════════════════════
 * ROLES DEL SISTEMA:
 * ═══════════════════════════════════════════════════════════════
 *   Rol 1 → Administrador      → Acceso total a todas las páginas
 *   Rol 2 → Gestor de Archivo  → Documentos, comunicaciones, chat, consultas
 *   Rol 3 → Dependencia Municipal → Solo consultas, API Colombia y chat
 *
 * ═══════════════════════════════════════════════════════════════
 * CÓMO USARLO DESDE UN SERVLET:
 * ═══════════════════════════════════════════════════════════════
 *
 *   import com.sadu.util.VerificadorRol;
 *
 *   // Al inicio del doGet o doPost, antes de cualquier lógica:
 *   if (!VerificadorRol.verificar(request, response, 1, 2)) return;
 *   // El número indica los roles permitidos. 1,2 = Admin y Gestor.
 *   // Si el usuario no tiene ese rol, es redirigido automáticamente.
 *
 * ═══════════════════════════════════════════════════════════════
 * TABLA DE PERMISOS POR MÓDULO:
 * ═══════════════════════════════════════════════════════════════
 *   Módulo                  Roles permitidos
 *   ─────────────────────── ─────────────────
 *   Dashboard               1, 2, 3  (todos)
 *   Quiénes somos           1, 2, 3  (todos)
 *   Documentos              1, 2
 *   Comunicaciones          1, 2
 *   Chat interno            1, 2, 3  (todos)
 *   API Colombia            1, 2, 3  (todos)
 *   Listar usuarios         1
 *   Registrar usuario       1
 *   Auditoría               1        (solo admin)
 *   Reportes                1, 2
 *   Consultas               1, 2, 3  (todos)
 * ═══════════════════════════════════════════════════════════════
 */
public class VerificadorRol {

    /**
     * Verifica si el usuario autenticado tiene uno de los roles permitidos.
     *
     * Si la sesión no existe → redirige a login.jsp
     * Si el usuario no tiene el rol requerido → redirige a acceso_denegado.jsp
     * Si el usuario tiene el rol → retorna true y el flujo continúa
     *
     * @param request       HttpServletRequest de la petición actual
     * @param response      HttpServletResponse de la petición actual
     * @param rolesPermitidos Lista de IDs de roles que pueden acceder
     *                        Ejemplo: verificar(req, res, 1) solo admin
     *                        Ejemplo: verificar(req, res, 1, 2) admin y gestor
     *                        Ejemplo: verificar(req, res, 1, 2, 3) todos
     * @return true si el usuario tiene acceso, false si fue redirigido
     */
    public static boolean verificar(
            HttpServletRequest request,
            HttpServletResponse response,
            int... rolesPermitidos) throws IOException {

        // -------------------------------------------------------
        // 1. Verificar que exista una sesión activa
        // -------------------------------------------------------
        HttpSession sesion = request.getSession(false);

        if (sesion == null || sesion.getAttribute("nombreUsuario") == null) {
            // No hay sesión — redirigir al login
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return false;
        }

        // -------------------------------------------------------
        // 2. Obtener el rol del usuario desde la sesión
        // -------------------------------------------------------
        int rolUsuario = (int) sesion.getAttribute("rolUsuario");

        // -------------------------------------------------------
        // 3. Verificar si el rol del usuario está en la lista de permitidos
        // -------------------------------------------------------
        for (int rolPermitido : rolesPermitidos) {
            if (rolUsuario == rolPermitido) {
                // Rol permitido — el flujo puede continuar
                return true;
            }
        }

        // -------------------------------------------------------
        // 4. Rol no permitido — guardar mensaje y redirigir
        // -------------------------------------------------------
        sesion.setAttribute("mensajeAccesoDenegado",
                "No tienes permisos para acceder a esta sección. " +
                "Contacta al Administrador si crees que es un error.");

        response.sendRedirect(request.getContextPath() + "/acceso_denegado.jsp");
        return false;
    }

    /**
     * Versión simplificada que solo verifica si hay sesión activa,
     * sin importar el rol. Útil para páginas accesibles a todos los roles.
     *
     * @param request  HttpServletRequest de la petición actual
     * @param response HttpServletResponse de la petición actual
     * @return true si hay sesión activa, false si fue redirigido al login
     */
    public static boolean verificarSesion(
            HttpServletRequest request,
            HttpServletResponse response) throws IOException {

        HttpSession sesion = request.getSession(false);

        if (sesion == null || sesion.getAttribute("nombreUsuario") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return false;
        }

        return true;
    }

    /**
     * Obtiene el rol del usuario actual desde la sesión.
     * Retorna -1 si no hay sesión activa.
     *
     * Útil para mostrar u ocultar secciones del menú en los JSP
     * según el rol sin necesidad de hacer verificación completa.
     *
     * @param request HttpServletRequest de la petición actual
     * @return ID del rol del usuario, o -1 si no hay sesión
     */
    public static int obtenerRol(HttpServletRequest request) {
        HttpSession sesion = request.getSession(false);
        if (sesion == null || sesion.getAttribute("rolUsuario") == null) {
            return -1;
        }
        return (int) sesion.getAttribute("rolUsuario");
    }
}