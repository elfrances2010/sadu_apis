<%
    /*
     * sidebar.jsp - Sidebar UNICO y unificado del sistema SADU con Chat ICQ Empresarial y Sonido ICQ
     */
    String paginaActual = request.getRequestURI();
    if (paginaActual == null) paginaActual = "";

    HttpSession sesionSidebar = request.getSession(false);
    String rolSidebarStr  = "0";
    String userSidebar    = "";
    int    idUserSidebar  = 0;

    if (sesionSidebar != null) {
        if (sesionSidebar.getAttribute("rolUsuario") != null) {
            rolSidebarStr = String.valueOf(sesionSidebar.getAttribute("rolUsuario"));
        }
        if (sesionSidebar.getAttribute("nombreUsuario") != null) {
            userSidebar = String.valueOf(sesionSidebar.getAttribute("nombreUsuario"));
        }
        if (sesionSidebar.getAttribute("idUsuario") != null) {
            try {
                idUserSidebar = Integer.parseInt(String.valueOf(sesionSidebar.getAttribute("idUsuario")));
            } catch (Exception e) {
                idUserSidebar = 0;
            }
        }
    }
    boolean esAdminSidebar = "1".equals(rolSidebarStr) || "ADMINISTRADOR".equalsIgnoreCase(rolSidebarStr);
    boolean esGestorSidebar = "2".equals(rolSidebarStr) || "GESTOR".equalsIgnoreCase(rolSidebarStr);
%>
<!-- Cargar Bootstrap Icons -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

<style>
/* =============================================
   SIDEBAR NAV
   ============================================= */
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

.content { margin-left: 230px; padding: 25px 30px; min-height: 100vh; }

/* =============================================
   CHAT FLOTANTE ICQ EMPRESARIAL
   ============================================= */
#chat-fab {
    position: fixed; bottom: 28px; right: 28px;
    width: 58px; height: 58px; border-radius: 50%;
    background: linear-gradient(135deg, #1f3b57, #10b981); color: white;
    border: 2px solid white; font-size: 24px;
    box-shadow: 0 4px 20px rgba(0,0,0,0.3);
    cursor: pointer; z-index: 999;
    transition: all 0.2s ease-in-out;
    display: flex; align-items: center; justify-content: center;
}
#chat-fab:hover { transform: scale(1.08); box-shadow: 0 6px 24px rgba(16,185,129,0.4); }

#chat-badge {
    position: absolute; top: -4px; right: -4px;
    background: #ef4444; color: white;
    border-radius: 50%; width: 22px; height: 22px;
    font-size: 11px; font-weight: bold;
    display: none; align-items: center; justify-content: center;
    border: 2px solid white;
    animation: pulse-badge 1.5s infinite;
}
@keyframes pulse-badge {
    0% { transform: scale(1); }
    50% { transform: scale(1.15); }
    100% { transform: scale(1); }
}

#chat-panel {
    position: fixed; bottom: 95px; right: 28px;
    width: 380px; height: 550px;
    background: #ffffff; border-radius: 16px;
    box-shadow: 0 10px 35px rgba(0,0,0,0.22);
    display: none; flex-direction: column;
    z-index: 998; overflow: hidden;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    border: 1px solid #e2e8f0;
}
#chat-panel.abierto { display: flex; }

