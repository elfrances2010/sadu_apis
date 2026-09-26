<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page import="javax.servlet.http.HttpSession" %>

<%
    /*
        Validar si existe una sesión activa.
        Si no existe sesión, se redirige al login.
    */
    HttpSession sesion = request.getSession(false);

    if (sesion == null || sesion.getAttribute("nombreUsuario") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Obtener datos guardados en sesión por LoginServlet
    String nombreUsuario = (String) sesion.getAttribute("nombreUsuario");
    String correoUsuario = (String) sesion.getAttribute("correoUsuario");
    String rolUsuario    = String.valueOf(sesion.getAttribute("rolUsuario"));
    int    idUsuario     = (int) sesion.getAttribute("idUsuario");

    Object dependenciaObj = sesion.getAttribute("dependenciaUsuario");
    String dependenciaUsuario = (dependenciaObj != null) ? dependenciaObj.toString() : "No asignada";
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - SADU</title>

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    

    <style>
/* =============================================
           LAYOUT GENERAL
        ============================================= */
        body {
            margin: 0;
            background-color: #f4f6f9;
            font-family: Arial, sans-serif;
        }

        /* =============================================
           CONTENIDO PRINCIPAL
        ============================================= */
        .content {
            margin-left: 230px;
            padding: 25px 30px;
            min-height: 100vh;
        }

        /* Barra superior con nombre y rol */
        .topbar {
            background-color: white;
            padding: 14px 20px;
            border-radius: 10px;
            margin-bottom: 22px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.08);
        }

        /* Caja de bienvenida */
        .welcome-box {
            background: linear-gradient(135deg, #1f3b57, #2f5579);
            color: white;
            border-radius: 14px;
            padding: 25px;
            margin-bottom: 22px;
        }

        /* Tarjetas del dashboard */
        .card-panel {
            border: none;
            border-radius: 12px;
            box-shadow: 0 3px 8px rgba(0,0,0,0.08);
        }
    </style>
</head>
<body>

    <!-- =============================================
         SIDEBAR — menú lateral izquierdo
    ============================================= -->

    <!-- =============================================
         CONTENIDO PRINCIPAL
    ============================================= -->
    <%@ include file="sidebar.jsp" %>

<div class="content">

        <!-- Barra superior -->
        <div class="topbar d-flex justify-content-between align-items-center">
            <div>
                <h4 class="mb-0">Panel principal</h4>
                <small class="text-muted">Sistema de Administración Documental Unificado</small>
            </div>
            <div class="text-end">
                <strong><%= nombreUsuario %></strong><br>
                <small>Rol: <%= rolUsuario %> — Dependencia: <%= dependenciaUsuario %></small>
            </div>
        </div>

        <!-- Bienvenida -->
        <div class="welcome-box">
            <h3>Bienvenido, <%= nombreUsuario %> 👋</h3>
            <p class="mb-1">Has iniciado sesión correctamente en el sistema SADU.</p>
            <p class="mb-0">Correo: <%= correoUsuario %></p>
        </div>

        <!-- Tarjetas de acceso rápido -->
        <div class="row g-4">
            <div class="col-md-4">
                <div class="card card-panel p-4">
                    <h5>👥 Usuarios registrados</h5>
                    <p class="text-muted">Consulta, administra y controla los usuarios del sistema.</p>
                    <a href="listarUsuarios" class="btn btn-primary">Ver usuarios</a>
                </div>
            </div>

            <div class="col-md-4">
                <div class="card card-panel p-4">
                    <h5>➕ Registrar usuario</h5>
                    <p class="text-muted">Crea nuevos accesos según el rol correspondiente.</p>
                    <a href="registrar_usuario.jsp" class="btn btn-success">Registrar</a>
                </div>
            </div>

            <div class="col-md-4">
                <div class="card card-panel p-4">
                    <h5>✅ Estado de sesión</h5>
                    <p class="text-muted">Tu sesión está activa y lista para seguir trabajando.</p>
                    <a href="logout.jsp" class="btn btn-danger">Cerrar sesión</a>
                </div>
            </div>
        </div>

        <!-- Información del sistema -->
        <div class="card card-panel mt-4 p-4">
            <h4>Información del sistema</h4>
            <p>
                Este panel corresponde al proyecto SADU y sirve como punto de acceso
                a los módulos administrativos del sistema.
            </p>
        </div>
    </div>

    

    <script>
        // Datos del usuario en sesión (pasados desde JSP a JS)
        const USUARIO_NOMBRE = "<%= nombreUsuario %>";
        const USUARIO_ID     = <%= idUsuario %>;

        // Estado del chat: abierto o cerrado
        let chatAbierto = false;

        // Intervalo para refrescar mensajes automáticamente cada 8 segundos
        let intervaloChat = null;

        /**
         * Abre o cierra la ventana del chat flotante.
         * Si se abre, carga los mensajes y activa el refresco automático.
         * Si se cierra, detiene el refresco automático.
         */
        function toggleChat() {
            const ventana = document.getElementById("chat-ventana");
            chatAbierto = !chatAbierto;

            if (chatAbierto) {
                // Mostrar ventana como flex para que el layout interno funcione
                ventana.style.display = "flex";
                cargarMensajes();

                // Refrescar mensajes cada 8 segundos mientras el chat esté abierto
                intervaloChat = setInterval(cargarMensajes, 8000);
            } else {
                ventana.style.display = "none";
                // Detener el refresco al cerrar para no hacer peticiones innecesarias
                clearInterval(intervaloChat);
            }
        }

        /**
         * Consulta los mensajes del chat llamando a ListarMensajesServlet.
         * El servlet devuelve el HTML del JSP, pero aquí usamos un endpoint
         * que devuelve JSON. Como aún no tenemos ese endpoint, llamamos al
         * servlet y extraemos los datos del atributo de sesión.
         *
         * SOLUCIÓN SIMPLE: usamos fetch al servlet de listado y mostramos
         * los mensajes parseando la respuesta en formato JSON simple.
         */
        function cargarMensajes() {
            fetch("ChatJsonServlet")
                .then(function(res) {
                    if (!res.ok) throw new Error("Error HTTP: " + res.status);
                    return res.json();
                })
                .then(function(mensajes) {
                    mostrarMensajes(mensajes);
                })
                .catch(function(err) {
                    document.getElementById("chat-mensajes").innerHTML =
                        '<div class="cargando">⚠️ No se pudieron cargar los mensajes.</div>';
                });
        }

        /**
         * Renderiza la lista de mensajes en la ventana del chat.
         * Los mensajes del usuario actual aparecen a la derecha (burbuja azul).
         * Los mensajes de otros aparecen a la izquierda (burbuja gris).
         *
         * @param {Array} mensajes Lista de objetos {idUsuario, nombreUsuario, asunto, mensaje, fechaEnvio}
         */
        function mostrarMensajes(mensajes) {
            const area = document.getElementById("chat-mensajes");

            if (!mensajes || mensajes.length === 0) {
                area.innerHTML = '<div class="cargando">📭 No hay mensajes aún.</div>';
                return;
            }

            let html = "";

            mensajes.forEach(function(m) {
                // Determinar si el mensaje es del usuario actual o de otro
                const esPropio = m.idUsuario === USUARIO_ID;
                const clase    = esPropio ? "propio" : "otro";

                // Formatear la fecha para mostrar solo hora:minuto
                let hora = "";
                if (m.fechaEnvio) {
                    const fecha = new Date(m.fechaEnvio);
                    hora = fecha.toLocaleTimeString("es-CO", {hour: "2-digit", minute: "2-digit"});
                }

                html += '<div class="burbuja ' + clase + '">';

                // Solo mostrar remitente en mensajes de otros
                if (!esPropio) {
                    html += '<div class="remitente">👤 ' + m.nombreUsuario + '</div>';
                }

                html += '<strong style="font-size:12px;">' + m.asunto + '</strong><br>';
                html += m.mensaje;
                html += '<div class="hora">' + hora + '</div>';
                html += '</div>';
            });

            area.innerHTML = html;

            // Scroll automático al último mensaje
            area.scrollTop = area.scrollHeight;
        }

        /**
         * Envía un nuevo mensaje al servidor usando EnviarMensajeServlet.
         * Usa fetch con método POST para no recargar la página.
         * Al enviar exitosamente, limpia los campos y recarga los mensajes.
         */
        function enviarMensaje() {
            const asunto  = document.getElementById("chat-asunto").value.trim();
            const mensaje = document.getElementById("chat-mensaje").value.trim();

            // Validar que ambos campos tengan contenido
            if (!asunto || !mensaje) {
                alert("Por favor completa el asunto y el mensaje.");
                return;
            }

            // Construir los datos del formulario como URLSearchParams
            const datos = new URLSearchParams();
            datos.append("asunto",  asunto);
            datos.append("mensaje", mensaje);

            fetch("EnviarMensajeServlet", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: datos.toString()
            })
            .then(function() {
                // Limpiar los campos del formulario
                document.getElementById("chat-asunto").value  = "";
                document.getElementById("chat-mensaje").value = "";

                // Recargar mensajes para ver el nuevo mensaje de inmediato
                cargarMensajes();
            })
            .catch(function(err) {
                alert("Error al enviar el mensaje. Intenta de nuevo.");
            });
        }

        /**
         * Permitir enviar el mensaje con la tecla Enter en el campo de mensaje.
         */
        document.getElementById("chat-mensaje").addEventListener("keydown", function(e) {
            if (e.key === "Enter") {
                enviarMensaje();
            }
        });
    </script>

</body>
</html>
