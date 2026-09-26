<%
    /*
     * ????????????????????????????????????????????????????????????
     * sidebar.jsp ? Sidebar ÚNICO y unificado del sistema SADU
     * ????????????????????????????????????????????????????????????
     * Se incluye en TODAS las páginas con:
     *   include file sidebar.jsp
     *
     * NO debe tener directiva page -- eso causa StackOverflowError.
     * ????????????????????????????????????????????????????????????
     */
    String paginaActual = request.getRequestURI();
    if (paginaActual == null) paginaActual = "";

    HttpSession sesionSidebar = request.getSession(false);
    Integer rolSidebar    = 0;
    String  userSidebar   = "";
    int     idUserSidebar = 0;

    if (sesionSidebar != null) {
        if (sesionSidebar.getAttribute("rolUsuario")    != null)
            rolSidebar    = (Integer) sesionSidebar.getAttribute("rolUsuario");
        if (sesionSidebar.getAttribute("nombreUsuario") != null)
            userSidebar   = (String)  sesionSidebar.getAttribute("nombreUsuario");
        if (sesionSidebar.getAttribute("idUsuario")     != null)
            idUserSidebar = (Integer) sesionSidebar.getAttribute("idUsuario");
    }
%>
<style>
/* ???????????????????????????????????????
   SIDEBAR
??????????????????????????????????????? */
.sidebar {
    width: 230px; height: 100vh;
    background-color: #1f3b57; color: white;
    position: fixed; top: 0; left: 0;
    overflow-y: auto; overflow-x: hidden;
    display: flex; flex-direction: column;
    z-index: 100;
}
.sidebar::-webkit-scrollbar       { width: 4px; }
.sidebar::-webkit-scrollbar-thumb { background-color: #2f5579; border-radius: 4px; }

.sidebar-logo {
    text-align: center; padding: 22px 10px 14px;
    font-size: 22px; font-weight: bold; letter-spacing: 2px;
    border-bottom: 1px solid #2f5579; margin-bottom: 8px;
    color: white; text-decoration: none; display: block;
}
.menu-title {
    font-size: 11px; text-transform: uppercase;
    color: #b8c7d6; padding: 12px 20px 4px; letter-spacing: 1px;
    display: block;
}
.sidebar a {
    display: block; color: white; text-decoration: none;
    padding: 11px 20px; font-size: 14px;
    transition: background 0.2s; border-left: 3px solid transparent;
}
.sidebar a:hover       { background-color: #2f5579; border-left-color: #5b9bd5; color: white; }
.sidebar a.activo      { background-color: #2f5579; border-left-color: #5b9bd5; font-weight: bold; }
.sidebar-divider       { border: none; border-top: 1px solid #2f5579; margin: 6px 20px; }
.sidebar a.link-logout { color: #e07575; }
.sidebar a.link-logout:hover { background-color: #3a1a1a; border-left-color: #e07575; color: #ff9999; }

/* Contenido principal ? compensar ancho del sidebar */
.content { margin-left: 230px; padding: 25px 30px; min-height: 100vh; }

/* ???????????????????????????????????????
   CHAT FLOTANTE
??????????????????????????????????????? */
#chat-fab {
    position: fixed; bottom: 28px; right: 28px;
    width: 54px; height: 54px; border-radius: 50%;
    background: #1f3b57; color: white;
    border: none; font-size: 24px;
    box-shadow: 0 4px 16px rgba(0,0,0,0.25);
    cursor: pointer; z-index: 999;
    transition: background 0.2s, transform 0.15s;
    display: flex; align-items: center; justify-content: center;
}
#chat-fab:hover { background: #2f5579; transform: scale(1.08); }

#chat-badge {
    position: absolute; top: -4px; right: -4px;
    background: #e53e3e; color: white;
    border-radius: 50%; width: 20px; height: 20px;
    font-size: 11px; font-weight: bold;
    display: none; align-items: center; justify-content: center;
    border: 2px solid white;
}

#chat-panel {
    position: fixed; bottom: 92px; right: 28px;
    width: 360px; height: 480px;
    background: white; border-radius: 16px;
    box-shadow: 0 8px 32px rgba(0,0,0,0.18);
    display: none; flex-direction: column;
    z-index: 998; overflow: hidden;
    font-family: Arial, sans-serif;
}
#chat-panel.abierto { display: flex; }

#chat-header {
    background: linear-gradient(135deg, #1f3b57, #2f5579);
    color: white; padding: 14px 18px;
    display: flex; justify-content: space-between; align-items: center;
    flex-shrink: 0;
}
#chat-header span  { font-weight: bold; font-size: 15px; }
#chat-header small { font-size: 12px; opacity: 0.8; display: block; }
#btn-cerrar-chat {
    background: none; border: none; color: white;
    font-size: 20px; cursor: pointer; line-height: 1; opacity: 0.8;
}
#btn-cerrar-chat:hover { opacity: 1; }

#chat-mensajes {
    flex: 1; overflow-y: auto; padding: 14px 16px;
    display: flex; flex-direction: column; gap: 10px;
    background: #f8fafc;
}
#chat-mensajes::-webkit-scrollbar       { width: 4px; }
#chat-mensajes::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 4px; }

.chat-burbuja {
    max-width: 85%; padding: 9px 13px;
    border-radius: 12px; font-size: 13px; line-height: 1.45;
    word-break: break-word;
}
.chat-burbuja.propio {
    align-self: flex-end;
    background: #1f3b57; color: white;
    border-bottom-right-radius: 4px;
}
.chat-burbuja.ajeno {
    align-self: flex-start;
    background: white; color: #1f2937;
    border: 1px solid #e2e8f0;
    border-bottom-left-radius: 4px;
    box-shadow: 0 1px 4px rgba(0,0,0,0.06);
}
.chat-burbuja .burbuja-autor  { font-size: 11px; font-weight: bold; margin-bottom: 3px; opacity: 0.75; }
.chat-burbuja .burbuja-asunto { font-weight: bold; font-size: 12px; margin-bottom: 2px; }
.chat-burbuja .burbuja-hora   { font-size: 10px; opacity: 0.55; margin-top: 4px; text-align: right; }
.chat-sin-mensajes { text-align: center; color: #9ca3af; font-size: 13px; padding: 20px; margin: auto; }

#chat-form {
    padding: 12px 14px; border-top: 1px solid #e2e8f0;
    display: flex; flex-direction: column; gap: 7px;
    flex-shrink: 0; background: white;
}
#chat-asunto {
    border: 1px solid #cbd5e1; border-radius: 8px;
    padding: 8px 12px; font-size: 13px; outline: none;
}
#chat-asunto:focus { border-color: #1f3b57; }
#chat-fila-envio   { display: flex; gap: 8px; }
#chat-texto {
    flex: 1; border: 1px solid #cbd5e1; border-radius: 8px;
    padding: 8px 12px; font-size: 13px; outline: none;
    resize: none; height: 60px;
}
#chat-texto:focus { border-color: #1f3b57; }
#btn-enviar-chat {
    background: #1f3b57; color: white; border: none;
    border-radius: 8px; padding: 0 16px;
    cursor: pointer; font-size: 18px; flex-shrink: 0;
    transition: background 0.2s;
}
#btn-enviar-chat:hover    { background: #2f5579; }
#btn-enviar-chat:disabled { background: #94a3b8; cursor: not-allowed; }
#chat-error { font-size: 12px; color: #e53e3e; display: none; padding: 0 2px; }
</style>