/* Encabezado ICQ */
#chat-header {
    background: linear-gradient(135deg, #1f3b57, #1e293b);
    color: white; padding: 12px 16px;
    display: flex; flex-direction: column; gap: 8px;
    flex-shrink: 0;
}
.chat-header-top {
    display: flex; justify-content: space-between; align-items: center;
}
.chat-header-title {
    display: flex; align-items: center; gap: 8px; font-weight: bold; font-size: 15px;
}
.icq-flower {
    width: 14px; height: 14px; border-radius: 50%; background: #10b981;
    box-shadow: 0 0 10px #10b981; display: inline-block; animation: flower-glow 2s infinite alternate;
}
@keyframes flower-glow {
    0% { box-shadow: 0 0 4px #10b981; }
    100% { box-shadow: 0 0 12px #34d399; }
}

.chat-header-actions {
    display: flex; align-items: center; gap: 8px;
}
.btn-icq-sound-toggle {
    background: rgba(255,255,255,0.15); border: none; color: #34d399;
    width: 30px; height: 30px; border-radius: 50%; display: flex;
    align-items: center; justify-content: center; font-size: 14px;
    cursor: pointer; transition: all 0.2s;
}
.btn-icq-sound-toggle:hover { background: rgba(255,255,255,0.3); color: white; transform: scale(1.1); }
.btn-icq-sound-toggle.muted { color: #f87171; }

#btn-cerrar-chat {
    background: none; border: none; color: #94a3b8;
    font-size: 20px; cursor: pointer; line-height: 1; transition: color 0.2s;
}
#btn-cerrar-chat:hover { color: white; }

/* Tabs Selector (Usuarios vs Mensajes) */
.chat-tabs {
    display: flex; background: rgba(255,255,255,0.1); border-radius: 8px; padding: 2px;
}
.chat-tab {
    flex: 1; text-align: center; padding: 6px 10px; font-size: 12px; font-weight: 600;
    color: #cbd5e1; border-radius: 6px; cursor: pointer; transition: all 0.2s;
    display: flex; align-items: center; justify-content: center; gap: 5px;
}
.chat-tab.activo { background: #3b82f6; color: white; }
.chat-tab:hover:not(.activo) { background: rgba(255,255,255,0.15); color: white; }

/* Vista Lista de Usuarios (Directorio ICQ) */
#chat-vista-usuarios {
    flex: 1; display: flex; flex-direction: column; overflow: hidden; background: #f8fafc;
}
.chat-search-box {
    padding: 10px 14px; background: white; border-bottom: 1px solid #e2e8f0;
}
.chat-search-box input {
    width: 100%; padding: 7px 12px; border: 1px solid #cbd5e1;
    border-radius: 18px; font-size: 13px; outline: none; background: #f8fafc;
}
.chat-search-box input:focus { border-color: #3b82f6; background: white; }

.usuarios-lista {
    flex: 1; overflow-y: auto; padding: 10px; display: flex; flex-direction: column; gap: 6px;
}
.usuario-card {
    display: flex; align-items: center; gap: 12px; padding: 10px 12px;
    background: white; border-radius: 10px; border: 1px solid #e2e8f0;
    cursor: pointer; transition: all 0.15s ease;
}
.usuario-card:hover { background: #eff6ff; border-color: #bfdbfe; transform: translateY(-1px); }
.usuario-card.seleccionado { background: #dbeafe; border-color: #3b82f6; }

.usuario-avatar {
    width: 38px; height: 38px; border-radius: 50%; background: #1f3b57;
    color: white; font-weight: bold; font-size: 13px;
    display: flex; align-items: center; justify-content: center;
    position: relative; flex-shrink: 0;
}
.status-indicator {
    width: 10px; height: 10px; border-radius: 50%; border: 2px solid white;
    position: absolute; bottom: -1px; right: -1px; background: #94a3b8;
}
.status-indicator.online { background: #10b981; box-shadow: 0 0 6px #10b981; }
.status-indicator.typing { background: #3b82f6; box-shadow: 0 0 6px #3b82f6; animation: typing-pulse 1s infinite; }
@keyframes typing-pulse { 0% { transform: scale(1); } 50% { transform: scale(1.3); } 100% { transform: scale(1); } }

.usuario-info { flex: 1; min-width: 0; }
.usuario-nombre { font-weight: 600; font-size: 13.5px; color: #1e293b; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.usuario-rol { font-size: 11px; color: #64748b; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.usuario-estado-lbl { font-size: 10px; font-weight: 600; margin-top: 1px; }
.usuario-estado-lbl.online { color: #059669; }
.usuario-estado-lbl.typing { color: #2563eb; }

/* Vista Mensajes Chat */
#chat-vista-mensajes {
    flex: 1; display: none; flex-direction: column; overflow: hidden; background: #f8fafc;
}
.chat-target-header {
    background: white; padding: 10px 14px; border-bottom: 1px solid #e2e8f0;
    display: flex; justify-content: space-between; align-items: center; font-size: 13px; font-weight: bold; color: #1f3b57;
}
.btn-back-users {
    background: #f1f5f9; border: 1px solid #cbd5e1; color: #475569;
    padding: 3px 10px; border-radius: 12px; font-size: 11px; cursor: pointer;
}
.btn-back-users:hover { background: #e2e8f0; color: #1e293b; }

#chat-mensajes {
    flex: 1; overflow-y: auto; padding: 14px; display: flex; flex-direction: column; gap: 10px;
}
.chat-sin-mensajes {
    margin: auto; text-align: center; color: #94a3b8; font-size: 13px; padding: 20px;
}

.chat-burbuja {
    max-width: 82%; padding: 10px 14px; border-radius: 14px; font-size: 13px;
    line-height: 1.4; word-break: break-word; position: relative;
}
.chat-burbuja.propio {
    align-self: flex-end; background: #1f3b57; color: white; border-bottom-right-radius: 3px;
}
.chat-burbuja.ajeno {
    align-self: flex-start; background: white; color: #1e293b; border: 1px solid #e2e8f0;
    border-bottom-left-radius: 3px; box-shadow: 0 2px 6px rgba(0,0,0,0.04);
}
.burbuja-autor { font-size: 11px; font-weight: bold; color: #2563eb; margin-bottom: 3px; }
.chat-burbuja.propio .burbuja-autor { color: #93c5fd; }
.burbuja-asunto {
    font-weight: bold; font-size: 12px; margin-bottom: 4px;
    border-bottom: 1px dashed rgba(0,0,0,0.1); padding-bottom: 3px;
}
.chat-burbuja.propio .burbuja-asunto { border-bottom-color: rgba(255,255,255,0.2); }
.burbuja-hora { font-size: 10px; opacity: 0.7; margin-top: 4px; text-align: right; }

.burbuja-img { max-width: 100%; max-height: 200px; border-radius: 8px; margin-top: 5px; cursor: pointer; }
.burbuja-audio { margin-top: 6px; width: 100%; max-width: 250px; }

.msg-actions {
    display: none; position: absolute; top: -8px; right: 8px; background: white;
    border: 1px solid #cbd5e1; border-radius: 12px; padding: 2px 6px; gap: 4px;
    box-shadow: 0 2px 6px rgba(0,0,0,0.12);
}
.chat-burbuja:hover .msg-actions { display: flex; }
.btn-msg-act { background: none; border: none; font-size: 12px; cursor: pointer; padding: 2px 4px; color: #475569; }
.btn-msg-act:hover { color: #1e293b; }

/* Input Form Chat */
#chat-form {
    background: white; padding: 10px 12px; border-top: 1px solid #e2e8f0;
    display: flex; flex-direction: column; gap: 6px;
}
.chat-previews-bar {
    display: flex; justify-content: space-between; align-items: center;
    background: #eff6ff; padding: 6px 12px; border-radius: 6px; font-size: 12px; color: #1e40af;
}
#chat-asunto-input {
    border: 1px solid #cbd5e1; border-radius: 6px; padding: 5px 10px; font-size: 12px; outline: none;
}
#chat-asunto-input:focus { border-color: #3b82f6; }
.chat-input-row { display: flex; gap: 8px; align-items: center; }
#chat-texto-input {
    flex: 1; border: 1px solid #cbd5e1; border-radius: 8px; padding: 8px 10px;
    font-size: 13px; outline: none; resize: none; height: 44px; font-family: inherit;
}
#chat-texto-input:focus { border-color: #3b82f6; }
.btn-chat-action {
    background: #f1f5f9; border: 1px solid #cbd5e1; color: #475569;
    width: 38px; height: 38px; border-radius: 8px; font-size: 16px;
    cursor: pointer; display: flex; align-items: center; justify-content: center; flex-shrink: 0;
}
.btn-chat-action:hover { background: #e2e8f0; color: #1e293b; }
.btn-chat-action.recording { background: #ef4444; color: white; border-color: #dc2626; animation: typing-pulse 1s infinite; }
#btn-enviar-chat {
    background: #1f3b57; color: white; border: none; width: 42px; height: 38px;
    border-radius: 8px; font-size: 16px; cursor: pointer; transition: background 0.2s;
    display: flex; align-items: center; justify-content: center; flex-shrink: 0;
}
#btn-enviar-chat:hover { background: #2563eb; }

/* Modal Imagenes */
#chat-img-modal {
    display: none; position: fixed; top: 0; left: 0; width: 100vw; height: 100vh;
    background: rgba(0,0,0,0.85); z-index: 99999; justify-content: center; align-items: center;
}
#chat-img-modal img { max-width: 90vw; max-height: 90vh; border-radius: 8px; }
#chat-img-modal-close { position: absolute; top: 20px; right: 30px; color: white; font-size: 32px; cursor: pointer; }
</style>

<!-- SIDEBAR -->
<div class="sidebar">
    <a href="dashboard.jsp" class="sidebar-logo">SADU</a>
    <div style="padding: 0 14px 10px;">
        <button type="button" onclick="abrirOmnibar()" style="width:100%; background:rgba(255,255,255,0.08); border:1px solid #3b82f6; border-radius:8px; color:#cbd5e1; padding:7px 12px; font-size:12.5px; display:flex; justify-content:space-between; align-items:center; cursor:pointer;">
            <span><i class="bi bi-search me-1 text-primary"></i> Buscar...</span>
            <kbd style="background:#0f172a; color:#94a3b8; font-size:10px; padding:2px 5px; border-radius:4px;">Ctrl+K</kbd>
        </button>
    </div>
    <span class="menu-title">Navegaci&oacute;n</span>
    <a href="dashboard.jsp" class="<%= paginaActual.endsWith("dashboard.jsp") ? "activo" : "" %>"><i class="bi bi-speedometer2 me-2"></i> Dashboard</a>
    <a href="chat.jsp" class="<%= paginaActual.endsWith("chat.jsp") ? "activo" : "" %>"><i class="bi bi-chat-dots-fill me-2"></i> Chat Empresarial</a>
    <a href="comunicaciones" class="<%= paginaActual.contains("comunicaciones") ? "activo" : "" %>"><i class="bi bi-envelope me-2"></i> Comunicaciones</a>
    <a href="documentos" class="<%= (paginaActual.contains("documentos") && !paginaActual.contains("documentos_registrados") && !paginaActual.contains("documentosRegistrados")) ? "activo" : "" %>"><i class="bi bi-folder me-2"></i> Documentos</a>
    <a href="documentosRegistrados" class="<%= (paginaActual.contains("documentos_registrados") || paginaActual.contains("documentosRegistrados")) ? "activo" : "" %>"><i class="bi bi-file-earmark-check me-2"></i> Doc. Registrados</a>
    <a href="microfilminas_fotos.jsp" class="<%= paginaActual.endsWith("microfilminas_fotos.jsp") ? "activo" : "" %>"><i class="bi bi-film me-2"></i> Microfilmes y Fotos</a>
    <a href="sincronizacion_territorial.jsp" class="<%= paginaActual.endsWith("sincronizacion_territorial.jsp") ? "activo" : "" %>"><i class="bi bi-geo-alt-fill me-2"></i> Territorio y Sedes</a>
    <a href="quienes_somos.jsp" class="<%= paginaActual.endsWith("quienes_somos.jsp") ? "activo" : "" %>"><i class="bi bi-info-circle me-2"></i> Qui&eacute;nes Somos</a>

    <% if (esAdminSidebar || esGestorSidebar) { %>
        <span class="menu-title">Administraci&oacute;n</span>
        <% if (esAdminSidebar) { %>
            <a href="usuarios" class="<%= paginaActual.contains("usuarios") ? "activo" : "" %>"><i class="bi bi-people me-2"></i> G. Usuarios</a>
        <% } %>
        <a href="reportes" class="<%= paginaActual.contains("reportes") ? "activo" : "" %>"><i class="bi bi-bar-chart me-2"></i> Reportes</a>
        <% if (esAdminSidebar) { %>
            <a href="auditoria" class="<%= paginaActual.contains("auditoria") ? "activo" : "" %>"><i class="bi bi-shield-check me-2"></i> Auditor&iacute;a</a>
        <% } %>
    <% } %>

    <hr class="sidebar-divider">
    <a href="manual_usuario.jsp" class="<%= paginaActual.endsWith("manual_usuario.jsp") ? "activo" : "" %>"><i class="bi bi-book me-2"></i> Ayuda</a>
    <a href="logout.jsp" class="link-logout"><i class="bi bi-box-arrow-right me-2"></i> Cerrar Sesi&oacute;n</a>
</div>

<!-- CHAT FAB BOTON FLOTANTE -->
<div id="chat-fab" onclick="toggleChat()" title="Abrir Chat ICQ SADU">
    <i class="bi bi-chat-dots-fill"></i>
    <span id="chat-badge">0</span>
</div>

<!-- PANEL CHAT ICQ -->
<div id="chat-panel">
    <div id="chat-header">
        <div class="chat-header-top">
            <div class="chat-header-title">
                <span class="icq-flower"></span> ICQ SADU Chat
            </div>
            <div class="chat-header-actions">
                <button type="button" class="btn-icq-sound-toggle" id="btn-icq-sound-toggle" onclick="toggleSonidoICQ()" title="Probar / Conmutar Sonido ICQ (Uh-Oh!)">
                    <i class="bi bi-volume-up-fill"></i>
                </button>
                <button type="button" id="btn-cerrar-chat" onclick="toggleChat()">&times;</button>
            </div>
        </div>

        <div class="chat-tabs">
            <div id="tab-usuarios-btn" class="chat-tab activo" onclick="switchTab('usuarios')">
                <i class="bi bi-people-fill"></i> Contactos
            </div>
            <div id="tab-mensajes-btn" class="chat-tab" onclick="switchTab('mensajes')">
                <i class="bi bi-chat-text-fill"></i> Mensajes
            </div>
        </div>
    </div>

    <!-- Vista 1: Lista de usuarios (ICQ) -->
    <div id="chat-vista-usuarios">
        <div class="chat-search-box">
            <input id="chat-search-user" type="text" placeholder="Buscar usuario en SADU..." oninput="filtrarUsuarios()">
        </div>
        <div id="usuarios-lista-container" class="usuarios-lista">
            <div style="text-align:center; padding:20px; color:#64748b; font-size:12px;">Cargando usuarios...</div>
        </div>
    </div>

    <!-- Vista 2: Mensajes -->
    <div id="chat-vista-mensajes">
        <div class="chat-target-header">
            <span id="chat-target-nombre"><i class="bi bi-globe me-1"></i> Chat General</span>
            <button class="btn-back-users" onclick="switchTab('usuarios')"><i class="bi bi-arrow-left"></i> Contactos</button>
        </div>

        <div id="chat-mensajes">
            <div class="chat-sin-mensajes">Cargando mensajes...</div>
        </div>

        <div id="chat-form">
            <div id="chat-preview-bar" class="chat-previews-bar" style="display:none;">
                <span id="chat-preview-text"><i class="bi bi-paperclip me-1"></i> Archivo adjunto listo</span>
                <button type="button" style="background:none; border:none; color:#ef4444; cursor:pointer; font-weight:bold;" onclick="limpiarAdjunto()">&times;</button>
            </div>

            <input id="chat-asunto-input" type="text" placeholder="Asunto (opcional)..." maxlength="120">

            <div class="chat-input-row">
                <input type="file" id="chat-file-input" accept="image/*" style="display:none;" onchange="manejarSeleccionImagen(event)">
                <button type="button" class="btn-chat-action" onclick="document.getElementById('chat-file-input').click()" title="Adjuntar imagen"><i class="bi bi-image"></i></button>
                <button type="button" id="btn-mic-chat" class="btn-chat-action" onclick="toggleGrabacionAudio()" title="Grabar nota de voz"><i class="bi bi-mic-fill"></i></button>
                
                <textarea id="chat-texto-input" placeholder="Escribe un mensaje..." oninput="notificarEscritura()"></textarea>
                <button id="btn-enviar-chat" onclick="enviarMensajeICQ()" title="Enviar mensaje"><i class="bi bi-send-fill"></i></button>
            </div>
        </div>
    </div>
</div>

<!-- Modal para ver imágenes ampliadas -->
<div id="chat-img-modal" onclick="cerrarModalImagen()">
    <span id="chat-img-modal-close">&times;</span>
    <img id="chat-img-modal-target" src="" alt="Vista previa">
</div>

<script>
const ID_MI_USUARIO = <%= idUserSidebar %>;
let chatAbierto = false;
let vistaActual = 'usuarios';
let targetReceptorId = null;
let targetReceptorNombre = '<i class="bi bi-globe me-1"></i> Chat General';

let usuariosCache = [];
let maxIdMensajeConocido = 0;
let primerCargaRealizada = false;
let noLeidosCount = 0;

let pollingInterval = null;
let bgPollingInterval = null;
let typingTimeout = null;

let adjuntoBase64 = null;
let adjuntoTipo = 'TEXTO';

let mediaRecorder = null;
let audioChunks = [];
let grabacionActiva = false;
let tiempoGrabacionSec = 0;
let timerGrabacionInt = null;

// Sistema de Audio ICQ
let icqAudioHabilitado = true;
const icqAudio = new Audio('sounds/icq-message-sound.mp3');
icqAudio.preload = 'auto';

icqAudio.onerror = function() {
    icqAudio.src = 'icq-message-sound.mp3';
};

function desbloquearAudioICQ() {
    try {
        icqAudio.play().then(function() {
            icqAudio.pause();
            icqAudio.currentTime = 0;
        }).catch(function(){});
    } catch(e){}
    document.removeEventListener('click', desbloquearAudioICQ);
    document.removeEventListener('keydown', desbloquearAudioICQ);
}
document.addEventListener('click', desbloquearAudioICQ, { once: true });
document.addEventListener('keydown', desbloquearAudioICQ, { once: true });

function reproducirSonidoICQ() {
    if (!icqAudioHabilitado) return;
    try {
        icqAudio.currentTime = 0;
        const p = icqAudio.play();
        if (p !== undefined) {
            p.catch(function(err) {
                console.log("Autoplay de sonido ICQ prevenido:", err);
            });
        }
    } catch (err) {
        console.log("Error al reproducir audio ICQ:", err);
    }
}

function toggleSonidoICQ() {
    icqAudioHabilitado = !icqAudioHabilitado;
    const btn = document.getElementById('btn-icq-sound-toggle');
    if (icqAudioHabilitado) {
        btn.classList.remove('muted');
        btn.innerHTML = '<i class="bi bi-volume-up-fill"></i>';
        btn.title = "Sonido ICQ Activado (Clic para probar / desactivar)";
        reproducirSonidoICQ();
    } else {
        btn.classList.add('muted');
        btn.innerHTML = '<i class="bi bi-volume-mute-fill"></i>';
        btn.title = "Sonido ICQ Desactivado (Clic para activar)";
    }
}

document.addEventListener('DOMContentLoaded', function() {
    verificarBackgroundNuevosMensajes();
    bgPollingInterval = setInterval(verificarBackgroundNuevosMensajes, 3500);
});

function toggleChat() {
    chatAbierto = !chatAbierto;
    const panel = document.getElementById('chat-panel');
    if (chatAbierto) {
        panel.classList.add('abierto');
        ocultarBadge();
        cargarUsuariosICQ();
        cargarMensajesICQ();
        if (!pollingInterval) {
            pollingInterval = setInterval(refreshSilencioso, 4000);
        }
    } else {
        panel.classList.remove('abierto');
        if (pollingInterval) {
            clearInterval(pollingInterval);
            pollingInterval = null;
        }
    }
}

function switchTab(tab) {
    vistaActual = tab;
    document.getElementById('tab-usuarios-btn').classList.toggle('activo', tab === 'usuarios');
    document.getElementById('tab-mensajes-btn').classList.toggle('activo', tab === 'mensajes');

    document.getElementById('chat-vista-usuarios').style.display = tab === 'usuarios' ? 'flex' : 'none';
    document.getElementById('chat-vista-mensajes').style.display = tab === 'mensajes' ? 'flex' : 'none';

    if (tab === 'mensajes') {
        cargarMensajesICQ();
    } else {
        cargarUsuariosICQ();
    }
}

function seleccionarUsuarioChat(id, nombre) {
    targetReceptorId = id;
    targetReceptorNombre = id ? ('<i class="bi bi-person-fill me-1"></i> ' + esc(nombre)) : '<i class="bi bi-globe me-1"></i> Chat General';
    document.getElementById('chat-target-nombre').innerHTML = targetReceptorNombre;
    switchTab('mensajes');
}

function cargarUsuariosICQ() {
    fetch('ChatJsonServlet?action=usuarios')
        .then(function(r) { return r.json(); })
        .then(function(usuarios) {
            if (!Array.isArray(usuarios)) return;
            usuariosCache = usuarios;
            renderUsuariosLista(usuarios);
        })
        .catch(function(err) { console.log('Error al cargar usuarios:', err); });
}

function renderUsuariosLista(lista) {
    const container = document.getElementById('usuarios-lista-container');
    const filtro = document.getElementById('chat-search-user').value.toLowerCase().trim();

    let html = '<div class="usuario-card ' + (targetReceptorId === null ? 'seleccionado' : '') + '" onclick="seleccionarUsuarioChat(null, \'Chat General\')">'
             + '<div class="usuario-avatar" style="background:#2563eb;"><i class="bi bi-globe"></i></div>'
             + '<div class="usuario-info">'
             + '<div class="usuario-nombre">Chat General</div>'
             + '<div class="usuario-rol">Mensajes para todos los usuarios</div>'
             + '</div></div>';

    const filtrados = lista.filter(function(u) {
        return u.idUsuario !== ID_MI_USUARIO &&
            (u.nombreCompleto.toLowerCase().indexOf(filtro) !== -1 ||
             u.username.toLowerCase().indexOf(filtro) !== -1 ||
             u.nombreRol.toLowerCase().indexOf(filtro) !== -1);
    });

    if (filtrados.length === 0 && lista.length > 1) {
        html += '<div style="text-align:center; padding:15px; color:#94a3b8; font-size:12px;">No se encontraron contactos.</div>';
    } else {
        filtrados.forEach(function(u) {
            const partes = u.nombreCompleto.split(' ');
            let iniciales = u.nombreCompleto.substring(0, 2).toUpperCase();
            if (partes.length >= 2 && partes[0][0] && partes[1][0]) {
                iniciales = (partes[0][0] + partes[1][0]).toUpperCase();
            }

            const esOnline = u.online;
            const esTyping = u.typing;

            let statusClass = 'offline';
            let statusText = '<i class="bi bi-circle-fill" style="font-size:7px; color:#94a3b8;"></i> Desconectado';
            let labelClass = '';

            if (esTyping) {
                statusClass = 'typing';
                statusText = '<i class="bi bi-pencil-fill"></i> Escribiendo...';
                labelClass = 'typing';
            } else if (esOnline) {
                statusClass = 'online';
                statusText = '<i class="bi bi-record-fill" style="color:#10b981;"></i> En l&iacute;nea';
                labelClass = 'online';
            }

            const sel = targetReceptorId === u.idUsuario ? 'seleccionado' : '';
            const nombreEsc = escAttr(u.nombreCompleto);

            html += '<div class="usuario-card ' + sel + '" onclick="seleccionarUsuarioChat(' + u.idUsuario + ', \'' + nombreEsc + '\')">'
                  + '<div class="usuario-avatar">' + iniciales + '<span class="status-indicator ' + statusClass + '"></span></div>'
                  + '<div class="usuario-info">'
                  + '<div class="usuario-nombre">' + esc(u.nombreCompleto) + '</div>'
                  + '<div class="usuario-rol">' + esc(u.nombreRol) + ' (@' + esc(u.username) + ')</div>'
                  + '<div class="usuario-estado-lbl ' + labelClass + '">' + statusText + '</div>'
                  + '</div></div>';
        });
    }

    container.innerHTML = html;
}

function filtrarUsuarios() {
    renderUsuariosLista(usuariosCache);
}

function verificarBackgroundNuevosMensajes() {
    fetch('ChatJsonServlet?action=mensajes')
        .then(function(r) { return r.json(); })
        .then(function(datos) {
            if (!Array.isArray(datos)) return;
            
            let hayNuevosAjenos = false;
            let maxIdEncontrado = maxIdMensajeConocido;

            datos.forEach(function(m) {
                if (m.idMensaje > maxIdMensajeConocido) {
                    if (m.idUsuario !== ID_MI_USUARIO) {
                        hayNuevosAjenos = true;
                        noLeidosCount++;
                    }
                }
                if (m.idMensaje > maxIdEncontrado) {
                    maxIdEncontrado = m.idMensaje;
                }
            });

            if (!primerCargaRealizada) {
                maxIdMensajeConocido = maxIdEncontrado;
                primerCargaRealizada = true;
                return;
            }

            if (hayNuevosAjenos) {
                reproducirSonidoICQ();
                if (!chatAbierto) {
                    const badge = document.getElementById('chat-badge');
                    badge.innerText = noLeidosCount > 99 ? '99+' : noLeidosCount;
                    badge.style.display = 'flex';
                }
                maxIdMensajeConocido = maxIdEncontrado;

                if (chatAbierto && vistaActual === 'mensajes') {
                    cargarMensajesICQ();
                }
            }
        })
        .catch(function(err) { console.log('Error polling background:', err); });
}

function cargarMensajesICQ() {
    let url = 'ChatJsonServlet?action=mensajes';
    if (targetReceptorId) url += '&receptorId=' + targetReceptorId;

    fetch(url)
        .then(function(r) { return r.json(); })
        .then(function(datos) {
            const container = document.getElementById('chat-mensajes');
            if (!Array.isArray(datos) || datos.length === 0) {
                container.innerHTML = '<div class="chat-sin-mensajes"><i class="bi bi-chat-left-dots fs-3 mb-2"></i><br>No hay mensajes en esta conversaci&oacute;n.<br>&iexcl;S&eacute; el primero en escribir!</div>';
                return;
            }

            let html = '';
            for (let i = datos.length - 1; i >= 0; i--) {
                const m = datos[i];
                const propio = m.idUsuario === ID_MI_USUARIO;
                const clase = propio ? 'propio' : 'ajeno';
                const hora = m.fechaEnvio ? new Date(m.fechaEnvio).toLocaleTimeString('es-CO', {hour:'2-digit', minute:'2-digit'}) : '';
                const editTag = m.editado ? ' <small style="opacity:0.6;">(editado)</small>' : '';

                let cuerpo = '';
                const urlEsc = escAttr(m.urlAdjunto);

                if (m.tipo === 'IMAGEN' && m.urlAdjunto) {
                    cuerpo = '<img src="' + esc(m.urlAdjunto) + '" class="burbuja-img" onclick="abrirModalImagen(\'' + urlEsc + '\')"><br>' + esc(m.mensaje);
                } else if (m.tipo === 'AUDIO' && m.urlAdjunto) {
                    cuerpo = '<audio controls src="' + esc(m.urlAdjunto) + '" class="burbuja-audio"></audio>';
                } else {
                    cuerpo = '<div class="burbuja-texto">' + esc(m.mensaje) + '</div>';
                }

                const autor = !propio ? '<div class="burbuja-autor">' + esc(m.nombreUsuario) + '</div>' : '';
                const asunto = m.asunto && m.asunto !== 'Chat' ? '<div class="burbuja-asunto">' + esc(m.asunto) + '</div>' : '';

                let btnAcciones = '';
                if (propio) {
                    const msgEsc = escAttr(m.mensaje);
                    btnAcciones = '<div class="msg-actions">'
                                + '<button class="btn-msg-act" title="Editar mensaje" onclick="editarMensaje(' + m.idMensaje + ', \'' + msgEsc + '\')"><i class="bi bi-pencil-fill"></i></button>'
                                + '<button class="btn-msg-act" title="Borrar mensaje" onclick="eliminarMensaje(' + m.idMensaje + ')"><i class="bi bi-trash-fill"></i></button>'
                                + '</div>';
                }

                html += '<div class="chat-burbuja ' + clase + '">'
                      + btnAcciones + autor + asunto + cuerpo
                      + '<div class="burbuja-hora">' + hora + editTag + '</div>'
                      + '</div>';
            }

            container.innerHTML = html;
            container.scrollTop = container.scrollHeight;
        });
}

function refreshSilencioso() {
    if (!chatAbierto) return;
    cargarUsuariosICQ();
    if (vistaActual === 'mensajes') {
        cargarMensajesICQ();
    }
}

function notificarEscritura() {
    if (typingTimeout) clearTimeout(typingTimeout);
    typingTimeout = setTimeout(function() {
        const params = new URLSearchParams();
        params.append('action', 'typing');
        fetch('ChatJsonServlet', { method: 'POST', body: params });
    }, 300);
}

function enviarMensajeICQ() {
    const asunto = document.getElementById('chat-asunto-input').value.trim();
    const texto = document.getElementById('chat-texto-input').value.trim();

    if (!texto && !adjuntoBase64) {
        alert('Escribe un mensaje o adjunta un archivo.');
        return;
    }

    let bodyData;
    if (adjuntoBase64) {
        const formData = new FormData();
        formData.append('action', 'enviar');
        if (asunto) formData.append('asunto', asunto);
        if (texto) formData.append('mensaje', texto);
        if (targetReceptorId) formData.append('idReceptor', targetReceptorId);
        formData.append('tipo', adjuntoTipo);
        formData.append('urlAdjunto', adjuntoBase64);
        bodyData = formData;
    } else {
        const params = new URLSearchParams();
        params.append('action', 'enviar');
        if (asunto) params.append('asunto', asunto);
        if (texto) params.append('mensaje', texto);
        if (targetReceptorId) params.append('idReceptor', targetReceptorId);
        params.append('tipo', 'TEXTO');
        bodyData = params;
    }

    fetch('ChatJsonServlet', { method: 'POST', body: bodyData })
        .then(function(r) { return r.json(); })
        .then(function(res) {
            if (res.success) {
                document.getElementById('chat-asunto-input').value = '';
                document.getElementById('chat-texto-input').value = '';
                limpiarAdjunto();
                cargarMensajesICQ();
                reproducirSonidoICQ();
            }
        });
}

function editarMensaje(idMsg, textoActual) {
    const nuevo = prompt('Corrige tu mensaje:', textoActual);
    if (nuevo === null || nuevo.trim() === '') return;

    const params = new URLSearchParams();
    params.append('action', 'editar');
    params.append('idMensaje', idMsg);
    params.append('nuevoTexto', nuevo.trim());

    fetch('ChatJsonServlet', { method: 'POST', body: params })
        .then(function(r) { return r.json(); })
        .then(function(res) { if (res.success) cargarMensajesICQ(); });
}

function eliminarMensaje(idMsg) {
    if (!confirm('Deseas eliminar este mensaje?')) return;

    const params = new URLSearchParams();
    params.append('action', 'eliminar');
    params.append('idMensaje', idMsg);

    fetch('ChatJsonServlet', { method: 'POST', body: params })
        .then(function(r) { return r.json(); })
        .then(function(res) { if (res.success) cargarMensajesICQ(); });
}

function manejarSeleccionImagen(e) {
    const file = e.target.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = function(evt) {
        adjuntoBase64 = evt.target.result;
        adjuntoTipo = 'IMAGEN';
        document.getElementById('chat-preview-text').innerHTML = '<i class="bi bi-image me-1"></i> Imagen lista: ' + esc(file.name);
        document.getElementById('chat-preview-bar').style.display = 'flex';
    };
    reader.readAsDataURL(file);
}

function toggleGrabacionAudio() {
    if (!grabacionActiva) {
        if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
            alert('Tu navegador no soporta grabación de audio.');
            return;
        }

        navigator.mediaDevices.getUserMedia({ audio: true })
            .then(function(stream) {
                mediaRecorder = new MediaRecorder(stream);
                audioChunks = [];
                mediaRecorder.ondataavailable = function(e) { audioChunks.push(e.data); };
                mediaRecorder.onstop = function() {
                    const blob = new Blob(audioChunks, { type: 'audio/webm' });
                    const reader = new FileReader();
                    reader.onloadend = function() {
                        adjuntoBase64 = reader.result;
                        adjuntoTipo = 'AUDIO';
                        document.getElementById('chat-preview-text').innerHTML = '<i class="bi bi-mic-fill me-1"></i> Audio grabado (' + tiempoGrabacionSec + 's)';
                        document.getElementById('chat-preview-bar').style.display = 'flex';
                    };
                    reader.readAsDataURL(blob);
                };

                mediaRecorder.start();
                grabacionActiva = true;
                tiempoGrabacionSec = 0;
                document.getElementById('btn-mic-chat').classList.add('recording');

                timerGrabacionInt = setInterval(function() {
                    tiempoGrabacionSec++;
                    document.getElementById('btn-mic-chat').title = 'Grabando: ' + tiempoGrabacionSec + 's (Clic para detener)';
                }, 1000);
            })
            .catch(function() { alert('No se pudo acceder al micrófono. Por favor permite el acceso.'); });
    } else {
        mediaRecorder.stop();
        mediaRecorder.stream.getTracks().forEach(function(t) { t.stop(); });
        grabacionActiva = false;
        clearInterval(timerGrabacionInt);
        document.getElementById('btn-mic-chat').classList.remove('recording');
        document.getElementById('btn-mic-chat').title = 'Grabar nota de voz';
    }
}

function limpiarAdjunto() {
    adjuntoBase64 = null;
    adjuntoTipo = 'TEXTO';
    document.getElementById('chat-preview-bar').style.display = 'none';
    document.getElementById('chat-file-input').value = '';
}

function abrirModalImagen(src) {
    document.getElementById('chat-img-modal-target').src = src;
    document.getElementById('chat-img-modal').style.display = 'flex';
}
function cerrarModalImagen() {
    document.getElementById('chat-img-modal').style.display = 'none';
}

function esc(str) {
    if (!str) return '';
    return String(str).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;')
                      .replace(/"/g,'&quot;').replace(/'/g,'&#039;');
}

function escAttr(str) {
    if (!str) return '';
    return String(str)
        .replace(/\\/g, '\\\\')
        .replace(/'/g, "\\'")
        .replace(/"/g, '&quot;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;');
}

function ocultarBadge() {
    noLeidosCount = 0;
    document.getElementById('chat-badge').style.display = 'none';
}

/* ========================================================
   BUSCADOR GLOBAL INTELIGENTE (OMNIBAR / CTRL+K)
   ======================================================== */
document.addEventListener('keydown', function(e) {
    if ((e.ctrlKey || e.metaKey) && (e.key === 'k' || e.key === 'K')) {
        e.preventDefault();
        abrirOmnibar();
    }
});

function abrirOmnibar() {
    let modalEl = document.getElementById('modalOmnibar');
    if (!modalEl) return;
    let modal = bootstrap.Modal.getInstance(modalEl);
    if (!modal) modal = new bootstrap.Modal(modalEl);
    modal.show();
    setTimeout(() => {
        const inp = document.getElementById('inputOmnibar');
        if (inp) { inp.focus(); inp.select(); }
    }, 300);
}

let omnibarTimer = null;
function ejecutarBusquedaGlobal() {
    clearTimeout(omnibarTimer);
    omnibarTimer = setTimeout(() => {
        const q = document.getElementById('inputOmnibar').value.trim();
        const contenedor = document.getElementById('resultadosOmnibar');
        if (q.length < 2) {
            contenedor.innerHTML = '<div class="text-center py-4 text-muted" style="font-size:13px;">Escribe al menos 2 caracteres para buscar en documentos, radicados, OCR y sedes...</div>';
            return;
        }

        contenedor.innerHTML = '<div class="text-center py-4 text-muted"><div class="spinner-border spinner-border-sm text-primary me-2"></div>Buscando en todo SADU...</div>';

        fetch('api/busqueda-global?q=' + encodeURIComponent(q))
            .then(r => r.json())
            .then(data => {
                let html = '';
                let total = (data.documentos?.length || 0) + (data.comunicaciones?.length || 0) + (data.microfilmes?.length || 0) + (data.sedes?.length || 0);

                if (total === 0) {
                    contenedor.innerHTML = '<div class="text-center py-4 text-muted" style="font-size:13px;"><i class="bi bi-info-circle me-1"></i> No se encontraron coincidencias para "<strong>' + esc(q) + '</strong>".</div>';
                    return;
                }

                // 1. Documentos
                if (data.documentos && data.documentos.length > 0) {
                    html += '<div class="mb-3"><small class="fw-bold text-uppercase text-primary" style="font-size:11px; letter-spacing:0.5px;"><i class="bi bi-folder-fill me-1"></i> Documentos Registrados (' + data.documentos.length + ')</small><div class="list-group mt-1">';
                    data.documentos.forEach(d => {
                        html += '<a href="' + d.url + '" class="list-group-item list-group-item-action py-2 px-3 border-0 rounded mb-1" style="background:#f8fafc;">' +
                                '<strong style="font-size:13px; color:#1f3b57;">' + esc(d.titulo) + '</strong><br>' +
                                '<small class="text-muted" style="font-size:11.5px;">' + esc(d.subtitulo) + '</small>' +
                                '</a>';
                    });
                    html += '</div></div>';
                }

                // 2. Comunicaciones
                if (data.comunicaciones && data.comunicaciones.length > 0) {
                    html += '<div class="mb-3"><small class="fw-bold text-uppercase text-warning" style="font-size:11px; letter-spacing:0.5px;"><i class="bi bi-envelope-fill me-1"></i> Comunicaciones y Radicados (' + data.comunicaciones.length + ')</small><div class="list-group mt-1">';
                    data.comunicaciones.forEach(c => {
                        html += '<a href="' + c.url + '" class="list-group-item list-group-item-action py-2 px-3 border-0 rounded mb-1" style="background:#f8fafc;">' +
                                '<strong style="font-size:13px; color:#1f3b57;">' + esc(c.titulo) + '</strong><br>' +
                                '<small class="text-muted" style="font-size:11.5px;">' + esc(c.subtitulo) + '</small>' +
                                '</a>';
                    });
                    html += '</div></div>';
                }

                // 3. Microfilminas y Fotos (OCR)
                if (data.microfilmes && data.microfilmes.length > 0) {
                    html += '<div class="mb-3"><small class="fw-bold text-uppercase text-indigo" style="color:#4f46e5; font-size:11px; letter-spacing:0.5px;"><i class="bi bi-film me-1"></i> Microfilmes, Fotos y Búsqueda OCR (' + data.microfilmes.length + ')</small><div class="list-group mt-1">';
                    data.microfilmes.forEach(m => {
                        html += '<a href="' + m.url + '" class="list-group-item list-group-item-action py-2 px-3 border-0 rounded mb-1" style="background:#f8fafc;">' +
                                '<strong style="font-size:13px; color:#4f46e5;">' + esc(m.titulo) + '</strong><br>' +
                                '<small class="text-secondary fst-italic" style="font-size:11.5px;">' + esc(m.subtitulo) + '</small>' +
                                '</a>';
                    });
                    html += '</div></div>';
                }

                // 4. Sedes y Bóvedas
                if (data.sedes && data.sedes.length > 0) {
                    html += '<div class="mb-2"><small class="fw-bold text-uppercase text-success" style="font-size:11px; letter-spacing:0.5px;"><i class="bi bi-building me-1"></i> Sedes Universitarias y Bóvedas (' + data.sedes.length + ')</small><div class="list-group mt-1">';
                    data.sedes.forEach(s => {
                        html += '<a href="' + s.url + '" class="list-group-item list-group-item-action py-2 px-3 border-0 rounded mb-1" style="background:#f8fafc;">' +
                                '<strong style="font-size:13px; color:#1f3b57;">' + esc(s.titulo) + '</strong><br>' +
                                '<small class="text-muted" style="font-size:11.5px;">' + esc(s.subtitulo) + '</small>' +
                                '</a>';
                    });
                    html += '</div></div>';
                }

                contenedor.innerHTML = html;
            })
            .catch(err => {
                contenedor.innerHTML = '<div class="text-center py-4 text-danger" style="font-size:13px;">Error de comunicación al buscar.</div>';
            });
    }, 250);
}
</script>

<!-- MODAL OMNIBAR GLOBAL (CTRL+K) -->
<div class="modal fade" id="modalOmnibar" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content shadow-lg border-0" style="border-radius:14px; overflow:hidden;">
            <div class="modal-header p-3" style="background:#1e293b; border:none;">
                <div class="input-group">
                    <span class="input-group-text bg-transparent border-0 text-primary" style="font-size:18px;">
                        <i class="bi bi-search"></i>
                    </span>
                    <input type="text" id="inputOmnibar" class="form-control bg-transparent border-0 text-white" 
                           placeholder="Buscar radicados, textos OCR, documentos, municipios o sedes..." 
                           oninput="ejecutarBusquedaGlobal()" 
                           style="font-size:15px; outline:none; box-shadow:none;">
                    <button type="button" class="btn-close btn-close-white ms-2" data-bs-dismiss="modal"></button>
                </div>
            </div>
            <div class="modal-body p-3" id="resultadosOmnibar" style="max-height:420px; overflow-y:auto; background:#ffffff;">
                <div class="text-center py-4 text-muted" style="font-size:13px;">
                    <i class="bi bi-keyboard me-1 text-primary"></i> Presiona <kbd style="background:#e2e8f0; color:#334155;">Ctrl+K</kbd> en cualquier momento para abrir esta búsqueda universal.
                </div>
            </div>
            <div class="modal-footer py-2 px-3 bg-light d-flex justify-content-between align-items-center" style="font-size:11px; color:#64748b;">
                <span>Navega con enter hacia cualquier resultado</span>
                <span>SADU Búsqueda Transversal</span>
            </div>
        </div>
    </div>
</div>
