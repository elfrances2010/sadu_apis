<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    /*
        Este archivo cierra la sesión del usuario.
        session.invalidate() elimina toda la información guardada
        en la sesión actual.
    */
    session.invalidate();

    /*
        Después de cerrar sesión, redirigimos otra vez
        al formulario de inicio de sesión.
    */
    response.sendRedirect("login.jsp");
%>