<!-- ??????????????? SIDEBAR HTML ??????????????? -->
<div class="sidebar">
    <a href="dashboard.jsp" class="sidebar-logo">&#128451; SADU</a>

    <!-- PRINCIPAL -->
    <span class="menu-title">Principal</span>
    <a href="dashboard.jsp"
       class="<%= paginaActual.contains("dashboard") ? "activo" : "" %>">
        &#127968; Dashboard
    </a>
    <a href="quienes_somos.jsp"
       class="<%= paginaActual.contains("quienes") ? "activo" : "" %>">
        &#8505;&#65039; Qui&eacute;nes somos
    </a>

    <hr class="sidebar-divider">

    <!-- GESTIÓN DOCUMENTAL -->
    <span class="menu-title">Gesti&oacute;n documental</span>
    <a href="documentos?accion=listar"
       class="<%= paginaActual.contains("/documentos") && !paginaActual.contains("Registrado") && !paginaActual.contains("registrados") ? "activo" : "" %>">
        &#128196; Documentos
    </a>
    <a href="documentosRegistrados?accion=listar"
       class="<%= paginaActual.contains("Registrado") || paginaActual.contains("registrados") ? "activo" : "" %>">
        &#128203; Docs. registrados
    </a>
    <a href="comunicaciones?accion=listar"
       class="<%= paginaActual.contains("comunicaciones") ? "activo" : "" %>">
        &#128140; Comunicaciones
    </a>

    <hr class="sidebar-divider">

    <!-- CONSULTAS Y REPORTES -->
    <span class="menu-title">Consultas y reportes</span>
    <a href="reportes?accion=listar"
       class="<%= paginaActual.contains("reportes") ? "activo" : "" %>">
        &#128202; Reportes
    </a>
    <a href="consultas.jsp"
       class="<%= paginaActual.contains("consultas") ? "activo" : "" %>">
        &#128269; Consultas
    </a>
    <a href="ApiColombiaServlet"
       class="<%= paginaActual.contains("ApiColombia") || paginaActual.contains("consultaApi") ? "activo" : "" %>">
        &#127988; Departamentos
    </a>
    <a href="MunicipiosApiColombiaServlet"
   class="<%= paginaActual.contains("Municipios") || paginaActual.contains("consultaMunicipios") ? "activo" : "" %>">
    &#128205; Municipios
