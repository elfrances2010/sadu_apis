<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%
    HttpSession sesion = request.getSession(false);
    if (sesion == null || sesion.getAttribute("nombreUsuario") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String nombreUsuario = (String) sesion.getAttribute("nombreUsuario");
    int idUsuario = (int) sesion.getAttribute("idUsuario");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chat Empresarial ICQ - SADU</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        body { background-color: #f4f6f9; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; }
        .chat-main-container { max-width: 1150px; margin: 20px auto; height: 780px; background: white; border-radius: 16px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); overflow: hidden; display: flex; }
        
        .contacts-panel { width: 340px; background: #f8fafc; border-right: 1px solid #e2e8f0; display: flex; flex-direction: column; }
        .contacts-header { background: #1f3b57; color: white; padding: 18px 20px; display: flex; justify-content: space-between; align-items: center; }
        .contacts-header h5 { margin: 0; font-size: 17px; font-weight: bold; display: flex; align-items: center; gap: 8px; }
        .icq-flower { width: 14px; height: 14px; border-radius: 50%; background: #10b981; box-shadow: 0 0 10px #10b981; display: inline-block; animation: flower-pulse 2s infinite alternate; }
        @keyframes flower-pulse { 0% { box-shadow: 0 0 4px #10b981; } 100% { box-shadow: 0 0 12px #34d399; } }

        .btn-test-sound { background: rgba(255,255,255,0.15); border: 1px solid rgba(255,255,255,0.25); color: #34d399; padding: 4px 10px; border-radius: 12px; font-size: 12px; font-weight: bold; cursor: pointer; transition: all 0.2s; display: flex; align-items: center; gap: 4px; }
        .btn-test-sound:hover { background: rgba(255,255,255,0.3); color: white; }

        .search-box { padding: 12px 16px; background: white; border-bottom: 1px solid #e2e8f0; }
        .search-box input { width: 100%; padding: 8px 14px; border: 1px solid #cbd5e1; border-radius: 20px; font-size: 13px; outline: none; background: #f8fafc; }
        .search-box input:focus { border-color: #3b82f6; background: white; }
        .contacts-list { flex: 1; overflow-y: auto; padding: 10px; display: flex; flex-direction: column; gap: 6px; }
        
        .contact-item { display: flex; align-items: center; gap: 12px; padding: 12px; background: white; border-radius: 12px; cursor: pointer; border: 1px solid #f1f5f9; transition: all 0.15s; }
        .contact-item:hover { background: #eff6ff; border-color: #bfdbfe; transform: translateY(-1px); }
        .contact-item.active { background: #dbeafe; border-color: #3b82f6; }
        .contact-avatar { width: 42px; height: 42px; border-radius: 50%; background: #1f3b57; color: white; font-weight: bold; display: flex; align-items: center; justify-content: center; position: relative; flex-shrink: 0; }
        
        .status-dot { width: 12px; height: 12px; border-radius: 50%; border: 2px solid white; position: absolute; bottom: 0; right: 0; background: #94a3b8; }
        .status-dot.online { background: #10b981; box-shadow: 0 0 6px #10b981; }
        .status-dot.typing { background: #3b82f6; box-shadow: 0 0 6px #3b82f6; animation: pulse 1s infinite; }
        @keyframes pulse { 0% { transform: scale(1); } 50% { transform: scale(1.2); } 100% { transform: scale(1); } }

        .contact-name { font-weight: 600; font-size: 14px; color: #1e293b; }
        .contact-sub { font-size: 11px; color: #64748b; }
        .contact-status-lbl { font-size: 11px; font-weight: 600; }
        .contact-status-lbl.online { color: #059669; }
        .contact-status-lbl.typing { color: #2563eb; }

        .chat-area { flex: 1; display: flex; flex-direction: column; background: #f8fafc; }
        .chat-area-header { background: white; padding: 16px 24px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; }
        .chat-area-header h5 { margin: 0; font-size: 17px; font-weight: bold; color: #1f3b57; }
        
        .messages-box { flex: 1; overflow-y: auto; padding: 20px; display: flex; flex-direction: column; gap: 12px; }
        
        .chat-bubble { max-width: 75%; padding: 12px 16px; border-radius: 16px; font-size: 14px; line-height: 1.45; word-break: break-word; position: relative; }
        .chat-bubble.own { align-self: flex-end; background: #1f3b57; color: white; border-bottom-right-radius: 4px; }
        .chat-bubble.other { align-self: flex-start; background: white; color: #1e293b; border: 1px solid #e2e8f0; border-bottom-left-radius: 4px; box-shadow: 0 2px 6px rgba(0,0,0,0.05); }
        .bubble-author { font-size: 12px; font-weight: bold; margin-bottom: 4px; color: #2563eb; }
        .chat-bubble.own .bubble-author { color: #93c5fd; }
        .bubble-subject { font-weight: bold; font-size: 13px; margin-bottom: 4px; border-bottom: 1px dashed rgba(0,0,0,0.1); padding-bottom: 4px; }
        .chat-bubble.own .bubble-subject { border-bottom-color: rgba(255,255,255,0.2); }
        .bubble-time { font-size: 11px; opacity: 0.7; margin-top: 6px; text-align: right; }

        .bubble-img { max-width: 100%; max-height: 250px; border-radius: 10px; margin-top: 6px; cursor: pointer; }
        .bubble-audio { margin-top: 8px; width: 100%; max-width: 300px; }

        .bubble-actions { display: none; position: absolute; top: -10px; right: 10px; background: white; border: 1px solid #cbd5e1; border-radius: 14px; padding: 2px 8px; gap: 6px; box-shadow: 0 2px 8px rgba(0,0,0,0.15); }
        .chat-bubble:hover .bubble-actions { display: flex; }
        .btn-act { background: none; border: none; font-size: 13px; cursor: pointer; padding: 2px 4px; border-radius: 4px; color: #475569; }
        .btn-act:hover { background: #f1f5f9; color: #1e293b; }

        .input-area { background: white; padding: 14px 20px; border-top: 1px solid #e2e8f0; display: flex; flex-direction: column; gap: 8px; }
        .previews-bar { display: flex; justify-content: space-between; align-items: center; background: #eff6ff; padding: 8px 14px; border-radius: 8px; font-size: 13px; color: #1e40af; }
        .input-row { display: flex; gap: 10px; align-items: center; }
        .input-text { flex: 1; border: 1px solid #cbd5e1; border-radius: 10px; padding: 10px 14px; font-size: 14px; outline: none; resize: none; height: 50px; font-family: inherit; }
        .input-text:focus { border-color: #3b82f6; }

        .btn-tool { background: #f1f5f9; border: 1px solid #cbd5e1; color: #475569; width: 44px; height: 44px; border-radius: 10px; font-size: 18px; cursor: pointer; display: flex; align-items: center; justify-content: center; }
        .btn-tool:hover { background: #e2e8f0; color: #1e293b; }
        .btn-tool.recording { background: #ef4444; color: white; border-color: #dc2626; animation: pulse 1s infinite; }
        .btn-send { background: #1f3b57; color: white; border: none; padding: 0 22px; height: 44px; border-radius: 10px; font-weight: bold; cursor: pointer; transition: background 0.2s; display: flex; align-items: center; gap: 6px; }
        .btn-send:hover { background: #2563eb; }

        #img-modal { display: none; position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(0,0,0,0.85); z-index: 99999; justify-content: center; align-items: center; }
        #img-modal img { max-width: 90vw; max-height: 90vh; border-radius: 8px; }
    </style>
</head>
<%@ include file="sidebar.jsp" %>
<body>

<div class="content">
    <div class="d-flex justify-content-between align-items-center mb-3" style="max-width:1150px; margin:0 auto;">
        <h2><i class="bi bi-chat-dots-fill text-primary me-2"></i> Chat Empresarial SADU (ICQ)</h2>
        <div class="d-flex gap-2">
            <button type="button" class="btn btn-outline-success btn-sm font-weight-bold" onclick="reproducirSonidoICQ()"><i class="bi bi-volume-up-fill me-1"></i> Probar Sonido ICQ (Uh-Oh!)</button>
            <a href="dashboard.jsp" class="btn btn-secondary btn-sm"><i class="bi bi-arrow-left me-1"></i> Dashboard</a>
        </div>
    </div>

    <div class="chat-main-container">
        <div class="contacts-panel">
            <div class="contacts-header">
                <h5><span class="icq-flower"></span> Contactos SADU</h5>
                <button type="button" class="btn-test-sound" onclick="reproducirSonidoICQ()"><i class="bi bi-volume-up-fill"></i> Sound</button>
            </div>
            <div class="search-box">
                <input id="page-search-user" type="text" placeholder="Buscar contacto..." oninput="filtrarContactosPagina()">
            </div>
            <div id="page-contacts-list" class="contacts-list">
                <div style="text-align:center; padding:20px; color:#64748b;">Cargando usuarios...</div>
            </div>
        </div>

        <div class="chat-area">
            <div class="chat-area-header">
                <h5 id="page-chat-target"><i class="bi bi-globe me-1"></i> Chat General (Todos los usuarios)</h5>
            </div>

            <div id="page-messages-box" class="messages-box">
                <div style="text-align:center; padding:30px; color:#94a3b8;">Cargando mensajes...</div>
            </div>

            <div class="input-area">
                <div id="page-preview-bar" class="previews-bar" style="display:none;">
                    <span id="page-preview-txt"><i class="bi bi-paperclip me-1"></i> Archivo listo</span>
                    <button type="button" class="btn-close btn-sm" onclick="limpiarAdjuntoPagina()"></button>
                </div>

                <input id="page-asunto-input" type="text" class="form-control form-control-sm mb-1" placeholder="Asunto (opcional)...">

                <div class="input-row">
                    <input type="file" id="page-file-input" accept="image/*" style="display:none;" onchange="manejarImagenPagina(event)">
                    <button type="button" class="btn-tool" onclick="document.getElementById('page-file-input').click()" title="Adjuntar imagen"><i class="bi bi-image"></i></button>
                    <button type="button" id="page-btn-mic" class="btn-tool" onclick="toggleAudioPagina()" title="Grabar nota de voz"><i class="bi bi-mic-fill"></i></button>
                    
                    <textarea id="page-texto-input" class="input-text" placeholder="Escribe un mensaje..." oninput="notificarEscrituraPagina()"></textarea>
                    <button class="btn-send" onclick="enviarMensajePagina()">Enviar <i class="bi bi-send-fill ms-1"></i></button>
                </div>
            </div>
        </div>
    </div>
</div>

<div id="img-modal" onclick="document.getElementById('img-modal').style.display='none'">
    <img id="img-modal-target" src="" alt="Vista previa">
</div>

<script>
const ID_USUARIO = <%= idUsuario %>;
let targetId = null;
let targetNombre = '<i class="bi bi-globe me-1"></i> Chat General';
let usuariosPagina = [];

let adjuntoBase64Pagina = null;
let adjuntoTipoPagina = 'TEXTO';

let mediaRecorderPag = null;
let audioChunksPag = [];
let grabacionActivaPag = false;
let secGrabacionPag = 0;
let timerGrabacionPag = null;

let maxIdPagina = 0;
let primerCargaPaginaDone = false;

document.addEventListener('DOMContentLoaded', function() {
    cargarUsuariosPagina();
    cargarMensajesPagina();
    setInterval(function() {
        cargarUsuariosPagina();
        cargarMensajesPagina();
    }, 3500);
});

function seleccionarContactoPagina(id, nombre) {
    targetId = id;
    targetNombre = id ? ('<i class="bi bi-person-fill me-1"></i> Conversando con ' + esc(nombre)) : '<i class="bi bi-globe me-1"></i> Chat General';
    document.getElementById('page-chat-target').innerHTML = targetNombre;
    cargarMensajesPagina();
    renderContactosPagina(usuariosPagina);
}

function cargarUsuariosPagina() {
    fetch('ChatJsonServlet?action=usuarios')
        .then(function(r) { return r.json(); })
        .then(function(users) {
            if (!Array.isArray(users)) return;
            usuariosPagina = users;
            renderContactosPagina(users);
        });
}

function renderContactosPagina(lista) {
    const container = document.getElementById('page-contacts-list');
    const q = document.getElementById('page-search-user').value.toLowerCase().trim();

    let html = '<div class="contact-item ' + (targetId === null ? 'active' : '') + '" onclick="seleccionarContactoPagina(null, \'Chat General\')">'
             + '<div class="contact-avatar" style="background:#2563eb;"><i class="bi bi-globe"></i></div>'
             + '<div><div class="contact-name">Chat General</div>'
             + '<div class="contact-sub">Mensajes públicos para todos</div></div></div>';

    const filtrados = lista.filter(function(u) {
        return u.idUsuario !== ID_USUARIO &&
            (u.nombreCompleto.toLowerCase().indexOf(q) !== -1 ||
             u.username.toLowerCase().indexOf(q) !== -1 ||
             u.nombreRol.toLowerCase().indexOf(q) !== -1);
    });

    filtrados.forEach(function(u) {
        const partes = u.nombreCompleto.split(' ');
        let iniciales = u.nombreCompleto.substring(0, 2).toUpperCase();
        if (partes.length >= 2 && partes[0][0] && partes[1][0]) {
            iniciales = (partes[0][0] + partes[1][0]).toUpperCase();
        }

        let dotClass = 'offline';
        let statusText = '<i class="bi bi-circle-fill" style="font-size:7px; color:#94a3b8;"></i> Desconectado';
        let lblClass = '';

        if (u.typing) {
            dotClass = 'typing'; statusText = '<i class="bi bi-pencil-fill"></i> Escribiendo...'; lblClass = 'typing';
        } else if (u.online) {
            dotClass = 'online'; statusText = '<i class="bi bi-record-fill" style="color:#10b981;"></i> En l&iacute;nea'; lblClass = 'online';
        }

        const active = targetId === u.idUsuario ? 'active' : '';
        const nomEsc = escAttr(u.nombreCompleto);

        html += '<div class="contact-item ' + active + '" onclick="seleccionarContactoPagina(' + u.idUsuario + ', \'' + nomEsc + '\')">'
              + '<div class="contact-avatar">' + iniciales + '<span class="status-dot ' + dotClass + '"></span></div>'
              + '<div><div class="contact-name">' + esc(u.nombreCompleto) + '</div>'
              + '<div class="contact-sub">' + esc(u.nombreRol) + '</div>'
              + '<div class="contact-status-lbl ' + lblClass + '">' + statusText + '</div></div></div>';
    });

    container.innerHTML = html;
}

function filtrarContactosPagina() { renderContactosPagina(usuariosPagina); }

function cargarMensajesPagina() {
    let url = 'ChatJsonServlet?action=mensajes';
    if (targetId) url += '&receptorId=' + targetId;

    fetch(url)
        .then(function(r) { return r.json(); })
        .then(function(datos) {
            const container = document.getElementById('page-messages-box');
            if (!Array.isArray(datos) || datos.length === 0) {
                container.innerHTML = '<div style="text-align:center; margin:auto; color:#94a3b8;"><i class="bi bi-chat-left-dots fs-3 mb-2"></i><br>No hay mensajes en esta conversaci&oacute;n.<br>&iexcl;S&eacute; el primero en escribir!</div>';
                return;
            }

            let maxIdActual = maxIdPagina;
            let nuevoMensajeAjeno = false;

            datos.forEach(function(m) {
                if (m.idMensaje > maxIdPagina) {
                    if (m.idUsuario !== ID_USUARIO) {
                        nuevoMensajeAjeno = true;
                    }
                }
                if (m.idMensaje > maxIdActual) {
                    maxIdActual = m.idMensaje;
                }
            });

            if (!primerCargaPaginaDone) {
                maxIdPagina = maxIdActual;
                primerCargaPaginaDone = true;
            } else if (nuevoMensajeAjeno) {
                maxIdPagina = maxIdActual;
                if (typeof reproducirSonidoICQ === 'function') {
                    reproducirSonidoICQ();
                }
            }

            let html = '';
            for (let i = datos.length - 1; i >= 0; i--) {
                const m = datos[i];
                const propio = m.idUsuario === ID_USUARIO;
                const clase = propio ? 'own' : 'other';
                const hora = m.fechaEnvio ? new Date(m.fechaEnvio).toLocaleTimeString('es-CO', {hour:'2-digit', minute:'2-digit'}) : '';
                const edit = m.editado ? ' <small style="opacity:0.6;">(editado)</small>' : '';

                let cuerpo = '';
                const urlEsc = escAttr(m.urlAdjunto);

                if (m.tipo === 'IMAGEN' && m.urlAdjunto) {
                    cuerpo = '<img src="' + esc(m.urlAdjunto) + '" class="bubble-img" onclick="abrirModal(\'' + urlEsc + '\')"><br>' + esc(m.mensaje);
                } else if (m.tipo === 'AUDIO' && m.urlAdjunto) {
                    cuerpo = '<audio controls src="' + esc(m.urlAdjunto) + '" class="bubble-audio"></audio>';
                } else {
                    cuerpo = '<div>' + esc(m.mensaje) + '</div>';
                }

                const autor = !propio ? '<div class="bubble-author">' + esc(m.nombreUsuario) + '</div>' : '';
                const asunto = m.asunto && m.asunto !== 'Chat' ? '<div class="bubble-subject">' + esc(m.asunto) + '</div>' : '';

                let acciones = '';
                if (propio) {
                    const msgEsc = escAttr(m.mensaje);
                    acciones = '<div class="bubble-actions">'
                             + '<button class="btn-act" onclick="editarPagina(' + m.idMensaje + ', \'' + msgEsc + '\')"><i class="bi bi-pencil-fill"></i></button>'
                             + '<button class="btn-act" onclick="eliminarPagina(' + m.idMensaje + ')"><i class="bi bi-trash-fill"></i></button>'
                             + '</div>';
                }

                html += '<div class="chat-bubble ' + clase + '">'
                      + acciones + autor + asunto + cuerpo
                      + '<div class="bubble-time">' + hora + edit + '</div>'
                      + '</div>';
            }

            container.innerHTML = html;
            container.scrollTop = container.scrollHeight;
        });
}

function notificarEscrituraPagina() {
    const params = new URLSearchParams();
    params.append('action', 'typing');
    fetch('ChatJsonServlet', { method: 'POST', body: params });
}

function enviarMensajePagina() {
    const asunto = document.getElementById('page-asunto-input').value.trim();
    const texto = document.getElementById('page-texto-input').value.trim();

    if (!texto && !adjuntoBase64Pagina) return;

    let bodyData;
    if (adjuntoBase64Pagina) {
        const formData = new FormData();
        formData.append('action', 'enviar');
        if (asunto) formData.append('asunto', asunto);
        if (texto) formData.append('mensaje', texto);
        if (targetId) formData.append('idReceptor', targetId);
        formData.append('tipo', adjuntoTipoPagina);
        formData.append('urlAdjunto', adjuntoBase64Pagina);
        bodyData = formData;
    } else {
        const params = new URLSearchParams();
        params.append('action', 'enviar');
        if (asunto) params.append('asunto', asunto);
        if (texto) params.append('mensaje', texto);
        if (targetId) params.append('idReceptor', targetId);
        params.append('tipo', 'TEXTO');
        bodyData = params;
    }

    fetch('ChatJsonServlet', { method: 'POST', body: bodyData })
        .then(function(r) { return r.json(); })
        .then(function(res) {
            if (res.success) {
                document.getElementById('page-asunto-input').value = '';
                document.getElementById('page-texto-input').value = '';
                limpiarAdjuntoPagina();
                cargarMensajesPagina();
                if (typeof reproducirSonidoICQ === 'function') {
                    reproducirSonidoICQ();
                }
            }
        });
}

function editarPagina(id, texto) {
    const n = prompt('Corrige tu mensaje:', texto);
    if (!n || !n.trim()) return;
    const params = new URLSearchParams();
    params.append('action', 'editar');
    params.append('idMensaje', id);
    params.append('nuevoTexto', n.trim());
    fetch('ChatJsonServlet', { method: 'POST', body: params }).then(function() { cargarMensajesPagina(); });
}

function eliminarPagina(id) {
    if (!confirm('Eliminar mensaje?')) return;
    const params = new URLSearchParams();
    params.append('action', 'eliminar');
    params.append('idMensaje', id);
    fetch('ChatJsonServlet', { method: 'POST', body: params }).then(function() { cargarMensajesPagina(); });
}

function manejarImagenPagina(e) {
    const file = e.target.files[0]; if (!file) return;
    const reader = new FileReader();
    reader.onload = function(evt) {
        adjuntoBase64Pagina = evt.target.result;
        adjuntoTipoPagina = 'IMAGEN';
        document.getElementById('page-preview-txt').innerHTML = '<i class="bi bi-image me-1"></i> Imagen seleccionada: ' + esc(file.name);
        document.getElementById('page-preview-bar').style.display = 'flex';
    };
    reader.readAsDataURL(file);
}

function toggleAudioPagina() {
    if (!grabacionActivaPag) {
        navigator.mediaDevices.getUserMedia({ audio: true }).then(function(stream) {
            mediaRecorderPag = new MediaRecorder(stream);
            audioChunksPag = [];
            mediaRecorderPag.ondataavailable = function(e) { audioChunksPag.push(e.data); };
            mediaRecorderPag.onstop = function() {
                const blob = new Blob(audioChunksPag, { type: 'audio/webm' });
                const r = new FileReader();
                r.onloadend = function() {
                    adjuntoBase64Pagina = r.result;
                    adjuntoTipoPagina = 'AUDIO';
                    document.getElementById('page-preview-txt').innerHTML = '<i class="bi bi-mic-fill me-1"></i> Audio grabado (' + secGrabacionPag + 's)';
                    document.getElementById('page-preview-bar').style.display = 'flex';
                };
                r.readAsDataURL(blob);
            };
            mediaRecorderPag.start(); grabacionActivaPag = true; secGrabacionPag = 0;
            document.getElementById('page-btn-mic').classList.add('recording');
            timerGrabacionPag = setInterval(function() { secGrabacionPag++; }, 1000);
        });
    } else {
        mediaRecorderPag.stop();
        mediaRecorderPag.stream.getTracks().forEach(function(t) { t.stop(); });
        grabacionActivaPag = false; clearInterval(timerGrabacionPag);
        document.getElementById('page-btn-mic').classList.remove('recording');
    }
}

function limpiarAdjuntoPagina() {
    adjuntoBase64Pagina = null; adjuntoTipoPagina = 'TEXTO';
    document.getElementById('page-preview-bar').style.display = 'none';
}

function abrirModal(src) {
    document.getElementById('img-modal-target').src = src;
    document.getElementById('img-modal').style.display = 'flex';
}

function esc(str) {
    if (!str) return '';
    return String(str).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#039;');
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
</script>
</body>
</html>