</a>

    <hr class="sidebar-divider">

    <!-- USUARIOS -->
    <span class="menu-title">Usuarios</span>
    <a href="listarUsuarios"
       class="<%= paginaActual.contains("usuario") || paginaActual.contains("Usuario") ? "activo" : "" %>">
        &#128100; Gesti&oacute;n de usuarios
    </a>

    <!-- MENSAJERÍA ? visible para todos los roles -->
    <hr class="sidebar-divider">
    <span class="menu-title">Mensajer&iacute;a</span>
    <a href="ListarMensajesServlet"
       class="<%= paginaActual.contains("chat") || paginaActual.contains("Mensajes") ? "activo" : "" %>">
        &#128172; Chat interno
    </a>

    <!-- ADMINISTRACIÓN ? solo Administrador (rol 1) -->
    <% if (rolSidebar != null && rolSidebar == 1) { %>
    <hr class="sidebar-divider">
    <span class="menu-title">Administraci&oacute;n</span>
    <a href="auditoria?accion=listar"
       class="<%= paginaActual.contains("auditoria") ? "activo" : "" %>">
        &#128221; Auditor&iacute;a
    </a>
    <% } %>

    <hr class="sidebar-divider">

    <!-- SESIÓN -->
    <span class="menu-title">Sesi&oacute;n</span>
    <a href="logout.jsp" class="link-logout">&#128682; Cerrar sesi&oacute;n</a>
</div>

<!-- ??????????????? CHAT FLOTANTE ??????????????? -->
<button id="chat-fab" title="Chat interno SADU" onclick="toggleChat()">
    <span id="chat-fab-icon">&#128172;</span>
    <span id="chat-badge"></span>
</button>

<div id="chat-panel">
    <div id="chat-header">
        <div>
            <span>&#128172; Chat interno</span>
            <small id="chat-subtitulo">Cargando mensajes...</small>
        </div>
        <button id="btn-cerrar-chat" onclick="toggleChat()" title="Cerrar">&#10005;</button>
    </div>

    <div id="chat-mensajes">
        <div class="chat-sin-mensajes">Cargando...</div>
    </div>

    <div id="chat-form">
        <input  id="chat-asunto" type="text" placeholder="Asunto del mensaje..." maxlength="120">
        <div id="chat-fila-envio">
            <textarea id="chat-texto" placeholder="Escribe tu mensaje..."></textarea>
            <button   id="btn-enviar-chat" onclick="enviarMensaje()" title="Enviar">&#10148;</button>
        </div>
        <span id="chat-error"></span>
    </div>
</div>

<script>
// ??? Estado del chat ???????????????????????????????????????????
const ID_USUARIO_ACTUAL = <%= idUserSidebar %>;
let chatAbierto     = false;
let ultimoIdMensaje = 0;
let intervaloChat   = null;

// ??? Abrir / cerrar panel ??????????????????????????????????????
function toggleChat() {
    chatAbierto = !chatAbierto;
    const panel = document.getElementById('chat-panel');
    const icon  = document.getElementById('chat-fab-icon');
    if (chatAbierto) {
        panel.classList.add('abierto');
        icon.innerHTML = '&#10005;';
        ocultarBadge();
        cargarMensajes();
        intervaloChat = setInterval(cargarMensajes, 8000);
    } else {
        panel.classList.remove('abierto');
        icon.innerHTML = '&#128172;';
        clearInterval(intervaloChat);
    }
}

// ??? Cargar mensajes via fetch ??????????????????????????????????
function cargarMensajes() {
    fetch('ChatJsonServlet')
        .then(function(r) { return r.json(); })
        .then(function(datos) {
            var area = document.getElementById('chat-mensajes');
            var sub  = document.getElementById('chat-subtitulo');

            if (!Array.isArray(datos) || datos.length === 0) {
                area.innerHTML = '<div class="chat-sin-mensajes">&#128172; A&uacute;n no hay mensajes.<br>&#161;S&eacute; el primero en escribir!</div>';
                sub.textContent = '0 mensajes';
                return;
            }

            // Detectar mensajes nuevos para el badge
            var maxId = Math.max.apply(null, datos.map(function(m) { return m.idMensaje; }));
            if (!chatAbierto && maxId > ultimoIdMensaje && ultimoIdMensaje > 0) {
                mostrarBadge(datos.filter(function(m) { return m.idMensaje > ultimoIdMensaje; }).length);
            }
            ultimoIdMensaje = maxId;

            sub.textContent = datos.length + ' mensaje' + (datos.length !== 1 ? 's' : '');

            var estabaAbajo = area.scrollHeight - area.scrollTop - area.clientHeight < 40;

            // Renderizar burbujas ? más recientes arriba (ya vienen DESC del servidor)
            var html = '';
            for (var j = datos.length - 1; j >= 0; j--) {
                var m      = datos[j];
                var propio = m.idUsuario === ID_USUARIO_ACTUAL;
                var clase  = propio ? 'propio' : 'ajeno';
                var hora   = m.fechaEnvio ? new Date(m.fechaEnvio).toLocaleTimeString('es-CO', {hour:'2-digit', minute:'2-digit'}) : '';
                var autor  = !propio ? '<div class="burbuja-autor">' + esc(m.nombreUsuario) + '</div>' : '';
                html += '<div class="chat-burbuja ' + clase + '">'
                      + autor
                      + '<div class="burbuja-asunto">' + esc(m.asunto)  + '</div>'
                      + '<div class="burbuja-texto">'  + esc(m.mensaje) + '</div>'
                      + '<div class="burbuja-hora">'   + hora           + '</div>'
                      + '</div>';
            }
            area.innerHTML = html;

            if (estabaAbajo) area.scrollTop = area.scrollHeight;
        })
        .catch(function() {
            document.getElementById('chat-subtitulo').textContent = 'Error al cargar';
        });
}

// ??? Enviar mensaje (POST /EnviarMensajeServlet) ????????????????
function enviarMensaje() {
    var asunto  = document.getElementById('chat-asunto').value.trim();
    var mensaje = document.getElementById('chat-texto').value.trim();
    var errorEl = document.getElementById('chat-error');
    var btnEnv  = document.getElementById('btn-enviar-chat');

    errorEl.style.display = 'none';

    if (!asunto)  { mostrarError('Escribe un asunto antes de enviar.'); return; }
    if (!mensaje) { mostrarError('El mensaje no puede estar vac&iacute;o.'); return; }

    btnEnv.disabled     = true;
    btnEnv.textContent  = '...';

    var formData = new FormData();
    formData.append('asunto',  asunto);
    formData.append('mensaje', mensaje);

    fetch('EnviarMensajeServlet', { method: 'POST', body: formData })
        .then(function() {
            document.getElementById('chat-asunto').value = '';
            document.getElementById('chat-texto').value  = '';
            cargarMensajes();
        })
        .catch(function() { mostrarError('No se pudo enviar. Intenta de nuevo.'); })
        .finally(function() {
            btnEnv.disabled    = false;
            btnEnv.innerHTML   = '&#10148;';
        });
}

// Enviar con Enter (Shift+Enter = salto de línea)
document.getElementById('chat-texto').addEventListener('keydown', function(e) {
    if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); enviarMensaje(); }
});

// ??? Badge de mensajes nuevos ???????????????????????????????????
function mostrarBadge(n) {
    var b = document.getElementById('chat-badge');
    b.textContent   = n > 9 ? '9+' : n;
    b.style.display = 'flex';
}
function ocultarBadge() {
    document.getElementById('chat-badge').style.display = 'none';
}
function mostrarError(msg) {
    var e = document.getElementById('chat-error');
    e.innerHTML     = msg;
    e.style.display = 'block';
}

// Polling silencioso en segundo plano (panel cerrado) cada 20 s
setInterval(function() {
    if (!chatAbierto) {
        fetch('ChatJsonServlet')
            .then(function(r) { return r.json(); })
            .then(function(datos) {
                if (!Array.isArray(datos) || datos.length === 0) return;
                var maxId = Math.max.apply(null, datos.map(function(m) { return m.idMensaje; }));
                if (ultimoIdMensaje === 0) { ultimoIdMensaje = maxId; return; }
                if (maxId > ultimoIdMensaje) {
                    mostrarBadge(datos.filter(function(m) { return m.idMensaje > ultimoIdMensaje; }).length);
                }
            }).catch(function() {});
    }
}, 20000);

// Carga inicial silenciosa para obtener el ultimoIdMensaje base
fetch('ChatJsonServlet')
    .then(function(r) { return r.json(); })
    .then(function(datos) {
        if (Array.isArray(datos) && datos.length > 0)
            ultimoIdMensaje = Math.max.apply(null, datos.map(function(m) { return m.idMensaje; }));
    }).catch(function() {});

// Utilidad ? escapar HTML para evitar XSS
function esc(str) {
    if (!str) return '';
    return str.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;')
              .replace(/"/g,'&quot;').replace(/'/g,'&#039;');
}
</script>
